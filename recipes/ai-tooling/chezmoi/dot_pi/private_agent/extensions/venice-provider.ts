/**
 * Venice.ai Provider Extension
 *
 * Registers Venice.ai as a model provider with dynamically fetched models.
 * Venice offers privacy-focused AI with open-source and frontier models.
 *
 * Setup:
 *   1. Get an API key from https://venice.ai/settings/api
 *   2. Either set VENICE_API_KEY env var, or add to ~/.pi/agent/auth.json:
 *      { "venice": { "type": "api_key", "key": "your-key" } }
 *   3. Use /model or ctrl+l to select a Venice model
 *
 * Models are fetched from Venice's /models API and cached locally:
 *   - Cache: ~/.pi/agent/cache/venice-models.json
 *   - TTL: 24 hours (background refresh on cache hit)
 *   - Fetch timeout: 3 seconds
 *
 * Only text models with function calling support are included.
 * Venice's default system prompt is disabled via venice_parameters
 * to avoid interfering with pi's system prompt.
 *
 * See https://docs.venice.ai for the full API documentation.
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { streamOpenAICompletions } from "@mariozechner/pi-ai";
import type { Model, Context, SimpleStreamOptions, AssistantMessageEventStream } from "@mariozechner/pi-ai";
import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";

const CACHE_DIR = join(homedir(), ".pi", "agent", "cache");
const CACHE_FILE = join(CACHE_DIR, "venice-models.json");
const CACHE_MAX_AGE_MS = 24 * 60 * 60 * 1000;
const FETCH_TIMEOUT_MS = 3000;

interface VeniceApiModel {
	id: string;
	type: string;
	model_spec: {
		name: string;
		pricing: {
			input: { usd: number };
			output: { usd: number };
			cache_input?: { usd: number };
		};
		availableContextTokens: number;
		maxCompletionTokens: number;
		capabilities: {
			supportsReasoning: boolean;
			supportsVision: boolean;
			supportsFunctionCalling: boolean;
		};
		offline: boolean;
	};
}

interface ProviderModel {
	id: string;
	name: string;
	reasoning: boolean;
	input: ("text" | "image")[];
	cost: { input: number; output: number; cacheRead: number; cacheWrite: number };
	contextWindow: number;
	maxTokens: number;
	compat: {
		supportsStore: boolean;
		supportsDeveloperRole: boolean;
	};
}

interface CachedData {
	timestamp: number;
	models: ProviderModel[];
}

function transform(m: VeniceApiModel): ProviderModel {
	const spec = m.model_spec;
	return {
		id: m.id,
		name: spec.name,
		reasoning: spec.capabilities.supportsReasoning,
		input: spec.capabilities.supportsVision ? ["text", "image"] : ["text"],
		cost: {
			input: spec.pricing.input.usd,
			output: spec.pricing.output.usd,
			cacheRead: spec.pricing.cache_input?.usd ?? 0,
			cacheWrite: 0,
		},
		contextWindow: spec.availableContextTokens,
		maxTokens: spec.maxCompletionTokens,
		compat: {
			supportsStore: false,
			supportsDeveloperRole: false,
		},
	};
}

function readCache(): ProviderModel[] | null {
	try {
		if (!existsSync(CACHE_FILE)) return null;
		const data: CachedData = JSON.parse(readFileSync(CACHE_FILE, "utf-8"));
		if (Date.now() - data.timestamp > CACHE_MAX_AGE_MS) return null;
		return data.models;
	} catch {
		return null;
	}
}

function writeCache(models: ProviderModel[]): void {
	try {
		mkdirSync(CACHE_DIR, { recursive: true });
		writeFileSync(CACHE_FILE, JSON.stringify({ timestamp: Date.now(), models } satisfies CachedData));
	} catch {
		// Ignore cache write errors
	}
}

async function fetchModels(): Promise<ProviderModel[] | null> {
	try {
		const controller = new AbortController();
		const timeout = setTimeout(() => controller.abort(), FETCH_TIMEOUT_MS);
		try {
			const res = await fetch("https://api.venice.ai/api/v1/models", { signal: controller.signal });
			if (!res.ok) return null;
			const data = (await res.json()) as { data: VeniceApiModel[] };
			const models = data.data
				.filter((m) => m.type === "text" && m.model_spec.capabilities.supportsFunctionCalling && !m.model_spec.offline)
				.map(transform);
			writeCache(models);
			return models;
		} finally {
			clearTimeout(timeout);
		}
	} catch {
		return null;
	}
}

// Fallback models when API is unreachable and cache is empty
const FALLBACK_MODELS: ProviderModel[] = [
	{
		id: "qwen3-235b-a22b-thinking-2507",
		name: "Qwen 3 235B A22B Thinking 2507",
		reasoning: true,
		input: ["text"],
		cost: { input: 0.45, output: 3.5, cacheRead: 0, cacheWrite: 0 },
		contextWindow: 128000,
		maxTokens: 32000,
		compat: { supportsStore: false, supportsDeveloperRole: false },
	},
	{
		id: "grok-41-fast",
		name: "Grok 4.1 Fast",
		reasoning: true,
		input: ["text", "image"],
		cost: { input: 0.5, output: 1.25, cacheRead: 0, cacheWrite: 0 },
		contextWindow: 256000,
		maxTokens: 64000,
		compat: { supportsStore: false, supportsDeveloperRole: false },
	},
	{
		id: "zai-org-glm-4.7-flash",
		name: "GLM 4.7 Flash",
		reasoning: true,
		input: ["text"],
		cost: { input: 0.12, output: 0.5, cacheRead: 0, cacheWrite: 0 },
		contextWindow: 128000,
		maxTokens: 32000,
		compat: { supportsStore: false, supportsDeveloperRole: false },
	},
];

/**
 * Custom streamSimple that wraps the built-in OpenAI completions streamer
 * to inject venice_parameters (disabling Venice's default system prompt).
 */
function streamVenice(
	model: Model<any>,
	context: Context,
	options?: SimpleStreamOptions,
): AssistantMessageEventStream {
	return streamOpenAICompletions(model, context, {
		...options,
		onPayload(payload: unknown) {
			// Inject venice_parameters to disable their default system prompt
			if (payload && typeof payload === "object") {
				(payload as Record<string, unknown>).venice_parameters = {
					include_venice_system_prompt: false,
				};
			}
			options?.onPayload?.(payload);
		},
	});
}

export default async function (pi: ExtensionAPI) {
	let models = readCache();
	if (models) {
		fetchModels(); // background refresh
	} else {
		models = await fetchModels();
	}

	if (!models || models.length === 0) {
		models = FALLBACK_MODELS;
	}

	pi.registerProvider("venice", {
		baseUrl: "https://api.venice.ai/api/v1",
		apiKey: "VENICE_API_KEY",
		api: "openai-completions",
		models,
		streamSimple: streamVenice,
	});
}
