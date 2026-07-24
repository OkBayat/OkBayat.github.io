---
layout: default
title: Startups & Entrepreneurship
parent: Essays
nav_order: 3
direction: ltr
description: "Essays about entrepreneurship, company-building, operating models, projects, and lessons from creating organizations."
permalink: /writing/essays/topics/startups-entrepreneurship
---

# Startups & Entrepreneurship

This topic is the home for present and future essays about entrepreneurship, company-building, operating models, project sustainability, and lessons from creating organizations.

{% for work in site.data.publications.works %}
{% if work.content_type == "essay" and work.themes contains "entrepreneurship-company-building" %}
- {% for edition in work.editions %}[{{ edition.title }}]({{ edition.url }}){% unless forloop.last %} · {% endunless %}{% endfor %} — {{ work.summary }}
{% endif %}
{% endfor %}

Projects that exist in practice remain discoverable through [Work](/work).
