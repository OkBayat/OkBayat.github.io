# okbayat.com — Content Architecture and Editorial Guide

This document defines how content on **okbayat.com** is organized, described, reviewed, and revised. It is the canonical guide for the site's navigation and editorial model and must be updated whenever either changes.

## 1. Purpose of the site

okbayat.com is a durable public record of what Mohammad Bayat is building, studying, testing, observing, and revising.

The work has two connected bodies:

1. **Building systems and organizations** — quantitative systems, software engineering, artificial intelligence, K2Quant, company-building, technical decisions, operating systems, and bounded social-impact initiatives.
2. **Studying human learning and transformation** — learning, memory, language, identity, context, performance, leadership, group coordination, and quality of life.

The site is not a stream of promotional posts and does not present open questions as settled answers. It should help a reader distinguish among:

- original argument and interpretation;
- published evidence;
- working questions and hypotheses;
- field observations and participant self-reports;
- software and organizational work that exists in practice;
- formal experiments, when an appropriate method exists;
- limitations, uncertainty, and revisions.

## 2. Editorial principles

### State only what can be supported

Do not use titles or claims that are larger than the work. In particular:

- Do not describe a working note or field observation as a scientific paper.
- Do not describe a program, product feature, or participant account as a validated intervention.
- Do not claim permanent learning, mastery, cognitive improvement, or durable transformation from short-term activity or self-report.
- Do not use words such as *groundbreaking*, *revolutionary*, or *proven* without evidence that supports that exact claim.

### Separate evidence from interpretation

A page should make clear which statements come from published sources, which are Mohammad's current interpretation, which are direct observations, and which remain open questions.

### Keep questions publishable

A question does not need a final answer before it can be published. An open question is useful when its scope, importance, current evidence, uncertainty, and next step are visible.

### Treat revision as part of the work

Research notes, agendas, field records, and project pages may change as evidence and experience change. Use `last_modified_date`, a status label, a research log, or a revision history where useful.

### Separate inquiry from promotion

Program records explain what a program is, where it came from, how it has been run, what has been observed, and what has not been demonstrated. Dates, prices, capacity, and registration calls belong on a current operational page and must not be mixed with research claims.

### Publish articles with complete metadata and in-page navigation

Every published article-like page must satisfy the metadata, language, SEO, and table-of-contents rules in Section 9. Missing required front matter or a missing in-page table of contents blocks publication.

### Keep navigation structured

Only durable section hubs belong in the global sidebar. Detailed concepts, old cohorts, course records, individual notes, and archive pages may use `nav_exclude: true` and remain accessible through their canonical index, internal links, and search.

Each section must have only one navigation page. Do not keep two pages with the same `title` and `permalink`.

Use only `parent` to declare a page's immediate parent. The theme resolves the rest of the hierarchy from the parent chain, so page front matter must never include `grand_parent`.

Parent pages with child pages already receive an automatically generated child-page table of contents from the theme. Do not add a manual `Explore` or `Table of Contents` section that repeats those links.

## 3. Canonical navigation

```text
Home

Thinking
├── Essays
├── Research Notes
├── Reading Notes
└── Translations

Human Transformation
├── Research Agenda
├── Field Projects
│   └── K2-Kids
├── Practice & Programs
│   └── Mastery for Life
├── Leadership
├── Source Library
├── Publications & Notes
└── Research Log

Building
├── K2Quant
├── Vocora
│   ├── Research Agenda
│   ├── Publications & Notes
│   └── Research Log
├── Projects
│   ├── K2 OS
│   └── FamilyLink
└── Experiments

Podcast
└── Inja-Anja

About
├── Biography
├── Resume
├── Current Work
└── Contact
```

### Why Human Transformation is separate from Leadership

Leadership is one setting in which questions about language, identity, context, performance, and durable change appear. It is not broad enough to contain the full inquiry. Human Transformation is therefore the parent program; Leadership remains a substantial subdomain with its existing resources, programs, coaching material, and field notes.

