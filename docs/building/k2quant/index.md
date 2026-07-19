---
layout: default
title: K2Quant
parent: Building
nav_order: 1
direction: ltr
description: "Mohammad Bayat's company-building work in quantitative systems, software, artificial intelligence, and technical operations."
permalink: /building/k2quant
---

# K2Quant

{ Quantitative systems, software, artificial intelligence, and company-building | fs-6 }

K2Quant is the main company-building part of my work. It is where I develop and operate software for quantitative and market-related systems while working on the practical problems of reliability, decision-making, team coordination, and organizational development.

## Current Focus

- Building and maintaining quantitative software systems
- Improving the reliability and clarity of technical processes
- Developing artificial-intelligence tools, skills, and agent-based workflows
- Developing tools that support research, analysis, and operations
- Learning from the day-to-day work of building a technical organization

## Related Writing

{% for work in site.data.publications.works %}
{% if work.project == "k2quant" %}
- **{{ work.content_type | replace: "-", " " | capitalize }}:** {% for edition in work.editions %}[{{ edition.title }}]({{ edition.url }}){% if work.editions.size > 1 %} — {{ edition.label }}{% endif %}{% unless forloop.last %} · {% endunless %}{% endfor %} — {{ work.summary }}
{% endif %}
{% endfor %}

The wider technical, organizational, and company-building archive is collected in [Building Publications & Notes](/building/publications).

## Relationship to Human Transformation

K2Quant is an operating company and technical body of work, not a human-subject research laboratory. However, the day-to-day work repeatedly raises questions about decisions, language, responsibility, coordination, leadership, context, and performance. Those cross-cutting questions are documented under [Human Transformation](/human-transformation) when they can be described without exposing confidential organizational information.

This page is intended to document concrete systems, decisions, and lessons as they become suitable for public release. It does not treat ambition as evidence or present future goals as completed work.

For more information, visit the [K2Quant website](https://www.k2quant.com).
