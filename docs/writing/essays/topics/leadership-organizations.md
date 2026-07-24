---
layout: default
title: Leadership & Organizations
parent: Essays
nav_order: 4
direction: ltr
description: "Essays about leadership, organizations, identity, coordination, commitment, and responsibility."
permalink: /writing/essays/topics/leadership-organizations
---

# Leadership & Organizations

This topic collects original arguments about leadership, identity, coordination, organizational context, commitment, and responsibility.

{% for work in site.data.publications.works %}
{% if work.content_type == "essay" and work.themes contains "leadership-identity-coordination" %}
- {% for edition in work.editions %}[{{ edition.title }}]({{ edition.url }}){% unless forloop.last %} · {% endunless %}{% endfor %} — {{ work.summary }}
{% endif %}
{% endfor %}

Programs and practice records remain discoverable through [Work](/work).
