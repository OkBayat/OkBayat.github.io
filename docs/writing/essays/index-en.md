---
layout: default
title: Essays
parent: Writing
nav_order: 1
nav_exclude: false
direction: ltr
lang: en
locale: en_US
description: "Original long-form arguments and syntheses, organized by body of work and theme without duplicating their canonical pages."
permalink: /writing/essays
---

# Essays

Essays are original long-form arguments, interpretations, and syntheses by Mohammad Bayat. Their canonical home is determined by **content type**, not by subject: a software-architecture essay, a company-building reflection, and an essay about human relationships can all belong here.

Subject discovery is handled separately. Each conceptual work is classified by one or more **bodies of work** and **themes**, then linked from the relevant Building or Human Transformation publication index. A work still has one canonical page and one revision history.

A page belongs elsewhere when its main purpose is different:

- unfinished investigations and evidence reviews belong in [Research Notes](/research-practice/notes);
- source-specific reflections belong in [Reading Notes](/writing/reading-notes);
- work written by another author belongs in [Translations](/writing/translations) with clear attribution.

## Browse by Body of Work

### Building Systems & Organizations

{% include canonical-work-list-en.html content_type="essay" body="building" %}

Related technical, organizational, startup, and project writing is also collected in [All Writing](/writing/all).

### Human Transformation

{% include canonical-work-list-en.html content_type="essay" body="human-transformation" %}

Related research-facing writing about learning, identity, language, relationships, leadership, and coordination is also collected in [Selected Research-Related Work](/research-practice/publications).

## Browse by Theme

### Software, AI & Agent Systems

{% include canonical-work-list-en.html content_type="essay" theme="software-ai-agent-systems" %}

### Entrepreneurship, Company Building & Project Reflection

{% include canonical-work-list-en.html content_type="essay" theme="entrepreneurship-company-building" %}

### Relationships, Identity & Human Transformation

{% include canonical-work-list-en.html content_type="essay" body="human-transformation" %}

## Language Editions

Persian and English versions of the same conceptual work are displayed as one entry. The current-language title is primary, and a parenthetical link opens the other language edition. Each edition keeps its own URL and language metadata, while `translation_key` or the central publication registry prevents the archive from presenting one idea as two unrelated works.

## Publication Rule

The publication registry in `_data/publications.yml` is the machine-readable source for content type, body of work, theme, project relationship, language editions, and canonical URLs. Index pages may cross-list a work under several relevant lenses, but they must not copy or republish its body.
