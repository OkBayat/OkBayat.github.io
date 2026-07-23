---
layout: default
title: Software & Agentic Systems
parent: Essays
nav_order: 2
direction: ltr
description: "Essays about software architecture, agentic systems, deterministic workflows, reliability, and engineering practice."
permalink: /writing/essays/topics/software-agentic-systems
---

# Software & Agentic Systems

This topic focuses on architecture, reliability, deterministic workflows, review systems, and the engineering required to make agentic software operationally trustworthy.

{% for work in site.data.publications.works %}
{% if work.content_type == "essay" and work.themes contains "software-ai-agent-systems" %}
- {% for edition in work.editions %}[{{ edition.title }}]({{ edition.url }}){% unless forloop.last %} · {% endunless %}{% endfor %} — {{ work.summary }}
{% endif %}
{% endfor %}

Some work also appears under Artificial Intelligence because the subjects overlap. Each article still has one canonical URL.
