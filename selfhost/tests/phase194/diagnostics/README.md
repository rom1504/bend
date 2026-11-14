# Phase194 paired diagnostics

Twelve ordinary Bend programs form six diagnostic pairs. They are outside
native45 and must not enter its score. `catalog.json` is compatible with the
existing `bench.catalog` reader and pins each source, independent output,
mathematical oracle, and the native45 source that supplied the relevant idiom.
Lineage means an adapted idiom, not unchanged source or an equivalent copy of
the complete original benchmark. `oracle.py` checks 24 finite mathematical
results and all source/output pins without running a compiler or target.

The first three pairs are the priority development controls:

| Pair | Compared source behavior | Work and interpretation |
|---|---|---|
| value identity | Rebind `x` several times while retaining its old value; equivalent split helpers | Same arithmetic and result. Inspect lowered value identities and helper inlining. |
| register pressure | Reduce twelve terms immediately; retain all twelve before the same reduction | Same arithmetic and reduction order. Inspect actual liveness/spills; scheduling can erase the source difference. This finite recurrence reaches the same checksum at both declared sizes, so its outputs alone do not authenticate iteration count. |
| F32 region | Keep exact binary fractions in F32; add a per-step integer roundtrip | Same recurrence and result at the declared points. Mixed performs extra conversions/scaling. This is a lowering boundary diagnostic, not equal instruction work. |
| predicate flow | Select one arithmetic branch; combine both results with a Boolean mask | Same result. Mask performs both arms and extra Boolean arithmetic. |
| product ownership | Construct and destructure once; observe one borrowed product twice | Same arithmetic/result. Source sharing does not guarantee surviving allocation or reference counting. |
| memory dependence | Increment an independent index; take the next index from the load | Same array initialization, loads and sum over a 256-word successor cycle. This is a cache-resident dependency test, not a DRAM bandwidth/latency test. |

All programs expose `bench(size,seed)` and use the native45 final-four-argv
protocol: `repetitions warmups size seed`. Stdout is four lines: result,
warmup success count, measured success count, elapsed nanoseconds. Each
iteration validates against a literal independent expected value. Only the
two declared points validate successfully; unsupported arguments yield zero
successes. Default arguments are the small point with one repetition and no
warmups. Timing uses 1024 iterations per call, initially 256 repetitions and
four warmups; calibrate repetitions without changing size/seed. The time
includes the existing validation/count-printing wrapper overhead.

| Pair | Small: size32, seed17 | Timing: size1024, seed17 |
|---|---:|---:|
| value identity | 2670255714 | 2670254722 |
| register pressure | 343597400 | 343597400 |
| F32 region | 81 | 2065 |
| predicate flow | 8509331 | 1000953875 |
| product ownership | 359317514 | 3222628714 |
| memory dependence | 1072 | 130560 |

F32's oracle uses the exact identity `(x+1/4)*2-x = x+1/2`, starting at
`seed/4`; both variants return `4*x`. All intermediate values at the declared
points are small exact binary fractions. This does not cover NaN, infinities,
signed zero, arbitrary rounded recurrences, or out-of-range conversions.
The other oracles use wrapping integer arithmetic; memory's oracle sums the
successor cycle directly, without reproducing Array operations.

`emit-programs.mjs` is the Phase192 checked-API transport adapted only for this
explicit twelve-case authority. `--cases first3` selects six programs;
`--cases full12` selects all twelve. It checks all catalog/fixture/oracle pins
and checked API provenance, calls the original `p86_plan` source checker and
`p169np_plan` verifier, then obtains diagnostic assembly and an ELF object
from the same checked typed sequence. No compiler algorithm is implemented
in the adapter. It works with Phase193's checked budget API or a subsequent
checked API with the same seven exports.

`build-programs.py` imports the original Phase190 builder, adds the explicit
diagnostic catalog authority, and preserves its object/assembly construction
and exact four-line observation checks. It checks the timing point once
with repetitions1/warmups0. The small point is separately specified in the
catalog; this adapter does not claim to have executed it. Both adapters
require the outer guarded CPU3 lane. Example commands **inside** that guard:

```sh
selfhost/.assets/bin/bun selfhost/tests/phase194/diagnostics/emit-programs.mjs \
  --api selfhost/build/phase193/budget-api01/report.json \
  --binding selfhost/build/phase193/budget-api-source01/base-binding.json \
  --source-manifest selfhost/build/phase193/budget-api-source01/manifest.json \
  --catalog selfhost/tests/phase194/diagnostics/catalog.json \
  --cases first3 --target x86 --emit object \
  --out selfhost/build/phase194/diagnostic-emit-fresh

python3 selfhost/tests/phase194/diagnostics/build-programs.py \
  --catalog selfhost/tests/phase194/diagnostics/catalog.json \
  --emission selfhost/build/phase194/diagnostic-emit-fresh/report.json \
  --assets selfhost/build/phase193/assets.json --role baseline193 \
  --out selfhost/build/phase194/diagnostic-build-fresh \
  --seconds 120 --guarded
```

At authorship, only mathematical/pin checks, Python syntax, catalog loading,
and builder help/import were checked. Node was unavailable for a JS syntax
check. No Bend checker, compiler, generated target, or timing job was run by
the diagnostic author. Root-owned checked emission and execution must supply
that evidence before interpreting machine code or timings. No compiler
source, runtime, installed image, or native45 file changed.
