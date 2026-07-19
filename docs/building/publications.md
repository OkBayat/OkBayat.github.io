---
layout: default
title: Publications & Notes
parent: Building
nav_order: 3
direction: ltr
description: "A curated index of essays, research notes, reading notes, translations, and project records about software, AI, entrepreneurship, organizations, and systems."
permalink: /building/publications
---

# Building Publications & Notes

This page is a topical index for work about building systems and organizations. Each item remains in its canonical content-type section—Essay, Research Note, Reading Note, Translation, Project Record, or Experiment Report—so authorship, evidence status, and revision history remain clear.

Some works appear under more than one theme because software, company-building, decision-making, and organizational design overlap. Cross-listing is intentional; the underlying page is not duplicated.

## Bodies of Work and Project Records

- [K2Quant](/building/k2quant) — quantitative systems, software, artificial intelligence, technical operations, and company-building.
- [Vocora](/building/vocora) — an open-source research-and-building project about learning, memory, language practice, and learning technology.
- [Projects](/building/projects) — bounded products, systems, organizations, and social-impact initiatives with explicit operating status.
- [Experiments](/building/experiments) — protocols and results when an explicit method, measurement plan, and interpretation exist.

## Software, AI & Agent Systems

{% for work in site.data.publications.works %}
{% if work.bodies_of_work contains "building" and work.themes contains "software-ai-agent-systems" %}
- **{{ work.content_type | replace: "-", " " | capitalize }}:** {% for edition in work.editions %}[{{ edition.title }}]({{ edition.url }}){% if work.editions.size > 1 %} — {{ edition.label }}{% endif %}{% unless forloop.last %} · {% endunless %}{% endfor %} — {{ work.summary }}
{% endif %}
{% endfor %}

## Entrepreneurship & Company Building

{% for work in site.data.publications.works %}
{% if work.bodies_of_work contains "building" and work.themes contains "entrepreneurship-company-building" %}
- **{{ work.content_type | replace: "-", " " | capitalize }}:** {% for edition in work.editions %}[{{ edition.title }}]({{ edition.url }}){% if work.editions.size > 1 %} — {{ edition.label }}{% endif %}{% unless forloop.last %} · {% endunless %}{% endfor %} — {{ work.summary }}
{% endif %}
{% endfor %}

## Systems, Operations & Decision-Making

{% for work in site.data.publications.works %}
{% if work.bodies_of_work contains "building" and work.themes contains "systems-operations-decision-making" %}
- **{{ work.content_type | replace: "-", " " | capitalize }}:** {% for edition in work.editions %}[{{ edition.title }}]({{ edition.url }}){% if work.editions.size > 1 %} — {{ edition.label }}{% endif %}{% unless forloop.last %} · {% endunless %}{% endfor %} — {{ work.summary }}
{% endif %}
{% endfor %}

## Project Reflections & Social Impact

{% for work in site.data.publications.works %}
{% if work.bodies_of_work contains "building" and work.themes contains "project-reflections-social-impact" %}
- **{{ work.content_type | replace: "-", " " | capitalize }}:** {% for edition in work.editions %}[{{ edition.title }}]({{ edition.url }}){% if work.editions.size > 1 %} — {{ edition.label }}{% endif %}{% unless forloop.last %} · {% endunless %}{% endfor %} — {{ work.summary }}
{% endif %}
{% endfor %}

- **Project record:** [FamilyLink](/family-link) — the factual record of the project's purpose, operating history, current paused status, evidence limits, and conditions for a responsible return.

## Learning Technology

{% for work in site.data.publications.works %}
{% if work.bodies_of_work contains "building" and work.themes contains "learning-memory-language" %}
- **{{ work.content_type | replace: "-", " " | capitalize }}:** {% for edition in work.editions %}[{{ edition.title }}]({{ edition.url }}){% if work.editions.size > 1 %} — {{ edition.label }}{% endif %}{% unless forloop.last %} · {% endunless %}{% endfor %} — {{ work.summary }}
{% endif %}
{% endfor %}

Project-specific context, design status, and external documentation remain collected in [Vocora Publications & Notes](/building/vocora/publications).

## Publication Rule

A work is included here because it informs an active Building question, not because it promotes a company or confirms a preferred conclusion. Failed projects, negative findings, inconclusive tests, revised interpretations, and explicit limitations are eligible when they are documented clearly.
