# Mixed scalar-array layout probe

This is a prerequisite observation, not a compact-IR performance result.
The checked probe in `selfhost/tests/phase148/layout.bend` allocates and fills
an `Array<U32>`, updates each element, traverses it again, and includes a cold
`Array<String>`. The latter deliberately prevents the whole-program scalar-array
capability from giving this small test a layout unavailable to the real compiler.

`selfhost/build/phase148/layout07` contains the frozen source, checked hosted
acquisition, explicit Phase147 N2 native build, complete QBE and machine products,
and guarded execution. The producer is the qualified image
`ab5662a17690f6814834074442905fec2f061a67203e66c3008d51d48727ca32`.
Five independent integer-output controls pass, including zero length, non-power
of two length, and U32 arithmetic wraparound. No out-of-bounds array operation is
executed. `experiments/phase148/layout-probe.py` preserves the run method.

The descriptor has capabilities=5: serial execution and live register bank,
without scalar-array capability=2. Its scalar cells therefore use the ordinary
eight-byte Term slots, not a four-byte packed buffer. They remain contiguous.
The native contract is in `selfhost/src/runtime/qbe/runtime.h` and
`selfhost/src/runtime/qbe/runtime.c` (`native_array_get/set`). Array indexing wraps;
the private codec must establish bounds independently. Array writes mutate
shared backing storage; explicit clones are necessary for independent branch
facts.

Generated QBE uses `p111_rt_op` opcode73 for array writes and
`p113_rt_array_pair` opcode72 for reads. Array-pair specialization avoids part of
the tuple transport, but these are still runtime calls. This is a concrete
remaining representation boundary if numeric indexing fails to pay off. Do not
describe the prototype as direct scalar machine-memory access.

The largest diagnostic control performs100 iterations over4096 elements, with
fill, read/update and final reduction. It completes in25.6ms including startup
and cleanup in this one observation. This is neither a paired speedup nor a
prediction of compiler performance. The complete multi-consumer experiment must
also charge name interning, side-table initialization, branch cloning, encoding,
decoding, original final verification and rendering.

The initial six source acquisitions failed on probe syntax/affine usage and
remain preserved in `layout01`–`layout06`; no successful target result was
discarded. A guard argument rejection before target launch was corrected by
using the maintained64MiB minimum file limit. The final source is independently
checked; these controls are finite tests, not a BendTT theorem.