### Why K2Quant and Vocora are under Building

K2Quant and Vocora are ongoing bodies of work rather than bounded side projects:

- **K2Quant** is the main company-building and quantitative-systems work.
- **Vocora** is an independent research-and-building project about learning, memory, language practice, and learning technology.

`Projects` is reserved for more bounded products, systems, organizations, and initiatives with a distinct scope and operating history, such as K2 OS and FamilyLink. Projects may be active, paused, completed, discontinued, or inconclusive. `Experiments` is reserved for explicit protocols and results.

### Reading Notes and the legacy Book Notes path

`Reading Notes` is the user-facing section for notes developed from books, papers, talks, and other identifiable sources. The existing `/thinking/book-notes` path remains available as a legacy book-specific archive so old URLs and parent relationships are not broken.

## 4. Content types

### Essays

Original long-form arguments, interpretations, and syntheses written by Mohammad Bayat. An essay should not be used for a direct translation, a source summary, or an unfinished collection of notes.

### Research Notes

Working investigations of a question, source, concept, observation, or design decision. A research note may be incomplete and is not assumed to be peer reviewed.

A useful research note normally includes:

- the question;
- why it matters;
- evidence or observations reviewed;
- the current interpretation;
- alternative explanations;
- limitations and uncertainty;
- implications or next questions;
- references, where applicable.

### Open Questions

A short record of a question that is active but not yet ready for a full evidence review. It should state what is being asked, why it matters, what would change the current view, and the next useful step.

### Field Notes

A structured account of something observed in a class, program, coaching relationship, organization, product, or group. A field note must distinguish direct observation from participant report and interpretation. It must not imply causality without an appropriate comparison and method.

### Reading Notes

Notes, interpretations, disagreements, and questions developed while reading a specific book, paper, talk, or source. These pages must distinguish the source author's position from Mohammad's interpretation.

### Translations

Translations or adaptations of work written by someone else. Every page must name the original author, original title and source, translator or adapter, and whether the page is a complete translation, selected translation, summary, or adaptation. Commentary added by Mohammad must be labelled.

### Project Pages

Stable descriptions of real work: what existed or exists, why it was built, its operating model, present status, evidence basis, current questions, limitations, and what has not been demonstrated.

Accepted project-status labels include **Planned**, **Active**, **Paused**, **Completed**, **Discontinued**, and **Inconclusive**. A paused, completed, discontinued, or unsuccessful project may remain important enough to publish when its record clarifies execution, decisions, evidence, failure modes, and lessons. The page must not imply that a paused or discontinued project is currently operating.

A durable project record should normally include:

- purpose, scope, and approximate operating period;
- the author's role and relevant partners;
- what was built or delivered;
- funding and operating dependencies;
- the evidence supporting any scale or outcome claim;
- what was not measured or demonstrated;
- current status and the reason for it;
- privacy, consent, safeguarding, or conflict-of-role issues where relevant;
- conditions for continuation, restart, transfer, or closure.

### Program Records

Durable descriptions of a facilitated program or recurring practice. A program record should document:

- origin and source lineage;
- purpose and questions;
- format and history;
- current evidence and observations;
- participant reports, clearly labelled as self-report;
- limitations and what cannot be concluded;
- revisions and future evaluation plans.

### Experiment Reports

Reports with an explicit question, hypothesis, method, participants or dataset, comparison, predeclared metrics, results, limitations, ethics, and status. `Planned`, `Running`, `Completed`, and `Inconclusive` are all acceptable statuses.

## 5. Human Transformation publishing model

Human Transformation is a cross-cutting inquiry rather than a claim that a complete theory of human change already exists.

Each page has one canonical home:

