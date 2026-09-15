---
layout: default
title: Publications & Notes
parent: Vocora
nav_order: 2
direction: ltr
description: "Research notes, translations, and reading that inform the learning principles and product decisions behind the Vocora startup."
permalink: /work/projects/vocora/publications
---

# Vocora Publications & Notes

This page collects reading and design notes that inform Vocora, my language-learning startup focused on English learning and IELTS preparation. Each item remains in its canonical section according to its content type. Inclusion here means that the item informs the product; it does not mean that it is a peer-reviewed publication or that a product-specific effect has been established.

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

## Product

[Vocora overview](/work/projects/vocora) · [Visit Vocora](https://vocora.ir)
