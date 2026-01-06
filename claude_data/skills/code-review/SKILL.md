---
name: code-review
description: Perform comprehensive code reviews comparing source branch against target branch with security, performance, and quality analysis. Use when reviewing pull requests, before merging branches, or when analyzing code changes. Automatically fetches remote changes when needed.
license: MIT
metadata:
  version: 1.1.0
  author: Converted from slash command
  category: engineering
  domain: code-quality
  updated: 2025-01-02
  python-tools:
  tech-stack: git
---

# Code Review Skill

This skill performs comprehensive code reviews comparing changes between source and target branches, analyzing code quality, security, performance, and best practices. It automatically handles fetching remote changes when needed.

## How to Use

Invoke this skill when you need to:
- Review a pull request or feature branch before merging
- Analyze code changes for security vulnerabilities
- Evaluate performance implications of code changes
- Assess code quality and maintainability
- Ensure best practices compliance
- Review specific commits or commit ranges

## Automatic Git Operations

The skill automatically performs necessary git operations:
- **Auto-fetch**: Fetches from remote when branches/commits aren't found locally
- **Remote resolution**: Detects and uses appropriate remote (origin, upstream)
- **Branch tracking**: Handles remote branch references (origin/main, etc.)
- **Commit resolution**: Finds commits across all branches and remotes
- **Diff generation**: Automatically generates diffs between any two references

### Supported Git References
- Branch names: `main`, `feature/my-feature`, `origin/main`
- Commit SHAs: `7bd6032`, `7bd6032f9f52de015b00e5898e564e3caca3f3aa`
- Tags: `v1.0.0`, `release-2024-01`
- Relative refs: `HEAD~3`, `main^`, `feature@{yesterday}`
- Commit ranges: `main..feature`, `abc123..def456`

## Review Process

### 0. **Git Repository Preparation**
Before analysis begins, the skill:
1. Verifies git repository status
2. Attempts to fetch from remote if references not found locally
3. Validates that source and target references exist
4. Generates appropriate diffs using git commands
5. Falls back gracefully with helpful error messages

**Git commands used automatically:**
```bash
# Check if reference exists
git rev-parse --verify <ref>

# Fetch from remote if needed
git fetch origin
git fetch --all  # if origin fails

# Get diff between references
git diff <target>..<source>

# Get commit list
git log <target>..<source> --oneline

# Get file list
git diff --name-status <target>..<source>
```

### 1. **Branch Comparison Analysis**
- Compare source branch/commit against target branch/commit (default: main)
- Retrieve all commits in source not in target
- Analyze overall diff and cumulative changes
- Identify scope and impact assessment
- Optional: Individual commit-by-commit analysis

### 2. **Code Quality Review**
- **Code Structure**: Evaluate architecture, design patterns, modularity
- **Readability**: Assess naming conventions, documentation, clarity
- **Maintainability**: Check for code duplication, complexity, testability
- **Best Practices**: Verify language-specific conventions and standards

### 3. **Security Analysis**
- **Input Validation**: Check for proper sanitization and validation
- **Authentication/Authorization**: Review access controls and permissions
- **Data Protection**: Identify sensitive data exposure risks
- **Dependency Security**: Analyze third-party library usage
- **Common Vulnerabilities**: Scan for OWASP Top 10 issues

### 4. **Performance Assessment**
- **Algorithm Efficiency**: Analyze time and space complexity
- **Resource Usage**: Check memory leaks, connection handling
- **Scalability**: Evaluate under load conditions
- **Optimization Opportunities**: Identify performance bottlenecks

### 5. **Testing and Reliability**
- **Test Coverage**: Assess unit tests, integration tests
- **Error Handling**: Review exception management and edge cases
- **Logging**: Verify proper logging and monitoring
- **Reliability**: Check for race conditions and concurrency issues

### 6. **Integration and Compatibility**
- **API Changes**: Review breaking changes and deprecations
- **Backward Compatibility**: Ensure existing functionality remains intact
- **Documentation**: Verify updated docs and changelogs
- **Configuration**: Check config changes and migration paths

## Review Depth Levels

### **Basic**
- High-level code quality assessment
- Security vulnerability scanning
- Performance bottleneck identification
- Basic test coverage review

### **Detailed** (default)
- Comprehensive code structure analysis
- Deep security assessment
- Performance profiling recommendations
- Thorough testing evaluation
- Integration impact analysis

### **Comprehensive**
- Line-by-line code analysis
- Advanced security threat modeling
- Performance benchmarking suggestions
- Complete test suite review
- Full architectural impact assessment
- Documentation and compliance review
- Individual commit-by-commit breakdown

## Output Format

The review will generate:

### **Executive Summary**
- Overall quality assessment (A-F grade)
- Branch/commit comparison summary (files changed, lines added/removed)
- Critical issues requiring immediate attention
- Positive highlights and strengths
- Risk assessment and mitigation recommendations

