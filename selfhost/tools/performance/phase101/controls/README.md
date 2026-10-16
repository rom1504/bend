# Native String representation controls

These finite controls protect observable values while changing String storage.
They are prepared independently of the implementation and contain no unsafe
Bend code. Preparation does not compile or execute a target:

```sh
python3 -B selfhost/tools/performance/phase101/controls/prepare.py \
  --out selfhost/build/phase101/string-controls-FRESH
```

Root owns all guarded, serial compiler/build/program execution. Compile each of
the four sources once through the baseline and candidate; compare complete
stdout bytes, empty stderr, and exit zero for every manifest record. The file
case's `argv` follows runtime options and `--`. Run with `--threads 1 --gpu off`
first; repeat at two/four workers for parallel ownership. Pin all generated C,
binaries, runtime/compiler identity and actual run inputs. No passing execution
or safe admission is claimed by this preparation alone.

| Source | Contract |
| --- | --- |
| `values.bend` | Empty/literal strings; shared roots/tails; escaping a disposed product; repeated matching; append/concat ownership; take/drop/reverse/list roundtrip; full `String.cmp` returned inputs and order; codepoint versus byte equality; complete 132-character value and a crossing slice. |
| `parallel.bend` | Sixteen forked leaves share an original suffix, prepend distinct paths, join in deterministic order, and retain the original after joining. Complete stdout includes embedded NUL, Greek and astral text. |
| `array-sharing.bend` | Replicate a String into 64 Array cells; extract a surviving alias; replace first/middle/last cells; consume and observe every cell; separately drop a 128-cell repeated Array while keeping an extracted tail and original source live. Exercises batched ownership in native Array filling. |
| `file-input.bend` | Runtime UTF-8 decoding, empty and embedded-NUL input, invalid-byte replacement, complete numeric codepoint sequence, reversal and raw re-encoding. Shared overlapping tails at offsets 60/61/62 are appended in both orders before observing the original roots again; inputs include 60/61/62-character boundaries and 260 characters spanning multiple chunks. Uses admitted args/open/read/close/print providers. |

The oracle uses Python integer lists and lexicographic ordering, not the Bend
runtime's String walkers. `parallel` uses a Cartesian product of paths rather
than implementing the Bend recursive fork tree. File decoding uses Python's
UTF-8 replacement decoder; its chosen boundary vectors must agree with the
unchanged baseline before being used to reject a candidate. If they disagree,
preserve the mismatch and resolve the IO contract explicitly. Full expected
bytes and every preparation/source hash are in `controls.json`.

`Char` is `Chr{code: U32}` in `bend2/base.bend`; `Char.from_u32` does not restrict
the value to Unicode scalars. A compact String representation must therefore
retain all 32 bits, including surrogates, values above `0x10FFFF`, and
`0xFFFFFFFF`. The high-value case observes decimal words, deliberately avoiding
assumptions about their encoding at an IO boundary. This is broader than a
UTF-8-only representation. `IO.print` is length-based and embedded NUL is data.
The native `io_str` boundary decodes invalid UTF-8 with replacement; it does not
justify discarding arbitrary in-memory Char values.

Before promotion, also replay the existing Phase98 generic Array/String and
borrowed observer alias controls, Phase99 borrowed-product escape controls,
the Phase100 complete app smoke set and frozen parallel image, then the changed
Phase93 programs and native conformance. The Phase97 ownership model is useful
for retain/read/release reasoning but does not prove this concrete runtime or
parallel protocol. Preserve the graph-planning gain and full original String
results, not just Boolean comparison answers. Old JS-only string-order tests
pin a different upstream and are research material, not a current-native gate.
