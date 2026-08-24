---
layout: default
title: "Maybe Evidence Matters More Than an AI Badge"
description: "A practitioner reflection on AI disclosure, verification, evidence, and what students may need to learn as generative AI becomes an ordinary tool."
parent: Essays
nav_exclude: false
direction: ltr
lang: en
locale: en_US
author: Mohammad Bayat
date: 2026-08-25
date_modified: 2026-08-25
last_modified_date: 2026-08-25
status: essay
project: k2quant
evidence_level: practitioner-reflection-informed-by-published-guidance-and-research
privacy: no-private-trading-system-or-confidential-company-details
seo:
  type: Article
categories:
  - writing
  - essays
tags:
  - artificial-intelligence
  - ai-literacy
  - generative-ai
  - evidence
  - verification
  - academic-integrity
  - human-judgment
  - responsible-ai
sitemap: true
permalink: /writing/essays/evidence-over-ai-badges
---

# Maybe Evidence Matters More Than an AI Badge
{: .no_toc }

{ A personal reflection on AI disclosure, evidence, verification, and responsibility | fs-6 }

{: .note-title }
> About this reflection
>
> This is a practitioner reflection, not an academic study or a policy proposal. The account of working with AI agents comes from my own engineering practice. Claims about Concordia's guidance, generative-AI risks, AI literacy, and measured human-AI performance are linked to published sources so they can be inspected independently.

I recently spent time reading Concordia University's guidance on [acknowledging the use of AI](https://library.concordia.ca/help/ai/acknowledging-ai.php), and I liked the direction behind it.

The guidance does not reduce the conversation to "AI is bad, so do not use it." It emphasizes acknowledgement, accountability, and keeping a human in the loop. Concordia also offers simple labels such as "Assisted by AI" and "Made with AI," while pointing researchers toward more detailed disclosure approaches when the role of AI is more substantial.

I think this is useful. Transparency matters.

But while reading it, I kept returning to a different question:

> As AI becomes an ordinary tool, is knowing that someone used AI the most important thing to know—or should we care more about whether that person can defend the work they produced?

<details open markdown="block">
  <summary>
    Table of contents
  </summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

## The calculator analogy only goes so far

I keep thinking about calculators.

If I am solving a mathematical problem and calculators are allowed, doing every piece of arithmetic manually does not necessarily demonstrate deeper understanding. The calculator can remove mechanical work and leave me more time to think about the actual problem and review the answer.

I increasingly see AI as useful in a similar way. If it can catch a spelling mistake, help reorganize a paragraph, challenge an idea, or help me explore alternatives faster, I do not see much value in deliberately refusing the tool simply to prove that I can work without it.

But the analogy breaks at an important point.

A generative AI system can produce something fluent, confident, and wrong. NIST's [Generative AI Profile](https://nvlpubs.nist.gov/nistpubs/ai/NIST.AI.600-1.pdf) calls one version of this problem *confabulation*: confidently stated but erroneous or false content, including incorrect reasoning and fabricated information.

