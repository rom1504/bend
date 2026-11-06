# Phase170: maintained fast compiler promotion

Status: **installed and verified**. The maintained source and all three public
release components are now promoted. See [metrics](metrics.json),
[reproduction](reproduce.md) and the exact [evidence index](evidence/final01/index.json).

This phase integrates Phase169's qualified ordinary QBE path into the maintained
compiler and qualifies the actual installed interfaces. It also repairs a
cross-target lexer allocation problem exposed by rebuilding the JavaScript
compiler from current source.

## Source and interfaces

The final canonical source is 3,150,535 bytes, 67,929 lines and 8,414 declarations:
SHA256 `434edd1d56128f9480800573abf8a0ae21d910a547837af089f25cd1d0e89b71`.
It assembles from the one maintained manifest, without historical overlays.

The first integration imported 144 exact live declarations from the qualified
Phase169 source, replaced two shared implementations, and redirected ordinary
`p111_native_request`. The existing main, argument/session dispatcher and hosted
QBE interface remain. The explicitly authorized native-entry protection pin
changed; the other 111 original protected entries did not. The subsequent lexer
fix preserves all 112 current protection pins and all prior declaration order.

JS, C and QBE have different entry contracts. The public `selfhost/bend` launcher
emits C; the installed QBE component is selected explicitly by the maintained
build tools. Successful ordinary QBE requests do not establish a native session
capability or qualify the public C option parser.

The previous installed selector remained at the consolidation release. Its
source-recipe pin no longer matched maintained source. Reachability inspection
found real shared frontend/C changes since that release, so the old JS and C
images could not honestly be relabeled with the new canonical identity. The
release auditor and its source/stage requirements are unchanged.

## Native integration before the lexer repair

The initial maintained source, SHA `5903812c…`, built N1 in 188.090 seconds and
N2 in 190.627 seconds. N1/N2/Q3 QBE was identical, as were assembly and objects.
The final ELF difference was confined to the nonloaded `.strtab`; every loaded
segment was exact. The full QBE product was 97,393,423 bytes.

All 64 native finite controls passed. All 45 broad correctness products and all 45
distinct timed-wrapper products were byte-identical to the qualified Phase169
products, with unchanged runtime, tools and machine flags. Native P140/2 also
passed six positive requests, mode-matched cold comparisons, actual no-op reuse,
and independent generated-program outputs `3` and `5`. Normal session-tool
admission then passed using the resulting explicit capability binding.

These results qualify that initial source/image, not the later lexer repair.
The final-source gates must be repeated where the changed compiler can matter.

Phase169's 147.764-second figure was a smaller extracted compiler self-build.
Its comparable full canonical workload measured 185.190 seconds versus 244.461
seconds for the reference. Restoring maintained interfaces does not make the
147.764-second scope the installed compiler's build metric.

## Integration finding: retaining String suffixes

The first genuine JS B2 attempt hit the 4 GiB process guard during complete-source
loading. It stopped safely. A bounded Node retry was cancelled without finishing
the loader; its guard's final receipt was not published. That interrupted root
is preserved unpruned, and supplies no clean timing or peak-memory result.

The scalar lexer already wrote `s` when a lookahead did not consume input.
However, pattern-match refinement reconstructed the matched String in generated
JS: `head + rest`, sometimes with two characters prefixed. Repeating this over
large suffixes can form and flatten large ropes. Native linked String nodes make
the same source pattern much cheaper. Native performance alone had therefore
not qualified the source's JS behavior.

Five small wrappers now pass both an inspected String and the original suffix
to private helpers. Only the inspected parameter is matched; a non-consuming
branch returns the untouched original. Every wrapper establishes equality of
the two inputs. Consuming tails, lexical predicates, their order, cursor
arithmetic and errors are unchanged. This adds 25 canonical source lines.

Both independently checked B1 APIs passed 315 exact token pairs and 10 comparator
mutation controls under Bun and Node, plus complete 64KiB loader-graph equality.
The 64KiB lexer observation was 0.397→0.160 seconds under Bun and 0.256→0.170 under
Node. These are small diagnostic observations. Bun's complete 64KiB loader was
slightly slower in its single observation (1.80→1.94 seconds); do not present the
lexer ratio as a whole-compiler result.

The actual repaired full-source JS load completed in 64.789 seconds under Bun.
Genuine B2 self-emission completed in 312.993 seconds, selecting 4,271 definitions
without increasing its capacity bound. The final same-source native comparison is 189.191 seconds with the old lexer
and 189.329 seconds with the repaired lexer, a 0.073% difference in single
observations. This supplies no evidence of a material native regression.

This is a source invariant plus finite/differential evidence, not a new BendTT
theorem or an end-to-end compiler proof.

## Final source builds

The final N1 builds N2 in **189.329 seconds**, including emission, QBE machine
construction, assembly and linking under the existing streaming pipeline.
Emission and QBE overlap (183.373 seconds), so their interval must not be added
to the total. This is a fresh process with authenticated prepared Base
(`--mode cache`), not a warm session and not a measurement of rebuilding Base.
Independent source checking is a separate gate, outside this clock.

N1, N2 and Q3 reproduce the complete QBE product. N1/N2 assembly and object bytes
are identical; all ELF loadable segments match. Whole ELF files differ only in
the nonloaded `.strtab`, so whole-binary byte equality is not claimed. The selected
N2 is 16,031,672 bytes, SHA256
`0dba3d4d19cd974e759058afbe86608fc7e1770d0c5ebf8f9d06c2697b658f4f`.

