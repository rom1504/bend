# Closed-template traversal experiment

Source-only preparation; no checking or performance result is claimed here.
See [the source investigation](../../../../../research/phase141/static-traversal.md).

`manifest-v01.json` pins append-only compiler-component modules and exports.
When using a Phase140 source that already contains `typed-v01.bend` and the
`p140tc_*` fixtures, append only `core-v01.bend`, `wrappers-v01.bend` and
`controls-v01.bend`; do not redeclare the exact fixture subset.

The standalone `native-v01.bend` needs only `import Base`. Exact original type
and helper spans, its workload and independent output oracle are recorded in
`native-source-v01.json`. `cases-native-v01.json` uses the existing Phase118
integrated-emitter case format. The no-argument ordinary output is six lines
containing `25`, with exit status zero and empty stderr.

After the ordinary gate passes, final runtime arguments are:

```text
-- REPEATS WARMUPS LIST_SIZE MODE
```

Modes: `0` runtime comparator callback, `1` handwritten typed traversal, `2`
closed template callback. Other mode values use the static path. Example:
`64 2 256 2` must print `25`, `50`, `1600`, then one elapsed integer line.
The first three lines are independently fixed by:

```text
25
(25 * WARMUPS) modulo 2^32
(25 * REPEATS) modulo 2^32
```

The fourth line is an `IO.now` delta. List construction and warmups precede the
timer; one result formatting/write is inside it, identically for all modes.
The list has `LIST_SIZE + 1` elements including its sentinel. Equal lists are
constructed independently in opposite orders; additional lists differ at the
sentinel or omit it. Immutable roots remain retained across comparisons.
This samples shared compiler-IR ownership, not every possible list workload.

Use one binary and calibrated fixed arguments in serial paired runs. Inspect
the actual instantiated QBE worker before attributing a result to callback
elimination. No machine build or compiler benchmark is hidden in these files.
