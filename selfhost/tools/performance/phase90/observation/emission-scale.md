# Phase90 remaining emission membership costs

Status: offline source investigation and an unqualified candidate. No compiler,
benchmark, or native target was executed by this agent. The source74 native
180-second profile is a stopped prefix, not a completed self-compilation.

## Evidence and attribution limit

`selfhost/build/phase90/native01-late-self03/stopped-self.windows.json` passed the
root's guard checks. Its last window is almost entirely reference-count/drop,
consuming String equality, and `NB_CONTAINS`. This is consistent with the five
table-builder changes removing the earlier append bottleneck. Native tail calls
erase the calling frame; this evidence alone cannot distinguish fork closure,
worker admission, or another caller. Root's subsequent `js-profile-self02`
capture found 84.03% `nb_contains` leaves and 11.97% GC in seconds 45–60, with
an actual `nb_emit -> nb_fork_close -> nb_fork_step -> nb_reaches` ancestor path.
Deep recursion truncated many stacks, so this does not attribute the full leaf
share to fork closure. It does confirm that the candidate addresses an observed
caller. Do not turn either prefix share into a whole-request speedup prediction.

## Exact remaining loops

- `back/native/tables.bend:nb_emit` computes
  `nb_fork_close(ss, nb_fork_roots(ss), count(ss))`, then flags. A pass scans all
  segments. Each non-fork segment tests its name against the growing root list;
  each dependency does the same. Upstream's generated code evaluates both Bool
  operands, so these lists are traversed even after a match. Admission is immediate
  within the pass, so source order materially changes the number of passes.
  Let S be segment count, E their total references, R closure size and P passes:
  the loose bound is O(P (S+E) R) name comparisons, with P <= S. An unfortunate
  chain order gives cubic comparison growth when E is proportional to S.
  `nb_flags_chunks` additionally performs up to S linear root-membership tests;
  changing string assembly alone did not change these tests.
- An empty initial fork set stabilizes in one pass, and all-fork segments skip
  the membership tests. Root count alone therefore is not enough: collect
  initial/final roots, non-fork count, pass count, and references examined.
- `book.bend:nc_terms_fork` conservatively marks any application headed by a Var,
  not only explicitly parallel source syntax. Higher-order compiler helpers can
  seed this closure. `nc_mark_segments_go` copies an owner's complete call list
  onto each ordinary continuation, so segment-level E can substantially exceed
  the number of source-level call edges.
- `flat.bend:nf_admit` is another ordered fixed point over workers and a linear
  ready list, with the same P*(W+E)*R bound. Direct self-dependencies are allowed;
  mutual cycles are not automatically admitted. A second admission runs after
  optional-product retry. Adapter generation, prototypes, bodies and signature
  filtering perform further ready-list membership sweeps.
- `nf_wrap_segments` itself already receives
  `book_cached(nf_adapter_defs(workers,ready),0)`. Its per-segment lookup therefore
  uses the exact index. It also already has the new tail-recursive accumulator.
  Replacing it with another index would not remove the repeated ready scans.
- `nv_program` identifier uniqueness already uses `index_find/index_set`.
  `nf_inline` walks each admitted body twice (prototype and definition), but
  that is linear in body text; it is not the demonstrated nested-membership cost.

## Small candidate

`fork-indexed.bend` adds no Data type. It carries the existing exact KDef trie
beside the original roots through each pass, using collision buckets and a
private marker kind. Initial duplicates remain in the returned list; the trie
only represents membership. Additions occur at exactly the original visit.
The original U32 count comparison, fuel consumption and order are retained.
Flags build one private index for the whole sweep. Existing public
`nb_fork_close`, `nb_flags_chunks`, `nb_flags_go`, `nb_flags`, `nb_fork_step` and
`nb_fork_next` signatures/results remain available. Zero-fuel and empty-segment
returns avoid index construction. The last two legacy helpers are unchanged.

The native source74 derivative replaces only close/chunks and inserts the
helpers: +57 physical lines. `fork01/compiler-fork.derivation.json` records
literal replacements and inverse byte equality to source74. This is a private
native profile candidate, not a public raw-JavaScript API admission. Malformed
raw JS strings and legacy exception/demand order are not covered by typed Bend
fixtures and require separate gates before any such promotion.

