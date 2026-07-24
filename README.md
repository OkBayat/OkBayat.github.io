# okbayat.com — Content Architecture and Editorial Guide

This document defines how content on **okbayat.com** is organized, described, reviewed, and revised. It is the canonical guide for the site's navigation, editorial model, publication taxonomy, and maintenance rules. Update it whenever any of those systems changes.

## 1. Purpose of the site

okbayat.com is a durable public record of what Mohammad Bayat is building, studying, testing, observing, and revising.

The work has two connected bodies:

1. **Building systems and organizations** — quantitative systems, software engineering, artificial intelligence, agent systems, K2Quant, company-building, technical decisions, operating systems, and bounded social-impact initiatives.
2. **Studying human learning and transformation** — learning, memory, language, identity, context, performance, leadership, group coordination, relationships, and quality of life.

The site is not a stream of promotional posts and does not present open questions as settled answers. It should help a reader distinguish among:

- original argument and interpretation;
- published evidence;
- working questions and hypotheses;
- field observations and participant self-reports;
- software and organizational work that exists in practice;
- formal experiments, when an appropriate method exists;
- limitations, uncertainty, failure, and revision.

## 2. Editorial principles

### State only what can be supported

Do not use titles or claims that are larger than the work. In particular:

- Do not describe a working note or field observation as a scientific paper.
- Do not describe a program, product feature, or participant account as a validated intervention.
- Do not claim permanent learning, mastery, cognitive improvement, or durable transformation from short-term activity or self-report.
- Do not use words such as *groundbreaking*, *revolutionary*, or *proven* without evidence that supports that exact claim.

### Separate evidence from interpretation

A page should make clear which statements come from published sources, which are Mohammad's current interpretation, which are direct observations, and which remain open questions.

### Publish questions as complete work

A question does not need a final answer before it can be published, but the public page should stand on its own as a complete essay or note. Its scope, importance, current evidence, and uncertainty should be visible without turning the page into a status update, research queue, or future study plan.

### Treat revision as part of the work

Revise the current canonical page in place as evidence, experience, or editorial judgment changes. Do not create archival copies, legacy versions, or duplicate pages merely to preserve earlier wording. If material remains useful, update it; if it is no longer useful, delete it. Use `last_modified_date`, a status label, a research log, or a revision history only when it helps readers understand the current work.

### Separate inquiry from promotion

Program records explain what a program is, where it came from, how it has been run, what has been observed, and what has not been demonstrated. Dates, prices, capacity, and registration calls belong on a current operational page and must not be mixed with research claims.

### Publish articles with complete metadata and in-page navigation

Every published article-like page must satisfy the metadata, language, SEO, and table-of-contents rules in this guide. Missing required front matter or a missing in-page table of contents blocks publication.

### Format code and technical identifiers explicitly

Code is always rendered left-to-right, including inside Persian pages. Use inline code for identifiers, paths, commands, field names, and other short technical tokens inside prose. Use a fenced code block for multi-line code, pseudocode, terminal output, or a standalone sequence of technical identifiers such as pass names or role names. Do not imitate a code block with unformatted ASCII-only lines and do not rely on the page direction to keep technical text readable.

### Keep navigation structured

Only durable section hubs belong in the global sidebar. Detailed concepts, old cohorts, course records, and individual notes may use `nav_exclude: true` and remain accessible through their canonical index, topical indexes, internal links, and search.

Each section must have only one navigation page. Do not keep two pages with the same `title` and `permalink`.

Use only `parent` to declare a page's immediate parent. The theme resolves the rest of the hierarchy from the parent chain, so page front matter must never include `grand_parent`.

Do not add `has_children: true` to page front matter. The theme derives child relationships automatically from `parent`, so `has_children` is redundant and must never be used.

Parent pages with child pages already receive an automatically generated child-page table of contents from the theme. Do not add a manual `Explore` or `Table of Contents` section that repeats those links.

## 3. The two-axis publication architecture

The site organizes writing on two independent axes. They answer different questions and must not be collapsed into one hierarchy.

