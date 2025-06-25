# CLAUDE.md

## Conversation Guidelines

- Always respond in Japanese

## Git Workflow

- **Always use `git wb` instead of `git worktree add`** when creating new worktrees
- `git wb` is a custom alias that provides enhanced functionality for worktree management


## Implementation Documentation

### Creating Documentation
**IMPORTANT**: After any of the following actions, you MUST ask "実装ドキュメントを作成しますか？":
- Creating or modifying code files
- Implementing new features
- Fixing bugs
- Making configuration changes

If the user approves, create documentation following the guidelines below.

### Documentation Guidelines

When creating implementation documentation, follow these steps precisely:

1. **Directory Creation**
   - Create `_docs/` directory in the project root (if it doesn't exist)

2. **File Naming Convention**
   - Format: `YYYY-MM-DD_feature-name.md`
   - Example: `2024-01-15_user-authentication.md`
   - Use `date +%Y-%m-%d` command to get the current date

3. **Documentation Template**
   - Use the template at `~/.config/claude/templates/implementation-doc.md`
   - Fill in each section appropriately and save to the `_docs/` directory in the project root

### Startup Behavior
At the start of each session:
- Check `_docs/` directory for past implementation logs
- Consider previous design decisions and documented side effects when making new proposals
