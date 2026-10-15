# Phase92: the native chain, measured separately

**The current native compiler chain is now compared on identical Bend source.**
A newly built upstream-C native B1 emits exactly the 38,614,882 bytes of C used
to build native07. Native07 reproduces those bytes again. Both stages pass the
selected native-host conformance and generated-program gates. No production
compiler source, runtime, installed JS image or public native selection changed.

The main finding is that **full-source native compilation remains about 3×
TypeScript/Bun**, even when upstream's C backend builds our Bend compiler.
The difference between our own-C and upstream-C native images is much smaller:
8.5% on full self compilation and about20% on ordinary requests. This isolates a
useful baseline for the next native profiling work.

[Design](../../design/phase92/native-chain-scoreboard.md) ·
[Machine-readable scoreboard](summary.json) · [Native lineage/build](native-chain.md) ·
[Six-source measurements](compilation-screen.md) · [Conformance](conformance.md) ·
[Generated products](broad-products.md) · [Execution ledger](execution-ledger.json).

## Five metrics

Ratios mean our time / reference time; smaller is faster. Native B1 is compiled
by pinned upstream TypeScript's C backend. Native B2 is the existing self-hosted
native07 image, reused after its complete C build input matched the new B1 output.
This is a content-linked native chain, not a newly rebuilt ELF claim.

| Metric | Native-chain result | Boundary |
|---|---|---|
| Compiled-program speed | Both stages preserve all 45 complete C products;45 executions pass | Output continuity/correctness, not a fresh execution-speed ratio; original C12 imports exceed the entry's scope |
| B1 compilation speed | Six-source process time0.465× TS/Bun; full source140.3s /2.898× TS | Prepared Base for native requests; full self is one fresh observation |
| B2 compilation speed | Six-source process time0.672× TS/Bun; full source152.2s /3.145× TS | Same native source/assets/Clang flags; no JS-hosted B2 substitution |
| Conformance |69/69 golden executions and3/3 rejections per stage; all 69 emitted-C hash/size pairs agree |31 native100 import/provider exclusions; no parse/check-only or JS-output API |
| Simplicity |132 maintained Bend modules,32,692 physical/26,693 code lines; zero compiler-source delta | Native frozen assembly38,711 lines includes generated material;14 existing profile replacements remain |

The native six-source request-only ratios are0.312×/0.376× TS/Bun. Native B2/B1
is1.203× request and1.444× process. Native Base decoding alone takes pooled
medians 59 ms/139 ms, explaining much of the extra cold-process difference.
The broader45-point, one-round comparison is consistent: B2/B1 request1.195×,
process1.373×. Its last request followed a disk-reclamation pause; the balanced
six-source campaign is the primary timing screen.

## Prepared Base and large inputs change the conclusion

| Workload/configuration | Native B1 | Native B2 | TypeScript/Bun |
|---|---:|---:|---:|
| Small, prepared Base, process median |156.8ms|247.6ms|514.4ms ordinary Base|
| Small, live Base, one process |1,672.3ms|1,891.4ms|513.4ms ordinary Base|
| Full compiler source, request |140.262s|152.191s|48.394s|
| Full compiler source, process |140.944s|152.984s|48.659s|

The live Small control passes complete-C equality and takes 3.257×/3.684× TS
process time. Its native Base preparation takes 1,594ms/1,803ms. Therefore the
small-source default workflow gains depend materially on the authenticated
prepared Base carrier; they are not evidence that the native compiler algorithm
is universally faster. Map loses even in the prepared six-source workflow.

Both native stages consume the same source, Base carrier, runtime parts and
nine providers. Native Base preparation precedes the request clock but is in
process time. TS ordinarily loads/checks Base inside its request. Full self
consumes the same original source path; TS emits its 17,764,676-byte C, while
both Bend stages emit identical 38,614,882-byte C. Each output is compared to its
own independently pinned oracle. Two fresh observations per small workload and
one per full-source role are screens, not confidence intervals. Filesystem
caches were not flushed.

## Correctness and scope

All 90 broad emissions equal their complete current C oracles, covering 45 catalog
points derived from 23 original programs. Each identical shared product is built
once with ClangO2 and executed against its independently retained stdout oracle.
This validates the native hosts' generated products without duplicating 45 builds.
It does not transfer the historical original-C12 runtime ratio 1.067× to these
different wrappers, or establish a fresh program-speed ratio.

The native69 gate executes the original unmodified fixtures through each native
compiler, ClangO3 and the existing golden judge. Sixty cases expect exit0 and
nine expect runtime exit1; both roles reproduce all historical observable fields.
The three rejected inputs per role produce no C. `deep_list_walk` is rejected,
but the native entry intentionally returns concise errors; it does not test or
fix the JS B2 rich-diagnostic stack overflow. The existing JS-hosted scoreboard
and its3173/3174 frontend result remain separate and unchanged.

Native entry limits remain one canonical Base-importing source, nine audited
providers and checked C emission.31 native100 fixtures need extra modules or
custom providers. Full frontend, original JS23/C12, parallel/GPU and independent
proof-kernel qualification are outside this entry. No language-wide claim or
public admission expansion is made.

## Efficient next loop

The [matched screen](../../selfhost/tools/performance/phase92/comparison/README.md)
took 33.0s once the two images existed. The uncached Small control took 6.5s.
Building a changed native B1 currently also costs about 60.6s of acquisition plus
194.6s of Clang;33s is not an edit-to-native-image promise. Full native self
requests cost about293s together, and the native69/rejection gate 430.6s.
Keep those as integration checks. Reuse exact product identity to avoid
unnecessary program retiming or duplicate Clang builds.

Next investigate native costs shared by both source-matched images, using Base,
Map and increasing source sizes before another full self run. Matching upstream
C lowering alone would still leave the observed B1 full-source 2.90× deficit.
The prepared-Base decoder is also a concrete own-backend hotspot:139ms versus
59ms. These observations locate investigations; they do not yet prove an
allocation, string representation or dispatch root cause. The prior JS-hosted
51.7s self observation is useful context, not a fresh matched measurement here.

## Resources and preserved evidence

Root ran 227 serial guarded jobs, occupying 1,176.5s (19m36.5s) within a 28m15.5s
first-to-last target span. Three agents prepared/audited offline; they launched
no target workloads. Peak process-tree RSS was 4,291,608,576 bytes during Clang.
There was no OOM, target timeout or overlapping guarded job. A pre-launch disk
reserve stopped the broad campaign after 89 successful requests. The
[failed report and continuation](resource-stop.md) are preserved; only the one
missing request was run before the 45 build/execution pairs.

[Evidence01](../../selfhost/tools/performance/phase92/evidence01/README.md)
preserves the build, self outputs and small screen.
[Evidence02](../../selfhost/tools/performance/phase92/evidence02/README.md)
preserves conformance, the full TS control, live control, failed broad attempt
and successful continuation. Every archive member was read back and verified.
Reclamation receipts preserve exact archive mappings for removed duplicates and
obsolete images. Active native06/07, current upstream B1, sources and receipts
remain. Actual quota consumption is unavailable; no quota estimate is claimed.
No PR comments were posted.

After the final evidence commit, 135 closed broad product files were reclaimed
only after exact committed-archive verification. [Reclamation receipt](reclamation-products.json)
records the 90 C outputs and 45 executables (31,096,894 bytes). The independent
oracles, current compiler images, source and all logs/reports remain locally.
Use `reclaim-products.py restore --out /tmp/FRESH` to recover their exact bytes
and modes for a full raw-product audit.
