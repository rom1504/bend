# Common work in ordinary library checking

The current ordinary checker **does recheck the Base declarations in the loaded
book**, despite receiving a previously checked Base cache. The cache saves Base
parsing/elaboration and supplies its source IR; it does not restore a checked
world or suppress declaration checking. This establishes common source work
across the 23 inputs. It does not establish how much of the measured checking
time that work consumes.

The broad stage screen reports `check-and-complete` at roughly 611–726 ms across
sources of 556–14,680 bytes, largest among individual stages for 22 of 23 inputs;
cache/identity work is roughly 188–212 ms. These are diagnostic stage
observations, not clean timing or measurements of Base alone. The completed
[46-worker screen](../../selfhost/build/phase60/stages01/report.json) has SHA256
`3383e42db487b1b1a6f742c575e838d8b70f0160fa5721c22af4c1d0dab25bf2`.

## Exact path

- [prepareBase](../../selfhost/tools/typed-driver.mjs#L368) checks Base on a cache
  miss and saves `loaded.book`, its hash, source spans, compiler identity and
  `validatedBy: 'check_book'`. It does **not** save `KWorld` specialization memo,
  fresh-name state or completed checked output. A hit returns that parsed book.
- [readBaseCache](../../selfhost/tools/typed-driver.mjs#L346) reads and parses the
  cache for ordinary requests. Its [span validation](../../selfhost/tools/typed-driver.mjs#L244)
  serializes/hashes the book and walks the object graph. The optional bounded
  memo belongs to persistent inspectors; this survey uses ordinary requests.
- [f_complete_seed](../../selfhost/src/load/modules.bend#L251) checks the seed's
  source identity; [fs_inject](../../selfhost/src/load/seed.bend#L114) joins its
  definitions into the loaded book. The Base events are therefore still present
  when the checker receives `loaded.book`.
- The [ordinary ABI2 call](../../selfhost/tools/typed-driver.mjs#L489) passes
  `cached.book` as `validated`. But
  [check_program_diagnostic](../../selfhost/src/driver/api.bend#L111) deliberately
  does not use `validated`: it calls `dg_check_world(book)`.
- [dg_check_world / dg_check_seed](../../selfhost/src/diagnostic/produce.bend#L108)
  scan the whole book for the fresh-ID bound, predeclare the whole book and
  create a fresh world. [dg_check_events](../../selfhost/src/diagnostic/produce.bend#L123)
  visits every declaration event, performs duplicate/signature checks and calls
  `check_definition_world`. There is no Base/native flag that bypasses this loop.
- [check_definition_world](../../selfhost/src/check/kernel.bend#L1256) checks each
  declaration's type. [check_definition_type](../../selfhost/src/check/kernel.bend#L1012)
  then checks ADT declarations, accepts absent bodies after the type check,
  validates foreign declarations, or checks ordinary/template bodies. Thus
  “rechecks Base” does not mean every Base event follows the same body path.

This behavior is explicitly documented in
[the exact-prefix compatibility entry](../../selfhost/src/diagnostic/produce.bend#L188):
source-only prefix caches cannot restore live memo/output state. That entry also
rechecks the book; falling back to ABI0/1 is not an existing Base-check shortcut.

## What the composite stage includes

[norm_max_book](../../selfhost/src/core/normalize.bend#L240) traverses declaration
types, values and children. [check_declarations](../../selfhost/src/check/kernel.bend#L951)
builds the fresh declaration context. Checking publishes bodies and checked
outputs and performs live specialization through
[sp_live_memo / sp_live_body](../../selfhost/src/check/specialize.bend#L357), with
a fresh per-request memo. On success,
[driver_program_checked](../../selfhost/src/driver/api.bend#L115) assembles checked
output and scans the original book for unfinished definitions/holes.
[sp_assembled](../../selfhost/src/check/specialize.bend#L327) is output assembly,
not an additional independent specialization pass. The host's separate
`specialize_book` branch is skipped for ABI2.

These source paths are byte-identical to their corresponding files in the
selected `checked-last01/snapshot`; the survey still uses the unchanged Phase58
B2. This audit performed no compiler execution, counter injection or source edit.

## Pinned TypeScript counterpart

**The measured TypeScript path also checks Base on every request.** The actual
[Phase60 worker](../../selfhost/build/phase60/method03/worker.mjs#L35) creates a
fresh `book_nil()`, calls `book_load(..., new Map())`, then `book_valid(book)`
without a `done` argument, followed by `js_lib(book, true)`. This applies to first
and later requests; imported compiler modules can remain loaded within a worker,
but its Book is new each time.

Pinned [book_load](../../selfhost/.bootstrap/upstream-phase23/bend2/bend.ts#L952)
recursively reads and parses `BASE_BEND` for `import Base`; its `seen` map only
deduplicates imports within that request. It marks Base declarations with `b`,
but [book_valid](../../selfhost/.bootstrap/upstream-phase23/bend2/bend.ts#L3791)
defaults `done` to zero and checks every declaration event, including Base types,
constructor telescopes and final definition bodies where present. The Base flag
exempts native unfilled declarations from hole counting; it is not a check skip.
Although this TS function supports resuming past a seeded prefix through `done`,
the measured worker does not use that facility or a persistent Base Book.

The host paths therefore differ: B2 deserializes and validates a primed parsed
Base cache through the ordinary driver, while TS reads/parses Base into a new
native Book and checks it in place. B2's cache path includes
[API/Base hashing](../../selfhost/tools/typed-driver.mjs#L323), JSON decoding,
book reserialization/hash and source-span/payload validation. TS's measured path
does not use those cache-identity operations. First-window timing includes
[TS `bend.ts`/`comp.ts` imports versus driver import plus B2 `loadApi`](../../selfhost/build/phase60/method03/worker.mjs#L108).
These source facts identify different work and representations; they do not
attribute the relative timing gap to Base rechecking alone. The pinned TS files
are the catalog's `bend.ts` SHA `de2b39db…` and `comp.ts` SHA `3bd7ed49…` at
upstream revision `018751270e800bc222a93dad7f257083ee53a5f7`.

## Attribution still needed

The similar stage durations are consistent with shared Base checking and
whole-book setup/assembly, but do not isolate their cost from user checking,
specialization, allocation/GC or first-process V8 compilation. Source byte count
alone is not a checker-work metric, and the stage screen does not prove a warm
steady-state floor.

The cheapest next discriminator is to inspect the already planned CPU ancestry
inside checking. If that cannot distinguish shared from source-dependent work,
a small diagnostic copy can count declaration checks by Base/source/generated
instance origin and time the existing outer world-setup, event-loop and
completion boundaries. Any such counts/times must remain diagnostic; skipping
Base checks as an experiment would change checker state and is not justified by
the present cache contract. No optimization is selected here.

A future state-reuse experiment would first need a fully checked state contract:
validated declarations/bodies, completed output, live specialization memo,
fresh-name state and source/diagnostic identities, with a defined way to extend
that state with the new source. It must preserve declaration order, duplicate
and law checks, extension visibility, instance names and fresh-ID bounds. The
current source-only cache supplies none of that resume proof. A separate
diagnostic implementation would need exact results/diagnostics and complete
emission parity against full checking before its timing could support reuse;
simply omitting Base events is not the proposed experiment.
