---
layout: default
title: "Designing Large Agent Skills as Deterministic, Phase-Oriented Systems"
description: "A reference architecture for decomposing large AI skills into explicit phases, lazy-loading context and code, controlling side effects, and preserving reliable, resumable execution."
parent: Essays
nav_exclude: false
direction: ltr
lang: en
locale: en_US
author: Mohammad Bayat
date: 2026-07-18
date_modified: 2026-07-18
last_modified_date: 2026-07-18
status: essay
translation_key: phase-oriented-agent-skills
evidence_level: architectural-proposal-informed-by-implementation-experience-and-primary-sources
seo:
  type: Article
categories:
  - writing
  - essays
tags:
  - ai-agents
  - agent-skills
  - workflow-architecture
  - state-machines
  - context-engineering
  - deterministic-systems
  - lazy-loading
sitemap: true
permalink: /writing/essays/phase-oriented-agent-skills-en
---

# Designing Large Agent Skills as Deterministic, Phase-Oriented Systems
{: .no_toc }

{ A reference architecture for reliable, context-efficient agent workflows | fs-6 }

{: .note-title }
> About this essay
>
> This is an architectural proposal developed from implementation work on large operational agent skills. It is not a formal standard, and I am not claiming that every skill needs this level of structure. The design is most useful when a skill coordinates multiple tools, reads and writes external state, pauses for review, resumes later, or must behave reliably across long executions. The external sources at the end provide background on progressive disclosure, workflow orchestration, state machines, durable execution, handoffs, guardrails, and tracing. The synthesis and proposed architecture are my own.

A small agent skill can be a good instruction file.

It can explain a task, name a few tools, give examples, and tell the agent when to stop. That is often enough. Adding a runtime, a state machine, or a directory full of contracts would only make the skill harder to understand.

A large skill is different.

Once a skill must inspect a repository, choose work from a queue, acquire a lock, create a branch, hand execution to a specialist, pause for review, resume against the same commit, publish a pull request, update external state, and record learning, it is no longer only a prompt. It has become a workflow runtime whose decisions are partly made by a language model.

That change in kind is easy to miss. The skill may still be stored in a folder with a `SKILL.md`, some scripts, and some references. But operationally it now resembles a small distributed system:

- it has states and transitions;
- it observes external systems that may change between reads;
- it performs side effects that can partially fail;
- it needs concurrency control;
- it may pause and resume;
- it must distinguish durable state from temporary execution context;
- it must keep its context window within a budget;
- and it must remain understandable to both the model and the humans maintaining it.

The central argument of this essay is simple:

> A large operational skill should be designed as a deterministic, phase-oriented shell around a bounded probabilistic core.

The model should still interpret, synthesize, judge, and create. But routing, state transitions, side effects, validation, resumption, and failure handling should be made as explicit and testable as possible.

<details open markdown="block">
  <summary>
    Table of contents
  </summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

## When a skill stops being a prompt

The Agent Skills specification describes a skill as a directory with a required `SKILL.md` and optional `scripts/`, `references/`, and `assets/`. It also recommends progressive disclosure: metadata is loaded first, the main instructions are loaded when the skill activates, and supporting resources are loaded only when needed.

That structure is a strong starting point. It prevents every possible instruction, reference, script, and template from entering the model's context at once.

But progressive disclosure at the file level does not automatically produce a well-architected runtime.

A skill can technically have separate reference files and still read all of them at startup. It can have separate scripts and still import every module from the entrypoint. It can query an external system for summary data and then immediately hydrate every issue, comment, review, and attachment. The directory looks modular, while execution remains eager and monolithic.

The problem becomes visible when the skill grows:

1. The main contract becomes too large to load and reason about safely.
2. References mix unrelated concerns, so reading one phase's rule pulls in several other phases.
3. Every command imports modules for work it will never perform.
4. Broad scans retrieve detail that belongs only to the selected item.
5. The model must remember rules for branches, review, publication, learning, rollback, and domain-specific validation simultaneously.
6. Failures become difficult to localize because the runtime has no explicit phase boundary.
7. A restart reconstructs what probably happened instead of resuming from a verified checkpoint.
8. Tests validate final outcomes but not the route, loaded context, or side effects used to reach them.

At this point, the answer is not simply “write a better prompt.” The skill needs an execution architecture.

## The deterministic shell and the probabilistic core

Language models are probabilistic systems. Even with stable inputs and conservative settings, their internal reasoning and wording should not be treated as a deterministic program.

That does not mean the whole workflow must be probabilistic.

A reliable skill can separate two kinds of work.

### The deterministic shell

The shell should own the parts of execution that can be stated as rules:

