## Multi-agent execution without pretending it is independent consensus

K2 supports a feature-flagged native multi-agent path.

When enabled:

1. each selected candidate agent runs in a separate read-only model call;
2. candidate outputs are normalized and sanitized;
3. domain evidence requirements are checked;
4. candidate failures are handled according to mode and policy;
5. a final verifier and synthesizer receives the candidate findings;
6. only the final schema-versioned output reaches the publisher.

Candidate concurrency defaults to one and is capped at three. This keeps cost and latency bounded.

The default failure policy is fail-closed. An optional policy can continue with a missing candidate in `fast` or `standard` mode, but `deep` and `council` modes still fail closed.

This architecture benefits from separation of attention: security does not compete with tests inside the same candidate prompt, and condition-audit evidence does not compete with generic style review.

But it is important not to overstate what this means. Unless external engines are configured, these agents are specialized passes using the same underlying engine family. Their errors may be correlated. `council_evidence` is not automatically multi-model consensus. Multiple calls provide multiple lenses, not statistical independence.

When the multi-agent feature is disabled, a single model run still has to report the selected mode, completed passes, verifier result, and synthesizer result. The contract stays the same even when the execution strategy changes.

## The verifier and synthesizer gates

Candidate findings are not publishable findings.

The verifier asks whether each proposed finding satisfies the publication contract:

- Is the line part of the changed diff?
- Is the issue introduced or made actionable by this pull request?
- Does the body identify concrete evidence?
- Can the author fix it in this pull request?
- Is it contradicted by a more specific authority?
- Is it a duplicate?
- Does its severity reflect impact rather than uncertainty?
- Does it meet the confidence threshold?
- Does a specialist finding include the required typed evidence?

The synthesizer then resolves overlap:

- merge duplicate concerns;
- prefer the narrowest applicable rule;
- keep the strongest actionable version;
- remove generic restatements;
- and cap the final result.

Both gates must report success in the final metadata. The publisher rejects an output that merely claims candidate passes without successful verifier and synthesizer gates.

## The finding contract

The judge returns JSON, not Markdown.

A simplified finding looks like this:

```json
{
  "schema_version": 2,
  "review_summary": {
    "checks_run": [
      "karpathy_guidelines",
      "condition_audit_judge",
      "professional_pr_review"
    ],
    "inline_findings_count": 1,
    "review_mode": "deep",
    "agent_passes": [
      "spec",
      "standards",
      "correctness",
      "security",
      "performance",
      "tests",
      "review_lifecycle",
      "false_positive_filter",
      "verifier",
      "synthesizer"
    ],
    "verifier_passed": true,
    "synthesizer_passed": true
  },
  "findings": [
    {
      "check_id": "professional_pr_review",
      "rule_id": "correctness_regression",
      "path": "src/example.ts",
      "line": 84,
      "side": "RIGHT",
      "severity": "high",
      "confidence": 91,
      "title": "Preserve the current-head state transition",
      "body": "This branch records completion before the durable write succeeds, so a retry can skip the unfinished operation."
    }
  ]
}
```

The service rejects unknown top-level fields, unknown checks, unknown rules, invalid modes, invalid agent identifiers, failed gates, invalid severity, invalid side, malformed confidence, and invalid line locations.

It also limits raw candidate findings and final inline findings separately. A model cannot flood the pull request simply by returning a large array.

### Why the threshold is 80

Professional findings require an integer confidence from 80 to 100. Findings below 80 are omitted rather than published or summarized as actionable issues.

This threshold is a noise-control policy. It does **not** mean “the finding has an 80 percent objectively calibrated chance of being correct.” LLM self-reported confidence is not automatically calibrated. The value is useful only in combination with evidence, rule constraints, changed-line anchoring, verifier checks, and human feedback.

A mature system should calibrate the threshold empirically by comparing scores with human outcomes. Until then, the number is an eligibility boundary, not a probability claim.

## Changed-line anchoring

A finding must point to a line that GitHub can represent in the pull request diff:

```text
path
line
side = RIGHT | LEFT
```

The publisher builds an index of added and deleted lines from the patch and checks every finding against it.

This removes several kinds of noise:

- broad comments about untouched code;
- architecture essays that cannot be acted on at one changed location;
- comments attached to context lines;
- and model-invented line numbers.

A valid concern may still be unpostable if no changed line can represent it. Such findings are skipped and may be reported in a general summary. They are not forced onto an unrelated line.

