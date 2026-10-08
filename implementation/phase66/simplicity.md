# Phase66 simplicity audit: final07 source and retained checkpoints

**Frozen checked attempt07 contains 28,490 physical Bend lines: +94 lines
(+0.331%) versus Phase65, with the same 115 modules, 642 laws and 119 types.**
The [final07 census](evidence/simplicity-final07.json) verifies 533 input
identities and counts actual checked/raw B1 and genuine B2 artifacts. The
[separate source-freeze audit](evidence/source-freeze-final07.json) verifies all
313 live original source files against their immutable attempt07 counterparts,
then rehashes both copies. Root records source freeze at `f9667c2`; the data audit
runs no Git and does not independently infer a commit from these hashes.

The [attempt03 receipt](evidence/simplicity-attempt03.json) (530 identities),
[attempt02 receipt](evidence/simplicity-attempt02.json), and
[baseline receipt](evidence/simplicity-baseline.json) (319 identities) remain
unchanged. The baseline includes the entire 299-file preserved source snapshot.
These are source/image inventories; compiler correctness, timing and installed
release admission remain separate gates. No compiler, generated program or
benchmark is executed by this audit.

## Consistent maintained-Bend boundary

Count exactly the `.bend` modules named in the frozen `src/compiler.json` for
each state, preserving manifest order and rejecting duplicate or escaping paths.
The rules are unchanged from [Phase65](../phase65/size.md): UTF-8 Python
`splitlines` for physical lines; code lines exclude blank lines and lines whose
first nonspace character is `#`; declarations count line-start `def`, `law` or
`type` followed by whitespace. Bytes are the original UTF-8 bytes, with no
whitespace normalization.

Exclude generated assembly/images, runtime/host sources, upstream Base, tests,
benchmarks, reports, experiment tools and nonmanifest backups from this Bend
series. They remain separate costs, rather than disappearing into an ambiguous
repository-wide denominator. In particular, adding migration evidence must not
be misreported as growth of the maintained compiler algorithms.

| Manifest-listed Bend source | Phase65 State10 | Phase66 final07 | Delta |
| --- | ---: | ---: | ---: |
| Modules | 115 | 115 | 0 |
| Physical lines | 28,396 | 28,490 | +94 |
| Code lines | 23,284 | 23,353 | +69 |
| `def` declarations | 3,269 | 3,282 | +13 |
| `law` declarations | 642 | 642 | 0 |
| `type` declarations | 119 | 119 | 0 |
| UTF-8 bytes | 1,295,705 | 1,301,018 | +5,313 |

These baseline values were recounted from
`selfhost/build/phase66/baseline-source/`, checked against
`baseline-source.json`, and required to equal the published Phase65 State10 size
receipt. Current mutable working-tree files are not the baseline.

For the candidate, count the immutable source snapshot of its actual genuinely
checked attempt and verify every manifest/module against the attempt's frozen
identity. Require the expected new upstream pin, `checked` and `strictExact`.
Report added, removed, changed and byte-identical modules separately. Keep failed
or intermediate candidate counts under their own identities; they cannot stand
in for the eventually selected source.

Final07 changes 27 modules relative to Phase65 and preserves 88 byte-for-byte.
The source after attempt03/04 adds **37 physical lines, 27 code lines and four
definitions** across three modules:

- `back/js/validate.bend`: +27 physical lines and three helpers thread successful
  printability visits across fields and constructor siblings. Shared child types
  are checked once per request; the existing recursive-type rule remains.
- `back/js/direct/calls.bend`: +10 lines and one helper use the existing remaining
  body-scan budget for telescope lookahead, replacing the separate 64-field
  ceiling without charging the body scan twice.
- `back/js/direct/core.bend`: no extra line; `Min` joins existing erased-expression
  cases. The change does not introduce runtime minimum arithmetic or a new pass.

Attempt03/04's +57-line inventory remains an intermediate checkpoint; these
corrections are the additional cost of closing the full-JavaScript gaps.