- command parsing;
- phase selection when the state is unambiguous;
- stable ordering and tie-breaking;
- schema validation;
- capability checks;
- lock acquisition;
- idempotency keys;
- read-before-write and read-after-write validation;
- state transition legality;
- checkpoint construction;
- stale-snapshot detection;
- retry and compensation policy;
- module and reference loading;
- tracing;
- stopping conditions.

Given the same verified inputs, this shell should choose the same route and authorize the same class of effects.

### The probabilistic core

The model should own tasks that genuinely require interpretation or generation:

- understanding an ambiguous request;
- summarizing a selected issue;
- choosing among strategies when no complete rule can encode the trade-off;
- writing or modifying code;
- evaluating qualitative evidence;
- drafting an explanation;
- proposing a learning;
- resolving a novel edge case within explicit boundaries.

The purpose of the shell is not to remove intelligence. It is to put intelligence where it adds value and keep it away from places where ambiguity creates avoidable operational risk.

This distinction resembles the difference Anthropic draws between workflows and agents: workflows follow predefined code paths, while agents dynamically direct their own process and tool use. A large skill often needs both. The outer route can be a workflow even when one or more phases contain agentic work.

## A phase is an execution contract, not a checklist item

Teams often use the word *phase* to mean a heading in a long instruction file:

1. `inspect`;
2. `plan`;
3. `implement`;
4. `test`;
5. `publish`.

That is useful for humans, but it is not enough for a runtime.

A real execution phase should have a contract. At minimum, that contract should define:

- **identity** — a stable phase name;
- **purpose** — the one responsibility of the phase;
- **entry conditions** — what must already be true;
- **required observations** — the data that must be read;
- **allowed references** — the instructions that may enter context;
- **allowed modules** — the code that may be loaded;
- **capabilities** — the external effects the phase may request;
- **decision schema** — the shape of the phase result;
- **postconditions** — what must be true after success;
- **failure semantics** — retry, block, compensate, or stop;
- **next-phase rules** — the legal transitions;
- **resume requirements** — the evidence needed to continue later.

A phase should be small enough that these fields can be stated precisely, but large enough to represent a meaningful unit of progress.

If a phase can both claim a task, edit source files, publish a pull request, and update a learning proposal, it is too large. If every file read or every tool call becomes a separate phase, the model is too fragmented and the runtime becomes ceremonial.

The right boundary usually appears where one of these changes:

- the authoritative source of state;
- the set of permitted side effects;
- the owner of execution;
- the failure and compensation policy;
- the context that must be loaded;
- the checkpoint required for resumption.

## Separate durable workflow state from ephemeral execution phase

One of the most important design decisions is to distinguish two layers of state.

### Durable domain state

Durable state belongs to the system of record and should survive the current execution. Examples include:

- an issue is queued, active, blocked, or ready for review;
- a pull request is draft, open, approved, or merged;
- a proposal is awaiting feedback or approved for application;
- a branch points to a particular commit;
- a review comment has been handled;
- a workflow event has been recorded.

This state should be visible to other processes and humans. It usually belongs in GitHub, a database, an event log, or another authoritative external system.

### Ephemeral execution phase

The runtime phase explains what the current invocation is doing:

- scanning review candidates;
- hydrating the selected issue;
- validating claim preconditions;
- waiting for a specialist handoff;
- resuming pre-publication review;
- rendering an artifact;
- verifying publication;
- performing post-task learning.

These phases should usually not become durable labels in the external system. Creating a label for every internal step makes the domain model noisy and couples external state to implementation details.

A task may remain durably “in progress” while the runtime moves through several internal phases. That is healthy. Durable state answers, “What is the work's public status?” The phase answers, “What must this execution do next?”

## A generic phase graph for a large operational skill

The exact phases depend on the domain, but a useful generic graph looks like this:

```text
COMMAND_ROUTE
      |
      v
MINIMAL_BOOTSTRAP
      |
      v
OBSERVE_SUMMARIES
      |
      v
ROUTE_WORK
      |
      +-------------------------+
      |                         |
      v                         v
HYDRATE_SELECTED_ITEM       IDLE_OR_STOP
      |
      v
DECIDE
      |
      v
PLAN_EFFECTS
      |
      v
EXECUTE_EFFECTS
      |
      v
READBACK_VALIDATE
      |
      +-------------------------+
      |                         |
      v                         v
HANDOFF_OR_RESUME          FINALIZE
      |                         |
      +-----------<-------------+
```

This graph expresses several principles.

First, broad observation and detailed hydration are separate. The skill may scan many candidates using summaries, but it fetches full bodies, comments, diffs, or attachments only for the item it selects.

Second, decision and mutation are separate. The runtime should know what it intends to do before it acquires write capabilities.

Third, every important mutation is followed by authoritative readback. A successful API response is evidence that a request was accepted, not always evidence that the desired state now exists.

Fourth, handoff and resumption are explicit states. A human or specialist agent may own part of the work, but the workflow still needs a verified boundary before and after that work.

