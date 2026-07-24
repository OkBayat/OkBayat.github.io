---
layout: default
title: همه‌ی نوشته‌ها
parent: Writing
nav_order: 5
direction: rtl
lang: fa
locale: fa_IR
description: "نمایه‌ی کامل جستارها، یادداشت‌های پژوهشی و مطالعاتی، ترجمه‌ها، سوابق پروژه و برنامه، و رسانه در okbayat.com."
permalink: /writing/all-fa
---

# همه‌ی نوشته‌ها

این صفحه نمایه‌ی کامل آثار منتشرشده درباره‌ی نرم‌افزار، هوش مصنوعی، سازمان‌ها، پژوهش، راهبری، یادگیری، پروژه‌ها و تحول انسان است. هر مورد در بخش مرجعِ نوع محتوای خود—جستار، یادداشت پژوهشی، یادداشت مطالعه، ترجمه، سابقه‌ی پروژه، سابقه‌ی برنامه یا گزارش آزمایش—باقی می‌ماند تا نویسندگی، وضعیت شواهد و تاریخچه‌ی بازنگری روشن بماند.

هر اثر مفهومی در فهرست زیر یک بار نمایش داده می‌شود. اثر دوزبانه یک مدخل با دو نسخه‌ی زبانی است، نه دو انتشار نامرتبط.

## جستارها

{% for work in site.data.publications.works %}
{% if work.content_type == "essay" %}
{% assign localized_summary = site.data.publications_fa.summaries[work.id] | default: work.summary %}
{% assign persian_edition = work.editions | where: "lang", "fa" | first %}
{% assign english_edition = work.editions | where: "lang", "en" | first %}
- {% if persian_edition %}[{{ persian_edition.title }}]({{ persian_edition.url }}){% if english_edition %} { ([English Version]({{ english_edition.url }})) | ltr }{% endif %}{% elsif english_edition %}{ [{{ english_edition.title }}]({{ english_edition.url }}) (English Version) | ltr }{% endif %} — {{ localized_summary }}
{% endif %}
{% endfor %}

موضوع‌های جستارها: [هوش مصنوعی](/writing/essays/topics/artificial-intelligence)، [نرم‌افزار و سیستم‌های ایجنتی](/writing/essays/topics/software-agentic-systems)، [استارتاپ و کارآفرینی](/writing/essays/topics/startups-entrepreneurship)، [راهبری و سازمان‌ها](/writing/essays/topics/leadership-organizations)، و [یادگیری و تحول انسان](/writing/essays/topics/learning-human-transformation).

## یادداشت‌های پژوهشی

{% for work in site.data.publications.works %}
{% if work.content_type == "research-note" %}
{% assign localized_summary = site.data.publications_fa.summaries[work.id] | default: work.summary %}
{% assign persian_edition = work.editions | where: "lang", "fa" | first %}
{% assign english_edition = work.editions | where: "lang", "en" | first %}
- {% if persian_edition %}[{{ persian_edition.title }}]({{ persian_edition.url }}){% if english_edition %} { ([English Version]({{ english_edition.url }})) | ltr }{% endif %}{% elsif english_edition %}{ [{{ english_edition.title }}]({{ english_edition.url }}) (English Version) | ltr }{% endif %} — {{ localized_summary }}
{% endif %}
{% endfor %}

## یادداشت‌های مطالعه

{% for work in site.data.publications.works %}
{% if work.content_type == "reading-note" %}
{% assign localized_summary = site.data.publications_fa.summaries[work.id] | default: work.summary %}
{% assign persian_edition = work.editions | where: "lang", "fa" | first %}
{% assign english_edition = work.editions | where: "lang", "en" | first %}
- {% if persian_edition %}[{{ persian_edition.title }}]({{ persian_edition.url }}){% if english_edition %} { ([English Version]({{ english_edition.url }})) | ltr }{% endif %}{% elsif english_edition %}{ [{{ english_edition.title }}]({{ english_edition.url }}) (English Version) | ltr }{% endif %} — {{ localized_summary }}
{% endif %}
{% endfor %}

## ترجمه‌ها

{% for work in site.data.publications.works %}
{% if work.content_type == "translation" %}
{% assign localized_summary = site.data.publications_fa.summaries[work.id] | default: work.summary %}
{% assign persian_edition = work.editions | where: "lang", "fa" | first %}
{% assign english_edition = work.editions | where: "lang", "en" | first %}
- {% if persian_edition %}[{{ persian_edition.title }}]({{ persian_edition.url }}){% if english_edition %} { ([English Version]({{ english_edition.url }})) | ltr }{% endif %}{% elsif english_edition %}{ [{{ english_edition.title }}]({{ english_edition.url }}) (English Version) | ltr }{% endif %} — {{ localized_summary }}
{% endif %}
{% endfor %}

## سوابق پروژه، برنامه و رسانه

- [K2Quant](/work/projects/k2quant) — سیستم‌های کمی، نرم‌افزار، هوش مصنوعی، عملیات فنی و شرکت‌سازی.
- [Vocora](/work/projects/vocora) — پروژه‌ای متن‌باز درباره‌ی یادگیری، حافظه، تمرین زبان و فناوری یادگیری.
- [K2 OS](/work/projects/k2-os) — پروژه‌ی سیستم‌عامل کسب‌وکار که در حال مستندسازی است.
- [FamilyLink](/work/projects/familylink) — پروژه‌ی متوقف‌شده‌ی اثر اجتماعی با سابقه‌ی عمومیِ فعالیت و محدودیت‌های شواهد.
- [حلقه‌ی یادگیری](/work/leadership-learning/human-transformation/field-projects/learning-circle) — سابقه‌ای عمومی و تعمیم‌یافته درباره‌ی مالکیت یادگیری و عقب‌نشینی تسهیل‌گر.
- [چیرگی بر زندگی](/work/leadership-learning/human-transformation/practice-programs/mastery-for-life) — سابقه‌ی برنامه‌ای که تاریخچه و گزارش شرکت‌کنندگان را از ادعای اثربخشی جدا می‌کند.
- [اینجا-آنجا](/writing/podcast/inja-anja) — پادکستی فارسی درباره‌ی جهان‌بینی، زبان، ادراک و تحول.
- [آزمایش‌ها](/work/projects/experiments) — خانه‌ی مرجع پروتکل‌ها و نتایج رسمی، هر زمان که وجود داشته باشند.

## قاعده‌ی انتشار

یک اثر به این دلیل در اینجا آمده است که بخشی از پورتفولیوی عمومی است، نه برای تأیید نتیجه‌ای از پیش مطلوب. پروژه‌های شکست‌خورده، یافته‌های منفی، آزمون‌های بی‌نتیجه، تفسیرهای بازنگری‌شده و محدودیت‌های صریح، اگر روشن مستند شده باشند، می‌توانند در این نمایه قرار گیرند.
