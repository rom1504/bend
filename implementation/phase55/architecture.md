# Phase55 source accounting

Frozen `checked-host02` adds **27 physical lines, 19 code lines and four definitions** over Phase54 `checked-graph02`. Only the direct backend's `model.bend` and `host.bend` change. All 17 native modules, both JavaScript runtimes and the typed driver remain byte-identical. This is a small compiler-source optimization, not a backend removal or a runtime change.

## Method and totals

The unchanged [Phase47 counting method](../../selfhost/tools/performance/phase47/measure-size.py), also used by [Phase54](../phase54/architecture.md), counts Python `splitlines()` as physical lines, nonblank lines excluding leading `#` comments as code lines, and leading `def`, `law` and `type` declarations. It covers only manifest-listed Bend modules. Declaration counts do not measure independent concepts; generated APIs and runtime JavaScript are separate artifacts.

The fresh data-only producer is `selfhost/build/phase55/source-census-host02.py`. Its report, `selfhost/build/phase55/source-size-host02.json`, retains per-module counts and SHA256 identities, both frozen manifests, changed-module deltas and all consumed inputs. It verifies frozen source hashes, candidate live counterparts and **343 input identities** before completing. It imports the counting method only; no compiler or generated target executes.

| Measure | Phase54 graph02 | Phase55 host02 | Change |
| --- | ---: | ---: | ---: |
| Manifest Bend modules | 107 | 107 | 0 |
| Physical lines | 26,259 | 26,286 | +27 |
| Code lines | 21,598 | 21,617 | +19 |
| Definitions | 3,015 | 3,019 | +4 |
| Laws | 629 | 629 | 0 |
| Types | 100 | 100 | 0 |
| Bend source bytes | 1,181,194 | 1,182,759 | +1,565 |
| Direct-backend modules | 11 | 11 | 0 |
| Direct-backend physical lines | 2,583 | 2,610 | +27 |
| Direct-backend code lines | 2,105 | 2,124 | +19 |
| Direct-backend definitions | 342 | 346 | +4 |

| Changed module | Physical-line change | Code-line change | Definitions | Bytes |
| --- | ---: | ---: | ---: | ---: |
| `src/back/js/direct/model.bend` | +20 | +15 | +3 | +985 |
| `src/back/js/direct/host.bend` | +7 | +4 | +1 | +580 |

The other **105 manifest modules** match exactly. Native C retains 17 modules, 2,092 physical lines, 1,745 code lines, 286 definitions, 41 laws and 17 types. The three common modules also match exactly. The model change reuses annotated matcher ownership when raising definitions; the host change reuses export eligibility work. Their behavior and compiler-cost qualification belong to the [arity report](arity.md) and [compiler-image study](bootstrap-usability.md), rather than this size census.

## Runtime and image identities

The direct runtime remains 13,212 bytes / 471 physical lines; the legacy runtime remains 57,500 bytes / 721 lines. The shared runtime core also matches exactly. The typed driver remains 53,800 bytes / 761 lines.

| Artifact | SHA256, identical in both attempts |
| --- | --- |
| Direct runtime | `c328b77360c98489343d4752d4644d93f64de9d697d2c964f5fbae6442a77d23` |
| Legacy runtime | `3158f543b3fb67d2319a83e18485c116708bc8f17998e602f29ee95e83c05e46` |
| Typed driver | `eb4bb871371fb2fb61fa1c077d093a817a1f6ae35205ebb2beecfb6e064fc417` |

The derived generator API grows from 1,828,672 to 1,830,492 bytes (+1,820); its physical lines grow from 44,046 to 44,086. The checked API grows from 1,805,276 to 1,807,041 bytes (+1,765). These are emitted compiler-image sizes, not retained Bend source counts.

| Binding | SHA256 |
| --- | --- |
| Phase54 graph02 derived API | `d7d0396cda189918299ddeb0105e9d682f6a22bffa70004ab6d0ebeac20f4857` |
| Phase55 host02 derived API | `cfde1ebf44d958e593331cfd9af77f7b6ee657441dbd582db8d27f3928815a62` |
| Counting method | `8e59af66ae57c32cb335bacd480404fa1c8e52105b45aab0f4028450cfcf8681` |
| Census producer | `fc301b8090296205d0f2cc90e9b923c774a4be8102280700b42bbcdf0cf02108` |
| Census report | `a02c565393be49a0196559ff7a6e959d179d9e3e31ed60831cb81b484acc906b` |

## Timing boundary

The first split full-image emission spent **121.392 seconds in library exports**. That is an observed phase of the earlier attempt, not a whole-request median or a paired measurement of host02. The successor result was still pending when this census completed. Source-size differences alone establish neither compiler throughput nor generated-program speed; full-image usability and self-reproduction require their separate gates.