And AI does not improve every task. In a field experiment involving [758 knowledge workers](https://doi.org/10.1287/orsc.2025.21838), access to GPT-4 improved performance on tasks that were inside the model's capability frontier, but on a task outside that frontier, people using AI were less likely to reach the correct answer.

So my conclusion is not simply "everyone should use AI."

It is: **we need to understand the tool we are using.**

## I learned this more clearly in real AI-agent work

I had used ChatGPT for years, and because I have a technical background, I assumed I understood AI reasonably well.

My understanding changed when I started putting AI agents inside real workflows in my quantitative and algorithmic-trading work at K2Quant.

In that environment, I began seeing how easy it was for an agent to sound completely confident that a task was finished while a closer review showed that something was missing, incorrect, or insufficiently verified.

That changed the way I work.

I stopped treating "the AI says it is done" as evidence that the work is done.

I started asking for evidence: the test, the source, the changed file, the result, the audit trail. I began breaking work into clearer stages and putting guardrails around consequential steps. For important changes, I still review the work before allowing it to move forward.

This is a personal engineering practice, not evidence that my exact workflow should be copied elsewhere. But the general need for verification is not only my observation. NIST recommends human oversight, fact-checking, comparison against known ground truth where possible, and explicit review of sources and citations generated by AI systems.

There is also a second trap: asking AI for evidence is not the same as having evidence.

If an AI gives me five papers supporting a claim, I still need to open them. Do they exist? Do they actually support the sentence? Is the quotation real? Is the connection I am making justified by the source?

**AI is not the evidence.**

It can help me find, organize, explain, or work with evidence. The underlying source is what I need to inspect.

## This is why I keep thinking about the badges

I am not arguing against disclosure.

There are contexts where an instructor, reviewer, researcher, or reader has a legitimate reason to know how AI contributed to a piece of work. Concordia is also clear that permission to use generative AI depends on the course, assignment, and instructor.

My question is about where the center of gravity should be.

Did you use AI for grammar? For brainstorming? Which model? Which version?

Those questions can be useful. But I am more interested in another set of questions:

- Where is the evidence?
- Did you verify it?
- Do you understand what you submitted?
- Can you explain your assumptions?
- Can you defend your numbers, references, and conclusions?

A disclosure tells me something about how the work was produced.

Evidence and understanding tell me whether I should trust it.

## Maybe the bigger opportunity is AI literacy

The more I work with these systems, the more I think education around AI may matter at least as much as rules around AI.

I do not mean that every student needs to become an AI engineer, or that universities need a course on how to make ChatGPT do assignments.

I mean practical AI literacy.

Students should understand that a confident answer can still be wrong. They should know that generated citations need to be checked. They should learn how to verify claims, distinguish a source from an AI summary of that source, and recognize when human judgement has to override the machine.

Most importantly, they should understand that putting their name on a piece of work also means taking responsibility for it.

Concordia is already moving in this direction. Its [GenAI Quickstart for Students](https://library.concordia.ca/learn/genai-students/index.html) is designed to build AI literacy, and its [academic-writing guidance](https://www.concordia.ca/students/success/learning-support/resources/writing/suggestions-using-gen-ai-academic-writing.html) emphasizes critical use, academic integrity, and maintaining authorship. UNESCO's [AI Competency Framework for Students](https://www.unesco.org/en/articles/ai-competency-framework-students) similarly emphasizes foundational AI knowledge and critical judgement, not merely tool operation.

I think that conversation is worth pushing further.

Not "Should we trust AI?"

Not "Should we ban AI?"

A more useful question may be:

> **How do we use AI without outsourcing our judgement to it?**

For me, the answer keeps returning to evidence, verification, and responsibility.

**A badge can tell me that AI was involved. Evidence tells me whether the work deserves my trust.**

## References

- Concordia University Library. [*Acknowledgement of AI use: Recommended practices*](https://library.concordia.ca/help/ai/acknowledging-ai.php).
- Concordia University Library. [*GenAI Quickstart for Students*](https://library.concordia.ca/learn/genai-students/index.html).
- Concordia University Student Success Centre. [*Suggestions for using Generative AI in academic writing*](https://www.concordia.ca/students/success/learning-support/resources/writing/suggestions-using-gen-ai-academic-writing.html).
- National Institute of Standards and Technology. [*Artificial Intelligence Risk Management Framework: Generative Artificial Intelligence Profile (NIST AI 600-1)*](https://nvlpubs.nist.gov/nistpubs/ai/NIST.AI.600-1.pdf).
- Dell'Acqua, F., et al. [*Navigating the Jagged Technological Frontier: Field Experimental Evidence of the Effects of Artificial Intelligence on Knowledge Worker Productivity and Quality*](https://doi.org/10.1287/orsc.2025.21838). *Organization Science*.
- UNESCO. [*AI Competency Framework for Students*](https://www.unesco.org/en/articles/ai-competency-framework-students).
