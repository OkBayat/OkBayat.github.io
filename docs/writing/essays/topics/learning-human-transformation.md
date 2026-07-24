---
layout: default
title: Learning & Human Transformation
parent: Essays
nav_order: 5
direction: ltr
description: "Essays about learning, relationships, identity, worldview, language, and human transformation."
permalink: /writing/essays/topics/learning-human-transformation
---

# Learning & Human Transformation

This topic collects original arguments about learning, relationships, identity, worldview, language, acceptance, and the possibility and limits of human transformation.

{% for work in site.data.publications.works %}
{% if work.content_type == "essay" and work.bodies_of_work contains "human-transformation" %}
- {% for edition in work.editions %}[{{ edition.title }}]({{ edition.url }}){% unless forloop.last %} · {% endunless %}{% endfor %} — {{ work.summary }}
{% endif %}
{% endfor %}

Research questions and developing evidence remain under [Research & Practice](/research-practice); programs and practice settings remain discoverable through [Work](/work).
