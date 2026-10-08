# H6: frame4 case-local field loads

The selected State09 helper eagerly validates and materializes 46,757 records.
Its source unconditionally loads nine fields per record: 420,813 loads for
224,332 actual fields. Only 22 loads exceed the typed-array extent; most unused
loads read subsequent records. Both real segments are aligned. These counts are
not a CPU-gain estimate: V8 may eliminate unused loads, and the fresh decoder's
tier-up cost could dominate.

The isolated patch moves field reads into each validated tag case. It preserves
all original validation, fixed literal shapes, object property order, complete
materialization, legacy world shapes, and the encoder. It changes no compiler
algorithm, driver, API, Base source, or cache bytes. The source/profile review is
`implementation/phase65/evidence/state09-frame4-h6-review.json`.

Root-requested preparation has produced
`selfhost/build/phase65/frame4-case-local01/manifest.json`. Its `commands.json`
contains a single-guard root probe command and a separate optional V8 trace
command. No target was executed during preparation. The unchanged Phase64
`arena-controls-v2.mjs` supplies 87 schema/domain controls, including unused
records, backwards references, U32/Unicode rules and historical world shapes.
The controller then runs four position-balanced baseline/candidate pairs in
fresh processes, using the same real frame4 cache bytes.

Each worker performs first, second, third and four later decodes before any
oracle decode or equality walk. Clocks include frame parsing, payload digest
checks and eager decoding, but exclude import/file read/preflight. All results
are retained until post-clock validation; natural GC pressure is therefore part
of this microprobe. Every node, reference-sharing relationship, prototype, root,
kind and string table is compared afterward. This is not a whole-compiler timing
claim or an OS-cold storage benchmark. Later decodes are diagnostics for tier-up,
not independent fresh-request samples.

The candidate is bound to the exact State09 helper. If H5's constructor-index
world field is selected, rebase into a fresh artifact and rerun appropriate
controls. Never overwrite a consumed helper, controller, manifest or receipt.
