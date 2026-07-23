---
layout: default
title: Essays
parent: Writing & Media
nav_order: 1
nav_exclude: false
direction: ltr
description: "Original long-form arguments and syntheses, organized by body of work and theme without duplicating their canonical pages."
permalink: /writing/essays
---

# Essays

Essays are original long-form arguments, interpretations, and syntheses by Mohammad Bayat. Their canonical home is determined by **content type**, not by subject: a software-architecture essay, a company-building reflection, and an essay about human relationships can all belong here.

Subject discovery is handled separately. Each conceptual work is classified by one or more **bodies of work** and **themes**, then linked from the relevant Building or Human Transformation publication index. A work still has one canonical page and one revision history.

A page belongs elsewhere when its main purpose is different:

- unfinished investigations and evidence reviews belong in [Research Notes](/research/notes);
- source-specific reflections belong in [Reading Notes](/writing/reading-notes);
- work written by another author belongs in [Translations](/writing/translations) with clear attribution.

## Browse by Body of Work

### Building Systems & Organizations

{% for work in site.data.publications.works %}
{% if work.content_type == "essay" and work.bodies_of_work contains "building" %}
- {% for edition in work.editions %}[{{ edition.title }}]({{ edition.url }}){% if work.editions.size > 1 %} — {{ edition.label }}{% endif %}{% unless forloop.last %}<br>{% endunless %}{% endfor %} — {{ work.summary }}
{% endif %}
{% endfor %}

Related technical, organizational, startup, and project writing is also collected in [All Writing](/writing/all).

### Human Transformation

{% for work in site.data.publications.works %}
{% if work.content_type == "essay" and work.bodies_of_work contains "human-transformation" %}
- {% for edition in work.editions %}[{{ edition.title }}]({{ edition.url }}){% if work.editions.size > 1 %} — {{ edition.label }}{% endif %}{% unless forloop.last %}<br>{% endunless %}{% endfor %} — {{ work.summary }}
{% endif %}
{% endfor %}

Related research-facing writing about learning, identity, language, relationships, leadership, and coordination is also collected in [Research Publications](/research/publications).

## Browse by Theme

### Software, AI & Agent Systems

{% for work in site.data.publications.works %}
{% if work.content_type == "essay" and work.themes contains "software-ai-agent-systems" %}
- {% for edition in work.editions %}[{{ edition.title }}]({{ edition.url }}){% unless forloop.last %} · {% endunless %}{% endfor %} — {{ work.summary }}
{% endif %}
{% endfor %}

### Entrepreneurship, Company Building & Project Reflection

{% for work in site.data.publications.works %}
{% if work.content_type == "essay" and work.themes contains "entrepreneurship-company-building" %}
- {% for edition in work.editions %}[{{ edition.title }}]({{ edition.url }}){% unless forloop.last %} · {% endunless %}{% endfor %} — {{ work.summary }}
{% endif %}
{% endfor %}

### Relationships, Identity & Human Transformation

{% for work in site.data.publications.works %}
{% if work.content_type == "essay" and work.bodies_of_work contains "human-transformation" %}
- {% for edition in work.editions %}[{{ edition.title }}]({{ edition.url }}){% if work.editions.size > 1 %} — {{ edition.label }}{% endif %}{% unless forloop.last %}<br>{% endunless %}{% endfor %} — {{ work.summary }}
{% endif %}
{% endfor %}

## Language Editions

Persian and English versions of the same conceptual work are displayed as one entry with multiple language links. Each edition keeps its own URL and language metadata, while `translation_key` or the central publication registry prevents the archive from presenting one idea as two unrelated works.

## Publication Rule

The publication registry in `_data/publications.yml` is the machine-readable source for content type, body of work, theme, project relationship, language editions, and canonical URLs. Index pages may cross-list a work under several relevant lenses, but they must not copy or republish its body.
