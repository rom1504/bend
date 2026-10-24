# Phase132: reversible compact QBE names

## Question and scope

How much of the 107 MB native compiler QBE is verbose names, and does removing
that text reduce QBE/assembler work without changing the generated machine?
This is a frozen-output ceiling experiment, not a production compiler change.
The compiler source, selected native compiler, runtime and optimization policy
remain unchanged.

The frozen input is `selfhost/build/phase130/p131-final-self01/program.ssa`,
107,059,385 bytes, SHA-256
`f3ff63b04b58e5a5b92be781d0d1cba8cc574a37765cbf66d817c3d38f4b576e`.
It is the Phase131 final N2 input. The linked runtime is the unchanged
`selfhost/build/phase128/runtime-borrow01/runtime.o`.

## Observed text reductions

| Variant | QBE bytes | Bytes removed | Reduction | Changed exported names |
| --- | ---: | ---: | ---: | ---: |
| Original | 107,059,385 | 0 | 0% | 0 |
| Private globals | 104,379,267 | 2,680,118 | 2.50% | 0 |
| Closed-image globals | 99,141,429 | 7,917,956 | 7.40% | 48,911 |
| Private globals + local variables/labels | 57,519,368 | 49,540,017 | 46.27% | 0 |
| Closed-image globals + local variables/labels | 52,281,530 | 54,777,855 | 51.16% | 48,911 |

Local names, rather than global function names, are the large opportunity.
Per-function variable renaming removes 46,199,481 bytes; block labels remove
660,418 bytes. There are 4,504,082 variable occurrences and 231,393 label
occurrences across 63,239 functions. Even the broader ceiling still exceeds
52 MB: name shortening alone cannot make this a 1 MB program.

The independent census in `implementation/phase132/census01.json` agrees on
63,814 global definitions and 48,913 exported definitions. It attributes
61,186,325 original bytes to variable tokens. This counts token bytes, whereas
the reduction above subtracts the replacement tokens and is the realizable
saving of this particular naming scheme.

## Preservation and ABI boundaries

`selfhost/tools/performance/phase132/symbols/compact.py` recognizes global
tokens outside quoted strings and comments. It does not run a regular expression
through arbitrary string contents. It rejects unsupported quoted identifiers
and unsupported token shapes. Definitions and every reference, including data
relocations, use one collision-free deterministic bijection. Names use `q` plus
a base-36 number. All unresolved/runtime names are preserved.

`locals.py` additionally renames variables and block labels by first occurrence
within each function. Parameters, repeated non-SSA variable assignments, uses,
branch targets and definitions share the same map. Each function resets its
maps. Names use `v`/`b` plus a base-36 number. The parser is deliberately limited
to the actual emitted function/header format; it is not a general QBE parser.

Both variants have an independently applied inverse mapping whose byte hash
equals the complete original source hash. This establishes preservation of all
non-name bytes, not only a count of changed identifiers. Mapping files are
explicit and retained, including one JSONL local-map record per function.
Strings/comments are separately hashed. The actual artifact has zero quoted
strings; constructor/effect names encoded as numeric data are still protected
by the whole-byte inverse check.

The conservative variant preserves **every exported name**, plus `main`,
`p111_program`, `p111_segments` and the runtime profiling accessor. It does not
change the generated object's exported symbol interface.

The separate closed-image experiment changes generated `p111_FID_` exports.
Runtime inspection found no imports of those symbols: dispatch uses function
addresses in the segment table and numeric IDs. Runtime foreign effects use
constructor-name data rather than native symbol lookup. The linked runtime's
undefined symbols are system-library symbols. This supports an experiment on
the exact generated object + runtime object + system libraries; it does **not**
establish drop-in object/library compatibility with arbitrary external callers.
Existing offline profilers that identify functions by generated names require
the inverse map. The conservative variant avoids this extra export question.
The independent runtime/ABI review and pinned `nm`/global-reference inventory
are in [incremental-boundaries.md](incremental-boundaries.md), section
“Compact-symbol ABI audit”, and `incremental-boundaries.json`.

## Evidence and reproduction

Metadata-only producers:

```sh
python3 -B selfhost/tools/performance/phase132/symbols/compact.py \
  --source selfhost/build/phase130/p131-final-self01/program.ssa \
  --runtime selfhost/build/phase128/runtime-borrow01/runtime.o \
  --out selfhost/build/phase132/compact-symbols01
python3 -B selfhost/tools/performance/phase132/symbols/locals.py \
  --globals selfhost/build/phase132/compact-symbols01/report.json \
  --out selfhost/build/phase132/compact-locals01
```

These commands require fresh output directories. Recorded receipts are
`selfhost/build/phase132/compact-symbols01/report.json` and
`selfhost/build/phase132/compact-locals01/report.json`; both include input and
output hashes, tool identities, refusal checks and inverse proof hashes.

