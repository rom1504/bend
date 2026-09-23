# P6-003 — Prefix operands and erased-name boundaries

- Owner: phase6_semantics; independent reviewer: root or delegated reviewer.
- Preregistered: 2026-09-23T05:09:08.606298+00:00. First bounded delivery by 2026-09-23 06:15 UTC; campaign ends 15:06:12 UTC.
- Objective: close real parse/check gaps without weakening checking or changing the core ABI.
- Initial status: read-only mechanism review; no implementation or measurement yet.
- Decision: investigate in isolated source projects; no default/source promotion here.
- Related evidence: [rejected scope-only marker](../../implementation/phase6/marked-name-analysis.md), [erased-name ablation](../../implementation/phase6/semantic-gap-analysis.md).

## Hypothesis and falsifiers

Pinned TypeScript consumes a `+` operand with postfix/application precedence before testing whether it is a binder or a quantified datatype. The port marks the atom before application growth, which loses the distinction between `+f(1)` and `(+f)(1)`. A source parser change to consume the full prefix operand, then classify it, should restore both cases. Empty calls must preserve the head, as upstream does: `+value()` is not the same case as a one-argument call. Existing operand errors must propagate unchanged.

A marked non-datatype value name must be deliberately unbound, never resolved to an existing lexical binder. Reuse the prior transient-marker mechanism only after the operand is classified; global freshening consumes the marker into a fresh ordinary Var without adding an environment mapping. No permanent core tag or U32 sentinel. A marked datatype requires a positive leading-quantity count; a bare name additionally requires all parameters to be quantities. This must reject the known `+U32` false acceptance. Local shadowing, imported/qualified globals, namespace resolution, templates, match/lambda/local binders, nested marks, arrays/offload syntax, and declaration order are explicit falsifiers. Namespace-global names need separate attention: a raw unqualified spelling can resolve to a qualified definition in an imported module.

Evaluate the already isolated erased-name guard separately on freshly retained controls, then combine only after the prefix capsule survives. Mandatory assignment and token-end error cursors may require a follow-up rather than silently broadening this first patch.

Stop or revise on any new acceptance/phase regression, binder capture, marker escape, changed accepted core graph, or error-order counterexample. A new candidate gets a new source project/attempt directory; failures remain immutable.

## Setup and gates

Baseline is repository commit `a6459af` and its released equality derivative `e2b5463678a26558e8fea1d585782e0863f1046067949a374f0469080281b15a`. Pinned upstream remains `6018e28ecc67cf1fffc0c20c64b11023474c2df8` and is never edited. All compiler source mutations remain under `selfhost/build/phase6/campaign/semantics`; production `selfhost/src` and `dist` stay unchanged.

Use the maintained genuinely checked bootstrap/equality workflow, frozen source/host/runtime/Base and fresh API-specific validated Base caches. CPU 1, Node 24.18.0, 4 MiB stack and 4 GiB heap; finite outer caps (300 seconds per build/selected gate, smaller direct controls). Jobs overlap independent correctness work, so elapsed observations are not speed comparisons. No full frontend, full source or fixed-point job without root scheduling.

Focused differential selection includes the two pinned `+name` fixtures, `prefix_operator_dead`, all prior marked/erased witnesses, the rejected direct-call counterexample, empty/grouped/multiple calls, bare and applied ADTs, qualified/aliased/local-shadow names, imported namespace globals, valid marked binders, and competing syntax errors. Preserve acceptance, phase, checked flag, exact diagnostics, strict oracle results and live-reference stability separately. Require actual small interpreter/JS/native execution for accepted controls after the frontend gate. Direct graph controls verify marker elimination and no collision with ordinary, nested or large raw binder IDs, and compare seeded/unseeded loading. Accepted controls compare final core graphs against the baseline where IDs should remain unchanged.

Durable output will include [the implementation report](../../implementation/phase6/prefix-semantics.md), source patches, exact fixture/oracle files, launch commands, input identities, raw reports and failed attempts. Generated APIs may be retained in a deduplicated archive or explicitly documented with genuine checked regeneration prerequisites. Root owns integration and Git.

## Follow-up bounded erased-assignment check — 2026-09-23T05:23:30.224005+00:00

The independently rebuilt original name guard reproduces28/28 classification agreement and20/28 exact observations. Before combining, test the documented mandatory-assignment gap: a bare `-x` must not become a valid reply referring to a bound x. A fresh erased-only project will validate the existing statement result is Local/Parallel/Error, otherwise report the required `=` at the actual remaining token. If an erased parallel let is formed, its body-level erased quantity must apply to every binder, not only the first. Retain both old and new source projects and test malformed/typed/plain/parallel neighbors, first error, and actual accepted execution. No broad parser rewrite or changes to ordinary statement rules are planned; a counterexample outside this narrow result boundary must be reported before broadening.

The result-only v2 counterexample is confirmed at 2026-09-23T05:28:27.372085+00:00: a valid erased binding with newline before `=` fails both lanes while pinned TS accepts. Its52-row gate remains immutable (50 phase agreements). V3 will parse only the erased header explicitly: after the first name, accept mandatory `=`/single-binder annotation across whitespace, or additional name-headed terms only on the same line; quantities become zero for all erased parallel binders. Existing shared value/body/parallel construction remains unchanged. Add plus-marked second-binder rejection, empty-call second binder, missing parallel assignment and body-order controls before accepting the wider boundary repair.

## Frozen combined candidate — 2026-09-23T05:37:36.355007+00:00

Prefixv2 plus erasedv3 is now frozen as project-combined-v1 / attempt-combined-v1. The140-observation paired frontend gate matches all classifications, with98 exact observations versus33 at baseline (65 gained, zero lost). Candidate/reference observations are also exactly unchanged from each capsule's separate ablation. Only the two known pinned +name checker diagnostic oracles fail; the pinned erased invalid-name fixture is exact. Twenty direct graph controls and36 interpreter/JS/native observations per compiler pass, with exact runtime agreement. No production/default source promotion or broad full-inventory claim. The report, file-only audit and evidence archive retain failed source/oracle/tooling/native attempts. Root owns the next integration gate; new experiments use a different directory and record.