### Axis 1: content type determines the canonical home

Content type describes authorship, evidence status, and the relationship between the page and its sources:

- Essay
- Research Note
- Reading Note
- Translation
- Project Record
- Program Record
- Experiment Report

A software essay and a relationship essay are both Essays when their main contribution is Mohammad's original argument. A startup book note remains a Reading Note because it depends on a specific source. A translated AI article remains a Translation because its authorship belongs to another writer.

### Axis 2: body of work and theme determine discovery

A canonical page may be linked from one or more topical lenses:

- All Writing
- Selected Research-Related Work
- essay topic indexes
- project indexes
- Vocora Publications & Notes
- future project- or series-specific indexes when enough durable work exists

Cross-listing is intentional. It creates several ways to find one work without copying its text or creating competing URLs.

### One conceptual work, one registry entry

`_data/publications.yml` is the machine-readable registry for canonical written works. It currently covers Essays, Research Notes, Reading Notes, and Translations.

Each conceptual work appears exactly once and declares:

```yaml
- id: stable-work-id
  content_type: essay
  primary_body: building
  bodies_of_work:
    - building
  themes:
    - software-ai-agent-systems
  project: k2quant
  summary: A concise description used by publication indexes.
  editions:
    - lang: en
      label: English
      title: Canonical page title
      url: /canonical/url
```

Project Records, Program Records, and Experiment Reports remain indexed manually until their volume justifies extending the registry. They still follow the same one-page and topical-index principles.

### Bilingual and multilingual works

Persian and English editions of the same conceptual work belong under one registry entry. Each edition keeps its own URL, language metadata, title, and page content. Index pages display them as language choices for one work rather than as unrelated publications.

The site does not maintain separate Persian and English versions of the entire navigation. A language switch appears only when a particular work has a real paired edition. Pages with one language remain independent and do not create a global language choice in the header or footer.

The sidebar language switch and paired breadcrumbs are determined exclusively by source filenames. A bilingual pair must be stored in the same directory and use the exact same filename stem:

- `<stem>-en.md` for the English edition;
- `<stem>-fa.md` for the Persian edition.

The English file is the primary navigation row. The Persian file appears as its `FA` switch and is not rendered as a separate row. `translation_key`, `lang`, and publication-registry metadata do not participate in discovering the pair. Files that do not follow the exact matching filename convention are treated as independent pages.

Canonical URLs remain controlled by each page's `permalink`; renaming a source file to satisfy the bilingual filename convention must not change a stable public URL.

Before merging a bilingual publication, inspect both generated pages and confirm one bilingual sidebar row, one `FA` link, no standalone Persian duplicate, and a complete breadcrumb chain in both languages.

### Controlled body-of-work identifiers

Use only these body identifiers unless this guide is revised:

- `building`
- `human-transformation`

A work may belong to both. `primary_body` determines its primary grouping in type indexes; `bodies_of_work` determines all topical indexes where it may appear.

### Controlled theme identifiers

Use focused, durable themes rather than creating a tag for every phrase:

- `software-ai-agent-systems`
- `entrepreneurship-company-building`
- `systems-operations-decision-making`
- `project-reflections-social-impact`
- `learning-memory-language`
- `leadership-identity-coordination`
- `relationships-acceptance`
- `philosophy-worldview`

A work may use several themes. Add a new controlled theme only when multiple durable works require a distinction that the existing vocabulary cannot express clearly.

### Categories, tags, and taxonomy fields serve different jobs

- `categories` describe canonical site structure and content type, such as `writing` and `essays`, or `research` and `research-notes`.
- `tags` describe the specific subject of one page for SEO and search.
- `bodies_of_work` and `themes` in the central registry control curated discovery across the site.
- `project`, `program`, and `translation_key` record durable relationships when applicable.

Do not use tags as a substitute for publication architecture.

## 4. Canonical navigation