| Actual image role | Phase65 bytes | Final07 bytes | Delta |
| --- | ---: | ---: | ---: |
| Raw checked B1 | 1,949,868 | 1,957,889 | +8,021 |
| Selected equality-derived B1 | 1,976,779 | 1,977,285 | +506 |
| Genuine B2 | 4,054,089 | 4,069,154 | +15,065 |

The selected baseline uses profile6; final07 uses profile7. The final images are
raw `ee717187…`, selected `bb6c6e2a…` and B2 `0067736c…`.
The B2 receipt binds the actual selected attempt and assembled source
`1b29d5c4…`; both Phase65 and final07 request 99 roots. An equal root count does
not imply identical reachable helpers, Base definitions or emitted bytes.

Outside the Bend series, maintained support costs also grow:

| Separately counted support boundary | Phase65 files/physical lines | Final07 files/physical lines | Line delta |
| --- | ---: | ---: | ---: |
| Four maintained host helpers | 4 / 1,797 | 4 / 1,798 | +1 |
| Five ordinary JS fragments plus direct runtime | 6 / 1,187 | 6 / 1,282 | +95 |
| JS effect provider source | 37 / 731 | 35 / 859 | +128 |
| Native runtime | 1 / 3,024 | 1 / 3,094 | +70 |
| Native effect provider source | 45 / 3,799 | 45 / 3,829 | +30 |

Provider files describe source inventory, not a count of qualified methods.
The removed old JS polling providers survive in the baseline snapshot. Ordinary
effect handling grows 101→174 lines and direct runtime 471→492; foreign/readback
change bytes without changing lines. Native additions repair ordinary Base ABI
and foreign-value bridges while explicitly refusing unsupported dispatches.
These are real maintenance costs; they are not hidden in the Bend-line total.
Detailed per-file metrics and grouped totals are in the two final07 receipts.

## Host, runtime and generated artifacts

The established host series counts `typed-driver.mjs`, `base-cache-graph.mjs`,
`development/workflow.mjs` and `development/release.mjs` separately. Report
changed files with physical lines, nonblank lines and bytes, and explicitly
inventory any newly introduced host helper outside this established list.

The runtime inventory separates the five maintained ordinary-JS fragments
(`core`, `base`, `effects`, `readback`, `foreign`), the direct-JS runtime,
native runtime and per-effect JS/C sources. Generated `src/runtime.mjs` receives
an identity but is not added again to maintained source totals. Its constituent
fragments already account for that ordinary runtime. Imported native/effect code
is implementation inventory, not evidence that a new compiler algorithm was
written in JavaScript or C.

Keep actual raw checked B1, equality-derived checked B1 and genuine B2 sizes
separate. The baseline receipt verifies their bytes against the published
Phase65 images and checks B1/B2 hashes against the registered campaign. A
candidate B2 is counted only when its complete passing emission receipt
binds it to the same checked attempt and source. Export-set changes must be
reported with image-size changes; actual artifacts with different export scopes
are not an equal-export size microcomparison.

A line reduction that moves algorithms from Bend into host glue, duplicates an
existing compatibility representation or drops supported behavior is not a
simplification under the task's purpose. Any changed scope must remain visible.

## Upstream inventory, with scope caveats

The audit independently reads both frozen upstream checkouts and verifies their
files against the registered upstream-delta hashes. The old pin is
`018751270e800bc222a93dad7f257083ee53a5f7`; the new pin is
`059266225b77c8ca256ac6b25ee5c21449bab151`.

| Upstream file/role | Old physical lines | New physical lines | Change |
| --- | ---: | ---: | ---: |
| `bend2/bend.ts`: language/parser/theory/checker | 3,869 | 3,882 | +13 |
| `bend2/comp.ts`: emitters and embedded runtimes | 6,468 | 6,373 | −95 |
| `bend2/main.ts`: CLI and loader | 908 | 924 | +16 |
| Primary three-file TypeScript inventory | 11,245 | 11,179 | −66 |
| `bend2/safe.ts`: verdict/elaboration support | 1,442 | 1,567 | +125 |
| `bend2/base.bend`: prelude, separately scoped | 3,009 | 3,089 | +80 |
| `bend2/bendtt.lean`: kernel/proof development | 3,892 | 3,895 | +3 |

