## The problem is not generating comments

The easiest version of AI code review looks like this:

```text
diff + prompt
     |
     v
    LLM
     |
     v
review text
```

This can produce good observations. It can also produce style preferences, imagined defects, repeated comments, advice about untouched code, findings based on stale commits, or confident statements that conflict with repository-specific requirements.

The main production problem is therefore not *whether an LLM can find something to say*. It is whether the surrounding system can decide:

1. whether the comment is supported;
2. whether it matters;
3. whether it belongs on a changed line;
4. whether it has already been said;
5. whether it still applies to the current head;
6. whether it is safe to publish;
7. and what should happen after publication.

This distinction matters because a review comment changes team behavior. It consumes attention, can delay a merge, can cause unnecessary code changes, and may be treated as authoritative simply because it is written confidently. A noisy reviewer does not merely fail to help; it can make the engineering process worse.

We therefore treated review quality as a systems problem rather than a prompting problem.

## What “LLM-as-a-judge” means here

In the research literature, an LLM-as-a-judge usually evaluates another model’s output against criteria, a reference answer, or human preferences. Foundational work such as [MT-Bench and Chatbot Arena](https://arxiv.org/abs/2306.05685), [G-Eval](https://aclanthology.org/2023.emnlp-main.153/), and later surveys such as [A Survey on LLM-as-a-Judge](https://arxiv.org/abs/2411.15594) show why the pattern is attractive: natural-language criteria can be applied at scale to outputs that are difficult to score with simple deterministic metrics.

They also show why the pattern is dangerous when treated casually. LLM judges can exhibit position bias, verbosity bias, self-preference, instability, and poor discrimination between close candidates. [Judging the Judges](https://arxiv.org/abs/2406.07791) studies position bias systematically, while [A Closer Look into Using Large Language Models for Automatic Evaluation](https://aclanthology.org/2023.findings-emnlp.599/) shows that details such as requesting an explanation can materially affect alignment with human ratings.

K2 uses the same broad pattern but changes the evaluated object. The judge is not grading an answer from another chatbot. It is evaluating a pull request against several classes of evidence:

- the stated task or linked specification;
- repository and workflow contracts;
- changed lines and nearby source behavior;
- test and CI evidence;
- review lifecycle invariants;
- and, for specialized K2 surfaces, domain-specific strategy, condition-audit, capital-risk, order-execution, and backtest evidence.

The output is not an unconstrained score. It is a typed finding that must survive several gates before it becomes a GitHub comment.

## The work we studied and what we took from it

We did not begin with a blank page. We reviewed agent architecture guidance, evaluation research, GitHub review products, open-source pull request agents, and software-engineering agents. The value was not copying one system. It was identifying patterns that could be combined under K2’s own trust and workflow constraints.

### Agent architecture

[Anthropic’s Building Effective Agents](https://www.anthropic.com/engineering/building-effective-agents) distinguishes predefined workflows from dynamically directed agents and describes routing, parallelization, orchestrator-worker, and evaluator-optimizer patterns. Three ideas were especially relevant:

- route distinct categories to specialized prompts rather than making one prompt handle every concern;
- use parallel calls when separate perspectives improve attention or confidence;
- add programmatic gates around intermediate and final outputs.

[OpenAI’s practical guide to building agents](https://openai.com/business/guides-and-resources/a-practical-guide-to-building-ai-agents/) similarly emphasizes clear tools and instructions, incremental complexity, guardrails, explicit exit conditions, and human intervention for high-risk actions.

K2 adopted the compositional patterns but kept routing and publication outside the model. The model does not decide which GitHub event is valid, whether a job is stale, whether a line is part of the diff, or whether it may write to GitHub.

### Evaluation engineering

OpenAI’s [Evaluation Best Practices](https://developers.openai.com/api/docs/guides/evaluation-best-practices), [Working with evals](https://developers.openai.com/api/docs/guides/evals), and [Graders](https://developers.openai.com/api/docs/guides/graders) reinforced several principles:

- define criteria before optimizing the system;
- prefer concrete pass/fail or pairwise decisions where possible;
- calibrate automated judgment against human judgment;
- log enough context to inspect failures;
- and treat evaluation as a continuous engineering process rather than a one-time prompt.

[DeepEval](https://github.com/confident-ai/deepeval) was also useful as an example of turning LLM-based evaluation into repeatable, test-like metrics with thresholds, explanations, datasets, and CI integration.

K2’s review rules, confidence threshold, typed output, verifier pass, hidden metadata, and later learning workflow all reflect this eval-driven view.

### Structured outputs

[OpenAI’s Structured Outputs](https://openai.com/index/introducing-structured-outputs-in-the-api/) demonstrates the value of constraining model output to a schema. It also makes an important limitation explicit: schema conformance does not guarantee that the values are correct.

That is exactly the boundary in K2. JSON validity is only the first gate. The service separately validates rule identifiers, line anchoring, confidence, evidence requirements, duplicate markers, review-mode metadata, and current-head ownership.

### AI review products and open-source tools

Several systems helped clarify the expected product surface:

- [OpenAI Codex code review](https://openai.com/index/introducing-upgrades-to-codex/) connects pull request intent, repository context, code execution, tests, automatic review, and review-thread follow-up.
- [GitHub Copilot code review](https://docs.github.com/en/copilot/how-tos/copilot-on-github/use-copilot-agents/copilot-code-review) shows the importance of comment-only reviews, ready-to-apply suggestions, base-branch instructions, and repository- or path-specific review guidance.
- [PR-Agent](https://github.com/The-PR-Agent/pr-agent) demonstrates an open-source, self-hostable pull request workflow with commands such as review, describe, improve, and ask, plus configurable prompts and support for multiple Git providers.
- [CodeRabbit’s pull request review documentation](https://docs.coderabbit.ai/overview/pull-request-review) describes automatic and incremental review, issue context, repository knowledge, feedback, and conversational follow-up.

We do not claim that K2 is universally better than these systems. They solve broader product problems and have different information about their own internal implementations. Our design is narrower: a repository-specific review governance system whose policies, risk routes, evidence requirements, publication gates, and fix workflow are explicit and testable inside K2.

### Software-engineering agents

The [SWE-agent paper](https://arxiv.org/abs/2405.15793) and [official repository](https://github.com/swe-agent/swe-agent) introduced the idea of an agent-computer interface: tools and feedback designed around the capabilities and limitations of language models.

That lesson appears throughout K2. The judge receives bounded, typed context. Candidate passes return a restricted finding shape. The publisher owns GitHub writes. The fixer receives a canonical thread state rather than reconstructing it from scattered commands. The model is given an interface it can use reliably instead of arbitrary access to the environment.

## Design goals and non-goals

The system was built around six goals.

### High signal over high volume

A clean review may contain no comments. Silence is a valid output. The system should prefer missing a weak observation to publishing a speculative one.

### Evidence before authority

A finding must name the behavior, contract, or repository evidence that makes the changed line wrong. A confident tone is not evidence.

### Current-head correctness

Every review belongs to an exact head SHA. A result for an older commit must not be published on a newer pull request state.

### Repository-specific judgment

Generic software advice is subordinate to more specific K2 authorities. A line that looks unusual in isolation may be required by a strategy workflow, an agent skill, an operating rule, or a validation contract.

### Read-only judgment, separate mutation

The reviewer should not silently edit code, resolve threads, or approve a pull request. Fixing is a different capability with a different risk boundary.

### Machine-readable lifecycle

The system should expose enough structured state to answer what was reviewed, which passes ran, what was published, what was skipped, and how later feedback was handled.

The non-goals are equally important:

- It is not a replacement for human review.
- It is not a style linter.
- It is not a generic architecture-advice generator.
- It is not a formal proof system.
- It does not execute untrusted pull request code in the judge path.
- Its `confidence` field is not a calibrated probability.
- “Multi-agent” does not automatically mean independent models or independent failure modes.

## The architecture in one view

```text
GitHub webhook or poller
          |
          v
Signature, event, author, draft, and repository gates
          |
          v
SHA-aware durable queue
  - coalesce duplicate deliveries
  - cancel superseded work
  - retry bounded failures
          |
          v
Isolated trusted-base worktree
          |
          v
Bounded PR context assembly
  - diff and changed files
  - linked task/specification
  - review threads and prior comments
  - CI/check summaries
  - repository authorities
          |
          v
Deterministic risk router
  fast | standard | deep | council
          |
          v
Specialized candidate passes
  spec | standards | correctness | security | performance
  tests | lifecycle | false-positive filter
  strategy | condition audit | capital risk | order execution | backtest
          |
          v
Verifier + synthesizer
          |
          v
Schema, confidence, evidence, line, duplicate, and current-head gates
          |
          v
GitHub COMMENT review with inline findings
          |
          v
Repository-side convergence loop
  fix | decline | escalate
          |
          v
Optional evidence-backed review learning
```

This is best understood as a deterministic shell around a bounded probabilistic core. That pattern is also the central argument of my related essay, [Designing Large Agent Skills as Deterministic, Phase-Oriented Systems](/thinking/essays/phase-oriented-agent-skills-en).

## Phase one: receiving work from GitHub

### Webhooks and polling are two inputs to one queue

The service can receive GitHub `pull_request` webhooks and can also poll recent open pull requests. Both paths produce the same internal job shape.

Webhook delivery is useful because it is immediate. Polling is useful because it removes dependence on public inbound routing and can recover work when delivery infrastructure fails. They are not separate review implementations; they are two observation mechanisms feeding one state machine.

For webhook delivery, the service follows GitHub’s security model:

- validate the `X-Hub-Signature-256` HMAC before parsing and queueing;
- use a securely stored webhook secret;
- compare signatures with a constant-time operation;
- reject unrelated repositories and events;
- and acknowledge the delivery quickly while processing asynchronously.

These practices follow GitHub’s documentation on [validating webhook deliveries](https://docs.github.com/en/webhooks/using-webhooks/validating-webhook-deliveries), [handling deliveries](https://docs.github.com/en/webhooks/using-webhooks/handling-webhook-deliveries), and [webhook best practices](https://docs.github.com/en/webhooks/using-webhooks/best-practices-for-using-webhooks).

### The event allowlist is intentionally narrow

Automatic review accepts only relevant pull request transitions, such as:

```text
opened
reopened
ready_for_review
synchronize
```

A draft transition updates local recovery state but does not automatically start review. Draft pull requests are skipped until GitHub reports that they are ready.

Manual triggers are supported through exact top-level commands:

```text
/k2 review
/k2 review once
/k2 review deep
```

They are accepted only from an owner, member, or collaborator. The command parser reads an allowlisted first line; it never executes comment text.

This is a small but important prompt-injection boundary. A comment is not a shell command and not an instruction to the reviewer. It is either a recognized control token or untrusted evidence.

### Every job is bound to a head SHA

The durable identity of review work is effectively:

```text
repository + pull_request_number + head_sha
```

This enables several deterministic behaviors:

- repeated webhook deliveries for the same head are coalesced;
- polling and webhooks do not create duplicate automatic jobs;
- a newer head removes queued jobs for older heads;
- a newer head aborts a running review for an older head;
- the live pull request head is checked before model execution;
- and it is checked again before publication.

GitHub cannot provide an atomic “publish this review only if the head is still X” transaction. A push can race with a write already accepted by the API. K2 therefore reduces the race window, propagates cancellation into GitHub requests, checks before and after important status mutations, and records cleanup work when a stale mutation may have occurred.

The key lesson is broader than this implementation:

> Never let an AI reviewer reason about “the pull request” as an abstract moving object. Bind every run, output, status marker, and write to an explicit snapshot.

### Retries are bounded and stateful

Transient failures are retried with a finite attempt count and delay. Permanent failure clears reviewer-owned status markers. Cleanup is represented as durable work rather than a best-effort `finally` block that disappears when the process exits.

This matters because status reactions and comments are externally visible state. A process crash after adding “review in progress” must not leave the pull request permanently looking active.

## The trust boundary: the pull request is evidence, not instruction

A pull request may come from an untrusted branch or contributor. Its title, body, changed code, comments, linked issues, branch names, and test artifacts can contain text that looks like instructions to an agent.

The judge therefore uses a trusted-base model:

1. create a fresh isolated worktree;
2. check out the trusted base commit;
3. do not check out or execute the pull request head;
4. treat the head patch as data;
5. run the model in a read-only, ephemeral sandbox;
6. keep GitHub credentials in the publisher process;
7. do not pass those credentials into the model process.

Repository instructions, policies, skills, and review routes are read from the base branch. This mirrors the rationale behind GitHub Copilot’s use of base-branch custom instructions: the code under review must not be able to rewrite the reviewer’s authority.

This separation is stronger than adding “ignore prompt injection” to a prompt. It removes capabilities from the model process and gives untrusted text no direct path to a credentialed write or code execution.

## Building the review context

A reviewer that sees only a diff lacks intent and repository meaning. A reviewer that sees the entire repository, every issue, every comment, and every log becomes expensive, slow, and harder to reason about.

K2 assembles a bounded context with explicit caps and truncation signals.

The context may include:

- pull request title, body, labels, author, base, and head;
- linked issues and acceptance evidence;
- changed files, patches, and diff size;
- prior review comments;
- GraphQL review-thread state, including resolved and unresolved discussions;
- current CI and check summaries;
- fetch errors and truncation flags;
- relevant repository instructions and skill contracts;
- project operating knowledge required by the changed surface;
- and specialized evidence, such as validated condition-audit data.

The important rule is not “retrieve more.” It is:

> Retrieve the minimum authoritative context required to prove or disprove a candidate finding, and make missing or truncated context visible.

If the required context is unavailable or ambiguous, the professional-review policy prefers no finding. Missing evidence is not silently converted into evidence of failure.

## Authority resolution before judgment

K2 has a hierarchy of authority.

A generic guideline may encourage simplicity or surgical changes. A more specific workflow may require a file, metadata block, validation sequence, or apparently unusual structure. The specific authority wins.

Before a finding is emitted, the reviewer may need to resolve:

```text
repository AGENTS.md
      ↓
review policy and path routing
      ↓
relevant skill contract
      ↓
required skill references
      ↓
project operating knowledge
      ↓
nearby trusted-base source behavior
```

Pull request prose helps locate relevant authorities, but it does not become authority itself.

This avoids a common failure mode of generic AI review: treating unfamiliar design as incorrect because the model lacks the local contract that explains it.

## Risk routing: not every pull request deserves the same review

A documentation correction should not pay the same latency and cost as a change to order execution. A normal application change should not use the same rubric as a modification to the reviewer itself.

The trusted-base router selects one of four modes.

| Mode | Typical surface | Required passes |
|---|---|---|
| `fast` | low-risk documentation, fixtures, lockfiles, or tests | standards, tests/evidence, verifier, synthesizer |
| `standard` | normal code changes | specification, standards, correctness, tests/evidence, verifier, synthesizer |
| `deep` | CI, webhooks, GitHub writes, migrations, reviewer code, large or high-risk automation changes | specification, standards, correctness, security, performance, tests/evidence, review lifecycle, false-positive filter, verifier, synthesizer |
| `council` | critical strategy, capital, risk, orders, exchange execution, authentication, secrets, or permissions | route-selected domain passes, verifier, synthesizer, council evidence, and human review |

Routing is deterministic and loaded from trusted JSON policy files. Path rules and labels can elevate a review mode. Sensitive Markdown policy files do not fall into “fast” merely because their extension is `.md`.

This is an application of the routing pattern described by Anthropic, but the classifier is primarily conventional code and repository policy rather than an unconstrained model decision.

## Specialized review passes

The professional review is decomposed into focused passes.

General passes include:

- **Specification:** Does the diff satisfy the linked task, acceptance criteria, and declared intent?
- **Standards:** Does it comply with repository, skill, workflow, and project contracts?
- **Correctness:** Does it introduce a concrete state, data-flow, boundary, API, or compatibility regression?
- **Security and privacy:** Does it expose credentials, expand permissions, execute untrusted input, enable injection, or leak data?
- **Performance and data access:** Does it introduce unbounded or unnecessary network, database, filesystem, subprocess, polling, or per-item work?
- **Tests and evidence:** Is the verification appropriate to the behavior and risk that changed?
- **Review lifecycle:** Are draft handling, retries, deduplication, line anchoring, reactions, thread state, and convergence preserved?
- **False-positive filtering:** Did a reviewer change weaken evidence requirements, confidence filtering, or low-noise behavior?

K2-specific passes include:

- **Strategy contract**
- **Condition audit**
- **Capital risk**
- **Order execution**
- **Backtest evidence**

Each specialist is required to return typed evidence appropriate to its domain. A capital-risk finding cannot pass with a generic statement about “risk.” It must identify a risk metric, project authority, strategy contract, or concrete source behavior.

### Three kinds of check

The current judge groups findings under three top-level checks.

#### Karpathy-style engineering guidelines

These rules look for clear violations of thinking before coding, simplicity, surgical scope, and goal-driven verification. They are not a license to complain about every abstraction or changed file. More specific K2 authorities override the generic rule.

#### Condition-audit judgment

This check evaluates changed strategy condition-audit pointers and evidence. It can detect mismatched metadata, unsupported technical roles, stale chronology, missing condition-level validation, unexplained thresholds, overfit risk, overclaimed partial evidence, and unresolved capital-first risk.

#### Professional pull request review

This check covers specification mismatch, project-standard violations, concrete correctness regressions, security or privacy risks, performance or data-access risks, test gaps, review-lifecycle regressions, and weakened false-positive filtering.

Stable rule identifiers matter. They make output validation, metrics, deduplication, learning, and later policy changes possible.