```text
Home

About
├── Biography
├── Professional Journey
├── Mastery
├── Values
└── Resume

Research
├── Research Profile
├── Selected Research-Related Work
├── Methods, Ethics & Evidence
├── Research Notes
└── Timeline

Leadership & Learning
├── Perspective
├── Leadership
│   └── Resources
├── Human Transformation
│   ├── Field Projects
│   │   └── Learning Circle
│   ├── Practice & Programs
│   │   └── Mastery for Life
│   └── Source Library
├── Learning & Facilitation
│   └── Coaching
└── Courses

Projects
├── K2Quant
├── Vocora
│   └── Publications & Notes
├── K2 OS
├── FamilyLink
└── Experiments

Writing & Media
├── Essays
│   ├── Artificial Intelligence
│   ├── Software & Agentic Systems
│   ├── Startups & Entrepreneurship
│   ├── Leadership & Organizations
│   └── Learning & Human Transformation
├── Reading Notes
├── Translations
├── Podcast
│   └── Inja-Anja
└── All Writing

Contact
└── Schedule a Meeting
```

The footer provides secondary discovery links to All Writing, Reading Notes, Translations, Podcast, Archive, rights and licensing, and public profiles. It does not contain a global language selector.

### Why Research and Writing are separate

Research answers: **What question is being pursued, with what method, evidence, ethical boundary, and uncertainty?**

Writing & Media answers: **What kind of authored or source-dependent work is this?** Essays, Reading Notes, Translations, and audio work remain distinct. Research Notes live under Research because their status and evidence boundaries are part of the research portfolio.

### Why Leadership & Learning is separate from Research

Leadership & Learning contains practice: leadership material, coaching, facilitation, courses, programs, and the Human Transformation archive. Research may draw questions from those settings, but practice records and participant accounts do not become research evidence merely by moving into a research-facing site.

### Why projects have their own section

Projects documents work Mohammad founded, built, or directly led. Client organizations and products he does not own are not presented as personal projects.

- **K2Quant** is the main company-building and quantitative-systems work.
- **Vocora** is an independent research-and-building project about learning, memory, language practice, and learning technology.

K2 OS and FamilyLink are bounded project records. Projects may be active, paused, completed, discontinued, or inconclusive. `Experiments` is reserved for explicit protocols and results.

## 5. Content types

### Essays

Original long-form arguments, interpretations, and syntheses written by Mohammad Bayat. An essay should not be used for a direct translation, a source summary, or an unfinished collection of notes.

An Essay may be labelled **Retrospective Practitioner Reflection** when its primary contribution is a critical examination of Mohammad's own past practice. That subtype must not turn participant messages, private writing, course artifacts, or remembered cases into research data without a prior consent basis. It should distinguish professional recollection from evidence, state role and power conflicts, and use the retrospective account to refine practice or design a prospective inquiry.

Essays remain together under `/writing/essays`. Topic pages such as Artificial Intelligence or Startups & Entrepreneurship are discovery indexes; they do not copy articles or create competing canonical URLs.

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

### Inquiry Notes

A bounded examination of a question that is not yet ready for a full evidence review. It should state what is being asked, why it matters, what evidence is currently available, and what remains uncertain. It must read as a complete note rather than a status update or future research plan.

### Field Notes

A structured account of something observed in a class, program, coaching relationship, organization, product, or group. A field note must distinguish direct observation from participant report and interpretation. It must not imply causality without an appropriate comparison and method.

### Reading Notes

Notes, interpretations, disagreements, and questions developed while reading a specific book, paper, talk, or source. These pages must distinguish the source author's position from Mohammad's interpretation.

### Translations

Translations or adaptations of work written by someone else. Every page must name the original author, original title and source, translator or adapter, and whether the page is a complete translation, selected translation, summary, or adaptation. Commentary added by Mohammad must be labelled.

### Project Records

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
- limitations and what cannot be concluded.

### Experiment Reports

Reports with an explicit question, hypothesis, method, participants or dataset, comparison, predeclared metrics, results, limitations, and ethics. Only completed or inconclusive reports belong on the public site; planned studies and in-progress experiment logs remain internal.

## 6. Publishing models

### Essays publishing model

