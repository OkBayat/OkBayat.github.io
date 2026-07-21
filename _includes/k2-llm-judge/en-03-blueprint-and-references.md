## A practical blueprint for building your own

The following sequence is a useful minimum architecture.

### 1. Write the authority hierarchy first

Define what the reviewer is allowed to treat as truth:

```text
base-branch repository policy
  > path-specific policy
  > workflow or skill contract
  > linked specification
  > generic review guideline
```

Decide how contradictions are resolved before writing prompts.

### 2. Separate the deterministic shell from model judgment

Deterministic code should own:

- event validation;
- authentication;
- queue state;
- snapshot identity;
- routing;
- context caps;
- schema validation;
- diff-line validation;
- duplicate suppression;
- retries;
- status;
- and all external writes.

The model should own:

- interpreting intent;
- comparing behavior with contracts;
- identifying concrete failure modes;
- explaining evidence;
- and synthesizing overlapping findings.

### 3. Define the job key and stale-work policy

At minimum:

```text
job_key = repo + pr_number + head_sha
```

Specify what happens to queued work, running work, status markers, and completed work when the head changes.

### 4. Make review modes explicit

Start with two modes if four are unnecessary:

```text
normal
high_risk
```

For each mode, name required passes, cost limits, failure policy, and whether human review is mandatory.

### 5. Give each pass one question

Bad candidate prompt:

```text
Review everything: correctness, architecture, security, tests, style,
performance, product requirements, and repository rules.
```

Better decomposition:

```text
spec:        Did the change satisfy the task?
correctness: Did it introduce a concrete behavior regression?
security:    Did it cross a trust or permission boundary unsafely?
tests:       Is required verification missing or stale?
```

### 6. Require a strict finding shape

Use a small allowlist of check and rule identifiers. Require:

```text
path
line
side
severity
confidence
title
body
evidence
introduced_by_pr
```

Reject aliases and extra fields. A stable schema is the foundation for analytics and future learning.

### 7. Treat confidence as one gate, not the proof

A useful publication predicate looks more like:

```text
postable =
    schema_valid
    and rule_allowed
    and introduced_by_pr
    and line_in_diff
    and evidence_sufficient
    and not_duplicate
    and not_contradicted
    and confidence >= threshold
    and verifier_passed
    and synthesizer_passed
    and head_is_current
```

No single model score should bypass the rest.

### 8. Make GitHub publication idempotent

Embed a stable hidden marker in each inline comment. Read existing comments before posting. Keep a separate marker for the general summary.

### 9. Preserve machine-readable metadata

Record the reviewed commit, routes, passes, gates, counts, truncation, and posting result. Without this, you cannot distinguish a clean review from a failed or incomplete one later.

### 10. Build feedback handling as a workflow

Do not instruct a coding agent to “address all comments.” Require `fix`, `decline`, or `escalate`. Require verification and a pushed SHA before resolution.

### 11. Measure reviewer outcomes

Useful operational metrics include:

- published findings per pull request;
- comment acceptance or useful-reaction rate;
- findings fixed versus declined;
- false-positive rate by rule and mode;
- stale-head aborts;
- duplicate comments suppressed;
- unanchorable findings;
- latency and cost by review mode;
- candidate-agent failure rate;
- human escalation rate;
- recurrence after an accepted fix;
- and agreement between automated and human reviewers.

Do not optimize for comment count. A reviewer that produces fewer, better findings may be more valuable.

### 12. Keep humans at high-risk boundaries

Require human review when consequences exceed the evidence available to the system. In K2, council mode is evidence for a human decision, not a substitute for it.

## Validation strategy

A review system needs tests at several layers.

### Deterministic unit tests

Test:

- webhook signatures;
- event and author allowlists;
- draft behavior;
- duplicate delivery coalescing;
- new-head supersession;
- retry scheduling;
- output schema rejection;
- route selection;
- confidence filtering;
- diff-line parsing;
- marker stability;
- review body construction;
- status ownership;
- and cleanup after interruption.

### Prompt contract tests

Use fixtures to verify that:

- each agent returns only allowed fields;
- low-confidence findings are omitted;
- missing specialist evidence fails;
- ambiguous context produces no finding;
- verifier and synthesizer gates are required;
- and candidate failures follow the mode policy.

### End-to-end tests

Use a test repository or controlled pull requests to verify:

- actual webhook delivery;
- queueing;
- review publication;
- inline anchors;
- retry behavior;
- a new push during review;
- duplicate suppression;
- draft-to-ready transitions;
- manual commands;
- and thread convergence after a fix or decline.

### Human calibration

Sample findings and label them:

```text
correct and important
correct but unimportant
incorrect
duplicate
stale
out of scope
insufficient evidence
```

Compare these outcomes by rule, agent, route, severity, and confidence band. This is the step that can eventually turn the current policy threshold into an empirically calibrated decision.

## Limitations and open questions

### We have not published a formal benchmark

The implementation has extensive contract and workflow validation, but this essay does not present a controlled study of precision, recall, developer time saved, or comparison with commercial reviewers.

### Confidence is not calibrated probability