GitHub’s [pull request review API](https://docs.github.com/en/rest/pulls/reviews) is the publication primitive. K2 submits one review with:

```json
{
  "commit_id": "<reviewed-head-sha>",
  "event": "COMMENT",
  "body": "<review-summary>",
  "comments": [
    {
      "path": "src/example.ts",
      "line": 84,
      "side": "RIGHT",
      "body": "<finding>"
    }
  ]
}
```

The event is always `COMMENT`. The system never approves a pull request and never requests changes on behalf of a human reviewer.

## Duplicate suppression and stable inline markers

Every inline finding includes a hidden marker:

```html
<!-- k2-llm-as-a-judge:inline:3d7deb43f04b930b -->
```

For a normal finding, the digest is derived from:

```text
commit SHA
path
line
side
check ID
rule ID
```

For condition-audit findings, a stable audit hash and condition expression can replace the volatile commit-and-line identity. This prevents the same audit concern from being reposted merely because surrounding lines moved.

Before publication, the service reads existing pull request review comments, extracts its own markers, and skips duplicates.

The general pattern is:

```text
dedupe_key = canonicalize(finding identity)
marker     = sha256(dedupe_key)[0:16]
```

The marker is not a security signature. It is an idempotency key embedded in a place that survives process restarts and can be read back from GitHub.

## Status without pretending to be an approval

The service uses pull request reactions as lightweight state:

- `eyes` while review is running;
- `+1` after a successful clean review with no actionable comments.

If findings are posted, the reviewer does not leave a clean marker. If a newer head supersedes the run, ownership of the status is invalidated and cleanup is scheduled.

Reactions are pull-request-scoped rather than head-scoped, so the queue stores which job and head own the current marker. The service checks ownership before and after mutation and removes only its own reactions.

This is a small example of why external UI state needs a real state machine. “Add eyes, later replace with thumbs-up” sounds trivial until two commits, a retry, and a process restart overlap.

## Hidden review metadata

Every review or summary body contains a hidden machine-readable metadata comment with fields such as:

- reviewed commit;
- checks run;
- review mode;
- agent passes;
- verifier and synthesizer status;
- finding counts;
- posted counts;
- skipped and duplicate counts;
- severity distribution.

This provides check-run-like data without requiring permission to create GitHub Checks.

It also creates the foundation for later evaluation. A learning process can correlate what the judge claimed with thread resolution, reactions, fixes, declines, and reruns.

Human-readable comments are for developers. Machine-readable metadata is for lifecycle integrity and measurement. A mature system needs both.

## Phase two: handling the inline reviews

Publishing a comment is not completion. The repository workflow must notice and resolve it.

K2 keeps this capability separate from the reviewer.

### Canonical review state

The repository-side review loop reads a canonical snapshot that combines:

- current pull request head;
- CI checks and their states;
- reviewer `eyes` and `+1` reactions;
- review decision;
- unresolved inline threads;
- comment identifiers and anchors;
- timestamps and a cutoff tied to the last push;
- and markers for previously handled invalid feedback.

It does not infer “clean” from one REST call or from the absence of a new notification. It waits until the configured reviewer and CI conditions are satisfied.

### Every item becomes fix, decline, or escalate

The write-capable workflow classifies each unresolved item as exactly one of:

| Classification | Meaning | Action |
|---|---|---|
| `fix` | Factually valid, in scope, actionable, and safe on the current branch | Make the smallest change, verify, commit, push, reply with evidence, then resolve |
| `decline` | Invalid, stale, duplicate, contradicted by stronger authority, or outside scope | Do not edit code; reply with a concise technical reason and mark it handled |
| `escalate` | Ambiguous, unsafe, conflicting, or dependent on a maintainer decision | Stop automation and present the decision clearly |

The comment itself is a request to evaluate, not an instruction to obey.

Before accepting it, the fixer asks:

- Is it true against the current branch?
- Is it necessary for the stated pull request contract?
- Is it inside scope?
- Does it avoid introducing a new feature?
- Does it address a practical failure mode?
- Can it be fixed with a small local diff?
- Can the result be verified?

If any answer is no, the system does not change code merely to satisfy the reviewer.

### Fixes must be pushed before threads are resolved

For valid feedback, the order is:

```text
inspect
  → patch
  → focused verification
  → commit
  → push
  → reply with SHA and evidence
  → resolve thread
  → wait for current-head review and CI again
```

This preserves an auditable link between the review comment, the exact fix, and the post-fix validation.

After every push, the loop restarts against the new head and a new cutoff. It continues until clean, timeout, or a concrete external blocker.

### Invalid feedback still needs convergence

Ignoring a bad comment leaves it pending forever. Resolving it without explanation hides the disagreement.

K2 replies under invalid or out-of-scope feedback with a concise reason and a hidden handled marker. The marker prevents the same already-addressed comment from blocking future scans, while the visible explanation preserves the technical decision.

This is one of the most important operational lessons: false-positive handling is part of the product, not an exception outside the workflow.

## A third, separate responsibility: learning from outcomes

K2 also separates review learning from review and fixing.

The learning workflow may inspect:

- hidden review metadata;
- useful or not-useful reactions;
- thread resolution;
- fix commits;
- decline and escalation reasons;
- verification evidence;
- recurrence of similar findings;
- and current routing or severity policies.

It may propose a small, evidence-backed policy change through a normal branch and pull request. It does not directly rewrite product code, reviewer policy, or persistent memory in place.

The separation is deliberate:

```text
reviewer  → proposes findings
fixer     → handles current findings
learner   → proposes changes to future review policy
```

Combining these roles would create a self-modifying system that could lower its own standards after one inconvenient review or broaden its authority without human approval.

## What is distinctive about the K2 design

Many modern review tools support automatic review, repository context, inline comments, commands, or fixes. K2’s contribution is not the existence of those features individually. It is the explicit composition of governance boundaries around them.

### The review policy lives in the trusted repository base

Risk routing, rule identifiers, specialist evidence requirements, and review-mode definitions are versioned with the codebase and reviewed like code.

### The publisher is deterministic and credentialed; the judge is probabilistic and uncredentialed

The model proposes typed findings. The Node service decides whether they can become GitHub writes.

### Review, mutation, and learning are separate capabilities

A comment-only judge cannot silently rewrite the branch. A fixer cannot redefine review policy. A learner cannot apply its own proposal.

### Current-head ownership is a first-class invariant

Jobs, status reactions, model outputs, comments, cleanup, and retries are tied to the reviewed SHA.

### Low-noise behavior is encoded, not merely requested

Confidence thresholds, changed-line anchoring, stable rules, typed evidence, verifier and synthesizer gates, finding caps, and duplicate markers all enforce the noise policy.

### Domain review is routed rather than appended to one giant prompt

Capital risk, order execution, condition audits, and backtest evidence have separate passes and evidence types.

### Clean runs are allowed to be silent

The system does not manufacture a summary to prove that it ran. A lightweight reaction is sufficient when there is nothing actionable to say.

## Comparison with existing approaches

The following comparison describes public product surfaces and design emphasis, not hidden implementation details.

| Approach | Publicly documented strength | K2’s design emphasis |
|---|---|---|
| OpenAI Codex review | Intent-to-diff review, repository navigation, code and test execution, GitHub follow-up | Trusted-base read-only judgment, repo-specific routing, deterministic publisher, separate fixer |
| GitHub Copilot code review | Native GitHub reviewer, comment-only output, custom base-branch and path instructions, applicable suggestions | Explicit schema and confidence gates, specialist evidence, SHA-aware job and reaction ownership |
| PR-Agent | Open-source and self-hostable, configurable commands and models, multiple Git providers | Deep K2-specific policy and two-phase review/fix convergence |
| CodeRabbit | Automatic and incremental review, linked-issue and repository context, team feedback and conversation | Versioned repository authorities, explicit verifier/synthesizer contract, machine-readable lifecycle metadata |
| SWE-agent | Agent-computer interfaces for repository navigation, editing, and testing | Uses the ACI lesson while separating read-only review from write-capable remediation |
| A single LLM prompt | Minimal complexity and low setup cost | Adds complexity only where operational reliability requires it |

The right choice depends on the organization. A general-purpose hosted reviewer may be the best answer for many teams. A small repository may need only one carefully designed prompt and a human reviewer. K2’s architecture is justified by repository-specific contracts, high-risk quantitative domains, automated agent workflows, and the need to make review behavior inspectable.

## Failure modes we encountered or designed against

### Generic review noise

A broad “review this PR” prompt tends to produce naming advice, speculative hardening, and future refactor suggestions. K2 limits rules, requires evidence and line anchors, and explicitly prefers no finding.

### Stale-head publication

Long model calls can finish after a new commit is pushed. The queue cancels old work and rechecks the head before publishing.

### Pull-request prompt injection

Untrusted code and prose can tell the agent to ignore rules or expose credentials. K2 checks out the trusted base, treats PR content as evidence, runs read-only, and keeps tokens outside the model process.

### Duplicate comments after retries

A retry can reproduce the same finding. Hidden deterministic markers make publication idempotent across process attempts.

### False consensus from multiple agents

Several calls to one model family can repeat one misconception. K2 uses specialization and synthesis but does not call it independent consensus; high-risk council mode still requires human review.

### Correct JSON with incorrect meaning

Schema conformance can hide semantically weak output. The service validates rules, lines, confidence, evidence, pass metadata, and current state after parsing.

### Unanchorable but plausible findings

A concern about the system as a whole may not correspond to a changed line. It is skipped or summarized rather than attached misleadingly.

### Reviewer becoming fixer

Allowing the judge to apply its own findings collapses detection, authorization, and mutation into one opaque act. K2 separates the write-capable convergence loop.

### Endless review loops

A fix creates a new head, which can produce another review. The loop has explicit clean, timeout, retry, and blocker outcomes rather than running indefinitely.

### Cost and latency explosion

Parallel agents multiply calls. Routing, feature flags, a concurrency cap, finding caps, and mode-specific failure policy keep the system bounded.
