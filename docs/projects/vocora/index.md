---
layout: default
title: Vocora
parent: Projects
nav_order: 2
direction: ltr
description: "An open-source research-and-building project about learning, memory, language practice, and learning technology."
permalink: /projects/vocora
---

# Vocora

{ An independent research-and-building project about human learning | fs-6 }

Vocora is my independent open-source project for studying how people practice, retain, and retrieve knowledge, and for turning some of those questions into working software.

The long-term motivation is broad: to understand learning and memory more carefully. The current work is deliberately narrower and easier to examine: vocabulary practice, retrieval, spacing, feedback, motivation, progress measurement, and language learning.

## Relationship to Human Transformation

Vocora is one bounded project within the broader [Human Transformation](/leadership-learning/human-transformation) inquiry. It provides a concrete software setting for a limited set of questions about learning and measurement. It is not the container for the wider questions about identity, worldview, leadership, children's learning, group coordination, or quality of life.

## Why It Exists

Learning applications can measure activity easily, but activity is not the same as durable learning. Vocora gives me a concrete system in which to examine that difference: define what a metric means, implement a small decision, observe its limits, and revise it.

The goal is not to attach scientific language to an ordinary product. It is to make the questions, sources, assumptions, measurements, and corrections behind the product visible.

## What Exists Today

The first working artifact is a full-stack vocabulary-practice application based on the Leitner system, currently focused on spelling for IELTS Listening.

The application currently includes:

- account registration and sign-in;
- learning state stored in MySQL and available across devices;
- Leitner-style review scheduling;
- import of Markdown and text word lists;
- progress and practice history;
- optional progress-story generation with privacy constraints;
- automated tests and a Docker-based development environment.

The official application is available at [vocora.ir](https://vocora.ir), where anyone can register and use it.

Vocora is open source. The code is available in the [Vocora GitHub repository](https://github.com/OkBayat/vocora), and anyone who would like to improve the software, documentation, or related research tooling is welcome to contribute.

## Questions Behind the Product

The product is shaped by questions such as:

- How should retrieval and review intervals be represented in a practical learning tool?
- Which measures reflect practice, and which could reasonably indicate longer-term retention?
- How can feedback support persistence without creating shame or dependence?
- How should progress be communicated without claiming permanent mastery?
- Which forms of gamification support autonomy and regular practice rather than compulsive engagement?
- How can language-learning software collect only the data it actually needs?

## What the Current Product Does Not Demonstrate

Vocora is not an academic laboratory, a clinical project, or a peer-reviewed neuroscience study. I am not claiming that the current application has already improved long-term memory or outperformed other methods.

At this stage, Vocora is an independent software and research project informed by published work in cognitive and learning science. Formal claims about effectiveness require appropriate comparison, delayed measurement, sufficient data, and a method that can be reviewed.

## Project Principles

- Learning outcomes matter more than time spent in the product.
- Short-term correct answers are not the same as durable learning.
- Claims should not be stronger than the available evidence.
- Motivation should be supported rather than manipulated.
- Progress should be represented honestly.
- Privacy and user choice are product requirements.
- Unsupported and inconclusive hypotheses should be documented, not hidden.