Fifth, stopping is a valid phase outcome. A skill should be able to say `idle`, `blocked`, `current-session-required`, or `stale-resume` without improvising a path forward.

## Transition contracts

A phase graph becomes reliable when transitions are governed by explicit contracts.

A transition contract can be represented as:

```yaml
transition:
  from: CLAIM_PREFLIGHT
  to: CLAIM_TRANSACTION

preconditions:
  - no_active_task
  - candidate_is_still_eligible
  - repository_identity_matches

inputs:
  - candidate_snapshot
  - source_boundary
  - prospective_handoff

capabilities:
  - repository_lock
  - issue_read
  - issue_write
  - branch_write

effects:
  - acquire_lock
  - revalidate_authoritatively
  - update_task_state
  - write_claim_record
  - prepare_branch_and_handoff

postconditions:
  - exactly_one_active_task
  - selected_task_is_active
  - handoff_is_valid

compensation:
  when: handoff_preparation_fails_after_state_change
  effects:
    - restore_task_to_queue
    - record_compensation
    - release_lock

next:
  success: EXECUTION_HANDOFF
  stale: ROUTE_WORK
  conflict: BLOCKED
```

The contract matters more than the syntax.

It prevents several common errors:

- entering a write phase with stale observations;
- performing only half of a multi-step state change;
- losing track of whether a lock has been released;
- marking work complete before publication has been verified;
- resuming from a handoff that belongs to an older commit;
- treating every exception as retryable;
- relying on the model to remember an unwritten rollback rule.

A good transition contract also makes review easier. A maintainer can ask, “What can this phase mutate?” without reading the entire skill.

## The architecture of a phase-oriented skill

A large skill should not put all of its logic in `SKILL.md`. The main file should act as an activation contract and phase index.

A possible structure is:

```text
large-skill/
├── SKILL.md
├── phases/
│   ├── command-route.md
│   ├── bootstrap.md
│   ├── observe.md
│   ├── decide.md
│   ├── mutate.md
│   ├── handoff.md
│   ├── resume.md
│   └── finalize.md
├── references/
│   ├── global-invariants.md
│   ├── state-model.md
│   ├── naming.md
│   ├── publication.md
│   ├── review-handling.md
│   └── learning.md
├── scripts/
│   ├── cli.ts
│   ├── phase-registry.ts
│   ├── phase-runner.ts
│   ├── effect-executor.ts
│   ├── gateways/
│   ├── phases/
│   └── adapters/
├── schemas/
│   ├── phase-result.schema.json
│   ├── checkpoint.schema.json
│   └── effect-plan.schema.json
├── tests/
│   ├── phases/
│   ├── transitions/
│   ├── fault-injection/
│   └── lazy-loading/
└── assets/
```

The responsibilities should be clear.

### `SKILL.md`

The main file should contain:

- what the skill does;
- when it should activate;
- the global safety invariants;
- the phase graph;
- the rule for selecting the first phase;
- the result vocabulary;
- direct links to phase contracts.

It should not contain every domain rule, publication template, review policy, and failure example.

### `phases/`

Each file should explain one phase in language suitable for the model:

- why the phase exists;
- what to inspect;
- what not to inspect;
- what output to produce;
- what tools are allowed;
- how to stop safely.

These phase files are not a second monolithic manual. The active phase should read only its own contract and the small number of references it directly needs.

### `references/`

References should describe reusable policies or domain knowledge:

- naming;
- state transition legality;
- evidence requirements;
- review semantics;
- safety constraints;
- artifact formats.

A reference should not combine several unrelated workflows merely because they once lived in the same document.

### `scripts/`

Scripts should implement deterministic operations:

- `parsing`;
- `routing`;
- `validation`;
- `sorting`;
- `locking`;
- `effect execution`;
- `readback`;
- `checkpointing`;
- `schema enforcement`.

Scripts can also expose safe, narrow tools to the model. They should return diagnostic errors rather than opaque `null` or generic failure messages.

### `adapters/`

Domain-specific behavior belongs behind an adapter boundary.

The core runtime should not know every field required by every kind of task. Instead, it should ask the selected adapter to:

- validate domain evidence;
- render the domain-specific part of an artifact;
- classify domain blockers;
- define domain-specific completion gates.

This prevents a generic task runner from importing every specialist validator and accumulating `if kind === ...` branches throughout the core.

## Lazy loading has three separate layers

When people discuss lazy loading in skills, they often mean only reference files. A complete design must control three different layers.

### 1. Reference lazy loading

The model should load only the instructions required for the current phase.

A phase manifest might declare:

```yaml
phase: REVIEW_CLASSIFY
references:
  - references/global-invariants.md
  - references/review-classification.md
```

The inline-feedback procedure should not be loaded merely because review work is possible. It should be loaded only after classification finds new inline feedback.

