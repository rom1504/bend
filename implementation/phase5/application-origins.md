# Application-origin reconstruction: rejected

P5-005 found a small correct diagnostic improvement, but its repeated parsing
cost is too high. **Do not promote the isolated overlay.** Production diagnostic
origins, KTerm representation and accepted compilation paths remain unchanged.
The [experiment and patch](../../experiments/phase5/P5-005-application-origins.md)
retain the tested candidate rather than silently replacing it with a different
algorithm.

## What was tested

Adding source positions to `App.id` is unsafe as a local change: exact comparison,
normalization, specialization keys and maximum-id traversal observe it, and the
Phase4 stable-substitution fast path requires canonical App metadata. Instead,
the candidate reuses a retained Ref head's lexer position. It requires the actual
head token followed by `(`, reparses with existing `f_expr(tokens,13)`, scopes with
empty context using existing `f_scope`, and requires `norm_exact` with the original
App. It also requires the parsed remainder to stay on the same physical line.
The resulting origin is the actual head token, not a claimed full application
span. Existing leaf-origin precedence and ambiguity refusal are unchanged.

The candidate adds four helpers only to an isolated `diagnostic/frontend.bend`.
Both original and candidate are genuine checked bootstraps with the pinned
upstream compiler. Their source/API identities are:

| Artifact | Original combined B1 | Isolated candidate |
| --- | --- | --- |
| Source SHA256 | `40c05814bd338e1d2270061b85f1567bad742b79b0625bca583b5d0cbcf363de` | `1e83a22817b74bf96b89e826910bef81de6bc670923c4e522c7c94009eff2160` |
| API SHA256 | `a17d909d9c481784545b5ca36c9f1dba73960eaa98cee2ac089362321674b9a4` | `1c209567fa543acdd779c95ce52f030d2064a9eb09885703407c8311abf0c06c` |

The isolated build passed. Eighteen original/candidate/live-TypeScript cases
passed an unchanged-or-exact-reference gate, repairing six custom examples.
Multiline calls, substituted heads/arguments, wrapped calls and import aliases
remained conservative refusals. A second four-case gate covers local heads,
local arguments, parenthesized heads and a 128-argument invalid application.
All four complete with the intended checked rejection; no compiler crash or
mutual failure is counted as correctness.

The broader selected gate covers **all 147 known missing-excerpt check cases and
all 82 previously exact negative-check cases**. All prior exact diagnostics remain
unchanged. Four upstream diagnostics become exact; the other 143 remain unchanged:

- `check/bool_one_way.bend`
- `check/float_builtin_arg.bend`
- `page/overapply_hint.bend`
- `parse/builtin_arity_mismatch_000.bend`

All 229 observations preserve acceptance/check phase and checked status. The
standard targeted harness still returns exit1/`selectedComplete:false` because
143 fixture diagnostic mismatches remain. Its `complete:false` also correctly
means this is not the full corpus. The separate comparison establishes only the
stated no-regression gate. An initial comparison-tool attempt incorrectly
required full-suite `complete:true`; its source and assertion log are retained,
and the corrected comparison validates all selected rows, identities and actual
checked rejections rather than changing any conformance verdict.

## Why it was rejected

For every App prefix, the candidate repeats head traversal, token search, parsing
and scoping. A long n-argument call can therefore repeat O(n)-sized work n times
while producing a rejection diagnostic. Independent review found no blocker in
the narrow head-token semantics, but identified this cost and the now-stale
original comment claiming that no source is reparsed. That comment remains in the
unpromoted historical snapshot; no production documentation inherits the claim.

A 128-argument invalid call produced these ordinary `inspect(mode:'check')`
observations, including fresh process startup and cached Base preparation:

| Variant | Wall | Peak RSS |
| --- | ---: | ---: |
| Original | 2.855 s | 402,104 KiB |
| Candidate | 4.845 s | 406,852 KiB |

Both ran on CPU2 with the same Node24.18.0, 4 MiB stack and 4 GiB heap and returned
the expected rejection. These are **one-direction, unpaired observations during
other correctness work**, not controlled benchmark ratios. They are nevertheless
a useful falsifier combined with the directly identified repeated work. An
earlier exploratory observation was 3.620→6.737 s; that correctness worker also
reconstructed origins a second time for inspection, so it is retained separately
and is not presented as ordinary compiler latency. No accepted-path speed claim,
full-source proof or production change follows from this experiment.

Skipping every App that is its parent's function child is not an equivalent
repair: `(f(bad))(x)` can have a useful inner written-call anchor while the outer
call cannot reconstruct. Arbitrary token budgets were not added. A future design
could parse once per actual retained Ref token, then associate exact reconstructed
source terms with existing paths. It would need to prove module/definition scope,
ambiguity and substitution behavior and measure index cost; it is not implemented
or promised here.

## Reproduction and evidence

Run from `selfhost/`, with fresh output directories and explicit CPU allocation:

```sh
node tools/performance/phase5/application-origins-probe.mjs \
  build/phase5/application-origins build/replay-origins
node tools/conformance/target.mjs \
  build/phase5/application-origins/negative-config.json build/replay-negatives
node tools/performance/phase5/application-origins-compare.mjs \
  build/phase5/application-origins/negative-selection-provenance.json \
  build/replay-negatives/paired.json build/replay-negatives/comparison.json
```

The prepared project must first be genuinely bootstrapped as recorded in its
retained bootstrap report. The supplemental and ordinary-cost tools accept the
prior gate directories; no new default API is generated. The
[archive manifest](application-origin-evidence/manifest.json) retains 4,259 file
identities in 3,325 verified gzip objects (4,139,186 bytes), including checked
inputs, all 229 observations and live reference results, selected requests,
fixtures, consumed tools, API/build reports, exploratory costs and comparator
failure. Absolute paths are historical identities; this is preservation, not a
claim of automatic relocated replay. Node remains an external hash-identified
prerequisite. Root owns any future implementation or integration decision.
