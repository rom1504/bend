# Phase165: isolate bendc's native checker memo substitution

The candidate changes the executing checker's memo policy while leaving its
parser, type rules, checker scheduling, reporting, optimizer and emitted-program
native table intact. It is a private source experiment, not a proposed removal
of memoization from our compiler. Our checker already memoizes through its
persistent GHeap. This ablation asks how much bendc's mutable native memo cells
contribute; it cannot explain the 2.132 billion allocations measured outside our
parse/check/report region or replace the broader backend-work investigation.

## Exact source preparation

Run from the repository root, with a fresh directory:

```sh
python3 experiments/phase165/tools/prepare-memo.py \
  --out selfhost/build/phase165/memo-source01
```

This preparation has run; it invokes no compiler or workload. The output contains
`original/` and `candidate/` copies of only the six imported Bend modules from
bendc `56edcc65b3527a75838011682c231072d5b46097`: `bendc.bend`, `check.bend`,
`core.bend`, `asm.bend`, `rt/rtjs.bend`, and `rt/rtchan.bend`. The original copy is
byte exact. Only candidate `check.bend` differs:

| Original identifier | Candidate identifier | Original declaration / use lines |
| --- | --- | --- |
| `memo.new` | `p165memo.new` | 1741 / 1768 |
| `memo.has` | `p165memo.has` | 1744 / 2195 |
| `memo.get` | `p165memo.get` | 1747 / 2196 |
| `memo.set` | `p165memo.set` | 1750 / 2239 |
| `memo.same` | `p165memo.same` | 1754 / 5424 |
| `memo.link` | `p165memo.link` | 1760 / 5431 |

The main import remains `import ./check.bend as Chk`, so the resolved names are
`Chk.p165memo.*`. The compiler recognizes only `Chk.memo.*` as these native
operations (`bendc.bend:3850`). Its `Natives()` table, including those strings,
is byte unchanged. Thus when this candidate compiler later emits another
program, its ordinary compiler native-recognition policy remains the original
one. The experiment changes its own checker implementation's call targets.

The tool pins all six input hashes, rejects destination-name collisions and
unhandled external lexical `Chk.memo.*` references, and requires exactly one
definition and one use per name. A byte scanner skips escaped string/character
literals and `#` comments. Its 12 edit spans reconstruct the original bytes
exactly when inverted; the full identifier stream also agrees modulo the six
renames. No strings, comments, whitespace, import paths or bodies are rewritten.
This is a narrow pinned-source lexer, not a general Bend parser.

The original checker is 310,429 bytes, SHA256
`786514afc1804c00371356943ac6790c16c04c04551e7ab8e0d8f6468e22bf41`;
candidate is 310,477 bytes, SHA256
`fec74488fae4ccb721269e46dcefffd06d91fbcb373a906b42d76894c226c6c3`.
`memo-source01/manifest.json` is SHA256
`f03b1e679e90d80dd2b6a58cb642294dd5d3aa48e38946ca4d0174172ec46f78`.
It pins the method, all source/effect files, products, counts and byte offsets.

`base-acquisition/base.bend` is a private exact copy of matching Base 2.0.34,
71,530 bytes, SHA256
`c742fae9c49b14f0cc9128429a2c6109364c8a933a142f2c90b9f2e5fd976661`,
with its 68 explicitly referenced C/JS effect files. No repository, binary,
seed, documentation or unrelated test tree is copied. Historical source trees
and checkouts remain untouched. This acquisition Base is distinct from the
75,064-byte common measured-input Base used in Phase162; retain that same
measured source/Base pair for attribution.

## What must change in emitted C

The existing Bend fallback bodies deliberately keep no memo state:
`new` returns `Qnt{NoSp{}}`, `has`/`same` return False, `get` returns its input,
`set` returns the result argument, and `link` returns its Boolean input.
The original runtime implementations at
`selfhost/build/phase157/vendor/rt/bendrt.h:3085–3139` instead allocate/mutate
shared memo cells and exploit cell identity. Direct memo API outputs therefore
are not an equivalence oracle for this ablation.

After root-owned C emission, audit actual executable function bodies, excluding
strings/comments and runtime definitions:

1. Original checker callers should reach `F_Chk_dmemo_dnew/has/get/set/same/link`
   (or equivalent optimized native call paths).
2. Candidate reachable checker bodies must have no calls to those six names.
   Portable definitions, if retained, mangle as
   `F_Chk_dp165memo_dnew` etc.; wrappers or specialization may change their
   prefixes/suffixes. Optimizers may inline or erase these trivial functions,
   so demanding six emitted definitions would be a false gate.
3. Inspect the actual `term_cell`, weak-head cell-force, and cell-equality paths:
   they must use the portable bodies/constants with no native memo allocation,
   has/get/set or same/link on those edges. Keep unrelated Array operations and
   String/Map native substitutions fixed.
4. Confirm `Natives()`'s emitted string entries remain unchanged. The runtime
   header still defines the six native functions unconditionally; their textual
   presence there is not evidence of an executed checker call.

The source manifest establishes lexical preparation only. Root should retain
ordinary source/emission admission and then require complete checker success
followed by the exact full unsafe/dependency report on the common input, plus
the existing exact invalid-body refusal. An early error, exhausted fuel, timeout
or crash is not a fast result. Repeated-force/shared-equality controls can add
coverage without asserting that mutable and portable memo APIs return identical
intermediate values. Source checking, finite outcomes, generated execution and
proof acceptance remain separate claims.

Keep seed image, bounded-search runtime, allocation policy, worker count, flags
and compilation toolchain fixed. Separate acquisition from checker execution;
do not combine this knob with portable Map/String until the independent result
is recorded. No target execution or performance result is claimed by this note.

## Additive source-effect closure correction

The first private acquisition (`original01`) completed no C output and refused
with `No such file or directory`: the six Bend modules also require source-relative
effect inputs. The initial preparation manifest is preserved unchanged.
`tools/add-source-effects.py` subsequently copied the exact pinned
`rt/{hub,cc}.{c,js}` files into both memo trees and all three lookup-ablation
trees. Ten quoted import occurrences resolve to these four files; the pinned
files have no further local include/import dependencies. System headers and the
machine runtime remain supplied by the separately pinned acquisition toolchain.

`selfhost/build/phase165/source-effects01/report.json`, SHA256
`b9d38bd86960f454dd309229d1c5f10ab9397adceae09748a7326be238ba854c`,
pins this additive tool, vendor manifest, four original assets, every preexisting
Bend file and every copied effect. No existing module or preparation receipt was
modified. `acquire.py --support` records that receipt and all source-tree files.
The later `original02` checked emission reproduces the original seed C exactly;
see [the emitted memo audit](emitted-memo-audit.md).