The local producer's one streaming rewrite took 47.60 s on CPU0; complete
production plus both inverse checks took 115.87 s, with 134.4 MiB peak RSS.
This Python cost is experiment preparation. It is neither an optimization of
Bend's emitter nor a saving in the production compilation pipeline.

`symbols/build-plan-v02.py` produces, without executing, the guarded build plan
`selfhost/build/phase132/compact-build02/jobs.json`. It builds a fresh original
baseline and conservative compact variant with the same QBE, assembler
alignment option, cached runtime and linker. The coordinator owns the CPU3
target lane. The file cap is 128 MiB because the existing assembly is about
78 MB. A read-only machine comparison follows both successful builds.

`symbols/machine-v02.py` compares allocated section bytes and addresses, symbol
type/binding/visibility/value/size after inverse name mapping, and object
relocations after normalizing symbol-table indices. It reports any difference;
it does not assume machine equality from alpha-equivalence. Build-ID notes may
differ. The conservative raw exported-symbol set must remain equal.

The initial audit preflight rejected `readelf`'s hexadecimal `0x100000` symbol
size because the parser expected decimal. The original audit and unexecuted
build-plan01 remain preserved. Version02 accepts hexadecimal or decimal sizes;
its read-only preflight parsed all 64,227 symbols and 245,409 object relocations
of the existing N2 successfully. No target rebuild was needed for this fix.

## Interpretation gates

1. Exact inverse text establishes an alpha-renaming experiment with unchanged
   non-name input bytes. It does not measure compiler speed.
2. Allocated machine equality would establish that runtime performance need not
   be re-benchmarked for this frozen linked image. If it differs, inspect the
   differences before drawing that conclusion.
3. QBE child time includes parsing, optimization, register allocation and
   assembly emission; it is not a parser-only timer. Assembler and link times
   are reported separately. A first build pair is descriptive, not a controlled
   repeated performance result.
4. Any native Bend emitter improvement remains unmeasured. Compact local names
   may reduce string construction, copying, output traffic and reclamation,
   but this output-only tool demonstrates only the textual opportunity and its
   downstream effects.
5. A production implementation should assign compact names at final rendering,
   retaining semantic IDs and the independent verifier. No IR rewrite or extra
   optimization pass is needed merely to shorten names.

## Native discriminator result

The coordinator completed the fresh baseline and conservative private-local
builds. **Their `.text` and all allocated section bytes, addresses and extents
are identical except the linker build-ID note.** Inverse-normalized ELF symbols
and object relocations match, and the exported-name set remains unchanged.
This frozen image has no program-runtime code or layout regression to measure;
another broad runtime campaign would repeat evidence already supplied by the
machine comparison. This statement does not qualify a future Bend renderer
implementation or the unbuilt closed-image variant.

| Cost | Original | Private + local | Interpretation |
| --- | ---: | ---: | --- |
| QBE child | 8.829 s | 8.277 s | 6.25% less in one pair |
| Assembler child | 4.823 s | 4.773 s | 1.03% less in one pair |
| Linker child | 0.315 s | 0.265 s | Small, noisy absolute cost |
| Three build children | 13.967 s | 13.315 s | 0.651 s / 4.66% less in one pair |
| Host global experiment producer | — | 43.537 s | Additional preparation, both global variants and audits |
| Host local experiment producer | — | 115.875 s | Additional preparation, both local variants and audits |
| Of local producer: rewrite | — | 47.597 s | Included in 115.875 s, not additive |

These are a discriminator, **not a repeated timing result**. No extra build
pairs are needed to establish the main conclusion: halving text does not yield
anything close to a 10× machine-build improvement. The experimental Python
postprocessor costs much more than the observed downstream saving. The
potential opportunity is generating short names directly in Bend and avoiding
the long strings in the first place; its native emission cost remains unmeasured.

The compact binary file is 16,278,648 bytes versus the fresh baseline's
17,132,056 bytes. Since allocated sections match, this reduction is non-runtime
metadata, principally shorter symbol spelling, not smaller generated code.

Concise evidence is archived at
[`implementation/phase132/evidence/symbols/summary.json`](../../implementation/phase132/evidence/symbols/summary.json).
The adjacent manifest pins all original reports; verbose global inventories and
machine symbol lists use lossless gzip. Total archive size is about 646 KB.
It preserves the metadata parser refusal and both prepared plans. Large QBE
outputs and deterministic name maps remain reproducible from the pinned source
and tools; their complete hashes and inverse-proof hashes are archived.

The production seam requires care. `p111q_local` prints an existing semantic
String name, but many `p113e_*` helpers create extra temporary names directly
during rendering. A semantic-name map alone misses these renderer temporaries;
a map on every textual reference could add costly String lookup. A bounded
function-level final renderer or compact names assigned when temporaries are
created is a hypothesis to compare, not an invitation to add another expensive
analysis pass. Keep the existing independent semantic verifier unchanged.