The 80 threshold is a practical publication rule. It should be calibrated with human outcomes before being interpreted statistically.

### Same-engine agents have correlated failure modes

Specialized prompts improve focus, but they do not guarantee independent judgment. True multi-model evaluation would require explicitly configured external engines and a method for reconciling their different biases.

### Static policy can become stale

Repository rules and route maps must evolve with the system. The learning workflow can propose updates, but humans must review whether a local outcome generalizes.

### Context remains incomplete

Caps are necessary for cost and safety. They also mean a relevant issue, thread, check, or source file may be absent. The correct response is often suppression, but suppression can reduce recall.

### GitHub writes cannot be perfectly atomic with the head

Pre- and post-write checks reduce races but cannot retract every request already accepted by GitHub. Durable ownership and cleanup are compensating controls, not atomic transactions.

### Inline-only policy excludes some legitimate concerns

Some architecture or product risks cannot be represented on one changed line. K2 intentionally avoids forcing them into inline comments. A separate human summary or design review may still be necessary.

### The reviewer can only enforce explicit knowledge well

Unwritten conventions are difficult to distinguish from personal preference. Making repository authority explicit improves the reviewer and the organization at the same time.

## The deeper lesson

The most important change was not adding more agents. It was changing the unit of design.

We stopped asking:

> What prompt will produce a good code review?

We started asking:

> What system can safely convert probabilistic judgment into a small number of current, evidenced, actionable, and reversible effects?

That question leads naturally to:

- trusted and untrusted boundaries;
- explicit snapshots;
- deterministic routing;
- bounded context;
- specialized judgment;
- structured output;
- verification;
- idempotent publication;
- separate mutation;
- observable outcomes;
- and human authority at high-risk boundaries.

An LLM reviewer is a model call.

A review system is an operating contract between the repository, the model, GitHub, the coding agent, and the humans responsible for the code.

K2 LLM Judge became useful when we designed the contract, not merely the prompt.

## References

### Agent and workflow architecture

- [Anthropic — Building Effective Agents](https://www.anthropic.com/engineering/building-effective-agents)
- [OpenAI — A Practical Guide to Building Agents](https://openai.com/business/guides-and-resources/a-practical-guide-to-building-ai-agents/)
- [Yang et al. — SWE-agent: Agent-Computer Interfaces Enable Automated Software Engineering](https://arxiv.org/abs/2405.15793)
- [SWE-agent official repository](https://github.com/swe-agent/swe-agent)
- [OpenAI — Introducing Structured Outputs in the API](https://openai.com/index/introducing-structured-outputs-in-the-api/)

### LLM-as-a-judge and evaluation

- [OpenAI — Evaluation Best Practices](https://developers.openai.com/api/docs/guides/evaluation-best-practices)
- [OpenAI — Working with Evals](https://developers.openai.com/api/docs/guides/evals)
- [OpenAI — Graders](https://developers.openai.com/api/docs/guides/graders)
- [Zheng et al. — Judging LLM-as-a-Judge with MT-Bench and Chatbot Arena](https://arxiv.org/abs/2306.05685)
- [Liu et al. — G-Eval: NLG Evaluation using GPT-4 with Better Human Alignment](https://aclanthology.org/2023.emnlp-main.153/)
- [Chiang and Lee — A Closer Look into Using Large Language Models for Automatic Evaluation](https://aclanthology.org/2023.findings-emnlp.599/)
- [Shi et al. — Judging the Judges: A Systematic Study of Position Bias in LLM-as-a-Judge](https://arxiv.org/abs/2406.07791)
- [Gu et al. — A Survey on LLM-as-a-Judge](https://arxiv.org/abs/2411.15594)
- [DeepEval official repository](https://github.com/confident-ai/deepeval)

### GitHub review infrastructure

- [GitHub Docs — Validating Webhook Deliveries](https://docs.github.com/en/webhooks/using-webhooks/validating-webhook-deliveries)
- [GitHub Docs — Handling Webhook Deliveries](https://docs.github.com/en/webhooks/using-webhooks/handling-webhook-deliveries)
- [GitHub Docs — Best Practices for Using Webhooks](https://docs.github.com/en/webhooks/using-webhooks/best-practices-for-using-webhooks)
- [GitHub Docs — Webhook Events and Payloads](https://docs.github.com/en/webhooks/webhook-events-and-payloads)
- [GitHub Docs — REST API Endpoints for Pull Request Reviews](https://docs.github.com/en/rest/pulls/reviews)
- [GitHub Docs — Using GitHub Copilot Code Review on GitHub](https://docs.github.com/en/copilot/how-tos/copilot-on-github/use-copilot-agents/copilot-code-review)

### Pull request review tools

- [OpenAI — Introducing Upgrades to Codex](https://openai.com/index/introducing-upgrades-to-codex/)
- [PR-Agent official repository](https://github.com/The-PR-Agent/pr-agent)
- [CodeRabbit — Pull Request Reviews](https://docs.coderabbit.ai/overview/pull-request-review)
- [CodeRabbit — Automatic Review Controls](https://docs.coderabbit.ai/configuration/auto-review)

## Revision history

- **July 21, 2026:** First published.
