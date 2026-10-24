# Isolated native writer experiment

`fixture-v02.bend` uses the actual unbatched writer definitions and actual v05
packet-builder/writer definitions, with a small ordinary Bend producer replacing
the compiler's cursor. The third writer sends the original piece and its newline
in separate File.write calls, avoiding concatenation. It uses a retained shared
String to emit4MiB, in either4,096 pieces of1,023 characters plus newline or512
pieces of8,191 characters plus newline. Shared preconstructed pieces isolate
writer overhead; they do not model compiler lowering, unique fresh strings,
mixed piece sizes, whole-image memory or compiler-runtime effects.

Qualified Phase131 N3 checked/emitted this ordinary7.8KB source in1.95 seconds;
aligned QBE/assembly/link took0.35 seconds. All six variants produced the exact
independently constructed4MiB bytes. Three rotated `/dev/null` observations per
variant produced these diagnostic medians:

| Payload per piece | Existing `text ++ LF` | Bounded v05 packet | Separate text/LF writes |
|---|---:|---:|---:|
| 1,023 characters | 234.84ms | 218.03ms | 171.82ms |
| 8,191 characters | 192.32ms | 215.97ms | 93.43ms |

The no-copy variant was26.8% and51.4% faster than the existing writer. Batching
was7.2% faster for small pieces but12.3% slower for larger pieces. This is a
small diagnostic experiment onCPU6 while a compiler acquisition occupiedCPU3,
not a clean end-to-end compiler comparison. It supports testing the simpler
no-copy writer; it does not establish a compiler gain or justify promotion.

The current runtime explains competing costs:

- `io_print_run` (runtime.c3225) directly converts and writes via synchronous
  `fwrite`; its newline does not copy the Bend String.
- `file_write_run` (3450) converts the supplied String, then `io_work` (2660)
  parks an activation, queues helper-thread work and resumes through a wakeup
  pipe. `file_write_call` loops on raw `write(2)` (3431).
- Thus batching saves IO round trips but adds a length traversal and linked
  String concatenation. The no-copy method doubles File.write transitions for
  newline-bearing pieces but removes the concatenation. The fixture shows the
  latter wins here despite those additional transitions.

`check.py` also runs the independently retained tiny IO fixture: exact pipe
output `one:two\n`, preservation of a redirected prefix, and `/dev/full` failure
with exit status28 and `No space left on device`. The selected runtime's
`file_close_run` (3482) calls raw `close(fd)` and ignores its return; there is no
stdio flush buffer on File.write. This does not prove all possible delayed
filesystem/close failures are reported. No runtime change was made.

Evidence:

- `selfhost/build/phase130/p134-writer02/report.json`
- `selfhost/build/phase111/p134-writer02/report.json`
- `selfhost/build/phase134/writer-check01/report.json`
- `selfhost/build/phase134/writer-check-guard01/process.json`

Initial fixture01 failed ordinary source checking because forward dependencies
were not marked unsafe. The final ordinary fixture marks the same mutually
recursive helpers unsafe, as the original compiler modules do; their values and
output still pass source checking and independent byte oracles. No compiler
admission predicate was changed.

`../../native-io-no-copy-v01.bend` is a source-only integration proposal. It
preserves the original per-piece cursor bound and error/close flow, removes
`text ++ LF`, and introduces no packet state or length scan. Its assembled compiler source and15 original controls are checked; native
compiler acquisition/qualification belongs to the separate root campaign.


The exact no-copy helper bodies also passed a separate second-write error
experiment. `newline-failure.bend` emits an empty piece with its newline marker.
On `/dev/full`, the first zero-length File.write succeeds; the subsequent one-byte
newline fails with ENOSPC28. Normal output is exactly one LF and append mode
preserves a prefix. `newline-bridge.json` binds all five unchanged helper bodies,
the qualified-producer acquisition, aligned native build and three passing
controls at `selfhost/build/phase134/newline-check01/report.json`.

`writer-evidence.tar.xz` retains the small sources, receipts, ordinary-output/error
controls and original runtime source. Large generated QBE, ELF and repetitive
4MiB outputs are omitted; their exact identities and deterministic construction
are retained. `writer-evidence.json` records every archived member and verifies
round-trip contents. No compiler image promotion is implied.
