---
layout: default
title: What Should Vocora Measure as Learning?
description: "A working note on separating practice activity, current performance, and longer-term retention in Vocora."
parent: Research Notes
nav_exclude: true
direction: ltr
lang: en
locale: en_US
author: Mohammad Bayat
date: 2026-07-17
last_modified_date: 2026-07-17
status: working-note
project: vocora
permalink: /thinking/research-notes/vocora-learning-metrics
categories:
  - thinking
  - research-notes
tags:
  - vocora
  - learning
  - memory
  - retrieval-practice
  - spaced-practice
  - measurement
sitemap: true
---

# What Should Vocora Measure as Learning?
{: .no_toc }

{ Working Research and Design Note · Vocora | fs-6 }

> **Status:** Working note, not peer reviewed  
> **Project:** [Vocora](/building/vocora)  
> **Last revised:** July 17, 2026

## The Question

A learning application can count many things: sessions, answers, time, streaks, completed reviews, and items that move to a later box. None of those numbers is automatically equivalent to learning.

The question for Vocora is:

> Which measures describe what the user actually did, which measures describe current task performance, and which measures can support a cautious inference about longer-term retention?

This distinction matters because product language can easily become stronger than the underlying data.

## Three Different Kinds of Measurement

### 1. Practice activity

These metrics describe behavior inside the product:

- reviews completed;
- active practice days;
- due reviews completed within a defined period;
- words encountered or retrieved;
- selected weekly goal completion.

They can describe consistency and workload. They do not show that an item will be remembered later.

### 2. Current performance

These metrics describe responses during a session:

- correct answers;
- accuracy;
- number of attempts;
- spelling errors;
- successful promotion to a later Leitner box.

They are useful for feedback and scheduling. However, a correct answer immediately after study may reflect temporary accessibility rather than durable retention.

### 3. Retention over time

A stronger learning measure requires a delay between practice and assessment. Examples include:

- successful unaided recall after a defined interval;
- recall after an item has not been shown recently;
- repeated success across separated days;
- performance on a transfer task that is meaningfully different from the practice prompt.

Vocora does not yet have a validated retention outcome. Defining one is a near-term research task.

## What Existing Evidence Suggests

Research on retrieval practice shows that attempting to retrieve information can improve later recall compared with repeated study in the tasks examined. A frequently cited experiment by Karpicke and Roediger found large delayed-recall benefits from repeated testing of foreign-language vocabulary, while additional study after successful learning did not produce the same effect in that experiment.

Research on distributed practice also indicates that spacing study or practice episodes can improve later retention compared with massed repetition. A large meta-analysis by Cepeda and colleagues found that the useful spacing interval depends partly on the intended retention interval.

These findings support using retrieval and spacing as design inputs. They do **not** demonstrate that every retrieval schedule is effective, that the Leitner system is optimal, or that the current Vocora implementation has produced the same outcomes.

## Current Vocora Metrics

The current application can calculate several honest product measures:

| Metric | What it describes | What it does not establish |
|---|---|---|
| Reviews today | Recorded answer attempts today | Learning or mastery |
| Correct answers today | Correct responses in today's sessions | Future recall |
| Accuracy today | Correct responses divided by attempts | Stable ability when the sample is small |
| Words strengthened today | Unique words promoted during the day | Permanent memory |
| Words in box 5 | Current scheduler state | Guaranteed long-term retention |
| Active days | Days with at least one real answer | Quality of practice |
| Current streak | Consecutive active days | Motivation, well-being, or learning quality |

Product copy should use these narrow descriptions. For example, “words strengthened today” is preferable to “words permanently learned.”

## Guardrails

Vocora currently applies several measurement and communication constraints:

- Low accuracy should not become a public comparison signal.
- A progress card should not include email, typed answers, difficult-word names, or detailed errors.
- Sharing should be optional and reviewed by the user before leaving the product.
- Opening the application is not counted as an active learning day; at least one answer is required.
- A broken streak should not erase total practice history or be used to shame the learner.
- Engagement should not be optimized without checking learning and well-being guardrails.

## What Needs to Be Added

The next useful measurement work is not another engagement counter. It is a clearer delayed-recall design.

A first protocol could specify:

1. a group of eligible words;
2. a fixed practice method;
3. a delay with no exposure to the test items;
4. an unaided spelling-recall test;
5. a predeclared primary outcome;
6. missing-data and retry rules;
7. a comparison or baseline;
8. limitations on generalization.

Until such a measure is implemented and evaluated, Vocora should describe box movement and session accuracy as scheduler and performance data, not as proof of durable learning.

## Current Interpretation

Retrieval and spacing are reasonable foundations for the product, but the scientific quality of Vocora will depend less on naming those ideas and more on how carefully the implementation, measurement, comparison, and limitations are documented.

The practical standard is simple:

> Every number shown to the user should mean exactly what its label says—and no more.

## References

- Karpicke, J. D., & Roediger, H. L. (2008). [The Critical Importance of Retrieval for Learning](https://doi.org/10.1126/science.1152408). *Science, 319*(5865), 966–968.
- Cepeda, N. J., Pashler, H., Vul, E., Wixted, J. T., & Rohrer, D. (2006). [Distributed Practice in Verbal Recall Tasks: A Review and Quantitative Synthesis](https://pubmed.ncbi.nlm.nih.gov/16719566/). *Psychological Bulletin, 132*(3), 354–380.
- Ryan, R. M., & Deci, E. L. (2020). [Intrinsic and extrinsic motivation from a self-determination theory perspective](https://selfdeterminationtheory.org/wp-content/uploads/2020/04/2020_RyanDeci_CEP_PrePrint.pdf). *Contemporary Educational Psychology, 61*.
- [Vocora Gamification and Sharing Principles](https://github.com/OkBayat/vocora/blob/main/docs/GAMIFICATION.md).

## Revision History

- **July 17, 2026:** First published.
