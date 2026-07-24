---
layout: default
title: Publications & Notes
parent: Vocora
nav_order: 2
direction: ltr
description: "A curated index of research notes, translations, reading, and project documentation connected to Vocora."
permalink: /projects/vocora/publications
---

# Vocora Publications & Notes

This page collects work related to Vocora. Each item remains in its canonical section according to its content type. Inclusion here means that the item informs the project; it does not mean that it is a peer-reviewed publication or that a product-specific effect has been established.

## Research and Design Notes

{% for work in site.data.publications.works %}
{% if work.project == "vocora" and work.content_type == "research-note" %}
- {% for edition in work.editions %}[{{ edition.title }}]({{ edition.url }}){% if work.editions.size > 1 %} — {{ edition.label }}{% endif %}{% unless forloop.last %} · {% endunless %}{% endfor %} — {{ work.summary }}
{% endif %}
{% endfor %}

## Translations and Source Material

{% for work in site.data.publications.works %}
{% if work.project == "vocora" and work.content_type == "translation" %}
- {% for edition in work.editions %}[{{ edition.title }}]({{ edition.url }}){% if work.editions.size > 1 %} — {{ edition.label }}{% endif %}{% unless forloop.last %} · {% endunless %}{% endfor %} — {{ work.summary }}
{% endif %}
{% endfor %}

## Project Documentation

### [Gamification and Sharing Principles](https://github.com/OkBayat/vocora/blob/main/docs/GAMIFICATION.md)

**Type:** Product design and evidence note  
**Location:** Vocora repository

Documents the motivation principles, metric definitions, privacy constraints, and design boundaries for progress sharing and gamification.

### [Vocora Source and Technical Overview](https://github.com/OkBayat/vocora)

The application source, setup instructions, architecture, tests, and current product capabilities.
