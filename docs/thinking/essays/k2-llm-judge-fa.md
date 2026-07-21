---
layout: default
title: "فراتر از یک بازبین هوش مصنوعی؛ چگونه K2 LLM Judge را به‌صورت یک سیستم بازبینی Pull Request ساختیم"
description: "شرحی کاربردی از K2 LLM Judge: خط لوله‌ی رویدادهای GitHub، مدل امنیتی مبتنی بر trusted base، بازبینی چندایجنتی مبتنی بر ریسک، گیت‌های verifier و confidence، انتشار inline comment و حلقه‌ی جداگانه‌ی رسیدگی به بازخورد."
parent: Essays
nav_exclude: false
direction: rtl
lang: fa
locale: fa_IR
author: Mohammad Bayat
date: 2026-07-21
date_modified: 2026-07-21
last_modified_date: 2026-07-21
status: essay
project: k2quant
translation_key: k2-llm-judge
evidence_level: implementation-record-and-architectural-synthesis-informed-by-primary-sources
seo:
  type: Article
categories:
  - thinking
  - essays
tags:
  - ال‌ال‌ام به‌عنوان داور
  - بازبینی کد با هوش مصنوعی
  - گیت‌هاب
  - سیستم‌های چندایجنتی
  - معماری نرم‌افزار
  - ارزیابی مدل زبانی
  - ابزارهای توسعه‌دهنده
  - کی‌توکوانت
sitemap: true
permalink: /thinking/essays/k2-llm-judge-fa
---

# فراتر از یک بازبین هوش مصنوعی؛ چگونه K2 LLM Judge را به‌صورت یک سیستم بازبینی Pull Request ساختیم
{: .no_toc }

{ یک معماری کاربردی برای بازبینی Pull Request با سیگنال بالا، شواهد روشن و نویز کم | fs-6 }

{ [English version](/thinking/essays/k2-llm-judge-en) | ltr }

{: .note-title }
> درباره‌ی این مقاله
>
> این مقاله سیستم بازبینی‌ای را مستند می‌کند که تا ژوئیه‌ی ۲۰۲۶ در K2Quant توسعه داده و به کار گرفته شده بود. متن حاضر یک گزارش پیاده‌سازی و ترکیب معماری است، نه یک مقاله‌ی benchmark کنترل‌شده. منابع خارجی، الگوهای پژوهشی و مهندسی مؤثر بر طراحی را توضیح می‌دهند؛ شیوه‌ی ترکیب آن الگوها در K2 LLM Judge، پیاده‌سازی خود ماست. هنوز اندازه‌گیری رسمی و منتشرشده‌ای از precision، recall یا برتری این سیستم نسبت به ابزارهای دیگر نداریم. مقدار `confidence` در این سیستم یک امتیاز eligibility برای اعمال policy است، نه احتمال کالیبره‌شده‌ی درست‌بودن یک finding.

یک مدل زبانی می‌تواند در یک فراخوانی، diff را بخواند و یک review comment قابل قبول بنویسد.

این توانایی مفید است؛ اما هنوز یک سیستم بازبینی قابل اتکا نیست.

یک بازبین production برای Pull Request باید به پرسش‌های دشوارتری پاسخ دهد:

- کدام رویداد باید بازبینی را آغاز کند؟
- دقیقاً کدام commit در حال بازبینی است؟
- اگر هنگام اجرای بازبینی commit تازه‌ای برسد، چه اتفاقی باید بیفتد؟
- کدام قواعد مخزن authority محسوب می‌شوند؟
- یک تغییر کم‌ریسک در مستندات چگونه باید با تغییر حساس به سرمایه، ریسک یا اجرای سفارش متفاوت بررسی شود؟
- چگونه مانع شویم که مدل متن Pull Request را به‌عنوان دستور اجرا تلقی کند؟
- چگونه findingهای ضعیف، تکراری، stale یا غیرقابل‌اتصال به diff را از Pull Request دور نگه داریم؟
- پس از انتشار review comment چه کسی مجاز است کد را تغییر دهد؟
- workflow چگونه تشخیص می‌دهد یک comment اصلاح، رد یا هنوز حل‌نشده است؟
- چه شواهدی باید حفظ شوند تا خود سیستم بازبینی بعداً بهتر شود؟

K2 LLM Judge از یک webhook کوچک GitHub آغاز شد و به پاسخی برای این پرسش‌ها تبدیل شد. تصمیم مرکزی معماری آن این است:

> مدل زبانی می‌تواند درباره‌ی شواهد قضاوت کند؛ اما مرزهای اعتماد، انتقال وضعیت، انتشار و اثرات جانبی باید در اختیار نرم‌افزار قطعی باشند.

سیستم حاصل عمداً دو نیمه‌ی جدا دارد. نیمه‌ی اول یک judge فقط‌خواندنی و یک publisher کنترل‌شده است که به GitHub متصل می‌شود، context محدود می‌سازد، Pull Request را براساس ریسک route می‌کند، passهای تخصصی بازبینی را اجرا می‌کند، findingهای نهایی را اعتبارسنجی می‌کند و reviewهای inline از نوع comment منتشر می‌کند. نیمه‌ی دوم داخل workflow مخزن قرار دارد: threadهای حل‌نشده و وضعیت CI را می‌خواند، هر مورد را به `fix`، `decline` یا `escalate` طبقه‌بندی می‌کند، فقط تغییرهای موجه را اعمال و آزمایش می‌کند، آن‌ها را push می‌کند و Pull Request را به سمت وضعیت clean همگرا می‌سازد.

این مقاله معماری، منابع و ابزارهای اثرگذار بر آن، failure modeهایی که برای مقاومت در برابرشان طراحی شده و یک blueprint عملی برای ساخت سیستمی مشابه را توضیح می‌دهد.

<details open markdown="block">
  <summary>
    فهرست مطالب
  </summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

{% include k2-llm-judge/fa-01-context-and-routing.md %}

{% include k2-llm-judge/fa-02-governance-and-convergence.md %}

{% include k2-llm-judge/fa-03-blueprint-and-references.md %}
