# Generated-program regressions: source isolation

The final five-round comparison observed Map/Set **11.28% slower**, edit distance
**11.23% slower**, and the local pair **8.50% slower** than the installed Phase56
outputs. The source difference for these three modules is completely isolated:
changing only computed constant object keys from `["field"]:` to `"field":`
in the old module reconstructs the entire new module byte-for-byte.

This is an exact source result, not yet an explanation of V8 behavior. It rules
out additional emitted differences from constructor lookup, scalar-origin
forwarding, literal-choice lowering or shared SCC bodies in these modules.
The compiler-latency gains in [the separate report](latency.md) do not establish
that the same literal syntax improves every generated program.

## Exact changed sites

The [data-only Acorn census](../../selfhost/tools/performance/phase58/analysis/program-fields.mjs)
reads both frozen manifests, checks each complete module identity, rewrites only
computed string-literal object initializer keys, and compares complete bytes. It
excludes `__proto__`, methods and shorthand properties. It never imports or runs
the generated modules. Its report records every original site, containing named
function, source line, constructor tag and changed field list.

| Module | Changed keys | Object sites | Complete field-only reconstruction |
| --- | ---: | ---: | --- |
| Map/Set | 1,008 | 436 | Yes |
| Edit distance | 16 | 4 | Yes |
| Local row / pair | 20 | 5 | Yes |
| Morning | 743 | 306 | No; four show wrappers and two shared SCC bodies also differ |

All edit-distance changes are the four `Dp` keys `a`, `b`, `prev`, `cur` in
`$jd$cell_46_f4`, `$jd$row`, `$jd$dp_46_f1` and `$jd$pair`. Local row adds the
same literal in `$jd$row_46_probe`. Array indexing, value expressions, stores,
argument order, helper calls and runtime bytes are identical. By the source's
256×256 loop, `cell.f4` reconstructs one record per grid cell: 65,536 per pair.
That count follows the loop structure; this census did not measure allocations.

Map/Set's 436 sites include 174 `MNode`, 90 `MLeaf`, 93 `Tuple`, 10 `Con`, eight
`Some` and 61 other object literals. Static site counts are not execution weights.
Most sites occur in the expanded Map helpers; this alone does not identify the
hot allocation or a particular JIT decision.

## What the saved measurements establish

Each final row below has five fresh samples per role. Times are microseconds per
call; ranges are observed process minima/maxima, not confidence intervals.

| Point | Phase56 median [range] | Final median [range] | Final / Phase56 | Maximum absolute half drift, old / new |
| --- | ---: | ---: | ---: | ---: |
| Map/Set | 17.260 [16.958–17.626] | 19.207 [18.272–19.703] | 1.1128× | 4.72% / 5.03% |
| Edit distance | 5,677.951 [5,554.396–6,076.377] | 6,315.733 [6,024.424–6,594.801] | 1.1123× | 1.73% / 3.29% |
| Local pair | 1,383.345 [1,375.791–1,520.839] | 1,500.952 [1,495.451–1,660.295] | 1.0850× | 1.82% / 2.64% |
| Edit distance, depth 0 / seed 17 | 1,381.534 [1,371.342–1,496.324] | 1,503.867 [1,499.554–1,651.040] | 1.0885× | 1.21% / 3.15% |
| Edit distance, depth 3 / seed 123 | 11,079.387 [10,968.704–11,964.952] | 12,030.662 [12,006.872–13,010.640] | 1.0859× | 1.75% / 0.52% |

For each of these points the candidate was slower in all five corresponding
rounds. That repetition warrants investigation; it is not a significance test.
The edit-distance TypeScript role had 1.61× max/min spread, so its TS ratio needs
additional caution. The old/new comparison above does not use that denominator.

Phase56 freshly measured only Map/Set. Its string01 median was 17.536 µs, range
17.523–19.536 µs, with 7.14% maximum half drift. That historical range overlaps
the new median, but does not erase the separation between contemporaneous roles
in the final Phase58 run. Phase56 retained dated Phase53 measurements for the
other 44 byte-identical points; there was no fresh Phase56 edit-distance campaign.

The matching Phase53 module bytes measured edit distance at 5,606.155 µs
[5,521.901–6,049.367], local pair at 1,385.884 µs [1,378.799–1,481.156], and the
two edit-distance variations at 1,390.743 µs [1,379.170–1,428.105] and
11,108.955 µs [11,046.258–11,716.256]. These are separate historical observations,
not pooled samples or a synthetic larger experiment. Today's baseline medians
are close to those historical medians.

## Cheapest discriminating tests

