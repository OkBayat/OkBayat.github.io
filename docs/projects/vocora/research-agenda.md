---
layout: default
title: Research Agenda
parent: Vocora
nav_order: 1
direction: ltr
description: "The current questions, methods, evidence standards, and boundaries guiding Vocora."
last_modified_date: 2026-07-17
permalink: /projects/vocora/research-agenda
---

# Vocora Research Agenda

{ Status: active and evolving · Last revised July 17, 2026 | sub }

This agenda records the questions currently guiding Vocora. It is a working document, not a claim that every topic listed below has already been studied or tested.

## Purpose

Vocora uses software development as a way to make questions about learning more concrete. A question should eventually lead to a design decision, a measurable hypothesis, a literature note, or an experiment that can be inspected and revised.

The broader motivation is to understand human learning and memory. The present scope is narrower: vocabulary and spelling practice, retrieval, spacing, feedback, motivation, and measurement.

## Current Research Areas

### 1. Retrieval and review timing

- How should due items be selected?
- How much difficulty is useful before a practice session becomes discouraging?
- Which review intervals are appropriate for different goals and retention periods?
- How should incorrect retrieval affect the next review?

### 2. Durable learning and measurement

- What can be inferred from an answer given during the same session?
- Which delayed-recall measures are practical enough for a real product?
- How should the product distinguish practice activity, current performance, and longer-term retention?
- When should a word be described as reviewed, strengthened, or retained?

### 3. Feedback and error correction

- Which feedback helps a learner notice spelling errors without simply copying the answer?
- How much information should be shown after an error?
- When does repeated correction become unproductive?

### 4. Motivation and ethical product design

- Can progress feedback support regular practice without pressure or public comparison?
- How should streaks, goals, and sharing behave after a missed day?
- Which engagement metrics conflict with learning or well-being?
- What information should never appear in a public progress card?

### 5. Language and spelling practice

- Which spelling variants should be accepted?
- How should pronunciation, meaning, context, and orthography be introduced over time?
- When does isolated word practice need to be supplemented by phrases or listening context?

## Evidence Standards

Vocora will use the following standards when publishing research-related material:

- Prefer primary papers, systematic reviews, meta-analyses, and official technical documentation.
- Identify the population, task, and outcome studied before applying a finding to the product.
- Separate published evidence from a product decision or personal interpretation.
- Avoid turning evidence for retrieval or spacing in general into evidence that Vocora itself is effective.
- Define metrics before evaluating a feature where practical.
- Report null, negative, and inconclusive results.
- State important limitations and plausible alternative explanations.

## Current Stage

### Implemented

- A full-stack vocabulary-practice application
- Leitner-style review state
- User accounts and server-side learning-state storage
- Practice history and daily activity data
- Explicit definitions for several product metrics
- Privacy and ethical constraints for progress sharing
- Automated application and interface tests

### Not Yet Demonstrated

- Superior long-term retention compared with another learning method
- An empirically optimized review schedule
- Generalization beyond the current vocabulary and spelling use case
- Causal effects of the current gamification design on motivation or retention
- Validated personalization based on individual memory differences

## Near-Term Work

1. Define a delayed-recall outcome that does not rely only on same-session correctness.
2. Document the current scheduling assumptions and their alternatives.
3. Establish a baseline before changing the review algorithm.
4. Publish a protocol before describing a product comparison as an experiment.
5. Add context and meaning carefully without losing the focused spelling task.
6. Revise product language so that every progress claim matches the underlying data.

## Research Boundaries

Vocora does not provide clinical assessment or treatment. It does not attempt to diagnose memory, attention, or language disorders. Findings from product use will not be presented as general neuroscience findings without an appropriate research design and evidence.

The aim is modest but serious: ask clearer questions, build traceable implementations, measure carefully, and revise conclusions when the evidence changes.
