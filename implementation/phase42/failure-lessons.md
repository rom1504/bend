# Phase42 failure lessons — interim ledger snapshot

This note reads [campaign.jsonl](../../selfhost/build/phase42/campaign.jsonl)
through sequence **292**: **291 enclosing job events**, **38 with
nonzero return codes**, and **253 zero-return events**. The ledger remains open;
these are job outcomes, not final gate counts, distinct defect counts, or release
qualification. Snapshot SHA256: `2d395bb70af681f35890cd66965709dfaef98c0a3fc1958ba48cedb95bbe84df`. Parent/child
intervals must not be added twice; no counterfactual time saving is claimed.

## Failures had different causes

- **Real compiler correctness and compatibility defects.** Covered-call rewriting
  replaced a recursive unary combiner's original App shell before structural
  classification; checked03/05 emitted an empty call spine and undefined `$u0`.
  Complete intermediate values exposed this although the outer checksum passed.
  Owner-thread refusal preserves the shell containing self recursion. Later,
  strict quantity1 Sigma equality replaced the shared local-region policy and
  removed established quantity2 vector workers. All35 fallback value oracles
  passed before activation failed. The five-line checked16 domain split restored
  the original region policy while retaining strict JPure comparisons. Preserve
  [fusion controls05](../../selfhost/build/phase42/fusion-actual-controls05)
  and [counter failure](../../selfhost/build/phase42/integration02/run-preflight-counter).
  The unchanged successor counter gate passes35 oracles/five boundaries;
  native proof retains43 observations.
- **Invalid fixtures or source implementation drafts.** The renamed call fixture
  first used an unsupported computed match scrutinee, then consumed an affine
  leaf twice. Valid v3 extracts the selector and uses a typed unrestricted alias;
  it passes pinned TypeScript before runtime acquisition. Selfhost patch drafts
  also had missing annotation/delimiter/arity errors. These are not generated
  program behavior regressions. Retain the failed acquisitions and corrected
  [fixture versions](../../selfhost/tools/performance/phase42/calls/fixture-renamed-v3.bend).
- **Stale instrumentation or provenance assumptions.** Early nested JS edits
  overlapped; AST composition fixed the producer. Structural controls selected
  an irrelevant root when mutating a union dependency, then required zero entry
  for `Array.isArray`, which that admitted path did not observe. Successors use
  each root's exact guard and preserve result/trace parity for irrelevant changes.
  Flat lexical clones made global worker/line counters incomplete; each probe
  must count its actual scope. The owned tree/unary producers also incorrectly
  required checked02 and selected16 runtimes to match despite the separately
  checked Nat metadata transition. Their frozen v2 successors bind each role's
  API/runtime/Base/driver to its own checked attempt. Semantic checks were not
  relaxed. See [v2 derivation review](../../selfhost/tools/performance/phase42/calls/owned-actual-derive-v2-review.json).
- **Producer/acquisition failures.** Checked12 used the old assembled runtime
  after editing a runtime fragment: BST216 values/24 aliases passed through
  fallback, but actual activation was zero. Rebuilding the bundle corrected the
  acquisition; the failed receipt remains. A TypeScript acquisition also needed
  a sandbox git retry. Neither is evidence that the algorithm was slower or wrong.
- **Contract diagnostics.** Preimport BigInt replacement produced a reentrant
  value/trace divergence. It remains preserved evidence outside the previously
  published standard-intrinsics-at-initialization contract, not a waived supported
  failure. Supported Nat controls independently pass10 arithmetic/error oracles
  and nine postimport boundaries, including Error-hook proof suspension.
- **Timed prototypes rejected on evidence.** Hoisting was inconsistent; lazy
  stacks/pruning regressed the largest tree around7–10%. Transfer temporaries
  added no gain over native constructors. Native-only BST construction won
  roughly1.30–1.67× in the scoped32/128 screen. Saved-JS success still required a
  general source patch, actual activation, aliases, mutations and deep controls.

## Highest-payoff changes to the next campaign

Use dedicated predicate/instrumentation interfaces with explicit scope and
versioned output, rather than matching generated names, comments or fixed source
substrings. A small emitted-assay descriptor should identify actual root guards,
lexical worker/clone identity and supported counter sites; instrumentation must
resolve bindings before inserting counters. Keep it separate from semantic
oracles so an instrumentation failure cannot masquerade as either correctness
or a lost optimization. Strict native equality should be probed through its
own API, not a shared legacy selector with a different proof domain.

Before the first build, enumerate consumers of every changed shared predicate
and run old-domain positives alongside new-domain refusals. Validate source
fixtures with pinned TypeScript and syntax-check generated diagnostics before
three-role acquisition. Assemble runtime fragments before binding a checked
image. Bind roles independently, then run cheap full-value **and ordinary-entry**
controls before timing or broad qualification. These changes target the repeated
avoidable retries; final numerical efficiency remains root-owned accounting.
