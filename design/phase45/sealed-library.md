# Optional sealed-library ABI: feasibility, not a release change

Status: read-only design investigation. No compiler/runtime changes or target
executions. Defer this feature from the current release. A separate explicit ABI
could justify private execution without public descriptor guards, but hiding `G`
alone does not justify it, and standard host intrinsics are not guaranteed by
import-time snapshots. Existing compatibility measurements remain unchanged.

## Actual exported interfaces

Our `j_library_context` in `selfhost/src/back/js/emit.bend:736` exports
`G,call,list,ctor` and a default wrapper for **every name in G**. Library root
selection at `emit.bend:764` excludes most Base roots, but reachable dependencies
are still in that exported registry. Current `--library` selection flows through
`selfhost/tools/typed-driver.mjs:519`, checked source emission at line 564, and
the CLI option at line 628. There is no sealed mode today.

Pinned TypeScript `js_lib(book,true)` at
`selfhost/.bootstrap/upstream-phase23/bend2/comp.ts:3374` exports only completed,
live, non-Base, nonforeign, non-IO source definitions. It exports a default
object of host-callable wrappers, without our public registry/helpers.
`js_host` at line 3360 converts arguments/results according to checked types;
`js_marshal` at line 3303 handles Nat and recursive Nat-containing values, and
function wrappers when their types require conversion. Many other values pass
through unchanged. Function values are JavaScript functions rather than our
public descriptor records. This is an ABI difference, not evidence that the
TypeScript module is isolated from mutable JavaScript intrinsics or that its
boundary recursively copies every value.

## Escape analysis required before removing guards

`selfhost/src/runtime/js/core.mjs:18` constructs function values as mutable
`{arity,code,env,bound}` records. A source export returning a named function can
expose a shared registry descriptor; partial application exposes its capture
array and code. Returning the descriptor inside a constructor, list, array or
record exposes it just as effectively. Restricting only the top-level result
tag is insufficient. Exported source factories can return internal helpers even
after direct helper exports are removed. A raw `.code` function provides another
entry path; its captures can retain registry access. Consequently, deleting the
named `G` export or freezing the default export object does not seal the graph.

The host problem is independent. `regionHostGuard` at `core.mjs:198` checks
numeric hooks and collection protocols against imported snapshots. A captured
pre-import custom hook may still be effectful. P45-007 and the superseding
P45-012 rejection preserve that distinction. No inference from these snapshots
to standard or inert intrinsics is available. Freezing caller-realm builtins
would mutate the caller's environment and is not an acceptable implementation.

## Two honest contracts

An export-only mode can provide typed source wrappers and conceal public runtime
helpers, while retaining host/provenance guards. This is a plausible smaller API
feature, but has no established guard-cost benefit. Any returned descriptor must
still be treated as an escape. It cannot be advertised as guard-free.

A genuinely sealed execution mode needs either an explicit caller promise about
standard immutable intrinsics, or a private execution realm with a trusted
standard-intrinsic initialization boundary. The former is a different supported
host contract, not a guarantee and not an authorized assumption for current
metrics. The latter is the stronger feature considered here. It is execution
isolation for compiler proofs, not a security sandbox.

The smallest credible initial sealed scope is fully proved closed worker graphs
with primitive scalar inputs and primitive scalar/String results. Export only
requested checked source definitions whose entire reachable graph passes this
proof. Refuse unsupported requested exports with a compiler diagnostic; do not
silently omit them. Refuse foreign/IO operations, function-valued inputs or
results, opaque/polymorphic boundary values and host objects in this initial
scope. Internal constructors and recursive worker state may remain private.

Private code and intrinsics must stay unreachable. Never return inner-realm
arrays, objects, functions, descriptor records or exceptions: their prototype
and constructor chains can reveal inner-realm constructors and globals. Even a
thrown Error is an escape unless translated at the boundary. Copy its supported
error data into a caller-realm error after private execution unwinds. This
changes error identity/stack behavior and must be documented as the new ABI.
First-slice primitive results avoid recursive value-copy machinery; extending
to ADTs/arrays needs checked recursive input/output marshalling and an explicit
value-copy/alias contract. Extending to returned functions needs outer wrappers
whose private closures retain the inner target without exposing its descriptor.
Function inputs introduce arbitrary callbacks/reentry and should be deferred.

Per-call host argument conversion/validation must complete outside the private
worker, because getters/coercions can call the module recursively. Conversion
must not pass caller objects into private state. Inputs and independent entry
state must be established before entry; no cross-entry proof memoization is
needed. Primitive source errors still require the explicit translation boundary.

## General implementation path

1. Add an explicit checked-emitter mode and CLI option, for example
   `--sealed-library`, preserving `--library` byte-for-byte in contract. Export
   selection comes from source/checker metadata and explicit requested exports,
   never workload names. Carry the ABI version and proof scope in receipts.
2. Reuse successful complete worker graph proofs and expose a separate emission
   result that certifies no foreign/host callback edge or public descriptor escape.
   Emit lexical private callable targets, not wrappers looking up mutable G.
3. Generate the minimal worker runtime into a private realm and retain that realm
   only in outer wrapper closures. The current runtime imports filesystem,
   networking, subprocess and other Node facilities; it cannot simply be copied
   wholesale and called sealed. Establish the isolation facility's trusted
   initialization premise explicitly, rather than comparing caller snapshots.
4. Generate checked boundary marshalling and error translation. Qualify attempted
   escapes through all outputs, exceptions and reentry, then mutation of caller
   G-like objects, prototypes, Error and pre-import custom intrinsic hooks.
   Host callbacks, foreign values and higher-order boundary types remain refused
   until an independent extension proves them safe.
5. Compare this mode separately, through its ordinary exported wrappers including
   marshalling. Record realm/import cost separately and do not replace default
   compatibility-role results. Matching a TypeScript export list does not imply
   matching its complete alias/error ABI.

This is a justifiable general feature for applications choosing a narrower typed
library boundary. It is not a modest optimization of the existing mutable ABI.
The escape boundary, isolated runtime and changed error/value contracts make it
unsuitable as a last-minute release guard reduction. Continue qualifying the
current backend; consider export-only API cleanup and sealed execution as
separate future proposals.