- `/human-transformation` — program overview and boundaries;
- `/human-transformation/research-agenda` — active questions and their status;
- `/human-transformation/field-projects` — index of practice-based field projects;
- `/human-transformation/practice-programs` — index of durable program records;
- `/human-transformation/source-library` — source lineage and concept-library index;
- `/human-transformation/publications` — curated index of related output;
- `/human-transformation/research-log` — dated changes in questions, evidence, methods, and interpretations;
- `/thinking/research-notes/...` — canonical research, field, literature, and design notes;
- `/thinking/essays/...` — original arguments and synthesis;
- `/thinking/reading-notes/...` — source-specific reading notes;
- `/thinking/translations/...` — translated or adapted work;
- `/building/experiments/...` — protocols and results when formal experiments exist.

The publications page links to canonical pages; it does not duplicate them.

## 6. Vocora publishing model

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

## 7. Evidence language

### Use explicit evidence layers

Human-related pages should identify the strongest available layer:

1. **Published evidence** — a claim reported by an identifiable source.
2. **Direct observation** — behavior or events recorded by the author.
3. **Participant self-report** — an experience described by a participant.
4. **Current interpretation** — the author's present explanation or synthesis.
5. **Hypothesis or open question** — an idea not yet established.

A stronger layer must not be inferred automatically from a weaker one. Repeated self-report is still self-report; a compelling observation is still not a controlled causal result.

### Use neuroscience terms carefully

Behavioral observation, subjective experience, and a proposed neural explanation are different claims. Do not say a phrase, class, or product has changed neural pathways unless an appropriate neuroscientific measure and study design support that statement. Prefer language such as “may change attention,” “is being examined as a framing effect,” or “a possible mechanism discussed in the literature” when that is the actual evidence level.

### Distinguish performance from durable change

Immediate performance, behavior inside a supportive context, delayed learning, transfer to another setting, identity change, and durable transformation are different outcomes and must be measured and described separately.

### Treat testimonials as participant accounts

Testimonials may preserve meaningful first-person experience, but they are not controlled evidence of efficacy. Pages containing testimonials must label them as self-reported accounts and must not convert them into causal or universal claims.

## 8. Human-participant ethics and privacy

Practice-based inquiry involving people requires proportionate safeguards even when it is not an academic study.

- Collect and publish only information needed for the stated purpose.
- Do not publish private coaching, family, health, or relationship details without clear permission.
- Use anonymized or aggregated records by default.
- Make it possible for a participant to request correction or removal of an identifiable account.
- Do not present participation in a course, workplace, or mentorship relationship as automatic consent to publication.
- State conflicts of role when the author is simultaneously facilitator, manager, coach, relative, product owner, or evaluator.

### Additional safeguards for children

Pages involving minors must:

- avoid names, identifiable certificates, school details, and unnecessary images;
- obtain parent or guardian permission before identifiable publication;
- seek the child's age-appropriate assent as well as adult permission;
- distinguish education and mentorship from research participation;
- avoid public ranking and permanent performance labels;
- report group-level observations where possible;
- acknowledge selection effects, maturation, family relationships, and observer bias.

## 9. Article metadata, SEO, and table of contents

The rules in this section are mandatory for every published article-like page: Essays, Research Notes, Reading Notes, Translations, Project Pages, Field Notes, Program Records, and Experiment Reports. They do not apply to section indexes, navigation pages, redirects, or short utility pages.

### SEO metadata

The shared site head invokes `jekyll-seo-tag` with `{% seo %}`. Article Markdown must therefore provide complete YAML front matter and must not contain hand-written HTML `<meta>` tags.

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

Add `image` when a relevant social-sharing image exists. Do not use an irrelevant placeholder image. Do not add `<meta name="keywords">`; front matter `tags` must not be used for keyword stuffing.

| Article language | `direction` | `lang` | `locale` | `title`, `description`, and topical `tags` |
|---|---|---|---|---|
| Persian | `rtl` | `fa` | `fa_IR` | Persian |
| English | `ltr` | `en` | `en_US` | English |

