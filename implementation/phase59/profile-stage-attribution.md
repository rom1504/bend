# First-window profile attribution by exact ancestors

A conservative partition is possible. The
[JSON](../../selfhost/tools/performance/phase59/evidence/profile-stage-attribution-v1.json)
(SHA256 `55e71c37afc2afac5817983873a4aca84e8bde1a0b3c5f4f701531dbacc30454`)
contains nine saved captures: four original CPU, four allocation, and the separate
fresh TS Evening CPU retry. This is data-only analysis; no compiler, generated
program or profiler ran. Existing raw files remain unchanged. Root's stage wall
clocks and the other owner's whole-profile/clean measurements remain separate.

## Method and boundaries

Each CPU `samples[]` event contributes one count. Each allocation `samples[]`
event contributes its recorded size once. Starting from that sample's node, walk
its actual parent chain and choose the nearest exact matched entry ancestor.
Every sample belongs to one bin, including `unassigned`; partition mass equals
raw sample count/size exactly. Never add inclusive parent weights or the heap
tree's `selfSize` totals to sample sizes. Sampled allocated bytes include collected
objects under the original producer policy; they are not peak RSS, retained heap
or exact allocation counts.

Direct boundaries require both exact selected API URL and actual generated
function name, verified present in the selected image. They are
`check_program_diagnostic`, `annotate_selected`, `reach_book`,
`jd_reach_selected`, `jd_library_selected`, and `jd_program_selected`.
The source-discovery boundary additionally requires the exact private ordinary
driver URL and `discoverSources` frame. Pinned TS boundaries are `book_load` and
`book_valid` in actual `bend.ts`, plus `file_book`, `js_lib`, and `js_book` in
actual `comp.ts`. The JSON retains the complete URL/name rules and hashed inputs.

The nearest-boundary rule separates nested work: `book_valid` samples are not also
counted in `book_load`, and `file_book` analysis is not also counted in enclosing
`js_lib`. Checking includes completion/specialization inside the actual checker
API, while source discovery includes host loading/parser/completion work. TS
`file_book` includes multiple backend preparation analyses; it is **not** declared
equivalent to Bend's `jd_reach_selected`. No generic `subst`, `kt`, `term_check`,
String helper, anonymous function or shared SCC dispatcher is assigned a stage
by its own name. Their actual ancestry alone determines context. Missing/inlined
or asynchronously detached boundaries leave samples unassigned. Recorded boundary
stack-node inventories are profile structure observations, not API call counts.

## Sample partitions

Percentages use each capture's full raw denominator. Rows are separate processes
and are not pooled into a clean performance comparison.

| Direct B2 capture | Check/completion | Discovery | Source reach | Annotation | Emitted reach | Library render | Unassigned |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Lexer CPU counts | 34.75% | 21.87% | 0.61% | 0.52% | 6.40% | 6.66% | 29.21% |
| Evening CPU counts | 22.79% | 10.36% | 0.73% | 2.61% | 22.00% | 14.97% | 26.55% |
| Lexer sampled allocated bytes | 38.01% | 14.02% | 1.23% | 0.37% | 8.38% | 10.76% | 27.22% |
| Evening sampled allocated bytes | 9.96% | 2.69% | 0.23% | 0.38% | 50.77% | 14.65% | 21.33% |

| Pinned TS capture | Check/completion | Load | File analysis | Library render | Unassigned |
| --- | ---: | ---: | ---: | ---: | ---: |
| Lexer CPU counts | 35.18% | 22.61% | 9.55% | 3.35% | 29.31% |
| Evening original CPU counts | 22.80% | 14.73% | 24.11% | 9.62% | 28.74% |
| Evening fresh retry CPU counts | 23.06% | 15.30% | 24.10% | 9.73% | 27.81% |
| Lexer sampled allocated bytes | 43.84% | 27.10% | 7.90% | 9.04% | 12.12% |
| Evening sampled allocated bytes | 24.55% | 14.49% | 27.55% | 11.98% | 21.43% |

The original TS Evening weighted CPU view was refused. Its healthy raw sample
counts remain a separate count-only observation; no `timeDeltas` were clipped or
used by this analysis, and the fresh retry does not overwrite that capture.
Percentages can differ from another owner's weighted-time charts. The unassigned
bin includes genuine import/host/GC/profile overhead and missing boundary ancestry;
the JSON retains its largest leaf names without guessing their compiler stage.

## What this adds

Evening's direct emitted-reach ancestry contains about half its sampled allocation
mass, making that stage a concrete place to inspect the separately reported
String-search/unique-reference dispatcher costs. Lexer instead places more sampled
allocation under checking/completion. This contextual result complements the exact
stage wall clocks and fair self-frame attribution; it does not identify a removable
fraction or prove that source reachability, checking, or any dispatcher causes a
measured slowdown. Root owns optimization decisions and target execution.

The analysis rehashes worker/profile/raw, exact selected API/driver and pinned TS
source bytes before and after reading. It requires complete passing one-first-
request workers and profile receipts. It does not repeat the producers' transitive
artifact audit or establish new language correctness. Reproduction needs only the
listed raw files and the explicit exact-boundary rules: rebuild parent maps, walk
to the nearest rule match for each sample, sum its count/size once, retain unknowns,
and assert mass conservation. Historical Phase59 captures must remain unchanged.