This reduces token use, but the more important benefit is cognitive isolation. Irrelevant rules can interfere with the model even when the context window is technically large enough.

Reference lazy loading fails when:

- `SKILL.md` tells the model to read every reference before beginning;
- one “contract” file contains the rules for several phases;
- references form deep chains that require broad exploratory reading;
- a phase cannot determine which reference applies without reading all of them;
- the runtime does not expose the current phase clearly.

The Agent Skills specification recommends focused reference files and on-demand resource loading. A phase manifest turns that recommendation into an enforceable runtime property.

### 2. Module lazy loading

Context efficiency and process efficiency are different.

A JavaScript entrypoint can keep reference files out of the model's context while still eagerly importing every execution module:

```js
const claim = require("./claim");
const review = require("./review");
const publish = require("./publish");
const learning = require("./learning");
const strategyAdapter = require("./adapters/strategy");
```

Now even `--help` or `list` initializes code for publication, learning, and a domain adapter.

The better pattern is to load the handler after routing:

```js
async function runPhase(phase, context) {
  const definition = PHASES[phase];
  const handler = await import(definition.handler);
  return handler.run(context);
}
```

Module lazy loading improves startup cost, reduces accidental coupling, and provides a testable signal that phase boundaries are real.

It also makes capability review easier. If a read-only command never imports a write gateway, we have stronger evidence that it cannot mutate external state accidentally.

### 3. Data hydration lazy loading

The third layer is often the most expensive.

A queue scan may need only:

- `identifier`;
- `title`;
- `state`;
- `labels`;
- `priority`;
- `creation time`;
- `update time`.

It does not need every issue body, comment, attachment, review thread, and linked document.

A review scan may need only pull-request summaries. Full review comments should be fetched only after one pull request has been selected.

This leads to a general rule:

> Scan broadly with summaries; hydrate narrowly after selection.

Data hydration should be visible in the phase graph. Otherwise a “read-only scan” can quietly become the largest source of token use and latency.

## Treat context as a budgeted dependency graph

A skill should know not only which phase it is in, but also what that phase is allowed to load.

A phase manifest can declare four budgets:

```ts
type PhaseDefinition = {
  handler: string;
  references: string[];
  modules: string[];
  capabilities: Capability[];
  contextBudget: {
    maxReferenceTokens: number;
    maxHydratedItems: number;
    maxToolResultTokens: number;
  };
};
```

The runtime can then trace:

- references requested;
- estimated reference tokens;
- modules imported;
- items hydrated;
- tool-result size;
- total phase input;
- total phase output.

The purpose is not to reject every run that exceeds an arbitrary number. The purpose is to make context growth explainable.

Without measurement, “lazy loading” remains an intention. With measurement, it becomes a property that can regress, fail a test, and be improved.

## Separate observation, decision, and effects

A phase-oriented skill should follow a disciplined flow:

```text
observe -> decide -> plan effects -> execute -> read back -> verify
```

Each step solves a different problem.

### Observation

Observation collects authoritative facts and produces a snapshot with identity:

```json
{
  "item_id": 2459,
  "state": "in-queue",
  "labels": ["priority:high", "kind:code-change"],
  "updated_at": "2026-07-18T08:15:00Z",
  "source_version": "main@abc123"
}
```

### Decision

Decision should be as pure as possible:

```json
{
  "decision": "claim",
  "reason": "highest eligible priority tier; oldest item",
  "snapshot_id": "sha256:..."
}
```

A pure decision can be unit tested without GitHub, a filesystem, or a language model when the rules are deterministic.

### Effect planning

The plan states intended mutations before they occur:

```json
{
  "effects": [
    {"type": "acquire_lock", "scope": "repository"},
    {"type": "replace_state", "item_id": 2459, "to": "in-progress"},
    {"type": "create_branch", "name": "agent/issue-2459"},
    {"type": "write_claim_record", "item_id": 2459}
  ],
  "postconditions": [
    "exactly_one_active_item",
    "selected_item_is_active",
    "branch_exists"
  ]
}
```

### Effect execution

A centralized executor enforces capabilities, idempotency, ordering, and compensation.

### Readback

The runtime re-reads the authoritative system and verifies the postconditions.

This structure supports dry runs naturally. A dry run can stop after effect planning without importing write gateways.

It also supports auditing. A trace can show what the skill observed, what it decided, what it intended to change, what it actually changed, and what it verified afterward.

## What deterministic should mean

The word *deterministic* is frequently used too loosely in agent systems.

It should not mean:

- the model will always produce identical prose;
- every reasoning path is reproducible token for token;
- the system can eliminate uncertainty;
- no human judgment is required.

For a phase-oriented skill, deterministic should mean something more operational:

> Given the same validated external snapshot, configuration, phase contract, and recorded model decision, the runtime selects the same legal transition, authorizes the same effect types, applies the same ordering rules, and evaluates the same postconditions.

