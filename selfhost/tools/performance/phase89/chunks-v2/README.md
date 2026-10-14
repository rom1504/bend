# Deferred native body composition, v2

Isolated compiler-source candidate, layered on the frozen owned-match patch.
No production or pinned-upstream edit is required for these controls. All
compiler and native target commands belong to the root investigator and use
the serial resource guards.

`NC_Code.body` becomes normalized `NC_Text` Data: Empty, Leaf, ordered Join.
Composers carry child trees; `nc_body` renders only at eight existing final
String boundaries. N_Segment, runtime and public emitted-C interfaces stay
String. `nc_text` exposes the internal tree. `nf_inline` checks up to 4097 Bend
characters without rendering; omitted-factory emptiness uses the normalized
Empty tag. No cached length, closure difference list or new optimization IR.

The worklist renderer uses the existing JS `JDText` traversal design, without
that type's marker metadata and eager length scans. It visits leaves right
first and prepends each to the accumulated suffix. Both rendering and the
length predicate use explicit tail-recursive state. V2 corrects v1's rejected
binder order by placing current String before pending tree work in the length
worker; [v2-correction.json](v2-correction.json) retains the exact changes.

Frozen source:

- `baseline/`: ten modules, with owned match composition already applied.
- `candidate/` and `candidate.patch`: 35 body construction sites transported;
  +79 physical lines relative to the owned baseline. Unchanged field-forwarding
  patterns need no edits. The patch is **relative to owned**, not original
  production bridge.bend.
- `derivation.json`: hashes of all 132 active modules, the ten frozen pairs,
  tools, and the eight allowed String boundaries. `prepare.py` reproduces this
  source transformation in a fresh directory; it refuses existing outputs.
- `compiler-native-chunks02.bend`: derivative of the retained
  `composition/compiler-native-owned01.bend`, preserving all existing native
  equality, prepared Base, cache, imports and IO permissions. Its adjacent
  receipt records 34 replaced declarations and 11 inserted declarations.
  Inverse edits recover every parent byte. `freeze-native.py NEW_OUTPUT.bend`
  performs source transport only, not checking or emission.

Run these gates in order:

1. Check/emit `controls.bend` through the existing Phase88 component workflow.
   Do not launch outputs unless acquisition reports complete. Run raw JS and
   native; `compare-controls.py JS_STDOUT NATIVE_STDOUT NEW_REPORT.json` requires
   byte-identical outputs and 114 independent oracle assertions across 19
   cases. These include normalized empty nodes, text order, reused subtrees,
   8192-deep left/right skew, and ASCII/Unicode/split boundaries at 4095–4097.
2. `assemble-controls.mjs baseline NEW_OLD.bend` and
   `assemble-controls.mjs candidate NEW_NEW.bend` produce full-manifest control
   sources while verifying every frozen input. Check both; run old JS, new JS
   and new native. `compare-lowering.py OLD_JS NEW_JS NEW_NATIVE NEW_REPORT.json`
   compares nine actual recursive-lowering products, with independent error,
   fresh and segment assertions. The body is rendered into P89Code only at the
   observation boundary; every other field is unchanged and compared exactly.
3. After focused gates pass, fully acquire the frozen native source. Require
   exact C on Map, a nested case and a shallow case before timing. Compare to
   owned-only, retaining the same Base and runtime adaptations. Request timing
   includes final rendering. Record append characters, allocation counts and
   memory alongside time so moved work is not mistaken for removed work.

No execution or speed result is asserted by the source receipts. Tree nodes
add allocations; String-producing leaves and final indentation still do work.
The whole-request append budget is not all attributable to body composition.
