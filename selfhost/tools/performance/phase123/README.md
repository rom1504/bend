# Phase123: predicate transport and array address selection

These are experiments on the authenticated Phase121 source, not changes to the
installed compiler. Compiler transformations are written in Bend. Host scripts
compose declarations, transport checked output and evaluate independent oracles.
[Design](../../../../design/phase123/typed-private-computations.md).

Retained candidate: `predicate/model02.bend` plus `scaled-address02.bend`, replacing
exactly `p113l_record`, `p113k_scalar_bin`, `p117h_address`. Build with `prepare.py`
against `implementation/phase121/candidate.json`; acquire an API using the unchanged
Phase111 `check-api.py`. Source04 is the combined candidate. Source03 preserves
a rejected two-argument use of unary `U32.shl`; its failed emission
correctly refused an unchecked receipt. Do not overwrite frozen attempts.

All target commands run serially on CPU3 under the Phase111 process-tree guard:
2GiB RSS,16GiB available floor,64MiB per-file cap and a bounded deadline. Use fresh
output directories. No full native image acquisition or production promotion.

## Fast loops

- `predicate/controls.mjs`: checked IR output versus600 independent BigInt cases;
  literal admission/refusal expectations and the unchanged full verifier.
- `address/controls.mjs`:80 modulo64 boundaries,450 masked offsets and exact
  GET/SET/SWAP templates. No pointer dereference.
- `controls01.json`:25 ordinary unsigned-boundary results plus56 renamed RLE
  alias/count-wrap/list results; unchanged Phase118 emission and functional runner.
- `screen.py`: unchanged original sources, frozen complete result/count oracles,
  rotated candidate/Phase121/upstream runs. Custom source-ceiling manifests are
  explicitly diagnostic and map to the original parent program.
- `ablation.py`: authenticated already-built original editdist products, four roles
  (Phase121, predicate-only, combined, upstream), four rotations and longer batches.
- `machine.py`: bounded read-only function disassembly, not execution counts.

Use existing Phase118 `emit-integrated.mjs` with
`P118_RUNTIME_REPORT=selfhost/build/phase118/runtime-extend01/report.json`.
For controls set `P118_CASE_MANIFEST` to `controls01.json`. For compiler-cost runs
use unchanged `cost-v2.mjs`, with `P118_PARENT_SELECTION` pointing to Phase121,
`P118_PARENT_API_REPORT` to `p121-api04/report.json`, parent emission to
`p121-broad-emit04/report.json`, and expected emission to the candidate's exact
receipt. This measures checked-hosted prepared request work, not native N1/N2.

## Broader gate and evidence

Emit the original45 with the same emitter/manifest. `screen.py --rounds 3 --scale 4`
retains the ordinary-assembler comparison. The final selected experiment uses
`screen-final.py` with `build-aligned.py`: GNU assembler receives
`-mbranches-within-32B-boundaries`. `screen-aligned.py` isolates that policy against
the same unaligned candidate; `replay.py` confirms suspicious short-screen results
without rebuilding. `functional-aligned.py` uses the same selected builder for
ordinary controls. No generated QBE or assembly text is rewritten. `summarize.py` preserves the44 timed points and zero-work sentinel;
`analyze-broad.py` also preserves the frozen family labels, sum-of-batches and
emitted sizes. A gain on one family is never evidence of full-corpus parity.

`accounting.py` accounts for every completed guard, including failures, and rejects
overlapping target lanes. `seal.py seal` archives small receipts, outputs and bounded
disassembly; `seal.py replay` verifies the archive without extracting it. Compiler
sources, generated SSA, APIs and binaries remain external but have recorded hashes.

RLE explicit state-lane variants are source ceilings only. Both variants end up
with all state lanes flattened, so they are not an isolated shell-depth ablation.
The strict-subterm layout experiment failed to admit the actual RLE aliases; its
control parser failure and all receipts are retained. The ready-call audit proposes
an explicit continuation node plus authenticated callable view; it is not implemented.

`reproduce.py --out FRESH_PHASE123_DIRECTORY` verifies the recipe and reproduces
the exact combined source. `finalize.py` pins the completed hosted candidate and
its separately qualified machine-build policy; it does not install or promote it.
