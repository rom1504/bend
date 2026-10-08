# Checked05 checkpoint

This is a tested migration checkpoint, not final release admission. The selected
upstream remains `059266225b77c8ca256ac6b25ee5c21449bab151`.

The final native runtime snapshot builds and passes strict36. Its selected B1
API remains `1ed7deccc250732402fb3aebda4c0852adacdf983a8bcfe12b12658dfda23094`.
Relative to checked04, the source change is confined to eight native C files;
the independent closure comparison separately qualifies reuse of JavaScript
evidence. The snapshots and failed attempts remain immutable.

This checkpoint enables optional annotations only for the independently
qualified new Base, fixes iterative legacy Array marshalling, and migrates
blocking native channel/socket result contracts. The C runtime accepts both
retained and current foreign helper signatures. Channel errors return their
payload; socket send errors return the unsent data; TCP EOF uses `None`.
Thirteen newly introduced native handlers remain explicitly unsupported.

Closed evidence at this checkpoint:

- Checked05 build and strict36: PASS, 29.887 supervised seconds.
- Actual B2 own-source check and exact B2/B3 reproduction: PASS.
- B1 and B2: 96 source, 34 numeric, 18 composition and two overapplication
  controls each pass; the reference's seven oracle failures remain recorded.
- New-Base cached-product and custom-Base fallback controls pass for B1 and B2.
- Native blocking IO: 19/19 source controls pass for both current upstream and
  Bend; fresh native arithmetic/array controls also pass.
- Full 23-source latency campaigns: 207 exact outputs pass for each compiler.
  Compilation-only ratios to current TypeScript are 1.396168× B1 and 1.327154×
  B2. Relative to their previous images, changes are +0.349% and −0.352%.
  Import-inclusive ratios are 0.981524× and 0.994718× respectively.

The full 45-point runtime campaign, executable JavaScript conformance, native
fault-injection check, installed-release checks and durable archive are still
pending here. The [phase report](README.md) records subsequent outcomes and
links the complete evidence; this dated checkpoint must not imply those passed.
