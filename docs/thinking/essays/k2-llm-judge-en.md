---
layout: default
title: "Beyond the AI Reviewer: How We Built K2 LLM Judge as a Governed Pull Request Review System"
description: "A practical account of K2 LLM Judge: its GitHub event pipeline, trusted-base safety model, risk-routed multi-agent reviews, verifier and confidence gates, inline comment publishing, and separate feedback-resolution loop."
parent: Essays
nav_exclude: false
direction: ltr
lang: en
locale: en_US
author: Mohammad Bayat
date: 2026-07-21
date_modified: 2026-07-21
last_modified_date: 2026-07-21
status: essay
project: k2quant
translation_key: k2-llm-judge
evidence_level: implementation-record-and-architectural-synthesis-informed-by-primary-sources
seo:
  type: Article
categories:
  - thinking
  - essays
tags:
  - llm-as-a-judge
  - ai-code-review
  - github
  - multi-agent-systems
  - software-architecture
  - evaluation
  - developer-tools
  - k2quant
sitemap: true
permalink: /thinking/essays/k2-llm-judge-en
---

# Beyond the AI Reviewer: How We Built K2 LLM Judge as a Governed Pull Request Review System
{: .no_toc }

{ A practical architecture for high-signal, evidence-backed, low-noise pull request review | fs-6 }

{ [نسخه‌ی فارسی](/thinking/essays/k2-llm-judge-fa) | rtl }

{: .note-title }
> About this essay
>
> This essay documents an operating review system developed for K2Quant as it existed in July 2026. It is an implementation record and architectural synthesis, not a controlled benchmark paper. The external sources explain the research and engineering patterns that informed the design; the way those patterns are combined in K2 LLM Judge is our own implementation. We have not yet published a formal measurement of its precision, recall, or superiority over other review tools. The system’s confidence value is an eligibility score used by policy, not a calibrated probability that a finding is correct.

An LLM can read a diff and write a plausible review comment in one call.

That is useful, but it is not yet a dependable review system.

A production pull request reviewer has to answer harder questions:

- Which event should start a review?
- Which commit is being reviewed?
- What happens if a new commit arrives while the review is running?
- Which repository rules are authoritative?
- How should low-risk documentation changes differ from capital-sensitive or execution-sensitive changes?
- How do we stop the model from treating pull request text as instructions?
- How do we keep weak, duplicate, stale, or unanchorable findings off the pull request?
- Who is allowed to change code after a review comment is published?
- How does the workflow know that a comment was fixed, declined, or still unresolved?
- What evidence should be preserved so the reviewer itself can improve later?

K2 LLM Judge grew from a small GitHub webhook into an answer to those questions. Its central design choice is this:

> The language model may judge evidence, but deterministic software must own trust boundaries, state transitions, publication, and side effects.

The resulting system has two deliberately separate halves. The first half is a read-only judge and publisher that subscribes to GitHub, assembles bounded context, routes the pull request by risk, runs specialized review passes, validates the final findings, and posts comment-only inline reviews. The second half lives in the repository workflow: it reads unresolved review threads and CI state, classifies each item as `fix`, `decline`, or `escalate`, applies only justified changes, verifies them, pushes them, and converges on a clean pull request.

This essay explains the architecture, the research and tools that informed it, the failure modes it is designed to resist, and a practical blueprint for building a similar system.

<details open markdown="block">
  <summary>
    Table of contents
  </summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

{% include k2-llm-judge/en-01-context-and-routing.md %}

{% include k2-llm-judge/en-02-governance-and-convergence.md %}

{% include k2-llm-judge/en-03-blueprint-and-references.md %}
