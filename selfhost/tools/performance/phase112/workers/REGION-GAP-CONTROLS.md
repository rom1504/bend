# Independent pure-gap controls

`region-gap-controls.mjs API.mjs FRESH_OUTPUT` prepares five paired native
fixtures and 22 admission/order controls. Export `p112g_pure`, `p112g_split` and
`p112g_splice` in addition to the existing `p112c_` and original verifier/emitter
APIs. Only the coordinator executes this transport and its generated targets.

The native oracles observe capture redefinitions (`112414`), use of the frame
call's zero result inside the gap (`915`), exactly 32 ordered pure instructions
(`731`), and a shared Unicode String in both release orders (`"α😀"`). The
capture test independently checks that transformed statements order the capture
snapshots, frame-zero assignment, original gap, and argument snapshots exactly.

Negative controls cover keep/sink calls, memory reads/writes, pointer copies,
state or scratch operands/destinations, symbolic operands, inner frames, the
33rd gap instruction and an unexpectedly short generated scaffold. A nested
frame blocks crossing that frame; it can still be a separate valid fusion site,
leaving the outer frame pending. The suite does not equate this case with a ban
on every later fusion.

Independent source review of `region-multi/gap-modules01.json`
(`948eb4275e7234023e06348ff173196b9781f637a9f39a76ac979c10e919ab5b`)
found no concrete defect under the existing exact source/runtime premises.
The gap is spliced after `captures+1` generated statements: all capture values
are saved before a gap can redefine their locals, and the frame's zero result
exists before the gap reads it. Arguments are snapshotted afterward. No runtime
call, memory operation or pointer-typed statement can cross the eliminated
frame. Original operand typing and namespace hygiene are still required: the
small pure gate does not independently reconstruct local types or ownership.
Copying a Term word does not create another owner credit; the unchanged source
ownership operations account for the two owners in the alias fixtures.

The original gap statements retain their order and numeric width. Global site
freshness, copied-continuation limits, immutable ranks and first-plan emission
remain unchanged. The helper is called only on the authenticated fusion
scaffold; standalone arbitrary lists are not its production admission boundary.

`admit-region-gap01.py` uses `conjunction-region-gap01.json` to bind 40 modules
and 322 final declarations, including the original verifier/model, actual final
hook and exact fusion scaffold. Thirty changed-source controls must refuse;
they cover gap purity, bound, splice order, short-scaffold fallback, frame-zero
behavior and the original verifier's terminal-path check. The selected CPU
runtime04 source/object remain pinned. Detected word-selector, float and static
overlays retain separate same-compiler receipt requirements.

```sh
python3 selfhost/tools/performance/phase112/workers/admit-region-gap01.py \
  --runtime-source selfhost/build/phase111/runtime-source04/runtime.c \
  --runtime-object selfhost/build/phase111/runtime-source04/runtime.o \
  --compiler COMPOSED/compiler.bend --out FRESH_ADMISSION
```

Source preparation checked all module hashes, Python syntax and the specific
mutation locations without invoking a compiler or target. Native qualification
is separate coordinator evidence.
