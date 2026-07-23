---
layout: default
title: All Writing
parent: Writing & Media
nav_order: 5
direction: ltr
lang: en
locale: en_US
description: "A complete index of essays, research notes, reading notes, translations, project records, program records, and media across okbayat.com."
permalink: /writing/all
---

# All Writing

This page is the complete discovery index for published work across software, artificial intelligence, organizations, research, leadership, learning, projects, and human transformation. Each item remains in its canonical content-type section—Essay, Research Note, Reading Note, Translation, Project Record, Program Record, or Experiment Report—so authorship, evidence status, and revision history remain clear.

Each conceptual work appears once below. A bilingual work is one entry with separate language editions, not two unrelated publications.

## Essays

{% for work in site.data.publications.works %}
{% if work.content_type == "essay" %}
- {% for edition in work.editions %}[{{ edition.title }}]({{ edition.url }}){% if work.editions.size > 1 %} — {{ edition.label }}{% endif %}{% unless forloop.last %}<br>{% endunless %}{% endfor %} — {{ work.summary }}
{% endif %}
{% endfor %}

Browse essay topics: [Artificial Intelligence](/writing/essays/topics/artificial-intelligence), [Software & Agentic Systems](/writing/essays/topics/software-agentic-systems), [Startups & Entrepreneurship](/writing/essays/topics/startups-entrepreneurship), [Leadership & Organizations](/writing/essays/topics/leadership-organizations), and [Learning & Human Transformation](/writing/essays/topics/learning-human-transformation).

## Research Notes

{% for work in site.data.publications.works %}
{% if work.content_type == "research-note" %}
- {% for edition in work.editions %}[{{ edition.title }}]({{ edition.url }}){% if work.editions.size > 1 %} — {{ edition.label }}{% endif %}{% unless forloop.last %}<br>{% endunless %}{% endfor %} — {{ work.summary }}
{% endif %}
{% endfor %}

## Reading Notes

{% for work in site.data.publications.works %}
{% if work.content_type == "reading-note" %}
- {% for edition in work.editions %}[{{ edition.title }}]({{ edition.url }}){% if work.editions.size > 1 %} — {{ edition.label }}{% endif %}{% unless forloop.last %}<br>{% endunless %}{% endfor %} — {{ work.summary }}
{% endif %}
{% endfor %}

## Translations

{% for work in site.data.publications.works %}
{% if work.content_type == "translation" %}
- {% for edition in work.editions %}[{{ edition.title }}]({{ edition.url }}){% if work.editions.size > 1 %} — {{ edition.label }}{% endif %}{% unless forloop.last %}<br>{% endunless %}{% endfor %} — {{ work.summary }}
{% endif %}
{% endfor %}

## Project, Program & Media Records

- [K2Quant](/projects/k2quant) — quantitative systems, software, artificial intelligence, technical operations, and company-building.
- [Vocora](/projects/vocora) — an open-source research-and-building project about learning, memory, language practice, and learning technology.
- [K2 OS](/projects/k2-os) — a business operating-system project currently being documented.
- [FamilyLink](/projects/familylink) — a paused social-impact project with a public record of its operating history and evidence limits.
- [Learning Circle](/leadership-learning/human-transformation/field-projects/learning-circle) — a generalized field-project record about learner ownership and facilitator withdrawal.
- [Mastery for Life](/leadership-learning/human-transformation/practice-programs/mastery-for-life) — a program record that separates history and participant report from efficacy claims.
- [Inja-Anja](/writing/podcast/inja-anja) — a Persian-language podcast about worldview, language, perception, and transformation.
- [Experiments](/projects/experiments) — the canonical home for formal protocols and results when they exist.

## Publication Rule

A work is included because it forms part of the public portfolio, not because it confirms a preferred conclusion. Failed projects, negative findings, inconclusive tests, revised interpretations, and explicit limitations remain eligible when they are documented clearly.
