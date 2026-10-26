# Occurrence predicates: positive hosted discriminator, modest whole-build ceiling

**Advance the modular-range candidate; keep NU_Set as a rejected alternative.**
The range version is strongly faster for4/64 fresh IDs and approximately neutral
for1 or immediate environment rejection. There is no robust evidence here that
requires a selective fallback. This authorizes further complete-output/native
testing, not production promotion or a whole-build speed claim.

[Checked API04](../../../../build/phase111/p143-prototypes-api04/report.json) ·
[screen01](../../../../build/phase143/occurrence-screen01/report.json) ·
[data-only grouped analysis](../../../../build/phase143/occurrence-analysis01/report.json).
The analyzer is `analyze-v01.py`; it runs no compiler targets.

## What passed and what was measured

All47 explicit controls and72 constructed semantic queries pass against all
three predicates, including reconstructed values. Six paired rounds per query
produce432 paired rounds/1,296 mode measurements. The complete observer takes
6.405s, including Base/frontend/body preparation; peak RSS292.3MB. Timing
completed before the20s soft limit. This is one hosted process, not native data.

The six exact compacted bodies are Lexer `seed`, `op`, `expand` and Map `main`,
`p37.map.remove`, `bench`. They contain9–62 syntax nodes and0–8 distinct variable
IDs. They were selected from the first eight ordinary source declarations by
size, not from hot-call counts. Two bodies exceed `nbc_select`'s32-node body
limit, so those64-query rows are stress ceilings for that particular caller.
Large arguments are possible in the real caller, but this screen does not
measure their production distribution.

Every row constructs a fresh-ID count of1,4 or64, with empty environment,
one actual child argument, or first/last environment collision. These counts
are **not the source function's arity**. All clear rows return True; all inserted
environment-collision rows return False. Fixed controls cover additional syntax
collisions, specialized terms, wrapping and sentinel behavior. The screen pins
the full-QBE oracles but does not emit or compare complete QBE itself.

## Results by fresh-ID count

Ratios below are candidate/original time; smaller is better. Each group has24
queries ×6 paired rounds. Both statistics retain every observation.

| Count | Range geometric / median paired ratio | NU_Set geometric / median paired ratio |
|---|---:|---:|
|1|1.0046 /1.0177|1.0068 /1.0730|
|4|0.5070 /0.4682|0.5898 /0.5004|
|64|0.3057 /0.2823|0.3421 /0.2913|

Range median paired ratios, separated by failure position:

| Count | Empty environment | Actual child argument | First env collision | Last env collision |
|---|---:|---:|---:|---:|
|1|1.0096|1.0200|1.0161|1.0336|
|4|0.4480|0.3783|1.0217|0.4286|
|64|0.2532|0.2050|1.0250|0.2777|

This matches the intended removal: repeated successful syntax scans disappear;
early rejection has little work to save. NU_Set retains extra preparation and
allocation, particularly on low-count/early-failure inputs. The range route needs
no Patricia set and is simpler. Do not add a per-owner or benchmark-specific
policy to chase these rows.

## Noise, regressions and limits

Individual intervals are short: minimum15.1µs, with584/1,296 measurements below
1ms. Median intervals are1.920ms original,0.864ms range and0.995ms NU_Set.
Some individual ratios exceed16× despite no corresponding repeated regression;
the worst six-round **per-query median** for range is1.0662. No range query has
a median above1.10. That is not a confidence interval or proof of a6.7% bound.
Count1 and first-env rejection look roughly1–3% slower by paired medians, too
small and noisy here to justify an additional dispatch policy. If native full
requests regress, investigate an exact count≤1 original branch separately.

The [fresh ordinary profile](../../../../build/phase143/profile01/attribution02/report.json)
contains216 `nc_occurs` and186 `nc_occurs_list` active-context samples out of
12,017: **3.3453% of all samples**, not20% of compilation. The older20.62% figure
was a cold-session raw-stage interior. The current slice includes other callers
and is not exclusive attribution to `nd_comb_fresh`. Even removing an entire
3.35% cost slice gives only about1.035× speedup under fixed-other-work arithmetic;
this is a planning bound on that sampled slice, not a formal compiler ceiling.

Next: compare complete frozen outputs/refusals for the isolated range override,
then measure actual native ordinary requests. Keep the full checker/final
verifiers and the qualified parent. No further native proxy framework is needed
before those direct gates.