The expected benefit is removing the R factor from ordinary membership, not
removing the fixed-point passes. Hashing walks each queried name; complete hash
collisions still scan an exact bucket. Index allocation/drop overhead can lose
on very small programs. A worklist could later remove repeated passes but must
preserve partial-fuel and sequential insertion behavior, so it is intentionally
not part of this first falsifier.

## Fast correctness and scale controls

`fork01/{legacy,indexed}.bend` return 46 whole products. Cases cover empty inputs,
duplicate initial roots and segment names, seeded/unseeded cycles, both chain
orders, mixed fork/bang bits, a fork omitted from explicit seeds, empty/Unicode
names, full FNV collision (`costarring`/`liquid`), repeated refs, self edges and
fuels 0/1/greater than segment count. Each product includes final ordered roots,
all flags, both public accumulator prefixes, initial automatic roots, unchanged
one-pass output, and retained original seeds/segments. The controls use actual
old/new functions and existing core index code, with the native String helper.

The frozen fixture generator's optional `legacyNameComparisons` diagnostics
model Python short-circuit evaluation. Inspection of generated upstream JS later
showed that this understates strict Bend demand; it does not affect the complete
result oracle, which passed all four target executions. The separate
`fork-demand-correction.json` preserves the correction without changing frozen
inputs. Strict source-level counts are 8 passes/546 comparisons for the
8-segment adversarial chain and 32 passes/33,666 for 32 segments. Reversed order
requires 2 passes and respectively 168/2,976 comparisons. These are algorithm
counts, not target counters or measured gains; optimization can change actual
execution. The asymptotic diagnosis remains the same.

Root-run protocol:

1. Check and execute both standalone sources under the existing serial guard;
   compare complete JS outputs first, then native outputs if the check passes.
2. Run the complete-product oracle, with 2 or 4 stdout files:
   `python3 selfhost/tools/performance/phase90/observation/compare-fork.py selfhost/tools/performance/phase90/observation/fork01/manifest.json OLD_JS NEW_JS OLD_NATIVE NEW_NATIVE --out REPORT.json`
3. Only after correctness, generate a fresh scale directory with
   `prepare-fork.py --out NEW_DIRECTORY --scales 16,64,256` (optionally `--compiler`
   with the exact source74 input). It refuses an existing output directory.
   Separate generation/compilation from execution; retain both input hashes and
   all complete outputs. Start with one small scale; do not launch the entire
   scale suite alongside the compiler build.
4. Once the JS profile confirms this caller, root can check/build the exact
   `fork01/compiler-fork.bend` derivative and repeat small/Map controls before
   a longer self-emission. Existing table-only tests did not exercise closure.

If the caller is instead worker admission, reuse the same membership-carrier
principle there, with new full ready-order controls for direct self calls,
mutual cycles, native dependencies, failed code, nonempty segments, initial
ready seeds, and optional-product withdrawal/retry. Do not infer its semantics
from fork propagation alone.

## Fixture acquisition corrections

Root's `fork-controls01/legacy/report.json` checked and emitted JavaScript but
upstream C emission refused `an arity over 247`. `fork02` split individual cases
and segment literals into helpers, but `fork-controls02/legacy/report.json`
reported the same C refusal. Both failures and both fixture versions remain.

Inspection explains why merely counting JS arguments was insufficient:
upstream `comp.ts:lay_of/lay_pack` flattens the nonrecursive `P90ForkCase` into
ten native words, and `seg_open` concatenates the word arrays of live values.
The generated JS still showed main constructing a list of all 46 case calls.
A native continuation can therefore exceed 247 words despite those JS calls
having only five arguments. This is a source-based diagnosis; no exact failing
native segment was captured. The guard in `compile_book` checks segment word
arity as well as encoded constructor arity.

Fresh `fork03`, generated by `prepare-fork-v3.py`, builds the output list through
four-case batches, bounding the live case products per batch to 40 words. It
retains the 16-segment literal helpers from fixture02. Its manifest pins the
previous failure and generator and verifies all 46 expected products unchanged.
The actual indexed algorithm and full compiler derivative remain byte-identical
to fork01. Root should use `fork03/manifest.json` with the unchanged comparator;
these offline generation checks do not establish native acquisition success.
