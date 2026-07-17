# okbayat.com — Content Architecture and Editorial Guide

This document defines how content on **okbayat.com** is organized and described. It should be updated whenever the site's main navigation or editorial model changes.

## 1. Purpose of the site

okbayat.com documents what Mohammad Bayat is building, studying, testing, and revising.

The site is not intended to be a stream of promotional posts. Its purpose is to keep a durable public record of:

- original thinking and interpretation;
- working research notes;
- books, papers, and translations worth returning to;
- companies, software projects, and experiments;
- professional experience and current interests.

## 2. Editorial principles

### State only what can be supported

Do not use titles or claims that are larger than the work. In particular:

- Do not describe a working note as a scientific paper.
- Do not describe an early product feature as a validated learning intervention.
- Do not claim permanent learning, mastery, or cognitive improvement from short-term product activity.
- Do not use words such as *groundbreaking*, *revolutionary*, or *proven* without clear evidence.

### Separate evidence from interpretation

A page should make clear which statements come from published sources, which are the author's interpretation, and which remain open questions.

### Treat revision as part of the work

Research notes and project pages may change as evidence and experience change. Use `last_modified_date`, a status label, or a revision history where useful.

### Publish articles with complete metadata and in-page navigation

Every published article-like page must satisfy the metadata, language, SEO, and table-of-contents rules in Section 6. Missing required front matter or a missing in-page table of contents blocks publication.

### Keep navigation structured

Published articles should appear under their canonical section in the sidebar. Use `nav_exclude: true` only for drafts, utility pages, redirects, or material that is intentionally unlisted.

Each section must have only one navigation page. Do not keep both an `index.md` file and another section file with the same `title` and `permalink`.

Use only `parent` to declare a page's immediate parent. The theme resolves the rest of the hierarchy from the parent chain, so page front matter must never include `grand_parent`.

Parent pages with child pages already receive an automatically generated child-page table of contents from the theme. Do not add a manual `Explore` or `Table of Contents` section that repeats those links.

## 3. Canonical navigation

```text
Home

Thinking
├── Essays
├── Research Notes
├── Book Notes
└── Translations

Leadership

Building
├── K2Quant
├── Vocora
│   ├── Research Agenda
│   ├── Publications & Notes
│   └── Research Log
├── Projects
│   └── K2 OS
└── Experiments

Voice

About
├── Biography
├── Resume
├── Current Interests
└── Calendar
```

### Why K2Quant and Vocora are directly under Building

K2Quant and Vocora are ongoing bodies of work rather than bounded side projects:

- **K2Quant** is the main company-building and quantitative-systems work.
- **Vocora** is an independent research-and-building project about learning, memory, language practice, and learning technology.

`Projects` is reserved for more bounded products and systems, such as K2 OS. `Experiments` is reserved for explicit protocols and results.

## 4. Content types

### Essays

Original long-form arguments, interpretations, and syntheses written by Mohammad Bayat.

An essay should not be used for a direct translation, a book summary, or an unfinished collection of notes.

### Research Notes

Working investigations of a question, source, concept, or design decision. A research note may be incomplete and is not assumed to be peer reviewed.

A useful research note normally includes:

- the question;
- why it matters;
- evidence reviewed;
- the current interpretation;
- limitations and uncertainty;
- implications or next questions;
- references.

### Book Notes

Notes, interpretations, and questions developed while reading a specific book. These pages should distinguish the book author's position from Mohammad's interpretation.

### Translations

Translations or adaptations of work written by someone else. Every page must name the original author, source, and translator or adapter. A short editorial note should explain why the text is being included.

### Project Pages

Stable descriptions of real work: what exists, why it is being built, its present status, and what has not yet been demonstrated.

### Experiment Reports

Reports with an explicit question, hypothesis, method, metrics, results, limitations, and status. `Planned`, `Running`, `Completed`, and `Inconclusive` are all acceptable statuses.

## 5. Vocora publishing model

Vocora content is distributed by type, with one canonical home for each page:

- `/building/vocora` — project overview and current state;
- `/building/vocora/research-agenda` — questions, methods, and boundaries;
- `/building/vocora/publications` — curated index of related output;
- `/building/vocora/research-log` — dated changes in questions, evidence, measurements, and decisions;
- `/thinking/research-notes/...` — research and design notes;
- `/thinking/essays/...` — original essays;
- `/thinking/translations/...` — translated work;
- `/building/experiments/...` — protocols and results when formal experiments exist.

The publications page links to these items; it does not duplicate them.

## 6. Article metadata, SEO, and table of contents

The rules in this section are mandatory for every published article-like page: Essays, Research Notes, Book Notes, Translations, and Experiment Reports. They do not apply to section indexes, navigation pages, redirects, or short utility pages.

### SEO metadata

The shared site head already invokes `jekyll-seo-tag` with `{% seo %}`. Article Markdown must therefore provide complete YAML front matter and must not contain hand-written HTML `<meta>` tags. The plugin uses front matter to generate the page title, meta description, canonical URL, Open Graph and Twitter metadata, and JSON-LD.

Every article must include:

- a unique, accurate `title` in the article's primary language;
- a specific, natural-language `description` that summarizes the page in one sentence and does not merely repeat the title;
- `author`, plus `translator` for translated or adapted work;
- `date` for first publication;
- `date_modified` for SEO metadata and `last_modified_date` for the theme; update both when the article changes materially;
- `direction`, `lang`, and `locale` using the language rules below;
- `seo.type: Article` so article pages are identified as articles in JSON-LD;
- one canonical `permalink` and `sitemap: true`;
- canonical `categories` for site structure;
- three to eight focused `tags` that describe the actual subject of the article.