Several practices support this definition.

### Stable ordering

Queues should have explicit ordering and tie-breakers:

```text
priority descending
created_at ascending
identifier ascending
```

Never let API response order become an accidental decision rule.

### Explicit snapshots

Handoffs and mutations should bind to identifiers such as:

- commit SHA;
- review head OID;
- issue update timestamp;
- comment IDs;
- configuration version;
- skill source version;
- digest of the structured model output.

### Structured model decisions

When the model must classify or choose, require a schema:

```json
{
  "classification": "actionable-inline-feedback",
  "confidence": "high",
  "evidence_ids": [81234, 81241],
  "unresolved_questions": []
}
```

The runtime validates the schema and then applies deterministic routing rules to the result.

### No hidden nondeterminism in the shell

Time, randomness, environment variables, network reads, and filesystem state should be explicit inputs or isolated effects.

Temporal's workflow model is instructive here: deterministic replay is possible because external interactions are recorded as events and reused instead of silently repeated. A skill does not need to adopt Temporal to learn from this principle.

### Run-to-completion transition semantics

Within a critical transition, do not interleave unrelated work.

The W3C SCXML specification describes run-to-completion semantics: an external event is processed only after the current transition's microsteps complete. The same idea is useful for skills. A claim transaction, for example, should not pause midway to scan another queue or start another task.

## Handoffs are typed suspension points

A handoff should not be an informal sentence such as “continue with the review skill.”

It should be a typed suspension point with a resume contract.

A minimal handoff payload might contain:

```json
{
  "schema_version": 1,
  "workflow_id": "task-2459",
  "phase": "PRE_PUBLICATION_REVIEW",
  "next_phase": "PRE_PUBLICATION_RESUME",
  "source_version": "skill@def456",
  "item_id": 2459,
  "branch": "agent/issue-2459",
  "head_sha": "abc123",
  "execution_result_digest": "sha256:...",
  "required_skill": "code-review",
  "required_references": [
    "references/review-policy.md"
  ]
}
```

The receiving skill should get only the context it needs. OpenAI's Agents SDK handoff model similarly supports typed handoff input and input filters, separating model-generated handoff metadata from application context.

On resume, the runtime should verify:

- the item is still active;
- the branch is unchanged;
- the head SHA still matches;
- the result digest is unchanged;
- the external review snapshot has not moved;
- the skill source version is compatible;
- the expected handoff actually completed.

If any binding is stale, the runtime should not guess. It should return to the appropriate observation phase.

A fresh invocation that reconstructs a plausible handoff from current state is not equivalent to resuming the original paused execution. Resumption should be evidence-based.

## Capabilities, side effects, and transaction boundaries

A large skill becomes safer when each phase has an explicit capability allowlist.

Possible capabilities include:

```text
repository:read
repository:branch-write
repository:push
issue:read
issue:write
pull-request:read
pull-request:write
review:write
worktree:create
lock:acquire
host:handoff
```

A summary scan may have only read capabilities. A dry run should not load the effect executor. A publication phase should not be able to claim a queue item. A domain adapter should not gain GitHub write access merely because it validates evidence.

### Locks should cover invariants, not entire tasks

A lock is appropriate when concurrent processes could violate a durable invariant.

For example, the invariant “only one task may be active” may require a repository-scoped lock around:

1. authoritative re-read;
2. eligibility validation;
3. state mutation;
4. claim record;
5. branch or handoff preparation;
6. compensation on failure.

The lock should not remain held while the model edits code for an hour.

### Idempotency should be designed, not hoped for

Every externally visible effect should answer:

- What is its idempotency key?
- How can the runtime detect that it already happened?
- Is retry safe?
- What readback proves success?
- What happens if the process dies after the effect but before recording completion?

Examples:

- a branch name can be the idempotency key for branch creation;
- a hidden marker can identify a generated pull-request section;
- handled review comment IDs can prevent duplicate replies;
- a workflow event ID can deduplicate ingestion;
- a checkpoint digest can prevent stale finalization.

### Compensation is not rollback

Distributed side effects often cannot be rolled back perfectly.

If a claim changes an issue label and then branch preparation fails, the runtime may compensate by restoring the queue label and recording why. That is not the same as pretending the original mutation never happened.

Compensation should be explicit, observable, and tested.

## Domain adapters keep the core small

A common failure mode is allowing a generic runner to accumulate domain-specific logic.

Suppose one task type requires:

- KPI thresholds;
- evidence tables;
- special source validation;
- a custom pull-request projection;
- domain-specific blocker categories.

Those rules should not be imported by every task, and they should not be scattered through the generic finalization code.

Use a keyed adapter:

