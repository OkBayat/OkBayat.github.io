---
layout: default
title: Translations
parent: Thinking
nav_order: 4
direction: ltr
description: "Attributed translations and adaptations, organized by the questions and projects they inform."
permalink: /thinking/translations
---

# Translations

This section contains translations and adaptations of work written by other authors. The canonical home is determined by authorship: a translated technical, startup, or human-learning text remains a Translation rather than becoming an Essay because of its subject.

## Published Translations & Adaptations

{% for work in site.data.publications.works %}
{% if work.content_type == "translation" %}
- {% for edition in work.editions %}[{{ edition.title }}]({{ edition.url }}){% if work.editions.size > 1 %} — {{ edition.label }}{% endif %}{% unless forloop.last %} · {% endunless %}{% endfor %} — {{ work.summary }}
{% endif %}
{% endfor %}

Translations related to learning technology are also collected in [Vocora Publications & Notes](/building/vocora/publications). Older leadership translations and source material remain accessible through the [Human Transformation Source Library](/human-transformation/source-library) and [Leadership Source Library](/leadership/resources).

## Required Attribution

Every page should identify:

- the original author;
- the original title and source;
- the translator or adapter;
- whether the page is a complete translation, selected translation, summary, or adaptation;
- an editorial note explaining why it is included.

The original author's language and claims should not be confused with my own research conclusions. Commentary added by me should be labelled clearly.
