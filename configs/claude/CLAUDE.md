# CLAUDE.md

## Conversation Guidelines

- Always respond in Japanese

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

## Git Workflow

- **Always use `git wb` instead of `git worktree add`** when creating new worktrees
- `git wb` is a custom alias that provides enhanced functionality for worktree management

### Commit Guidelines

- **Only commit when explicitly requested**: Only create commits when the user explicitly asks for it
- **Commit message convention**: Follow Conventional Commits with these prefixes:
  - `feat:` - Add new feature
  - `fix:` - Fix bugs
  - `docs:` - Documentation changes
  - `style:` - Format/style changes (no functionality change)
  - `refactor:` - Code refactoring (no behavior change)
  - `test:` - Add or modify tests
  - `chore:` - Other maintenance tasks

### Branch Management

**Creating and Managing Branches**

- **Before creating a new branch**: Always fetch the latest version of the base branch
  - Check project docs for specified base branch, otherwise use: `git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@'`
  - Update to latest: `git checkout <base-branch> && git pull origin <base-branch>`
- **Conflict resolution**: Understand both change intentions before resolving carefully

**Branch Naming Convention**

- **feature/**: New feature development
  - Example: `feature/add-tmux-config`, `feature/improve-zsh-setup`
- **fix/**: Bug fixes
  - Example: `fix/zsh-plugin-error`, `fix/broken-symlink`
- **hotfix/**: Emergency fixes
  - Example: `hotfix/security-patch`, `hotfix/critical-config-bug`
- **chore/**: Maintenance tasks (including documentation updates)
  - Example: `chore/update-brewfile`, `chore/cleanup-old-configs`, `chore/update-readme`

**Naming rules:**
- Use lowercase and hyphens (kebab-case)
- Use concise and descriptive names
- Use English for naming

**Hierarchical Branch Strategy** (for progressive large-scale changes, use only when requested by user):

**Integration branches (2-tier):**
- `feature/feature-name-main`
- `fix/fix-name-main`
- `chore/task-name-main`

**Derived branches (3-tier):**
- `feature/feature-name/specific-feature`
- `fix/fix-name/specific-fix`
- `chore/task-name/specific-task`

**Example:**
```
Integration: feature/development-tools-main
Derived: feature/development-tools/mise-config
Derived: feature/development-tools/docker-setup
Derived: feature/development-tools/vscode-settings
```