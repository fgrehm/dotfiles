#!/usr/bin/env python3
"""
PR Opener - Automates pull request creation with intelligent context gathering.

This script orchestrates the PR opening workflow:
1. Check git status and get unpushed commits
2. Extract git log since base branch (origin/main)
3. Read .github/pull_request_template.md if present
4. Display proposed PR title and description for review
5. Push code (if needed) and create draft PR via gh
"""

import subprocess
import sys
import json
from pathlib import Path
from datetime import datetime


def run_cmd(cmd, capture=True):
    """Run a shell command and return output or status."""
    try:
        if capture:
            result = subprocess.run(cmd, shell=True, capture_output=True, text=True, check=True)
            return result.stdout.strip()
        else:
            subprocess.run(cmd, shell=True, check=True)
            return None
    except subprocess.CalledProcessError as e:
        print(f"Error running command: {cmd}")
        print(f"stderr: {e.stderr}")
        sys.exit(1)


def check_git_status():
    """Check if there are unpushed commits."""
    try:
        # Check if current branch has unpushed commits
        behind_output = run_cmd("git rev-list --count --left-only @{u}...HEAD")
        return int(behind_output) > 0 if behind_output else False
    except:
        return False


def get_current_branch():
    """Get the current git branch name."""
    return run_cmd("git rev-parse --abbrev-ref HEAD")


def get_git_log_since_main():
    """Get commit log since origin/main."""
    # Get commits that are on current branch but not on origin/main
    log_output = run_cmd(
        "git log origin/main..HEAD --oneline"
    )
    return log_output if log_output else "(no commits yet)"


def read_pr_template():
    """Read .github/pull_request_template.md (case-insensitive)."""
    github_dir = Path(".github")
    if not github_dir.exists():
        return None

    # Check for template files with case-insensitive matching
    template_names = ["pull_request_template.md", "PULL_REQUEST_TEMPLATE.md"]
    for template_name in template_names:
        template_path = github_dir / template_name
        if template_path.exists():
            return template_path.read_text()

    # Fallback: check all files in .github for case-insensitive match
    for file_path in github_dir.iterdir():
        if file_path.is_file() and file_path.name.lower() == "pull_request_template.md":
            return file_path.read_text()

    return None


def generate_pr_proposal(git_log, conversation_summary, template):
    """Generate proposed PR title and description from context."""
    # Extract first line from git log for title suggestion
    first_commit = git_log.split('\n')[0] if git_log and git_log != "(no commits yet)" else None

    # Build title
    if first_commit:
        # Use first commit message as base for title
        title = first_commit.split(' ', 1)[1] if ' ' in first_commit else first_commit
    else:
        title = conversation_summary[:60] if conversation_summary else "Work in progress"

    # Build description
    description_parts = []

    if conversation_summary:
        description_parts.append(f"## Summary\n{conversation_summary}\n")

    if template:
        description_parts.append(f"## PR Template\n{template}\n")

    if git_log and git_log != "(no commits yet)":
        description_parts.append(f"## Changes\n\n```\n{git_log}\n```")

    description = "\n".join(description_parts)

    return {
        "title": title[:72],  # Keep under typical PR title length
        "description": description
    }


def format_for_review(proposal, branch):
    """Format the proposal for user review."""
    output = f"""
=== PR PROPOSAL ===

Branch: {branch}
Base: origin/main

Title:
{proposal['title']}

Description:
{proposal['description']}

=== END PROPOSAL ===
"""
    return output


def push_if_needed():
    """Push unpushed commits if any exist."""
    if check_git_status():
        print("Pushing commits...")
        run_cmd("git push -u origin HEAD")
        print("Pushed successfully.")
    else:
        print("Code already pushed.")


def open_pr_via_gh(title, description, branch):
    """Open a draft PR using gh command."""
    cmd = f'gh pr create --draft --title "{title}" --body "{description}" --base origin/main --head {branch}'
    print(f"\nOpening PR with gh...")
    run_cmd(cmd, capture=False)
    print("PR created successfully!")


def main():
    """Main workflow orchestration."""
    print("=== PR Opener ===\n")

    # Get current context
    branch = get_current_branch()
    print(f"Current branch: {branch}\n")

    if branch == "main":
        print("ERROR: Cannot open PR from main branch")
        sys.exit(1)

    # Gather context
    print("Gathering context...")
    git_log = get_git_log_since_main()
    template = read_pr_template()

    # For now, conversation_summary should be passed in by Claude
    # In actual use, this would come from Claude's analysis of the conversation
    conversation_summary = """
    Work completed as discussed in conversation.
    Review the git log below for specific changes.
    """

    # Generate proposal
    proposal = generate_pr_proposal(git_log, conversation_summary, template)

    # Display for review
    print(format_for_review(proposal, branch))

    # Note: In actual integration with Claude, the user would review/edit at this point
    # and Claude would call push_if_needed() and open_pr_via_gh() based on approval

    print("\n[Review proposal above - Claude will prompt for confirmation]")


if __name__ == "__main__":
    main()
