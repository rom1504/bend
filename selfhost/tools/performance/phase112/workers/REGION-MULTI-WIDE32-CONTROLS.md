# Wide continuation-fusion boundary controls

`region-multi-wide32-controls.mjs API.mjs FRESH_OUTPUT` prepares five paired
native fixtures plus two refusal controls. It requires the existing `p112c_`
API exports and `p112w_symbol`. Only root executes the transport and native pairs.

Widths9,16,32 each capture distinct values, pass an independently permuted full
argument list to a private leaf, take the leaf's returned product, and construct
a final product with `2*n` fields. Full readback observes every captured value
and every argument; no checksum substitutes for positional equality. The
32-capture continuation has original arity33 and its copied suffix has101
statements, within the unchanged128-statement limit. Its private callee has33
machine arguments including state, crossing the register/stack ABI boundary.

Two width9 fixtures use one shared dynamic String for all18 capture/argument
credits, plus a19th owner retained by an outer continuation. Every keep feeds
the returned sealed owner into the next keep. The product-first variant drops
all18 fields and returns the outer alias; the alias-first variant drops that
alias and returns the complete18-field product. Expected files observe the
full Unicode String content in both release orders.

Separate33-argument and33-capture graphs remain legal generic IR but must not
fuse or admit the caller privately. Neither refusal graph is executed.

The isolated overlay is `region-multi/wide32-entry.bend`, pinned by
`wide32-modules01.json`
(`36639759289720d7ff076129c87e50f593a112f7d4f5bf46e403981b013f74cf`).
Independent review confirms its only changes are capture bound8→32 in
`p112c_frame` and callee bound8→32 in `p112c_target`. Snapshot/bind/argument code
is count-parametric;32 words require256 bytes of the existing2048-byte scratch.
Eight sites, six immutable ranks, the128-statement copied-continuation limit,
original verification and pinned CPU fail-stop runtime remain prerequisites.

The separate `admit-region-multi03.py` method uses
`conjunction-region-multi03.json`, pins37 modules plus the final hook and selected
runtime source/object, and requires21 changed-source refusals. It does not alter
the preserved multi02 recipe. All detected float/static/word-selector companions
must bind the same composed compiler.

```sh
python3 selfhost/tools/performance/phase112/workers/admit-region-multi03.py \
  --runtime-source selfhost/build/phase111/runtime-source04/runtime.c \
  --runtime-object selfhost/build/phase111/runtime-source04/runtime.o \
  --compiler COMPOSED/compiler.bend --out FRESH_ADMISSION
```

No target execution occurred during this preparation. The source argument and
controls do not themselves establish native ABI or ownership qualification.
