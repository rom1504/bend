# Bounded packet writer experiment

Final checked candidate: `../native-io-v05.bend`, with `batch-controls-v04.bend`,
composed into `selfhost/build/phase134/batch-source05/compiler.bend`:
`95c4ac4f0d529a0c63cc2e8a7e010c4e95ef4a4db2d697817560a46518f68c99`.
The existing `plan-v02.bend`, `success.bend` and original streaming source02
remain unchanged. This writer is experimental until separately native-qualified.

The packet builder consumes the same sealed-plan cursor. It writes at most64
original pieces and65,536 **characters** in one packet. A single larger original
piece is written alone; a pending rendered piece can survive one flush, so the
live-text bound includes the packet, one lookahead piece, transient concatenation
and the File.write byte buffer. This is not a bound on the whole compiler's IR
or RSS. UTF-8 byte counts can exceed character counts.

A capped U32 counter inspects at most65,537 characters of a piece. It does not
allocate a unary Nat length or scan the remainder of an oversized piece. A
packet that cannot accept the next piece retains that already-rendered step;
it does not render the function twice. Original print-newline markers become
separate one-character fragments. `nt_text_finish` concatenates the reversed
fragment list once per packet; there is no per-piece `text ++ "\n"` operation.
The existing File.open/File.write/File.close effects and failure path are reused.

The implementation adds work for capped length traversal and concatenation.
Fewer writes/effect transitions are a hypothesis, not a measured speedup.
Native acquisition and comparison must establish whether the saved transport
cost exceeds this work. No runtime or optimizer policy is changed.

Evidence:

- `phase111/p134-batch-api05/report.json`: full source check,13 exports;
  guarded acquisition14.21s,2.02GiB peak process-tree RSS.
- `phase128/p134-batch-finite05/report.json`:25/25 controls pass in1.90s:
  original15 emission controls plus10 independent packet cases.
- Cases cover empty streams/pieces, existing and added newlines, exact character
  limit, an oversized piece alone, retained lookahead, the64-piece limit and
  multiple data fragments. They compare complete concatenated bytes against
  explicit expected strings and the unchanged data-table emitter.
- `phase134/batch-source-contract01.json`: separate source-only audit from the
  validation owner; native qualification remains a separate gate.

Negative evidence was retained. The first writer/control version used
`nt_choose` for long recursion: the checked hosted API compiled these closure
calls without a self loop, and the65K-character control hit a JS stack limit.
The final counter and fixture generators use explicit Boolean parameters and
direct self-tail calls. The long-string oracle uses the existing independent
`p88_string_eq` loop, avoiding the recursive reconstruction in `String.eq`.
Two intermediate source checks also rejected illegal local/later scrutinee
matching; no native image was acquired from any failing version.
