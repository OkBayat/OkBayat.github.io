---
layout: default
title: Artificial Intelligence
parent: Essays
nav_order: 1
direction: ltr
description: "Essays about artificial intelligence, LLM evaluation, agent behavior, and responsible use in real systems."
permalink: /writing/essays/topics/artificial-intelligence
---

# Artificial Intelligence

This topic collects essays about using and evaluating artificial intelligence in real systems, including LLM judges, agent workflows, evidence, failure modes, and operational responsibility.

{% for work in site.data.publications.works %}
{% if work.content_type == "essay" and work.themes contains "software-ai-agent-systems" %}
- {% for edition in work.editions %}[{{ edition.title }}]({{ edition.url }}){% unless forloop.last %} · {% endunless %}{% endfor %} — {{ work.summary }}
{% endif %}
{% endfor %}

The articles remain canonical in [Essays](/writing/essays); this page is a topical route, not a duplicate archive.
