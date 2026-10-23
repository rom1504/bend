# Phase128 third checkpoint: real N1 gain and a stronger field-read candidate

The first actual combined N1 passes all19 focused native cases. Three rotated
cold source-to-QBE rounds give:

| Request | Repaired source32 image | New Phase128 N1 | Upstream TypeScript/Bun |
|---|---:|---:|---:|
| Lexer | 2.223385s | 2.118534s | 0.728538s |
| Closures | 0.617597s | 0.600333s | 0.528506s |
| Map | 3.505974s | 2.967446s | 1.101433s |

Geometrically, request time is7.79% lower than the repaired image, and2.07229×
upstream. This is useful but does not approach parity yet. The repair image
contains unchanged Phase126 source32, emitted with Phase127's capability repair;
it is not an image of Phase127 source. The new compiler has different source.
Both newly emitted products link the same additive runtime; the compiler
executables retain their own recorded runtimes. Ready-executable time is a
different metric with different runtime-build policies.

The modest compiler gain versus the large proxy gain is not a contradiction:
the proxy concentrates one particular computation. Other native requests still
pay Base decoding, frontend work, candidate analysis and verification. The
remaining2.07× deficit cannot be projected away from a kernel result.

## A further bounded experiment

The borrowed readers still called an opaque runtime field helper and copied
fields through scratch. A certified late template exposes those reads to QBE
after the original verifier, preserving exact tag/constructor/count checks,
RFC header decoding, scratch/status semantics and the helper fallback.

Five rotated clean rounds on the unchanged compiler-name kernel:

| Version | Median |
|---|---:|
| Parent QBE | 1.490729s |
| Combined borrowing/boundary restoration | 0.531184s |
| Plus guarded field template | 0.368798s |
| Upstream C/Clang | 0.102037s |

The template saves30.57% beyond the combined candidate. Overall the kernel is
4.04× faster, still3.61× upstream. Machine inspection shows **more** whole-function
instructions (equality reader130→220) and the same number of textual call sites;
retained fallback blocks explain why those static totals do not measure hot
work. The independent ABI fixture proves the valid path bypasses the helper.

The unchanged compiler verifier and21 template controls pass. The independent
QBE/C ABI fixture passes545 checks: raw/static-like and RFC payloads, widths2–8,
high header words, exact status, unchanged state/heap/canaries, and malformed
tag/CID dispatch before dereference. Its helper spy tests dispatch, not production
failure behavior; the real helper's fail-stop semantics remain separately audited.
Ordinary sharing/alias/Unicode and renamed numeric-spine programs pass27 lines.
Actual borrowed workers for the renamed spine and numeric list are present.

The final wired source
`6bd9de05e251180280a6761fa46be30dc2a22164cdb35c9ca48fd710911d0f4d`
passes100 predicates and has a source-bound acquisition admission including the
545-check oracle. Final hosted acquisition is running. Existing qualified and
installed selections remain unchanged; this checkpoint does not claim N1/N2
self-reproduction for either new source.

## Costs and rejected directions

The first full hosted acquisition took526.60 guarded seconds and3.44GiB peak;
machine build14.34s; focused19 took22.60s; first request timing57.51s. Using Node
for the checked API is an acquisition choice, not a native throughput gain.
Its smaller same-source Map probe emitted identical QBE; the historical full
Bun build is a different source and therefore not a controlled speed ratio.

The constructor-index audit stopped after finding a small ceiling for the
current request benchmark: old profiles assign0.55% lexer and0.33% Map to that
context. Existing index and provenance search also have different duplicate and
nesting rules. Blindly reusing the index would be unsound. The research note
preserves the evidence and points to decoding and repeated usage queries as
larger remaining costs, without treating old sample shares as new gain forecasts.

Evidence: `selfhost/build/phase112/p128-research01-repair-n1/report.json`,
`selfhost/build/phase128/field-timing01/report.json`,
`field-machine01/report.json`, `native-admission02.json`, and the field-template
[audit](borrow-field-template-audit.md). Final native and broad runtime results
will be reported separately.
