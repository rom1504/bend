# Phase178 — frontend cleanup; reject a neutral product refactor

[Design](../../design/phase178/README.md) · [Metrics](metrics.json) ·
[Evidence index](evidence-index.json) · [Reproduction](reproduce.md).

The maintained frontend is smaller, with one selected declaration-parser path.
We removed eight unused definitions and four forward signatures, reconciled the
source inventory, and corrected source/image workflow documentation. We also
implemented and measured a narrow producer/consumer refactor. It preserved the
tested semantics but did not improve complete request time, so it remains an
experiment rather than additional production complexity.

## What changed

Phase177's selected parser resolves a declaration once and carries that result
through its continuations. The old six-helper chain in
`selfhost/src/front/compact-parser.bend` was still present but had no incoming
production call. Its removal also orphaned `f_def_signature` and `f_decl_find`
in `front/declarations.bend`. Neither is a protected declaration, profile root
or promised public export. Delete those too, rather than preserving unused
internal functions with new compatibility wrappers.

The actual fast parser functions are unchanged. All surviving assembled
declarations match the parent after removing comments and blank/trailing
whitespace. The manifest preserves survivor order, all five profiles and all 112
protected declarations. No language, backend, ownership or final verifier rules
changed. Obsolete experimental-source comments in `core/term.bend` were removed.

| Maintained QBE source | Parent `296f288` | Selected cleanup |
| --- | ---: | ---: |
| Physical lines, including comments/signatures | 68,499 | 68,369 |
| Ordered declarations | 8,488 | 8,476 |
| Source bytes | 3,174,925 | 3,167,327 |

This is **130 fewer source lines**, not a large architectural reduction. Exact
selected source SHA256:
`8fd5043cd47361474ab9da6713687a2fd0825d8a7f0885192e5f70f67d7994db`.
Removing source that the checker previously read is not evidence of faster
execution on the same input.

The shared build directory now contains `check-source.mjs`, generalized from
the existing Phase177 independent source gate. It runs the unchanged pinned
upstream loader/checker and requires zero unresolved holes, without acquiring
a JavaScript API. This consolidates a repeated validation operation; compiler
algorithms remain in Bend. The workflow now accurately distinguishes current
source, Phase177 N1, fully reproduced Phase175 N2 and installed Phase171, and
documents all five entry profiles.

## The refactor we tested and rejected

Annotation/layout fusion would either alter roughly twenty dependent helper
contracts or duplicate substantial annotation logic. We chose a narrower test:
produce the erased body and its ordered runtime references together. Three
immediate consumers could then skip a separate `nc_refs(body)` traversal.

The prototype has one shared erasure core, with explicit typed result products
instead of metadata hidden inside `KTerm`. Collection-disabled compatibility
calls avoid constructing reference lists; collecting consumers preserve order,
duplicates, seeded accumulators and pending queues. Native/foreign body
construction retains its original scanner fallback. Annotation, layout and the
independent verifier remain unchanged.

It passes **1,474 complete-value observations**, including bodies, metadata,
erased arguments, dependent fields, aliases, native/foreign wrappers, closure
visitation and incremental fresh/reuse results. Independent review caught an
incorrect seeded-reference expectation before execution; the observer was fixed
without changing the original baseline algorithms.

We built the extracted native frontend with the same qualified Phase175 N2
producer as its reusable Phase177 baseline. CPU3, one runtime worker, GPU off,
identical prepared Base and the frozen 656,302-byte compiler input:

| Complete medium workload | Baseline median | Candidate median | Reduction |
| --- | ---: | ---: | ---: |
| Frontend interval | 12.234s | 12.2215s | 0.10% |
| Fresh process, including observation/teardown | 14.8163s | 14.7884s | 0.19% |

Order was baseline/candidate/candidate/baseline. Frontend samples were 12.234,
12.312, 12.131, 12.234s. All native observations matched. Variation exceeds the
difference: **neutral**, not a validated speedup. The extracted ELF grew from
5,904,864 to 5,933,976 bytes. This is the small frontend executable, not the full
compiler or a generated-program benchmark score.

The new intermediate products and continuation contracts are real costs; this
experiment does not separately attribute their time. It demonstrates that
removing this traversal does not justify those costs at the complete-workload
boundary. We stopped before full compiler acquisition, broader products or a
large qualification campaign. The stronger annotation-consumer retirement idea
remains untested by this negative result.

## Validation and limits

- The final complete maintained source independently checks with zero holes.
  This is source acceptance, not BendTT proof of unsafe assumptions or compiled
  semantic equivalence.
- 565 parser/header observations pass: complete parsed books, diagnostics,
  imports, spans, aliases and cut states. These ran after the nine-declaration
  parser deletion. The final three deletions are its newly orphaned helpers;
  final source acceptance and the source-closure audit cover that extension.
- All five maintained entry closures match the parent: ordinary QBE 5,197
  declarations, native C 3,263, public JS API union 6,810, policy QBE 5,252,
  policy-test 5,289. Every surviving full-source declaration also matches after
  comment/whitespace normalization. The removed names are absent from each
  closure. This is a conservative lexical audit, not a backend theorem.
- No new whole cold-build, generated-program runtime or upstream ratio is
  claimed. Global numbering/source spans can alter emitted bytes despite
  identical reachable code; we did not claim byte-identical compiler images.
- Installed selectors and qualified references are unchanged. There is no new
  N1/N2 qualification, JS/C execution campaign or PR comment.

The earlier full-source result remains Phase177's 54.0595s frontend and 176.8633s
cold-build observation on its frozen input, with the original limitations. Do
not relabel those as Phase178 measurements.

## Rejected attempts and research cost

The initial parser consolidation used optional resolution state and compatibility
wrappers. The API audit showed these wrappers would preserve only dead internal
functions; deletion was simpler. Its source and failed test adapter are retained.
An invalid match placement in that obsolete adapter failed source checking.
One batch invocation used an unsupported flag and failed before target work.
Later, a metadata tuple/list comparison prevented inventory publication; the
following source-check job failed on the missing source before loading Bend.
The maintained CLI refresh corrected that transport mistake. All failures remain
in the evidence, alongside the neutral erasure-product result.

Two bounded agents handled source implementation/audits and independent review.
Root owned integration and the single resource-intensive lane. Two independent
small API checks used disjoint CPUs under one aggregate guard; final native
timing was isolated. The 11 outer jobs total **144.69s**, including 1.16s across three nonzero jobs.
The evidence index records each job and retention closure. Guard time excludes
agent reasoning, metadata work and report writing; no quota figure is inferred.
No build artifacts were deleted.

## What this changes next

Keep the smaller parser. Do not extend the erased-body/reference product merely
because a traversal disappeared. A worthwhile next semantic refactor must retire
a larger representation and its consumers, with native admission and complete
producer-plus-consumer cost measured first. In particular, avoid a per-node
summary product when only a per-definition summary is needed.

The audit also found older lexer helpers and checker adapters, but their
historical API intent needs separate review. They are deliberately outside this
bounded cleanup. The source remains large; this phase does not establish that
large-scale line reduction or a universal IR rewrite would improve performance.
