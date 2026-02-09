---
name: studio-evolution
description: "Meta-skill. Analyzes project work and proposes improvements for skills and workflows. Use periodically or at the end of a project."
---

# Studio Evolution

## Purpose

This skill helps **evolve** the studio's skills and workflows based on real project experience.

---

## When to use

1. **At the end of each project** — retrospective
2. **When actions repeat** — if you do something 3+ times
3. **When issues arise** — if an existing skill didn't help
4. **On user request** — `/studio-evolution`

---

## Analysis Process

### 1. Audit Current Session

Analyze the work history in this project:

- What tasks were solved?
- Which skills were used?
- Which skills were NOT used but could have helped?
- Were there repeating actions?
- Were there non-standard solutions?

### 2. Review Existing Skills

For each used skill ask:

| Question | Action if "Yes" |
|----------|----------------|
| Skill helped solve the task? | Keep it |
| Something was missing? | Propose addition |
| Outdated advice? | Propose update |
| Skill wasn't needed at all? | Check relevance |

### 3. Find New Patterns

Look for:

- **Repeating code** → Can it be added to a skill?
- **Repeating commands** → Can we create a workflow?
- **Non-standard solutions** → Can we document them?
- **Problems without a skill** → Need a new skill?

### 4. Review Workflows

For each workflow:

| Question | Action |
|----------|--------|
| Was it used? | If not — is it needed? |
| Were all steps useful? | Remove unnecessary ones |
| Was something missing? | Add steps |
| Was the order logical? | Reorganize |

---

## Proposal Format

When you find something to improve, report in this format:

### Proposal: [Name]

**Type:** New skill / New workflow / Skill change / Workflow change

**Reason:**
> Brief description of why this is needed

**What to add/change:**
```markdown
[Specific changes or new content]
```

**Priority:** High / Medium / Low

---

## Example Proposals

### Example 1: New Skill

**Type:** New skill `image-optimization`

**Reason:**
> In the last three projects we manually converted images to WebP and set up lazy loading. This can be automated.

**What to add:**
- Image optimization checklist
- Conversion commands
- Patterns for Next.js Image

---

### Example 2: Workflow Change

**Type:** Change `deploy-preview.md`

**Reason:**
> The workflow didn't include a mobile testing step via BrowserStack. Important for clients without access to various devices.

**What to add:**
```markdown
9.5. Test on BrowserStack or LambdaTest (if no real device available)
```

---

## Actions After Analysis

1. **If improvement found** — propose to user
2. **If user approves** — make changes
3. **Push changes to GitHub** repo `web-studio-skills`
4. **Update README** if a new skill/workflow was added

---

## Automatic Triggers

Run this skill automatically when:

- [ ] Project is finished (after final deploy)
- [ ] User did something non-standard 3+ times
- [ ] User explicitly said "we need to remember this"
- [ ] 5+ projects since the last review

---

## Retrospective Checklist

At the end of a project, go through this checklist:

- [ ] Which skills were used?
- [ ] Which skills were NOT used?
- [ ] What was done manually but could be in a skill?
- [ ] Which workflows were used?
- [ ] Were there deviations from workflows?
- [ ] Any improvement proposals?
- [ ] Need to add anything to the GitHub repo?

---

## Philosophy

> **"Every project makes the studio smarter"**

The goal is not just to finish a project, but to extract knowledge for future projects. Skills and workflows should evolve together with the studio's experience.