The existing old/new modules already form an exact whole-module field-syntax
contrast for Map/Set, edit distance and local pair. A repeat must keep the warmed
measurement protocol comparable: a short cold pilot can reach a different JIT
state and cannot supersede the five-round result merely by giving a different
ratio.

A smaller diagnostic can restore only the four computed keys in final
`cell.f4`, retaining every other byte and the complete output oracle. This tests
the per-cell record site before considering another compiler build. Plausible
mechanisms include allocation boilerplates, object maps or subsequent inlining
and scalar replacement decisions; none has been measured for this loop yet.

A general rollback of literal-field emission is also a legitimate candidate.
The original compiler-image experiment preceded elimination of the hot
constructor-miss path, so its earlier benefit need not survive the later changes.
Test the rollback on the final compiler image and these generated programs before
choosing it. A benchmark-specific field rule would not follow from this evidence.
This note implements neither rollback nor a production exception.

## Actual optimized caller inspection

The subsequent bounded `dp-v8-plan01` execution completed both ordinary full-oracle
workers successfully. Node 24.18.0 / V8 13.6.233.17-node.50 printed the actual
optimized `$jd$row`; no forced optimization or tier changes were used. These
diagnostic timings are not replacements for the clean five-round measurements.

Both versions compile that function once to TurboFan and inline the same eight
functions: `cell`, `cell.f1`–`cell.f4`, `b2u`, `umin` and `umin.go`. Both reserve
`0xb8` stack bytes, contain 75 deoptimization sites, and record no executed
deoptimization bailout. The printed sites are possible exits, not observed
deoptimizations. Code size is 3,676 bytes before and 3,656 bytes after.

Both retain four static young-generation allocation paths, each advancing the
allocation pointer by `0x40` (64 bytes) for a `Dp` record. Four paths in the
printed function do not mean four allocations per cell. Neither optimized row
eliminates the loop-carried record, and neither retains a keyed-property runtime
call. This capture therefore contradicts the simple explanation that quoted
keys uniquely lose inlining or scalar replacement here.

The actual difference is initialization: the old code initializes a partial map,
uses a filler in the not-yet-written final slot, and transitions to the final map;
the new code installs the final map immediately and uses an uninitialized-value
sentinel before writing that field. Register scheduling and code offsets also
differ. Those are concrete code-shape differences, not a demonstrated cause of
the execution-time difference or evidence of more allocated bytes.

Logs are `selfhost/build/phase58/dp-v8-baseline01/stdout.log`, SHA
`ab1b47bf92edc42d0908cd703fdb029cd577195f1622af416c9f741823e46dfc`,
and `dp-v8-candidate01/stdout.log`, SHA
`2a05b9f838067546c20db1b2c4956567ed58b7bf545a259f5f41feaa99b31ab0`.
The exact safe-argv recipe is `dp-v8-plan01/commands.json`, SHA
`072c22b97f0407be654617f2b432422cb25f80f44fb7ff3f5afdeaa0720966f5`.
No record-width policy follows from this result.

## Evidence and replay

The static census is
`selfhost/build/phase58/program-regression-source01/report.json`, SHA-256
`e89de9692c6ab91363ee5cd64f1e34daca4f9a806e793f931ca73a599015f009`.
Its producer is `7a94b48d4e94f8d60d88c77f3a34d1c2403e3eecdfa84222031c31ca6da5ab4a`.
Inputs include both manifests, all module hashes, the Node binary and producer;
all were rehashed after reading. Independent review reproduced the three exact
reconstructions. No target execution occurred in this investigation.

The final aggregate is
`selfhost/build/phase58/program-performance-shared01/aggregate/report.json`, SHA
`13fa732a629589a2717e118df3e592eae17fab08b559a284ccbebfeead894626`.
Historical reports remain unchanged: Phase56 `string01-performance/timing-0`
SHA `8d06e7e0e1c42f35c1b9d1e1ec940d49267bd7566b223d1f991e81c95cebec56`,
Phase53 `full-checked-ordered02-batch0`
SHA `8f02120036ea422bf823f1d36cec80fec55217fdae69b8367787eb2852a9b370`,
and `batch1` SHA `09c5b26b6237bacd417c77e9558e54d29d906788f2214df5370baa40e209e96f`.

Replay only the data analysis into a fresh output file:

```sh
taskset -c 0 node selfhost/tools/performance/phase58/analysis/program-fields.mjs \
  selfhost/build/phase56/string01-full/manifest.json \
  selfhost/build/phase58/final-shared01/checked/program45/manifest.json \
  selfhost/build/phase58/program-regression-source-replay/report.json \
  test-map-set-ops editdist local-pair test-morning-program
```