### **Detailed Findings**
- **Security Issues**: Categorized by severity (Critical/High/Medium/Low)
- **Performance Concerns**: Optimization opportunities with impact estimates
- **Code Quality Issues**: Maintainability and readability improvements
- **Testing Gaps**: Missing test coverage and quality improvements
- **Documentation Issues**: Incomplete or outdated documentation

### **Specific Recommendations**
- Actionable improvement suggestions
- Code examples for problematic patterns
- Refactoring recommendations
- Security hardening measures
- Performance optimization techniques

### **File-by-File Analysis**
For each modified file:
- Purpose and impact summary
- Quality assessment score
- Specific issues and recommendations
- Best practices compliance

### **Commit History** (if include_commits=true)
- Individual commit analysis
- Commit message quality assessment
- Logical grouping of changes

## Usage Examples

```
Review feature branch against main (default):
skill: code-review (source_branch: feature/user-authentication)

Review specific commit against main:
skill: code-review (source_branch: 7bd6032f9f52de015b00e5898e564e3caca3f3aa)

Review remote branch:
skill: code-review (source_branch: origin/feature/new-api, target_branch: main)

Review against different target branch:
skill: code-review (source_branch: feature/new-api, target_branch: develop)

Review commit range:
skill: code-review (source_branch: abc123..def456)

Comprehensive review with commit history:
skill: code-review (source_branch: feature/refactor, target_branch: main, depth: comprehensive, include_commits: true)

Basic quick review:
skill: code-review (source_branch: bugfix/memory-leak, depth: basic)
```

## Common Workflows

```
# Pre-PR review
skill: code-review (source_branch: feature/my-feature, target_branch: main)

# Review specific issue commit
skill: code-review (source_branch: 7bd6032f9f52de015b00e5898e564e3caca3f3aa, target_branch: main)

# Compare staging to production
skill: code-review (source_branch: staging, target_branch: production, depth: comprehensive)

# Review hotfix before merge
skill: code-review (source_branch: hotfix/critical-bug, target_branch: main, depth: detailed)

# Review before release
skill: code-review (source_branch: release/v2.0, target_branch: main, depth: comprehensive, include_commits: true)

# Review changes from remote branch
skill: code-review (source_branch: origin/feature/xyz, target_branch: origin/main)
```

## Parameters

- **source_branch** (required): Branch, commit SHA, tag, or git reference to review
- **target_branch** (optional, default: main): Base branch/commit to compare against
- **depth** (optional, default: detailed): Review depth (basic/detailed/comprehensive)
- **include_commits** (optional, default: false): Include individual commit analysis

## Git Error Handling

The skill gracefully handles common git scenarios:

### Missing References
- Automatically runs `git fetch origin` if source/target not found
- Tries `git fetch --all` if origin fetch fails
- Provides clear error messages if references still can't be found

### Remote Branches
- Automatically detects remote branch references (origin/, upstream/)
- Handles both local and remote branch comparisons
- Suggests correct remote syntax if branch not found

### Detached HEAD / Orphan Commits
- Can review commits not on any branch
- Handles detached HEAD state
- Works with commit SHAs from any point in history

### Merge Conflicts
- Reports if branches have conflicts
- Analyzes changes on both sides
- Suggests merge strategy if applicable

## Quality Metrics

Each review includes quantitative metrics:
- **Code Complexity**: Cyclomatic complexity, cognitive load
- **Maintainability Index**: Score based on readability and structure
- **Test Coverage**: Percentage of code covered by tests
- **Security Score**: Based on vulnerability assessment
- **Performance Score**: Efficiency and scalability rating
- **Branch Divergence**: Number of commits and changes from target

## Integration with Development Workflow

The review provides:
- **Pre-merge Checklist**: Items to address before merging
- **Breaking Changes**: API or behavioral changes requiring attention
- **Migration Requirements**: Steps needed for deployment
- **Follow-up Actions**: Recommendations for future improvements
- **Team Learning**: Educational opportunities and best practices
- **Documentation Updates**: Required changes to technical docs

## Troubleshooting

If you encounter issues:

1. **"Reference not found" error**: The skill will auto-fetch, but if it persists:
   - Verify the branch/commit name is correct
   - Check if you have access to the remote repository
   - Ensure git remotes are configured: `git remote -v`

2. **"No changes found"**: 
   - Verify source and target are different
   - Check if branches are already merged
   - Use `git log target..source` to confirm commits exist

3. **"Permission denied"**:
   - Ensure you have read access to the repository
   - Check git credentials are configured
   - Verify remote URL is accessible

This comprehensive review ensures code meets high standards for security, performance, and maintainability while providing actionable feedback for improvement before merging branches.