The TypeScript primary total includes embedded native/runtime source in
`comp.ts`, while our manifest-only Bend total excludes runtime and host files.
Conversely, our maintained source includes explicit law/declaration structure
whose textual cost differs from TypeScript. Therefore final07’s 28,490 versus 11,179 is a
reproducible inventory comparison, **not an equivalent-scope complexity ratio**.
The new upstream is 66 physical lines smaller across those three files, but that
alone does not establish fewer concepts or equivalent functionality after its
95-commit change set. Source-size and performance changes are independent axes.

## Qualitative concept and responsibility ledger

A `type` declaration or function is not one semantic concept. Do not invent a
single concept count by equating those proxies, or claim a reduction because
names were shortened. Review the following responsibility areas against the
actual migration diff and record each added, retained, combined or retired
contract with its owning files:

| Review area | Existing responsibility | Final07 migration account |
| --- | --- | --- |
| Core terms and evaluation | Canonical terms, binding/substitution, normalization and graph evaluation | Core KTerm/normalization model retained; no new intermediate representation or evaluation engine |
| Source context and checking | Names, prefixes, source origins, quantities and checking decisions | Raw namespace identity stays internal; display conversion is an explicit boundary, not a second lookup identity |
| Typed backend planning | Shared facts, call/layout decisions and lowering products | Min uses existing erasure; wide-field lookahead shares the existing budget, with incomplete scans still refused |
| Native representations and ABI | Scalars, constructors, calls and runtime admission | New Base shapes require queue marshalling, foreign-value/native ABI repair and explicit unsupported native effects |
| Prepared Base artifacts | Mandatory world/graph data plus optional owned annotations | Existing formats/lifecycle retained; final07 owned/custom controls qualify exact new Base permission on both B1 and genuine B2 |
| Diagnostics and resource boundaries | Current stops, budgets, errors and refusal order | Printability now shares successful visits across sibling paths; existing recursive-type and body-scan limits remain |
| Effects and host support | Runtime implementations, loading, transport and validation | Timed waits add deadline/cancellation obligations; old JS polling files retire; retained legacy/native gaps remain explicit |
| Compiler image roles | Checked B1, genuine B2, reproduction and installed package | Profile7 admits the new unary runtime while retaining six historical replay profiles; checked B1 and genuine B2 remain separate |

This is an eight-area review checklist, **not a claim that the compiler has eight
concepts**. Phase65's optional annotation lifecycle already existed, so requalifying it
for the new Base does not remove that responsibility. Final07 keeps the core,
cache formats and backend representations while simplifying repeated
printability work and removing the unrelated fixed-width call-analysis ceiling.
The migration also adds real effect, ABI and historical image-compatibility
duties. It closes behavior gaps with a small source increase; it does not
establish fewer overall semantic concepts or a 50%/75% line reduction.

## Reproduction and immutable receipts

The [audit script](simplicity-audit.py) reads data only and writes a fresh output.
It does not import Node, spawn a process, run Git or mutate source snapshots.
Run it on CPU0 with a new pathname:

```sh
taskset -c 0 python3 implementation/phase66/simplicity-audit.py \
  --output /tmp/phase66-simplicity-baseline-recheck.json
```

The [version2 audit](simplicity-audit-v2.py) labels the actual selected B1 role
explicitly, so a raw `checked` attempt is not mislabeled equality-derived. The
original producer and baseline receipt remain unchanged. The final07 source/image invocation is:

```sh
taskset -c 0 python3 implementation/phase66/simplicity-audit-v2.py \
  --attempt selfhost/build/phase66/checked-b1-07 \
  --b2-report selfhost/build/phase66/bootstrap-b2-07/full/report.json \
  --output /tmp/phase66-simplicity-selected-recheck.json
```

Use a fresh output path; never overwrite a consumed census. The final07 receipt
already binds the closed B2 emission to its actual checked attempt. Earlier
checked-source-only inventories intentionally omit B2. Audit success establishes
the counted bytes and identities, not correctness, speed, installed release
readiness or compiler soundness.