```ts
interface KindAdapter {
  validateResult(input: ExecutionResult): ValidationResult;
  renderArtifact(input: ExecutionResult): ArtifactSection;
  classifyBlocker(input: ExecutionResult): BlockerClassification;
  completionGates(input: ExecutionResult): GateResult[];
}
```

The runtime selects the adapter only after it knows the task kind and reaches the phase that needs domain behavior.

This produces two forms of lazy loading:

- unrelated tasks do not load the adapter's code;
- unrelated phases do not load the adapter's references.

It also creates a clean review boundary. The core team can maintain orchestration while domain maintainers own evidence and completion rules.

## Observability should follow the phase model

A trace should describe the execution in the same vocabulary used by the architecture.

OpenAI's Agents SDK traces generations, tool calls, handoffs, guardrails, and custom events. A phase-oriented skill can add domain-specific spans around those primitives.

A useful phase span records:

```json
{
  "workflow_id": "task-2459",
  "phase": "CLAIM_TRANSACTION",
  "source_version": "skill@def456",
  "started_at": "...",
  "ended_at": "...",
  "references_loaded": [
    "global-invariants.md",
    "claim-transaction.md"
  ],
  "estimated_reference_tokens": 1830,
  "modules_loaded": [
    "claim-transaction.ts",
    "issue-write-gateway.ts"
  ],
  "observations": {
    "candidate_count": 12,
    "hydrated_count": 1
  },
  "effects_requested": 4,
  "effects_completed": 4,
  "postconditions": {
    "passed": 3,
    "failed": 0
  },
  "next_phase": "EXECUTION_HANDOFF"
}
```

Observability should answer more than “did the task finish?”

It should answer:

- Why was this lane selected?
- Which snapshot governed the decision?
- What context entered the model?
- Which module imports occurred?
- Which capabilities were used?
- Which external calls were made?
- Which transition took the most time?
- Where did token use grow?
- Which postcondition failed?
- Was a retry safe?
- Did the workflow resume from the intended checkpoint?

This is how a team distinguishes a reasoning problem from a routing problem, a stale-state problem, a tool-design problem, or a context-loading problem.

## Testing a phase-oriented skill

End-to-end tests are necessary but insufficient. A reliable skill needs tests at several levels.

### Phase unit tests

Test pure functions:

- queue ordering;
- classification;
- transition selection;
- schema validation;
- artifact rendering;
- checkpoint digesting;
- stale-snapshot detection.

These tests should not require network access.

### Transition tests

Given a starting state and event, assert:

- legal next phase;
- required capabilities;
- effect plan;
- postconditions;
- terminal action.

A transition table makes missing paths visible.

### Golden workflow tests

Record representative workflows:

- idle;
- active-task resume;
- successful claim;
- claim conflict;
- review with no new feedback;
- actionable feedback;
- blocked execution;
- ready-for-review publication;
- stale handoff resume;
- no-op learning;
- multi-proposal learning.

Golden tests are useful during refactors because they preserve externally visible behavior while internal phases are extracted.

### Fault-injection tests

Failures should be injected at every meaningful side-effect boundary:

- before lock;
- after lock;
- before mutation;
- after mutation;
- during comment creation;
- during branch creation;
- during publication;
- after publication but before readback;
- during compensation;
- during lock release.

The test should verify invariants, not merely error messages.

### Lazy-loading tests

Inspect what was loaded for each command:

```text
help:
  no network gateway
  no write module
  no domain adapter

list:
  summary read gateway only

dry-run:
  no effect executor

generic finalization:
  no specialist adapter

review with no feedback:
  no inline-feedback write helper
```

These tests convert architectural intention into an enforceable budget.

### Replay and resume tests

Record a checkpoint, change one binding, and assert that resumption fails closed:

- head SHA changed;
- issue state changed;
- review cursor moved;
- configuration version changed;
- result digest changed;
- skill source became incompatible.

Then test the valid path with identical bindings.

### Property tests

Some invariants are well suited to generated cases:

- a stable sort always produces the same order;
- no legal transition creates two active tasks;
- a read-only phase never requests a write capability;
- compensation never leaves the lock held;
- every nonterminal phase has at least one legal next phase;
- every mutation phase has readback postconditions.

## Common failure modes

Several designs look modular but remain operationally monolithic.

### The index that requires everything

`SKILL.md` links to separate files but instructs the agent to read all of them before beginning.

This is file separation without progressive execution.

### The multipurpose reference

One document contains routine selection, review handling, publication, learning, and rollback.

Any phase that needs one rule loads all five concerns.

### Dynamic references, eager code

The model reads references on demand, but the script entrypoint imports every coordinator and adapter.

Context improves; runtime coupling does not.

### Lazy code, eager data

Modules load on demand, but the first scan fetches all issue bodies and comments.

Startup improves; token and latency costs do not.

### The model as transaction coordinator

The prompt says “update the label, create the branch, write a comment, and undo the label if anything fails.”

