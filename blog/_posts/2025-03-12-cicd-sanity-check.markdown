---
title: "My CI/CD pipeline sanity check"
layout: post
date: 2025-03-12 19:13
tags: [devops, cicd]
image: /assets/images/banner.png
headerImage: true
blog: true
hidden: false # don't count this post in blog pagination
description: "Why does this CI/CD pipeline keep failing?"
category: blog
author: belinhacbr
externalLink: false
---
I did my fair share of staring at a red X in my CI/CD pipeline while muttering: *"Why does this CI/CD pipeline keep failing?"*, not always sure if I made the undesired sight happen, but always knowing I wasn't alone in this. I feel pipeline failures are similar to unexploded WWII bombs in your DevOps workflow: they frustrate the team, slow you down and often stem from sneaky, overlooked issues.

Before rage-quitting, `rm -rf` an entire setup and never seeing a sweet terminal again, I got the habit to run a quick **sanity check** on the usual suspects.

### 1. The Obvious Culprit: Your Code

- **Failing tests?** Check the logs! Flaky tests, race conditions, or bad assertions love to sneak in.
- **Syntax errors?** Linters and IDE checks help, but CI systems don't forgive typos. Mirror the pipeline linter on your IDE, hold it close.
- **Dependency hell?** `npm install`, `pip`, or `go mod` can break overnight. Lock your versions.
- **New failure?** **Write a test for it.** If something breaks in CI, it'll break again. Capture the bug with a test *now* instead of future-you debugging it twice.

**Quick sanity check (e.g.) :**

```bash
# Reproduce locally, then lock it down with a test
pytest tests/test_fixed_bug.py -k "test_thing_that_failed_in_ci"
```

### 2. The Silent Killer: Pipeline Configs
Your `.gitlab-ci.yml`, `Jenkinsfile`, or GitHub Actions workflow might be:

- **Misconfigured** (indentation, wrong keys, missing steps).
- **Using outdated syntax** (CI tools evolve fast).
- **Assuming wrong environments** ("But it works on my machine!").

**Quick sanity check (e.g.) :**

```yaml
# Validate your configs (e.g., GitHub Actions)
gh workflow lint .github/workflows/deploy.yml
```

### 3. The Phantom Menace: Environment Variables

**Secrets vs. Variables:**

- **Secrets** (API keys, tokens) should *never* be hardcoded. Use your CI's secret store.
- **Configs** (e.g., `ENV=staging`) can be plain variables but should still be version-controlled.

**Common fails:**

- **Missing vars:** Your local `.env` isn't magically in CI. List required vars in your `README`.
- **Typos:** `DATABASE_URL` ≠ `DB_URL` (case sensitivity matters!).
- **Scope issues:** Does the variable exist in *this* job/stage?

**Quick sanity check (e.g.) :**

```bash
# Debug env vars in CI (GitHub Actions example)
- name: Log env vars
  run: printenv | sort
```

### 4. The Empire Strikes Back: Permissions

- **Missing secrets?** AWS keys, SSH tokens, or database URLs must exist in CI variables.
- **Wrong permissions?** Can your runner access the registry, repo, or deployment target?
- **Resource limits?** OOM kills, slow runners, or Docker rate limits can fail builds.

**Quick sanity check (e.g.) :**

```bash
# Debug permissions in a CI step
- name: Check AWS access
  run: aws sts get-caller-identity
```


### 5. The Hidden Time Bomb: External Dependencies

- **APIs down?** Tests calling `https://some-unreliable-api.com` will fail randomly. Mock these as much as possible without compromising your tests.
- **Package registry issues?** npm, PyPI, or Maven outages do break builds. Breathe. Cache if possible.
- **Race conditions?** Parallel jobs might conflict (e.g., DB migrations vs. tests). These deserve their own place in hell but also another chance.
**Quick sanity check (e.g.) :**

```yaml
# Retry flaky steps in GitHub Actions
- name: Test
  run: pytest
  retry-on-error: true
```


### 6. The Human Factor

- **"It worked yesterday!"** → Someone changed a config, test, or dependency. Check those.
- **Manual hotfixes?** Untracked changes in production can desync with CI. I know there's no time to run a pipeline, run it anyway.
- **Stale branches?** Merging old code without rebasing = 💥. Run pipelines on every bit of code. Fail in a PR, always merge with a pass and live a happy life.

**Quick sanity check (e.g.) :**
```bash
# Enforce "test before merge"
git push origin HEAD --force-with-lease  # (Just kidding, don't.)
```



### Main Quest: Make Your Pipeline Resilient

- **Fail fast**: Put cheap checks (lint, unit tests) early. Run pipelines early, either on branches or PRs, avoid breaking `main`.
- **Log everything**: Debugging without logs is like fixing a car blindfolded while holding a hyperactive hamster. If a riddle appears in the form of an error message, add some logs to help the next tortured soul (might be future-you).
- **Automate recovery**: Auto-retry flaky steps, but **always** with limits.

Next time your pipeline fails, **don't panic** -- run this checklist. And if all else fails, blame Docker. (Kidding... mostly.)
