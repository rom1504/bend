# Function-body suffix fusion and native renderer fixture

Research/source preparation only until the root's checked and native receipts
exist. No installed selector or runtime change.

`body-tail-v01.bend` defines the new suffix-preserving helper.
`prepare-wrappers-v02.py` mechanically derives `wrappers-v02.bend` from exact
qualified Phase143 source; `wrappers-v02.json` records all16 edits, the retained
independent oracle and two unchanged body-only uses. It proves reverse-exact
source edits. `controls-v01.bend` exports `p144e_controls` with ten independent
expected-string controls, including both invalid-body and fallthrough markers.
Version01 wrapper preparation remains frozen and unexecuted; version02 is the
candidate because it preserves the existing oracle renderer.

Composed source:
`selfhost/build/phase144/body-tail-source02/compiler.bend`, SHA
`7fb6564797c7c8ba51730c5e183609f3e9f9e4dc550fc86a35d7e121cc5bf781`.
Use its manifest for exact modules/overrides; do not manually edit the frozen
compiler source. The normal Phase144 source composer preserves protected gates.

## Actual function fixture: useful capture, failed acquisition

**Do not retry the full captured-constant fixture with a longer timeout.** The
root executed the capture and two native acquisition attempts. Capture02 passed
the full Lexer product gate. Acquisition01 rejected a missing associated law
declaration; prepare-native-v02 preserves all same-name laws/definitions in
original source order. Acquisition02 timed out after150 seconds, with no QBE
and about160MB peak process-tree RSS. The787KB source embeds a huge complete
renderer context. No native renderer speed result exists. Keep these failures;
complete ordinary-program QBE comparisons and integrated native timing are the
next economical gates.

The commands below describe corrected future capture methods, not a request to
repeat the failed native acquisition now.

Root executes targets in its controlled lane. `capture-v02.mjs` uses the parent
checked API from an already authenticated Phase143 hosted-stream input. It
checks the complete parent product and retains real renderer input/context plus
the exact emitted function bytes, selecting small/middle/large cases in each
available cursor family. It generates no QBE itself.

```sh
selfhost/.bootstrap/bun-1.4.3/bun \
  selfhost/tools/performance/phase144/emission/capture-v02.mjs \
  selfhost/build/phase143/integrated-hosted-lexer01/input.json \
  selfhost/build/phase144/render-capture-new01
```

Then select a fixture name from that report, initially the middle private
function. Preparation below is metadata/source extraction only:

```sh
python3 -B selfhost/tools/performance/phase144/emission/prepare-native-v02.py \
  --capture selfhost/build/phase144/render-capture-new01/report.json \
  --case NAME_FROM_REPORT \
  --out selfhost/build/phase144/render-native-new01
```

The result contains `baseline.bend`, `body-tail.bend`, `expected.stdout` and a
pinned manifest. It extracts actual selected Bend renderers and their recursive
dependency closure; candidate substitutions are the same frozen production
wrapper edits. Captured constructors are serialized as typed Bend data with
field-set checks. This is not a host compiler. Source checking is still required:
the extraction metadata alone cannot establish a complete typing closure.

Acquire/build the two ordinary programs through the existing Phase125 native
emitter and Phase123 aligned builder with the same Phase143 qualified N2 and
unchanged Phase128 runtime. Use the **actual** native source checker and original
ordinary output oracle; do not substitute a generated expected hash from either
new binary. No args emits exactly the captured function text. One numeric arg,
such as `100`, renders and writes the complete function that many times to
`/dev/null`, closes it and prints one decimal IO.now elapsed-millisecond line.
Input construction happens before timing; render, native UTF-8 conversion,
writing and output reclamation are included. Calibrate to >=200ms and rotate
baseline/candidate order. No target runs have been performed by the audit agent.

Capture Map/closures through their existing Phase143 hosted inputs for transfer.
Require private, legacy and public coverage before generalizing a gain. A
workload with no legacy entries must be reported as absent coverage, not silently
replaced with a synthetic case. The fixture excludes frontend/optimization and
machine acquisition from its kernel; price them separately and use full-request
measurements only after a compelling native result. A future private-only
fixture can project unused context fields after an explicit source read-set
proof; no such fixture was acquired in this cycle.