The genuine JS B2 builds in 312.993 seconds; B3 freshly checks the same source
and emits the exact same API bytes in 275.154 seconds. The selected B2 is
5,024,712 bytes, SHA256
`a689f6b8629eb959f1489f63675a15748f033e14f2cb57fdba5489c5e7c54329`.

The native public C compiler is derived through the maintained thin CLI profile,
with only `main` and `p86_effect_read` replaced. Bend emits its C; the unchanged
Clang `-O2` policy builds the package. This image is 23,839,160 bytes, SHA256
`cbb3351284179518c6aa221575a7b19db4fd1d65699886446000b51deec89489`.
It passed the independent public compatibility controls, including exact incumbent
numeric/IO C products, complete output oracles, live/cache equality, relocation,
option handling and corrupt-asset refusal.

The final N2 passes all 64 finite controls. Both its 45 broad correctness QBE
products and the distinct 45 timed-wrapper products are byte-identical to Phase169
with unchanged runtime/toolchain identities. This preserves the corresponding
measured generated code; it does not constitute a new runtime observation.

The actual final B2 passes all 45 broad program controls. The first attempt reached
its underestimated 300-second outer deadline after passing 33 cases; it remains
an incomplete qualification, not a semantic failure or a pass. The unchanged gate
was repeated with a 600-second bound and completed in 401.361 seconds (402.349
including the outer guard). The retry retained the same RSS/disk limits.

The final N2 also passes positive native P140/2 reuse: six requests match same-mode
cold results, no-op reuse is observed, an edit changes the product, and generated
programs independently print `3` and `5`. Normal maintained session admission then
passes with the resulting exact-image capability binding. Hosted recovery/object
unit checks are separate; native recovery/object units are not claimed.

## Resource and evidence discipline

All compiler and generated-program jobs use one guarded CPU 3 lane, bounded RSS,
fresh roots and the 5 GiB disk reserve. Frozen source, images, runtime/toolchain
identities and independent output oracles remain explicit. Failed attempts are
retained. The interrupted Node run is explicitly distinguished from normally
closed failed guards.

Verified selective reclamation recovered 1,095.59 MiB from 135 superseded files
across 51 closed roots: assembly/object products plus five archived diagnostic
graph/book JSON files. All other archived members, current/reference
images, quality products and performance oracles remain intact. No phase folder
was deleted by age. See the [retention audit](../../experiments/phase170/retention.md).

## Installed result and qualification

The unchanged release auditor accepted the final proposal. Installation replaced
QBE N2, JS B2 and public native C N1, retained actual destination backups, then
published `selfhost/manifests/current.json` last. Operational verification
reassembles the maintained modules and matches the exact canonical identity.
All three operational asset maps now select the installed QBE N2 and the separate
checked hosted B1 API. Their unrelated providers and toolchains are unchanged.

| Gate on actual final artifact | Result |
| --- | --- |
| Native QBE finite suite | 64/64 |
| JS B2 broad suite | 45/45 |
| Public native C broad suite | 45/45 |
| Public JS behavior | 7/7 |
| JS frontend type/affine refusals | 2/2 |
| JS-hosted C focused execution | 5/5 |
| Checked hosted QBE focused suite | 19/19 |
| Native session positive requests | 6, with mode-matched cold references |
| Hosted session controls | 8, including 2 semantic refusals and cold comparisons |
| Timed QBE products | 45/45 exact Phase169 products |

Installed default native QBE, hosted QBE and native session smoke checks pass.
The default public JS command under Node 24 prints `42`; the public native C
command emits the exact independently qualified C product. An initial smoke
assertion incorrectly expected empty native CLI stderr. Its normal 59-byte
proof-check diagnostic matched the previously qualified baseline; the corrected
smoke checks that exact contract. No compiler change was needed. The failed
smoke and its original method remain in the evidence.

The transaction is `selfhost/build/phase170/install-final01`, with destination
backups and a mutation journal. The separate asset-map transaction is
`selector-install01`. The earlier selector, native package and component images
also remain in `previous-install`. These are local rollback artifacts, not
files to delete by age. The bounded committed receipt archive deliberately omits
large executables, generated APIs and QBE; their exact identities and acquisition
receipts are retained. A fresh checkout still requires authenticated external
assets or a new acquisition using the maintained workflow.

## Cost and remaining limits

The [cost ledger](costs.json) records **3,825.41 measured guard seconds** across
38 completed attempts, approximately 63.76 minutes of target-lane wall time.
It includes acquisition, final validation, earlier validation, installed smoke
checks and failed attempts. The interrupted Node attempt lacks a final receipt
and is explicitly excluded; this is a lower bound, not total research elapsed
time, agent cost or cumulative CPU time. Acquisition alone accounts for 2,154.10
seconds. The avoidable JS deadline retry accounts for 300 seconds; future broad
live-JS gates should budget from the observed roughly 402-second full run.

This phase makes the accepted fast path usable by default and repairs its
cross-target integration. It does not establish a new upstream speed ratio,
full language conformance, a new BendTT theorem or a universal optimization proof.
The current full maintained-source target remains below 150 seconds; the measured
189.329 seconds has not reached it. Use the installed native compiler for the
next research cycle, with full release qualification reserved for source/interface
changes that justify its cost.

Source checkpoints: `d351a28` integrates the qualified fast path; `a97447e`
preserves lexer suffixes. No PR comment was posted.
