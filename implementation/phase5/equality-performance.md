# Maintained equality derivative on a new checked build

P5-012 reproduces a useful speed improvement on the second genuine Phase5
integrated compiler. With opposite-order fresh-process samples, median request
time falls **36.4%** on the fixed core-library capsule and **25.0%** on list_sort.
This is an explicitly derived compiler image. The default checked bootstrap and
public H are unchanged; no faster generated-program execution is claimed.

| Workload | Checked B1 request | Derived request | Pinned TS request |
| --- | ---: | ---: | ---: |
| Fixed312-declaration core library |19.278s|12.262s|Not compared|
| list_sort compilation |2.464s|1.849s|0.397s|

The list request remains 6.20× TS for checked B1 and 4.65× for the derivative.
TS rereads/checks Base each time; both Bend APIs use separate already-validated
serialized Base caches. This is the stated development-request policy, not an
isolated checker algorithm comparison. Median instrumented process wall is
20.232→13.215s for core and3.408→2.778s for list; TSlist1.535s. Whole-process
startup, input hashing and file capture contribute to those walls and peak RSS.
They are measurement-wrapper costs, not production CLI measurements.

## Correctness and identities

All 10 timed rows pass. Checked/derived outputs are exactly byte-identical on
both workloads. All list programs, including TS, execute and print exactly `6`.
Core coverage is complete checked library compilation and JS syntax checking,
not runtime execution of every exported core function. This small comparison
does not establish a current full derived-compiler frontend inventory.

Original genuine checked API:
`c3c2ac7b14566e3d50f8f8dd121068cd7a1b59f6a39f44213fd538ff03fdc7e1`.
Derived API:
`76b1db68be2fa2cd720262842dfee5dab99e59ec6e8eee5fc631b88e95bf5cf9`.
Source:
`bc9d7b136463ab4bd75ee7470f725506ea8b2f4da5c54b95e7b6dfaa5bd262fb`.
The maintained helper verifies the original bootstrap's consumed inputs and
replays its own guarded transformation before/after the matrix. It creates a
separate derivation report, never a fabricated bootstrap sidecar. Original
checking evidence remains independently recorded.

## All samples

CPU 3 was reserved; other intentional compiler work paused. Start 22:49:25.818UTC,
finish 22:51:16.180UTC on 2026-09-22. Forward then reverse variant order, Node 4 MiB
stack / 4 GiB heap, fresh process per row. Base priming ran separately outside the
timed samples. Same frozen Bend host, canonical Base and output runtime; TS uses
its own pinned runtime. OS caches were not flushed. All artifact/cache hashes
remained unchanged.

| Sample | Request seconds | Process seconds | Peak RSS KiB |
| --- | ---: | ---: | ---: |
| core-0-checked | 19.305 | 20.264 | 484,380 |
| core-0-derived | 12.233 | 13.182 | 480,408 |
| list-0-checked | 2.451 | 3.399 | 299,188 |
| list-0-derived | 1.845 | 2.772 | 257,488 |
| list-0-typescript | 0.396 | 1.536 | 275,348 |
| core-1-derived | 12.292 | 13.248 | 480,836 |
| core-1-checked | 19.252 | 20.200 | 483,380 |
| list-1-typescript | 0.399 | 1.534 | 271,976 |
| list-1-derived | 1.853 | 2.784 | 256,188 |
| list-1-checked | 2.478 | 3.417 | 299,736 |

Request time excludes module import, provenance verification and output writing;
it includes normal host input/cache reads and the compiler pipeline. API timing
counters are nested instrumentation, not additive phase totals. Peak RSS covers
the complete child, including verification. Four lightweight harness tests also
pass, covering bounded settings, missing/failed cell withholding, exact malformed
diagnostic preservation, input drift and deadline failure retention. Root reviewed
the wrapper before granting the isolated slot.

## Reproduce

From selfhost, with the recorded Node24 binary:

```sh
node tools/performance/phase5/equality-compare.mjs CONFIG.json NEW_DIRECTORY
```

CONFIG names a genuine maintained checked `attempt`, a `coreLibrary` input,
`cpu`, even `repetitions` (default 2), and `timeoutMs` (default 180000). The wrapper
copies a frozen shared host, derives and verifies the optional image, primes its
own separate caches and retains all observations. Unknown provenance or failed
rows stay failures; medians require the complete comparison cell to pass.

[Preregistration](../../experiments/phase5/P5-012-portable-equality-measurement.md)
and [archive manifest](equality-performance-evidence/manifest.json) preserve
commands, original checking/derived lineage, actual APIs/sources/tools, caches,
raw timings, emitted programs and logs. Every compressed member was read back
and checked by path, size and SHA. Node/toolchain binaries and pinned Git metadata
are external prerequisites; restoring bytes does not create new provenance.
