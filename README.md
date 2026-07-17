# okbayat.com — Content Architecture and Editorial Guide

This document defines how content on **okbayat.com** is organized and described. It should be updated whenever the site's main navigation or editorial model changes.

## 1. Purpose of the site

okbayat.com documents what Mohammad Bayat is building, studying, testing, and revising.

The site is not intended to be a stream of promotional posts. Its purpose is to keep a durable public record of:

- original thinking and interpretation;
- working research notes;
- books, papers, and translations worth returning to;
- companies, software projects, and experiments;
- professional experience and current interests.

## 2. Editorial principles

### State only what can be supported

Do not use titles or claims that are larger than the work. In particular:

- Do not describe a working note as a scientific paper.
- Do not describe an early product feature as a validated learning intervention.
- Do not claim permanent learning, mastery, or cognitive improvement from short-term product activity.
- Do not use words such as *groundbreaking*, *revolutionary*, or *proven* without clear evidence.

### Separate evidence from interpretation

A page should make clear which statements come from published sources, which are the author's interpretation, and which remain open questions.

### Treat revision as part of the work

Research notes and project pages may change as evidence and experience change. Use `last_modified_date`, a status label, or a revision history where useful.

### Keep the navigation small

Section indexes belong in the sidebar. Most individual notes should use `nav_exclude: true` and be linked from an index page.

## 3. Canonical navigation

```text
Home

Thinking
├── Essays
├── Research Notes
├── Book Notes
└── Translations

Leadership

Building
├── K2Quant
├── Vocora
│   ├── Research Agenda
│   └── Publications & Notes
├── Projects
│   └── K2 OS
└── Experiments

Voice

About
├── Biography
├── Resume
├── Current Interests
└── Calendar
```

### Why K2Quant and Vocora are directly under Building

K2Quant and Vocora are ongoing bodies of work rather than bounded side projects:

- **K2Quant** is the main company-building and quantitative-systems work.
- **Vocora** is an independent research-and-building project about learning, memory, language practice, and learning technology.

`Projects` is reserved for more bounded products and systems, such as K2 OS. `Experiments` is reserved for explicit protocols and results.

## 4. Content types

### Essays

Original long-form arguments, interpretations, and syntheses written by Mohammad Bayat.

An essay should not be used for a direct translation, a book summary, or an unfinished collection of notes.

### Research Notes

Working investigations of a question, source, concept, or design decision. A research note may be incomplete and is not assumed to be peer reviewed.

A useful research note normally includes:

- the question;
- why it matters;
- evidence reviewed;
- the current interpretation;
- limitations and uncertainty;
- implications or next questions;
- references.

### Book Notes

Notes, interpretations, and questions developed while reading a specific book. These pages should distinguish the book author's position from Mohammad's interpretation.

### Translations

Translations or adaptations of work written by someone else. Every page must name the original author, source, and translator or adapter. A short editorial note should explain why the text is being included.

### Project Pages

Stable descriptions of real work: what exists, why it is being built, its present status, and what has not yet been demonstrated.

### Experiment Reports

Reports with an explicit question, hypothesis, method, metrics, results, limitations, and status. `Planned`, `Running`, `Completed`, and `Inconclusive` are all acceptable statuses.

## 5. Vocora publishing model

Vocora content is distributed by type, with one canonical home for each page:

- `/building/vocora` — project overview and current state;
- `/building/vocora/research-agenda` — questions, methods, and boundaries;
- `/building/vocora/publications` — curated index of related output;
- `/thinking/research-notes/...` — research and design notes;
- `/thinking/essays/...` — original essays;
- `/thinking/translations/...` — translated work;
- `/building/experiments/...` — protocols and results when formal experiments exist.

The publications page links to these items; it does not duplicate them.

## 6. Recommended page metadata

Research-related pages should include as many of these fields as apply:

```yaml
---
layout: default
title: Example title
description: "A precise one-sentence description."
parent: Research Notes
nav_exclude: true
direction: rtl
lang: fa
locale: fa_IR
author: Mohammad Bayat
date: 2026-07-17
last_modified_date: 2026-07-17
status: working-note
project: vocora
categories:
  - thinking
  - research-notes
tags:
  - vocora
  - learning
sitemap: true
permalink: /thinking/research-notes/example
---
```

Use a content label near the beginning of the page when readers could otherwise misunderstand its status:

- Essay
- Working Research Note
- Literature Review
- Design Note
- Experiment Report
- Translation or Adaptation

## 7. Source and evidence rules

- Prefer primary papers, systematic reviews, meta-analyses, and official documentation.
- Link to the original source whenever possible.
- Do not turn a general finding into a claim that the current product has already produced that effect.
- State when a conclusion is an inference.
- Include limitations when evidence is narrow, indirect, or disputed.
- Preserve the distinction between short-term task performance and durable learning.

## 8. Maintenance checklist

Before publishing or merging a structural change:

1. Confirm that every `parent` matches an existing page title exactly.
2. Check that every permalink is unique.
3. Keep individual articles out of the sidebar unless they are intentionally featured.
4. Check internal links and the Jekyll build.
5. Update this guide when navigation or definitions change.

## 9. Success criteria

The site is succeeding when a reader can quickly understand:

- what Mohammad is actually working on;
- which pages are original, translated, exploratory, or tested;
- what evidence supports a claim;
- what remains uncertain;
- how the work changes over time.