- `/writing/essays/...` is the canonical home for original arguments and synthesis.
- `/writing/essays` groups works by primary body and durable theme;
- `/writing/essays/topics/...` provides subject discovery without copying articles;
- bilingual editions appear as one conceptual work with multiple language links.
- All Writing, Selected Research-Related Work, and project indexes may cross-list the same essay.

### Research publishing model

- `/research` — research portfolio overview;
- `/research/profile` — practitioner-researcher identity and position;
- `/research/publications` — selected published and documented research-related work;
- `/research/methods-ethics-evidence` — public evidence and participant-protection standard;
- `/research/notes/...` — canonical research, field, literature, and design notes and reviews;
- `/research/timeline` — chronological archive of registered published work.

### Projects publishing model

- `/projects` — portfolio of work built or directly led by Mohammad;
- `/projects/k2quant` — K2Quant overview and related writing;
- `/projects/vocora` — Vocora overview and current state;
- `/projects/k2-os` — K2 OS project record;
- `/projects/familylink` — FamilyLink project record;
- `/projects/experiments` — protocols and results when formal experiments exist;
- `/writing/all` — complete discovery index for writing and durable records.

### Leadership & Learning publishing model

- `/leadership-learning` — practice overview;
- `/leadership-learning/leadership` — leadership practice and source material;
- `/leadership-learning/human-transformation` — Human Transformation practice archive;
- `/leadership-learning/learning-facilitation` — facilitation, coaching, and learner-ownership questions;
- `/leadership-learning/courses` — current and historical course records.

Practice pages may link to Research and Writing, but do not duplicate those canonical works.

### Vocora publishing model

Vocora content is distributed by type, with one canonical home for each page:

- `/projects/vocora` — project overview and current state;
- `/projects/vocora/publications` — curated project index;
- `/research/notes/...` — research and design notes;
- `/writing/translations/...` — translated work, even when an older stable permalink does not mirror the current folder;
- `/projects/experiments/...` — protocols and results when formal experiments exist.

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

## 9. Article metadata, taxonomy, SEO, and table of contents

The rules in this section are mandatory for every published article-like page: Essays, Research Notes, Reading Notes, Translations, Project Records, Field Notes, Program Records, and Experiment Reports. They do not apply to section indexes, navigation pages, or short utility pages.

### Required front matter

Every article must include:

- a unique, accurate `title` in the article's primary language;
- a specific, natural-language `description` that summarizes the page in one sentence and does not merely repeat the title;
- `author`, plus `translator` for translated or adapted work;
- `date` for first publication when known;
- `date_modified` for SEO metadata and `last_modified_date` for the theme; update both when the article changes materially;
- `direction`, `lang`, and `locale`;
- `seo.type: Article`;
- one canonical `permalink` and `sitemap: true`;
- canonical `categories` for site structure;
- three to eight focused `tags` that describe the actual subject of the article.

Add content-type fields such as `status`, `project`, `program`, `note_type`, `evidence_level`, `privacy`, `translation_key`, or `image` when they apply. Declare only the immediate `parent`; never repeat higher levels of the hierarchy with `grand_parent`.

Add `image` when a relevant social-sharing image exists. Do not use an irrelevant placeholder image. Do not add `<meta name="keywords">`; front matter `tags` must not be used for keyword stuffing.

| Article language | `direction` | `lang` | `locale` | `title`, `description`, and topical `tags` |
|---|---|---|---|---|
| Persian | `rtl` | `fa` | `fa_IR` | Persian |
| English | `ltr` | `en` | `en_US` | English |

`locale` is used by `jekyll-seo-tag` for locale-specific SEO metadata and takes priority over `lang`. Keep both fields present because they serve different consumers.

### Publication registry requirement

Before a canonical Essay, Research Note, Reading Note, or Translation is published, add or update its entry in `_data/publications.yml`.

Validation must confirm:

