# Phase182 JavaScript migration controls

These controls target the maintained direct JS backend and runtime at upstream
`9a4223d577ba56a0cb53d1fd952d2b481c38930f`. They are source additions, not a
record of successful execution. Root owns guarded source checks and execution.

`run.mjs --out FRESH --api CHECKED_API.mjs --upstream PINNED_CHECKOUT` runs the
paired library and foreign gate. It checks the actual checkout revision, keeps
every compiler output and failure, and records input hashes and child statuses.
The upstream lane uses its unmodified loader/checker and `js_lib(book, true)`;
the foreign executable uses `js_book(book)`. The selfhost lane uses maintained
`typed-driver.inspect` with the explicit image, direct backend and no Base cache.
Invoke it through `selfhost/tests/phase182/job.py`, never alongside another gate.

- `runtime.mjs` reads the maintained runtime into an isolated VM. It checks Nat
  host validation, packed full-U32 Char operations, scalar readback, F32 parsing,
  direct tail calls, nested effect schedulers, Exit, and the current RTS grammar.
- Compile `library.bend` independently to two fresh `.mjs` outputs, then invoke
  `compare.mjs UPSTREAM.mjs SELFHOST.mjs`. It checks scalar host conversion,
  aggregate identity, constructor interchange, exact qualified export names,
  literal dot names, and `__proto__` export hygiene.
- Compile and execute `foreign.bend` with each compiler; its `#|` lines specify
  the expected output. The imported provider checks constructor CID versus
  qualified effect CID/FID, Number Nat, non-scalar text, and F32 rounding.

The direct runtime and vendored providers must have the same pin. Socket FFI,
display devices, subprocesses, and broad effect scheduling are outside these
finite controls. The legacy descriptor JS backend/runtime retains its earlier
ABI and is not qualified against the new upstream by these tests. The exact
multiword Array.new extreme-depth limit requires an emitted layout footprint;
the current two-argument call still has the historical one-word limit.
