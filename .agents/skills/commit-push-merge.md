# Skill: Fast Commit, Push, and Auto-Merge

**Description**: The `/commit-push-merge` skill is used to commit and push changes to the repository, create a pull/merge request, and seamlessly auto-merge it. This bypasses manual reviews for AI-assisted momentum.

## Instructions

When asked to "commit, push, and merge", execute the following sequence without blocking. **Assume approval and do NOT wait for a human review.** Provide a concise summary once complete.

### 1. Stage, Commit, and Push
```bash
git add .
git commit -m "<descriptive_message>"
git push -u origin HEAD
```
*(If already on the `main` or `master` branch, stop here since no PR/MR is needed).*

### 2. Create and Auto-Merge PR/MR
Determine if the project uses GitHub or GitLab, then execute the corresponding commands to create and cleanly merge everything in one shot:

**GitHub (`gh`)**:
```bash
gh pr create --fill
gh pr merge --squash --delete-branch
```

**GitLab (`glab`)**:
```bash
glab mr create --fill --yes
glab mr merge --squash --remove-source-branch
```

## Constraints
* **No Review Loop**: Proceed straight to merge. Do not ask for PR/MR reviews.
* **Failures**: If CI checks, lack of authentication, or merge conflicts block the process, stop and immediately notify the user for intervention.