- every registered `id` is unique;
- every canonical edition URL is unique;
- every `content_type`, body identifier, and theme identifier is supported;
- every registry URL resolves to a published page;
- every published canonical written work is represented exactly once;
- language editions of one conceptual work share one registry entry;
- index pages do not hard-code a second competing classification for the same work.

### Content labels

Use a content label near the beginning of a page when readers could otherwise misunderstand its status:

- Essay
- Essay · Retrospective Practitioner Reflection
- Inquiry Note
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

The table of contents belongs **after the introduction or summary and before the first main section**. `{:toc}` may appear only once on a page. To omit a heading from the generated table of contents, place `{: .no_toc }` immediately after that heading. Never maintain a manual list of heading links when the generated table of contents can be used.

## 10. URL, navigation, and language rules

- Every page has one current canonical URL.
- When a URL changes, update its `permalink`, the publication registry, and every internal reference in the same change.
- Never retain an old URL through a redirect, transition page, legacy page, duplicate page, or compatibility path.
- Do not change a stable URL merely to make its path mirror a new taxonomy. Canonical type, parent, categories, and indexes can change without unnecessary URL churn.
- Edit useful content in place and delete obsolete content; do not create archives merely to preserve previous versions.
- Keep section indexes in the sidebar and detailed pages out of it unless they are intentionally featured.
- Use one primary language per page and set `direction`, `lang`, and `locale` accordingly.
- Central hub pages may link to Persian and English material; do not switch language mid-paragraph without a clear reason.
- A translated page must not be presented as Mohammad's original argument.

## 11. Maintenance checklist

Before publishing or merging a structural change:

1. Confirm that every `parent` matches the immediate parent page's `title` exactly.
2. Confirm that page front matter contains neither `grand_parent` nor `has_children`.
3. Confirm that each section has only one navigation page and that no two pages share the same permalink.
4. Confirm that every registered work and edition has a unique ID and URL.
5. Confirm that every canonical Essay, Research Note, Reading Note, and Translation is represented once in `_data/publications.yml`.
6. Confirm that bilingual editions share one conceptual registry entry, use exact matching `<stem>-en.md` and `<stem>-fa.md` source filenames, and render as one navigation row.
7. Confirm that all body and theme identifiers come from the controlled vocabulary.
8. Confirm that type indexes group by `primary_body` and topical indexes filter by `bodies_of_work` and `themes`.
9. Confirm that cross-listing links to the canonical page and never copies the article body.
10. When a URL or file path changes, search the entire repository and update every reference to the old value.
11. Confirm that no redirect, transition page, legacy page, duplicate page, or compatibility path preserves an obsolete URL.
12. Confirm that useful material was edited in place and obsolete material was deleted rather than archived.
13. Keep published articles discoverable through their canonical index and relevant topical indexes; use `nav_exclude` only intentionally.
14. Confirm that every article has the required SEO front matter, language values, dates when known, and `seo.type`.
15. Confirm that every article has exactly one generated table of contents after its introduction and before its first main `##` section.
16. Confirm that project pages state current status, evidence basis, operating dependencies, and what has not been demonstrated.
17. Confirm that human-related claims identify evidence level, alternative explanations, and limitations.
18. Confirm that pages involving people satisfy the privacy and consent rules; apply the additional safeguards for children.
19. Check internal links and the Jekyll build.
20. Inspect generated pages, registry-rendered indexes, SEO tags, breadcrumbs, language switches, and the sidebar.
21. Update this guide when navigation, definitions, controlled vocabularies, or evidence standards change.

## 12. Success criteria

The site is succeeding when a reader can quickly understand:

- Mohammad's identity across research, leadership and learning, projects, and writing;
- what he is actually building and studying now;
- which pages are original, translated, exploratory, observed, reported, or tested;
- where a work canonically belongs and which subjects or projects it informs;
- how to browse technical, company-building, human, and cross-disciplinary writing without encountering separate competing archives;
- what evidence supports a claim and what remains uncertain;
- how K2Quant, Vocora, FamilyLink, Learning Circle, leadership practice, and facilitated programs relate without being collapsed into one kind of work;
- how questions, methods, and interpretations change over time.
