---
layout: default
title: Research Notes
parent: Research
nav_order: 6
nav_exclude: false
direction: ltr
description: "Working investigations, evidence reviews, field observations, and design decisions grouped by their primary body of work."
permalink: /research/notes
---

# Research Notes

Research Notes contain work in progress: a question being clarified, evidence being reviewed, a field observation being documented, a design assumption being examined, or an interpretation being revised.

They are not automatically scientific papers and are not assumed to be peer reviewed. A strong note should make its status, evidence level, alternative explanations, and uncertainty visible.

Each note remains canonical here because **Research Note** describes its epistemic and editorial status. Project and subject indexes provide additional discovery without moving or duplicating the page.

## Building, Product Design & Learning Technology

{% for work in site.data.publications.works %}
{% if work.content_type == "research-note" and work.primary_body == "building" %}
- {% for edition in work.editions %}[{{ edition.title }}]({{ edition.url }}){% if work.editions.size > 1 %} — {{ edition.label }}{% endif %}{% unless forloop.last %} · {% endunless %}{% endfor %} — {{ work.summary }}
{% endif %}
{% endfor %}

These notes are also discoverable in [All Writing](/writing/all) and, when connected to the project, [Vocora Publications & Notes](/projects/vocora/publications).

## Human Learning, Leadership & Transformation

{% for work in site.data.publications.works %}
{% if work.content_type == "research-note" and work.primary_body == "human-transformation" %}
- {% for edition in work.editions %}[{{ edition.title }}]({{ edition.url }}){% if work.editions.size > 1 %} — {{ edition.label }}{% endif %}{% unless forloop.last %} · {% endunless %}{% endfor %} — {{ work.summary }}
{% endif %}
{% endfor %}

These notes are also collected in [Research Publications](/research/publications).

## Field Notes

{% assign field_notes = site.pages | where_exp: "note", "note.categories contains 'field-notes'" | sort: "date" | reverse %}
{% for note in field_notes %}
- [{{ note.title }}]({{ note.url }}) — {{ note.description }}
{% endfor %}

## Common Note Types

### Open Question

A concise statement of an active question, why it matters, what is currently known, and what would be a useful next step.

### Field Note

A structured account of a real setting such as a class, coaching relationship, organization, facilitated group, or product. It must distinguish direct observation, participant self-report, and the author's interpretation.

### Literature Review

A review of published evidence that identifies the population, task, comparison, outcome, limitations, and the distance between the source finding and the current practical setting.

### Design Note

A record of a project or program decision, the assumptions behind it, alternatives considered, and how the decision could be evaluated.

## Recommended Structure

1. Question and status
2. Why it matters
3. Setting, source, or material reviewed
4. Direct observation or published evidence
5. Participant self-report, when applicable
6. Current interpretation
7. Alternative explanations
8. Implications for practice or a project
9. Limitations, privacy, and uncertainty
10. Open questions and next step
11. References