`locale` is used by `jekyll-seo-tag` for locale-specific SEO metadata and takes priority over `lang`. Keep both fields present because they serve different consumers.

#### Persian front matter example

```yaml
---
layout: default
title: عنوان دقیق و یکتای مقاله
description: "یک توضیح یک‌جمله‌ای دقیق و طبیعی درباره مسئله و محتوای اصلی مقاله."
parent: Research Notes
direction: rtl
lang: fa
locale: fa_IR
author: Mohammad Bayat
date: 2026-07-17
date_modified: 2026-07-17
last_modified_date: 2026-07-17
status: working-note
seo:
  type: Article
categories:
  - thinking
  - research-notes
tags:
  - یادگیری
  - زبان
  - تحول
sitemap: true
permalink: /thinking/research-notes/example
---
```

#### English front matter example

```yaml
---
layout: default
title: A Precise and Unique Article Title
description: "A specific one-sentence summary of the article's central question and contribution."
parent: Research Notes
direction: ltr
lang: en
locale: en_US
author: Mohammad Bayat
date: 2026-07-17
date_modified: 2026-07-17
last_modified_date: 2026-07-17
status: working-note
seo:
  type: Article
categories:
  - thinking
  - research-notes
tags:
  - learning
  - language
  - transformation
sitemap: true
permalink: /thinking/research-notes/example
---
```

Add content-type fields such as `status`, `project`, `program`, `note_type`, `evidence_level`, `privacy`, `translator`, or `image` when they apply. Declare only the immediate `parent`; never repeat higher levels of the hierarchy with `grand_parent`.

Use a content label near the beginning of the page when readers could otherwise misunderstand its status:

- Essay
- Open Question
- Working Research Note
- Field Note
- Literature Review
- Reading Note
- Design Note
- Project Record
- Program Record
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

The table of contents belongs **after the introduction or summary and before the first main section**.

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

## 10. URL, navigation, and language rules

- Preserve an existing permalink whenever the content still represents the same page.
- When a canonical URL changes, add an explicit redirect or transition page before removing the old path.
- Keep section indexes in the sidebar and deep archives out of it unless they are intentionally featured.
- Use one primary language per page and set `direction`, `lang`, and `locale` accordingly.
- Central hub pages may link to Persian and English material; do not switch language mid-paragraph without a clear reason.
- A translated page must not be presented as Mohammad's original argument.

## 11. Maintenance checklist

Before publishing or merging a structural change:

1. Confirm that every `parent` matches the immediate parent page's `title` exactly.
2. Confirm that page front matter does not contain `grand_parent`.
3. Confirm that each section has only one navigation page and that no two pages share the same permalink.
4. Confirm that old paths remain available when canonical URLs change.
5. Keep published articles discoverable through their canonical index; use `nav_exclude` only intentionally.
6. Confirm that every article has the required SEO front matter, language values, dates, and `seo.type`.
7. Confirm that every article has exactly one generated table of contents after its introduction and before its first main `##` section.
8. Confirm that project pages state current status, evidence basis, operating dependencies, and what has not been demonstrated.
9. Confirm that human-related claims identify evidence level, alternative explanations, and limitations.
10. Confirm that pages involving people satisfy the privacy and consent rules; apply the additional safeguards for children.
11. Check internal links and the Jekyll build.
12. Inspect generated pages, SEO tags, redirects, and the sidebar.
13. Update this guide when navigation, definitions, or evidence standards change.

## 12. Success criteria

The site is succeeding when a reader can quickly understand:

- the two main bodies of Mohammad's work;
- what he is actually building and studying now;
- which pages are original, translated, exploratory, observed, reported, or tested;
- what evidence supports a claim and what remains uncertain;
- how K2Quant, Vocora, FamilyLink, K2-Kids, leadership practice, and facilitated programs relate without being collapsed into one kind of work;
- how questions, methods, and interpretations change over time.