This relies on the model to remember distributed transaction semantics while also reasoning about the task.

### Hidden mutation

A function named `inspect` also refreshes a branch or writes a cursor.

Read phases should not have surprising side effects.

### Phase labels in the domain system

Every internal implementation step becomes an issue label.

The external state model becomes brittle and difficult for humans to interpret.

### Resume by reconstruction

A new process looks at current state and invents what the previous execution probably intended.

This can finalize unreviewed work or acknowledge stale feedback.

### Phase explosion

Every tool call becomes a phase, creating excessive handoffs and boilerplate.

Phases should align with responsibility, capability, and failure boundaries—not with individual lines of code.

### Deterministic theater

The workflow is called deterministic because it returns JSON, while model-generated choices silently control ordering, mutation, or stopping.

Structured output is not enough. The runtime must define how that output is validated and converted into effects.

## A practical migration path

A large existing skill should not be rewritten in one step.

A safer approach is a strangler refactor.

### 1. Establish a behavioral baseline

Capture:

- command outputs;
- external calls;
- side effects;
- loaded references;
- loaded modules;
- failure behavior;
- compensation behavior.

Create golden workflows before changing architecture.

### 2. Introduce phase vocabulary

Add `lane`, `phase`, `next_phase`, and a common result envelope around the existing implementation.

The monolith can temporarily remain as one legacy phase.

### 3. Split references by responsibility

Turn the main contract into a short index. Separate review, publication, learning, naming, and domain rules.

Add tests for required references per phase.

### 4. Build a minimal kernel

Extract:

- `command parser`;
- `phase registry`;
- `result schema`;
- `capability gate`;
- `dynamic handler loader`.

The kernel should know almost nothing about the domain.

### 5. Extract read-side routing

Separate summary scans from detail hydration. Make lane priority and stable ordering deterministic.

This usually produces immediate context savings with low mutation risk.

### 6. Extract the highest-risk transaction

Move claim, lock, authoritative revalidation, mutation, compensation, and release into one tested phase.

Do not weaken invariants to make extraction easier.

### 7. Extract finalization and adapters

Separate generic completion from domain-specific evidence and artifact rendering.

Add paused review and resume validation.

### 8. Extract secondary lanes

Learning proposals, maintenance, or review synchronization can move after the main task path is stable.

### 9. Enforce capability and lazy-load budgets

Fail tests when unrelated references, modules, data, or write capabilities appear.

### 10. Remove the legacy path

Only after phased and legacy executions agree on the golden workflows should the monolith be deleted.

## A compact phase manifest

A phase registry can make the architecture executable:

```ts
type Capability =
  | "issue:read"
  | "issue:write"
  | "pull-request:read"
  | "pull-request:write"
  | "git:read"
  | "git:branch-write"
  | "git:push"
  | "lock:acquire"
  | "host:handoff";

type PhaseDefinition = {
  handler: string;
  references: string[];
  capabilities: Capability[];
  terminal?: boolean;
  legalNext: string[];
  contextBudget: {
    maxReferenceTokens: number;
    maxHydratedItems: number;
  };
};

export const PHASES: Record<string, PhaseDefinition> = {
  QUEUE_SCAN: {
    handler: "./phases/queue-scan.js",
    references: [
      "references/global-invariants.md",
      "references/queue-selection.md"
    ],
    capabilities: ["issue:read"],
    legalNext: ["ITEM_HYDRATE", "IDLE", "BLOCKED"],
    contextBudget: {
      maxReferenceTokens: 2500,
      maxHydratedItems: 0
    }
  },

  CLAIM_TRANSACTION: {
    handler: "./phases/claim-transaction.js",
    references: [
      "references/global-invariants.md",
      "references/claim-transaction.md"
    ],
    capabilities: [
      "issue:read",
      "issue:write",
      "git:branch-write",
      "lock:acquire"
    ],
    legalNext: ["EXECUTION_HANDOFF", "QUEUE_SCAN", "BLOCKED"],
    contextBudget: {
      maxReferenceTokens: 3500,
      maxHydratedItems: 1
    }
  }
};
```

The registry is not merely configuration. It is a reviewable map of the system's trust boundaries.

## A common result envelope

Every phase should return a common outer structure:

```json
{
  "schema_version": 1,
  "workflow_id": "task-2459",
  "lane": "task",
  "phase": "CLAIM_TRANSACTION",
  "status": "succeeded",
  "action": "continue",
  "snapshot_id": "sha256:...",
  "decision": {
    "type": "claimed",
    "reason": "highest eligible candidate"
  },
  "effects": {
    "requested": 4,
    "completed": 4,
    "compensated": 0
  },
  "postconditions": {
    "passed": true
  },
  "next_phase": "EXECUTION_HANDOFF",
  "resume_context": null,
  "diagnostics": []
}
```

