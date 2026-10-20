# Optional table ablations

The coordinator selected H-first plus structured unwind after the separate and
joint experiments below. Both overlays start from the checked
`p114-table-api01` source, retain Table01, and pin the table and transport
inventories. Their source inventories remain separate from execution receipts.

`unwind-structured.bend` overrides only `p114h_cases` and `p114h_unwind`.
It sends exact constant pop/get calls through `p114t_stmt`, which owns the stack
layout, operation order and fresh site allocation. The table still decrements
depth, pops the FID, dispatches, pops captures, assigns the original pop result
zero, restores captures in order, and restores the recursive result. Zero-capture
cases still omit the capture pop. Full U64 values and the original frame stores
are unchanged. The structured FID is copied to the existing dispatch local.
Every new block resets the emitter's terminal flag; every template threads the
same `P111QCode` counter. The transport namespace gate remains mandatory.

`first-entry.bend` changes only public route selection: complete direct workers
retain priority, then H is tried before the existing R/G/generic chain. No
universal subsumption claim is made: H has its own namespace and size limits.
An H refusal can be checked again by the unchanged fallback chain. Keeping this
small redundant check avoids changing the existing fallback implementation.

## Recorded experiments

All four screens completed on CPU 3, three rounds per role, one runtime thread
and GPU off. Each compares the same tree-bitonic, list-pipeline-128 and
expression-128 inputs and repetition counts within that screen. Values below
are geometric means of candidate milliseconds / upstream milliseconds, rounded
to six decimals; each linked receipt retains exact ratios and samples. Lower is
better. Different screens are not pooled.

| Screen receipt | Candidate | Same-run comparator | Old31 | Correct / qualified records |
| --- | ---: | ---: | ---: | ---: |
| [Table01](../../../../build/phase112/p114-table-screen01-measure/report.json) | Table **5.054188** | Pre-table combined 7.374621 | 11.250931 | 36 / 36 |
| [Unwind01](../../../../build/phase112/p114-unwind-screen01-measure/report.json) | Unwind **4.718717** | Table 4.995604 | 11.192428 | 36 / 36 |
| [First01](../../../../build/phase112/p114-first-screen01-measure/report.json) | H-first **5.303849** | Table 5.298760 | 11.594852 | 36 / 36 |
| [First+unwind01](../../../../build/phase112/p114-first-unwind-screen01-measure/report.json) | H-first + unwind **4.639735** | Unwind 4.792902; Table 5.056486 | 11.363529 | 45 / 45 |

The H-first-only experiment did not establish an improvement. The joint screen
supports selecting the combination: its geometric elapsed-time ratio is 3.20%
lower than unwind alone and 8.24% lower than Table01 in that same run. Final
same-run median batch times, in milliseconds:

| Role | Tree | List | Expression |
| --- | ---: | ---: | ---: |
| Upstream C/Clang | 52 | 49 | 51 |
| Old31 QBE | 554 | 701 | 491 |
| Table01 | 352 | 304 | 157 |
| Structured unwind | 336 | 302 | 141 |
| H-first + structured unwind | **334** | **290** | **134** |

This is a three-kernel selection screen, not a full-corpus result or an unseen
holdout. The clock measures the existing in-program batch, including result
validation; it excludes startup, warmups and compiler/build time. Its 1 ms
resolution and three rounds limit small percentage claims.

All four checked APIs completed with status 0. Unwind-only and H-first-only each
passed four ordinary complete-output observations: zero captures, multiple
owned captures, two-child expression recursion, and owned tree scan beneath a
caller continuation. The joint variant passed those four plus owned String
append, including shared suffix/alias observations. For the 13 observations
under `phase111/p114-{unwind01,first01,first-unwind01}-*-observe/report.json`,
the recorded actual status/stdout/stderr exactly equals the frozen expected
record. The final screen's 45 records also all report correct and qualified.

The selected [checked API receipt](../../../../build/phase111/p114-first-unwind-api01/report.json)
pins compiler source SHA-256
`ba5be2e46ec43fe4f060d6fe361ced8c07eecce3ef8d7d821552c86f86a070c7`
and API SHA-256
`1e758c3e034746d81238df4f6a089d1ec32b26d18be0a58ccc283df697cb5cd5`.
The final measurement receipt SHA-256 is
`ba71518e6de6593aaf541c2fa96dd0a80e46094ad99108fcb2be07a6a0874838`.

## Independent source review of the combination

The independent IR reviewer found no concrete defect in either overlay. Pop-one
then get-zero supplies the unchanged FID dispatch. Each selected case retains
capture-pop, original pop-result zero, ordered capture loads, and result
restoration, including zero-capture cases and pop-name aliasing. The shared
counter advances through all transport expansions and case bodies; opening a
case resets only terminal status. No native recursive edge is introduced.
H-first retains complete-direct precedence and the original R/G/generic fallback;
rechecking a refused H plan does not create a selection loop.

The source author additionally checked that all eight overlay declarations in
the selected composed source match the frozen overlay declarations, ignoring
blank lines and full-line comments, and that both overlay file hashes still
match their inventories. This is source correspondence and a bounded review,
not an arbitrary ownership or whole-compiler proof. It relies on the original
verified graph, closed bounded continuation plan, authenticated transport
layout, reserved namespaces and existing fail-stop runtime boundary. R/G
emitters, the runtime and Table01 remain unchanged. All target execution above
was performed by the coordinator; the source author and independent reviewer
ran no targets.
