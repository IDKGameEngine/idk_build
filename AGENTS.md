# Project instructions

- Follow existing naming, formatting, and architecture.
- Avoid editing idk_build/thirdparty unless explicitly requested.
- Preserve unrelated local changes.
- Use the GitHub MCP server configured in `~/.codex/config.toml` for remote GitHub operations. Do not use shell Git, `gh`, or SSH for remote GitHub operations.
- Before any remote GitHub write, call the configured server's `get_me` tool and verify that the authenticated login is `mellic03-agent`. If it is not, stop the write; do not fall back to personal credentials.
- Local Git may be used for local repository work. Any local commits must use the verified machine user's author and committer identity, not the personal `mellic03` identity.
- Do not push or publish changes unless explicitly requested by the user.
- Run the relevant build or checks after code changes.
- Report what changed, what was verified, and any remaining issues.
- Never use exceptions, lambdas or std::function.
- Avoid the use of dynamic memory allocation where possible. Reference libidk for examples data structures which do not use dynamic memory allocation.