Add `image` when a relevant social-sharing image exists. Do not use an irrelevant placeholder image. Do not add `<meta name="keywords">`: search engines do not need it, and front matter `tags` must not be used for keyword stuffing.

The article language determines all reader-facing metadata. Product and project names such as `Vocora` and `K2Quant` may retain their canonical spelling.

| Article language | `direction` | `lang` | `locale` | `title`, `description`, and topical `tags` |
|---|---|---|---|---|
| Persian | `rtl` | `fa` | `fa_IR` | Persian |
| English | `ltr` | `en` | `en_US` | English |

`locale` is the value used by `jekyll-seo-tag` for locale-specific SEO metadata and takes priority over `lang`. Keep both fields present because they serve different consumers.

#### Persian front matter example

```yaml
---
layout: default
title: عنوان دقیق و یکتای مقاله
description: "یک توضیح یک‌جمله‌ای دقیق و طبیعی درباره مسئله و محتوای اصلی مقاله."
parent: Essays
direction: rtl
lang: fa
locale: fa_IR
author: Mohammad Bayat
date: 2026-07-17
date_modified: 2026-07-17
last_modified_date: 2026-07-17
seo:
  type: Article
categories:
  - thinking
  - essays
tags:
  - کارآفرینی
  - تصمیم‌گیری
  - سیستم‌سازی
sitemap: true
permalink: /thinking/essays/example
---
```

#### English front matter example

```yaml
---
layout: default
title: A Precise and Unique Article Title
description: "A specific one-sentence summary of the article's central question and contribution."
parent: Essays
direction: ltr
lang: en
locale: en_US
author: Mohammad Bayat
date: 2026-07-17
date_modified: 2026-07-17
last_modified_date: 2026-07-17
seo:
  type: Article
categories:
  - thinking
  - essays
tags:
  - entrepreneurship
  - decision-making
  - systems-building
sitemap: true
permalink: /thinking/essays/example
---
```

Add content-type fields such as `status`, `project`, `translator`, or `image` when they apply. Declare only the immediate `parent`; never repeat higher levels of the hierarchy with `grand_parent`.

Use a content label near the beginning of the page when readers could otherwise misunderstand its status:

- Essay
- Working Research Note
- Literature Review
- Design Note
- Experiment Report
- Translation or Adaptation

### In-page table of contents

Every article must contain exactly one Kramdown-generated in-page table of contents. This is different from the automatic child-page navigation shown on section index pages.

Use this order at the beginning of every article:

1. the page `#` heading, immediately followed by `{: .no_toc }`;
2. an optional subtitle, content label, status block, or source block;
3. a concise introduction, abstract, or editorial note that explains the article's question, value, and scope;
4. the table of contents;
5. the first main `##` section.

The table of contents therefore belongs **after the introduction or summary and before the first main section**. Do not place it before the opening context, at the end of the article, or inside YAML front matter.

Use the following blocks exactly. In particular, do not indent the `1. TOC` or `{:toc}` lines. The `open` attribute is part of the site standard so the table of contents is expanded by default.

#### Persian article

```markdown
# عنوان مقاله
{: .no_toc }

{ زیرعنوان یا برچسب محتوا | fs-6 }

> بلوک وضعیت، نویسنده یا منبع در صورت نیاز

یک یا چند پاراگراف مقدمه یا خلاصه که مسئله، ارزش و محدوده متن را روشن می‌کند.

<details open markdown="block">
  <summary>
    فهرست مطالب
  </summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

## بخش اول
```

#### English article

```markdown
# Article title
{: .no_toc }

{ Subtitle or content label | fs-6 }

> Status, author, or source block when needed

One or more opening paragraphs that explain the article's question, value, and scope.

<details open markdown="block">
  <summary>
    Table of contents
  </summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

## First section
```

`{:toc}` may appear only once on a page. To omit a heading from the generated table of contents, place `{: .no_toc }` immediately after that heading. Never maintain a manual list of heading links when the generated table of contents can be used.

## 7. Source and evidence rules

- Prefer primary papers, systematic reviews, meta-analyses, and official documentation.
- Link to the original source whenever possible.
- Do not turn a general finding into a claim that the current product has already produced that effect.
- State when a conclusion is an inference.
- Include limitations when evidence is narrow, indirect, or disputed.
- Preserve the distinction between short-term task performance and durable learning.

## 8. Maintenance checklist

Before publishing or merging a structural change:

1. Confirm that every `parent` matches the immediate parent page's `title` exactly.
2. Confirm that page front matter does not contain `grand_parent`; the theme resolves ancestors from the parent chain.
3. Confirm that each section has only one navigation page and that no two pages share the same permalink.
4. Keep published articles visible under their canonical section; use `nav_exclude` only for intentional exclusions.
5. Confirm that every article has the required SEO front matter, including the correct `direction`, `lang`, `locale`, `date_modified`, `last_modified_date`, and `seo.type` values.
6. Confirm that every article has exactly one generated table of contents after its introduction and before its first main `##` section.
7. Check internal links and the Jekyll build.
8. Inspect the generated page, including the table of contents and the SEO tags in `<head>`.
9. Review the generated sidebar, not only the source files.
10. Update this guide when navigation or definitions change.

## 9. Success criteria

The site is succeeding when a reader can quickly understand:

- what Mohammad is actually working on;
- which pages are original, translated, exploratory, or tested;
- what evidence supports a claim;
- what remains uncertain;
- how the work changes over time.
