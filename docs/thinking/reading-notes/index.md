---
layout: default
title: Reading Notes
parent: Thinking
nav_order: 3
nav_exclude: false
direction: ltr
description: "Source-specific notes and interpretations, grouped by their primary relevance to building systems or human transformation."
permalink: /thinking/reading-notes
---

# Reading Notes

Reading Notes document what I am learning from a specific source: its main ideas, questions it raises, points of disagreement, connections to my work, and claims that need further evidence.

Their canonical home is based on source dependence. A note may inform both Building and Human Transformation and may therefore appear in both topical publication hubs, while remaining one page here.

## Organizations, Decisions & Long-Term Building

{% for work in site.data.publications.works %}
{% if work.content_type == "reading-note" and work.primary_body == "building" %}
- {% for edition in work.editions %}[{{ edition.title }}]({{ edition.url }}){% if work.editions.size > 1 %} — {{ edition.label }}{% endif %}{% unless forloop.last %} · {% endunless %}{% endfor %} — {{ work.summary }}
{% endif %}
{% endfor %}

## Human Learning, Philosophy & Leadership

{% for work in site.data.publications.works %}
{% if work.content_type == "reading-note" and work.primary_body == "human-transformation" %}
- {% for edition in work.editions %}[{{ edition.title }}]({{ edition.url }}){% if work.editions.size > 1 %} — {{ edition.label }}{% endif %}{% unless forloop.last %} · {% endunless %}{% endfor %} — {{ work.summary }}
{% endif %}
{% endfor %}

## Source Types

A Reading Note may be based on:

- a book or chapter;
- a research paper or review;
- a lecture, course, or recorded talk;
- an official technical or institutional document;
- another identifiable long-form source.

## Editorial Standard

Each note should distinguish among:

- the source author's argument;
- direct quotation;
- my summary;
- my interpretation or disagreement;
- a practical implication;
- questions that require additional evidence.

A Reading Note is not a substitute for the original source and should link to it whenever possible.