Possible actions should be few and stable:

```text
continue
idle
blocked
current-session-required
spawn-parallel-workers
completed
stale-resume
```

A small action vocabulary makes the outer orchestrator easier to test and prevents every phase from inventing its own stopping semantics.

## What should remain intelligent

A deterministic shell can become harmful if it tries to encode every judgment.

Some tasks remain irreducibly interpretive:

- deciding whether evidence is persuasive;
- choosing a code change among several valid designs;
- synthesizing conflicting review comments;
- identifying a novel failure mode;
- deciding whether a learning is general enough to preserve;
- explaining uncertainty honestly.

The architecture should not force these decisions into brittle rules merely to call the system deterministic.

Instead:

1. Give the model the smallest relevant context.
2. State the decision boundary clearly.
3. Require structured evidence and uncertainty.
4. Validate the output schema.
5. Keep irreversible effects outside the model call.
6. Preserve human review where consequences justify it.
7. Record enough context to understand the decision later.

The goal is not to turn the model into a state machine. The goal is to let the state machine create a safe and legible place for model judgment.

## Design rules

The following rules summarize the architecture.

1. **Keep simple skills simple.** Phase architecture is for operational complexity, not for every instruction file.
2. **Use `SKILL.md` as an index and activation contract.** Do not make it the entire runtime manual.
3. **Give every phase one responsibility.**
4. **Separate durable domain state from ephemeral execution phase.**
5. **Route before loading phase-specific context.**
6. **Lazy-load references, modules, and hydrated data independently.**
7. **Scan broadly with summaries; hydrate narrowly after selection.**
8. **Separate observation, decision, effect planning, execution, and readback.**
9. **Bind decisions and handoffs to explicit snapshots.**
10. **Keep side effects behind capability gates.**
11. **Hold locks only across invariant-preserving critical sections.**
12. **Design idempotency and compensation before failure occurs.**
13. **Treat handoffs as typed suspension points with resume contracts.**
14. **Reject stale resumes instead of reconstructing intent.**
15. **Put domain-specific validation and rendering behind adapters.**
16. **Trace phases in the same vocabulary used by the design.**
17. **Measure context, module, hydration, and tool-use budgets.**
18. **Test lazy loading directly.**
19. **Use fault injection to test transaction boundaries.**
20. **Define determinism as reproducible routing and effects over recorded inputs—not identical model prose.**
21. **Keep the probabilistic core bounded, evidenced, and reviewable.**
22. **Add complexity only when it improves reliability or understanding.**

## From prompt engineering to runtime engineering

The first generation of skills is naturally prompt-centered. We ask whether the instructions are clear, whether examples are good, and whether the model knows when to use the skill.

Those questions remain important. But large operational skills introduce another discipline: runtime engineering.

Runtime engineering asks:

- What phase are we in?
- What is authoritative?
- What may be loaded?
- What may be mutated?
- What snapshot governs this decision?
- What happens if the process stops here?
- How do we resume?
- What proves success?
- What must be compensated?
- What can be replayed?
- What can be tested without a model?
- What should remain a model judgment?

A skill that can answer these questions is easier to debug, safer to evolve, and less likely to spend its context window on rules and data that do not matter yet.

The most useful mental model is therefore not “a very long prompt with tools.”

It is a small workflow system with a language model inside it.

The workflow provides explicit phases, legal transitions, bounded capabilities, verified state, checkpoints, and observability. The model provides interpretation, creativity, synthesis, and judgment where rules are insufficient.

That division of labor is what allows a large skill to remain both intelligent and dependable.

## References

- [Agent Skills Specification](https://agentskills.io/specification) — directory structure, focused references, scripts, and progressive disclosure.
- [Building Effective Agents](https://www.anthropic.com/engineering/projects-effective-agents) — the distinction between predefined workflows and dynamically directed agents, along with routing, chaining, evaluator, and orchestrator patterns.
- [State Chart XML (SCXML): State Machine Notation for Control Abstraction](https://www.w3.org/TR/scxml/) — formal state-machine concepts, transitions, determinism, and run-to-completion semantics.
- [Temporal Workflows](https://docs.temporal.io/workflows) — event history, deterministic replay, durable execution, and the separation of workflow decisions from external activities.
- [OpenAI Agents SDK: Handoffs](https://openai.github.io/openai-agents-python/handoffs/) — typed handoff metadata and control over what context is passed to a receiving agent.
- [OpenAI Agents SDK: Guardrails](https://openai.github.io/openai-agents-python/guardrails/) — validation boundaries around agent and tool execution.
- [OpenAI Agents SDK: Tracing](https://openai.github.io/openai-agents-python/tracing/) — traces and spans for generations, tools, handoffs, guardrails, and custom workflow events.

## Revision History

- **July 18, 2026:** First published.
