---
layout: default
title: Publications & Notes
parent: Human Transformation
nav_order: 2
direction: ltr
lang: en
locale: en_US
description: "A curated index of canonical essays, research notes, reading notes, translations, field records, and project pages related to human transformation."
permalink: /human-transformation/publications
---

# Human Transformation Publications & Notes

[نسخه‌ی فارسی](/human-transformation/publications-fa)

This page is a topical index. Each item remains in its canonical content section so authorship, evidence status, language metadata, and revision history are not duplicated or blurred.

A work may appear under more than one theme because learning, identity, relationships, leadership, language, and worldview overlap. Cross-listing does not create a second copy of the page.

## Program and Field Records

- [Human Transformation Research Agenda](/human-transformation/research-agenda) — active questions, evidence boundaries, and methods.
- [Learning Circle](/human-transformation/field-projects/learning-circle) — children's autonomy, peer teaching, group coordination, and facilitator withdrawal.
- [Mastery for Life Program Record](/human-transformation/practice-programs/mastery-for-life) — program history, questions, participant self-reports, limitations, and evaluation needs.
- [Leadership](/leadership) — hub for the existing practice, coaching, course, research, and source archive.

## Relationships, Acceptance & Completion

{% for work in site.data.publications.works %}
{% if work.bodies_of_work contains "human-transformation" and work.themes contains "relationships-acceptance" %}
- **{{ work.content_type | replace: "-", " " | capitalize }}:** {% for edition in work.editions %}[{{ edition.title }}]({{ edition.url }}){% if work.editions.size > 1 %} — {{ edition.label }}{% endif %}{% unless forloop.last %}<br>{% endunless %}{% endfor %} — {{ work.summary }}
{% endif %}
{% endfor %}

## Leadership, Identity & Coordination

{% for work in site.data.publications.works %}
{% if work.bodies_of_work contains "human-transformation" and work.themes contains "leadership-identity-coordination" %}
- **{{ work.content_type | replace: "-", " " | capitalize }}:** {% for edition in work.editions %}[{{ edition.title }}]({{ edition.url }}){% if work.editions.size > 1 %} — {{ edition.label }}{% endif %}{% unless forloop.last %}<br>{% endunless %}{% endfor %} — {{ work.summary }}
{% endif %}
{% endfor %}

## Learning, Memory & Language

{% for work in site.data.publications.works %}
{% if work.bodies_of_work contains "human-transformation" and work.themes contains "learning-memory-language" %}
- **{{ work.content_type | replace: "-", " " | capitalize }}:** {% for edition in work.editions %}[{{ edition.title }}]({{ edition.url }}){% if work.editions.size > 1 %} — {{ edition.label }}{% endif %}{% unless forloop.last %}<br>{% endunless %}{% endfor %} — {{ work.summary }}
{% endif %}
{% endfor %}

Vocora is a bounded software project within this wider inquiry. Its project-specific writing is collected in [Vocora Publications & Notes](/building/vocora/publications).

## Philosophy, Worldview & Context

{% for work in site.data.publications.works %}
{% if work.bodies_of_work contains "human-transformation" and work.themes contains "philosophy-worldview" %}
- **{{ work.content_type | replace: "-", " " | capitalize }}:** {% for edition in work.editions %}[{{ edition.title }}]({{ edition.url }}){% if work.editions.size > 1 %} — {{ edition.label }}{% endif %}{% unless forloop.last %}<br>{% endunless %}{% endfor %} — {{ work.summary }}
{% endif %}
{% endfor %}

- [Podcast: Inja-Anja](/voice/podcast) — conversations about worldview, frames of reference, perception, language, and integrity.
- [Human Transformation Source Library](/human-transformation/source-library) — source lineage and concept maps.
- [Leadership Source Library](/leadership/resources) — translations and concept material whose source lineage remains visible.

## Publication Rule

A page is added here because it contributes to an active question, not because it confirms a preferred answer. Inconclusive notes, revised interpretations, negative observations, and contradictory evidence are eligible when they are documented clearly.
