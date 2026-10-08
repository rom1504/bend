# Phase66 backend migration

The first isolated candidate (`backend-v1.patch`, SHA256
`ae457b74272b6c5a2560b141e609932e0fdcfd6870331ab9c22114f702d22c44`)
is a bounded semantic migration to upstream
`059266225b77c8ca256ac6b25ee5c21449bab151`, not a speed optimization.
`backend-v1.json` binds every original and candidate file. `prepare-v1.py`
uses exact source seams and writes only new candidate copies; no compiler or
program target ran in this lane.

## Identity and representation contract

Internal loader names are `namespace:member`. The shared frontend-owned
`name_key` replaces only the first colon with a dot. Apply it at external
constructor tags, exported property names, foreign source identifiers,
diagnostics, and readback. Keep raw names in book/constructor lookups, graph
edges, SCC facts, generated function identities and native symbol encodings.
In particular, `nc_ctor_display` is also a decoder used by constructor lookup;
it must remain raw. Only its readback consumer adds `name_key`.

The legacy JS emitter retains raw `G`, schema and constructor keys. Its
public default export and foreign module tables expose dotted names. Its
`constructorOwn` mapping supplies foreign/readback display tags without
collapsing the internal constructor table. The private compiler transform
recognizes exactly one complete old or new public export ending, so an old
image remains replayable and a mixed/duplicated image remains refused.

## Semantic changes and upstream correspondence

| Change | Existing representation / bounded action |
| --- | --- |
| Namespace separation | Preserve raw identity; convert external boundaries only. No generic flattening or new symbol table. |
| IO.OP request matching | Replace the old `$FFI` interception with a fail-stop for tags other than `Emit`/`Halt`. Upstream `mat_ctrs`/`mat_ops` likewise restrict the user's default arm to these two constructors. |
| Pure-main readback | Put the display constructor name in descriptor cell `D[a+1]`, retain all field offsets, and pass the one mixed descriptor array to the jointly selected direct runtime. |
| Equality Array elements | Admit a normalized `Eql` head as well as `ADT`, matching upstream `lay_el`. Both original demanded Array branches still normalize exactly once; erased/non-Array paths remain skipped. |
| Poll | Reserve the newly compiler-owned type name in direct driver/native validation. Foreign/host layout still derives its actual checked declaration. |
| Native boxed Word fixes | No speculative packed-layout port. Our native representation uses uniform slots and reconstructs Word through its existing bridge; the new upstream fixtures are required discriminators. |
| Native readback/foreign names | Keep raw constructor/FID/CID encodings; print display names. Support the new first-colon namespace in the old synthetic-Foreign fallback, retaining the dotted fallback. |

The direct runtime and queued host converters are owned by the host lane;
this patch requires their selected new show/effect protocol. The frontend
lane owns `name_key` and the canonical loader names.

## Qualification boundaries

Independent source review by `broad_benchmarks` found no blocker in this
narrow scope and checked all 18 files, 36 before/after identities, exact patch
reconstruction, and exact generated legacy-runtime fragment assembly. The
host owner independently checked the show descriptor and IO.OP seams.
These are source reviews, not executed semantic gates.

`source-controls-v1.json` pins 17 actual upstream fixtures for root-owned
execution. They cover namespace/sanitization collisions, alias readback,
foreign imported nullary tags, proof Array construction/get/set/clone/size
and pure printing, boxed U32/F32 Word defaults/sequences, deep Array-wrapped
host graphs, effect helper collisions, and IO.OP foreign-request fail-stop.
Run the JS direct/native lanes where supported; run the relevant namespace
and readback subset through legacy JS too. In addition, require a synthetic
private-image test to accept each exact old/new ending and reject absent,
duplicated and mixed endings. The complete migration gates remain root-owned.

## Separate legacy effect migration

The namespace patch does not qualify legacy effects against new Base
signatures. Its module emitter already supports per-module `io_eff`
registration, but legacy foreign calls do not implement continuation parking.
The legacy Node runtime also predefines the old channel/socket operations.
A separate patch must update changed return values, add or explicitly refuse
new `try_` operations, and avoid silently reusing old `Bool`/EOF/send-failure
shapes. Reusing the upstream scheduler wholesale would require `bun:ffi` for
parking/socket polling and would change existing Node support. Exact timed
send cancellation is a specific Node portability boundary, not a namespace
issue. No compatibility claim is made before those controls close.

## First checked-build correction

The first combined B1 attempt refused the source at the newly introduced
`match String.split(...)`: this Bend grammar requires a match variable.
`backend-v2.patch` (SHA256
`dafe90257cc5c0b747e566fde72c1384ed8e54c5ff432c5d6d14f532355c5350`)
is a one-file successor to v1 that passes the split list through
`nc_foreign_namespace_parts`. It changes no namespace resolution rule.
Root owns its next build; the rejected attempt produced no qualified API.
`private-ending-controls-v1.mjs` now supplies the six exact ending gates,
including runtime preservation of distinct raw private export identities.

## Separate legacy Node effect candidate

`legacy-effects-v1.patch` (SHA256
`869509c3df9864e5cdf46061365ab9d9a6b2ca17f4bd0d4cab60ff52d336a517`)
is layered on namespace v1 and is not yet selected. It reuses the existing
Node runtime and event loop, rather than copying the 35 upstream providers.

- `Chan.send` returns `Done{Unit}` or `Fail{originalValue}`. Both channel
  `try_` calls return `Ready`/`Wait`, cancel timed queue entries and preserve
  the original unsent value. Closing wakes ordinary and timed waiters.
- TCP receive distinguishes data from EOF with `Some`/`None`. Receive and
  accept gain `Poll` deadlines. An EOF is a read half-close, so it does not
  itself prohibit a later write.
- UDP gains byte-list operations and timed receive; zero-sized receives
  refuse before consuming a datagram. Blocking send failures retain the
  original complete datagram in the new nested error payload.
- Four new TCP/UDP timed-send functions explicitly refuse before touching
  the socket. Node cannot reliably cancel a queued write at the deadline;
  returning `Wait{rest}` would risk sending the same bytes twice.
- An asynchronous TCP write failure also explicitly refuses when Node
  cannot expose the exact unsent suffix. Preflight closed-socket and invalid
  byte-list failures return the known complete remainder; successful
  blocking writes keep working. This is an explicit compatibility limit
  at a changed ABI, not a claim of complete legacy network parity.

`legacy-effects-controls-v1.mjs` binds the exact candidate runtime and tests
25 return-value, cancellation, ownership, queue and refusal observations.
It opens no sockets; actual Bend channel/network fixtures remain additional
required qualification. No execution result is claimed yet.

## Legacy source-review successors

Legacy v1 was rejected before execution: a busy task could match an already
expired channel waiter, and long U32 deadlines overflowed Node timers.
Legacy v2 added absolute deadline sweeps before every channel matching/close
operation and chunked rearming for channel/network try_ waits. Source review
then identified that merely marking a read EOF was insufficient: Node
sockets close their writable half by default.

`legacy-effects-v3.patch` (SHA256
`aa0391929f1e2a3d7311c9d76fd401c3b8c144addc8d3924290eb855d2a5ae81`)
is the complete replacement patch against namespace v1, including explicit
`allowHalfOpen` on accepted and client TCP sockets. Independent source review
passes this limited legacy scope. Do not stack legacy v1/v2 with v3.

Use `legacy-effects-controls-v4.mjs` (SHA256
`3d14ad2697895ab6e49877d7ee0f36e2fa791ff0b6186c26d67a3aac15eac208`)
with `--out <fresh-directory>`. It binds the exact v3 runtime, tests 34 cases,
and records separately ordinary runtime controls, mocked network handles,
and three real local TCP/UDP loopback cases. The TCP controls collect legal
short reads through EOF before testing a delayed reverse-direction reply.
The long timer contract applies only to the channel/network waits changed
here; unrelated existing IO.sleep and Process.run timers are outside this
patch. Runtime results and compiled Bend source results remain pending.

## Executed checkpoint

Root ran legacy controls v4: **34/34 passed**, including the three actual
local networking cases, then applied legacy v3. Receipt:
`selfhost/build/phase66/legacy-effects-controls01/report.json`.
The next combined checked image is still required for actual-source
qualification; runtime-only passes do not establish emitter correctness.

The subsequent `printable-key-v1.patch` changes two printability recursion
keys from display text to `term_key`. `printable-key-controls-v1/main.bend`
imports a distinct `child:Box` hidden beneath the root's dotted `child.Box`;
the nested function must be refused, even though the names print alike.
The frontend and independent backend reviewer approved the source contract;
root applied the exact patch. `prepare-source-controls-v1.py` supplies
explicit new-pin direct/legacy/native/reference recipes, and can include
that witness with `--include-printable-witness`.

## Explicit native toolchain recipe

`prepare-native-toolchain-v1.py` derives fresh native/reference commands
from an existing source-control recipe. It binds the exact Clang 16 binary,
LLVM/Clang libraries and `CC`/include/library environment from the previously
qualified Phase65 release receipt. Environment assignments remain inside
the resource guard, and the old unsupported attempt is not overwritten.
This is a data-only recipe producer; root owns compiler execution and the
resulting native qualification. See the implementation report for outcomes.

## Subsequent native and direct-gap closure

`join-native-v2.py` binds the selected-05 native-only runtime migration to
source19, native16/native3, deterministic syscall7 and the separately admitted
legacy controls. Its passing receipt is
[`native-backend05.json`](../../../../../implementation/phase66/evidence/native-backend05.json).
The thirteen new native methods that remain unavailable are enumerated there
and in the [native guide](../../../../docs/native-effects.md).

`min-erasure-v1/candidate.patch` adds checked quantity meet to direct expression
erasure, matching the actual reference's `null` result without evaluating its
children. `wide-call-fields-v2/candidate.patch` replaces an arbitrary 64-field
lookahead ceiling with the existing remaining analysis budget. It preserves
the original body fuel and refuses incomplete counts. The unconsumed v1 draft
is retained as rejected because it would double-charge constructor fields.

`wide-call-fields-v2/prepare-final-controls.py` is a data-only factory that
requires both exact patch hashes in a checked image, preflights its private
declarations and emits guarded commands for five actual source programs plus
18 analysis controls. On checked-07, all five source executions and all 18
diagnostics passed; see
[`min-wide07.json`](../../../../../implementation/phase66/evidence/min-wide07.json).
`join-controls-v2.py` records only the five individually passing reference
observations; it does not claim that the whole reference report passed.

`join-native07-v2.py` closes the subsequent native admission in
[`native-backend07.json`](../../../../../implementation/phase66/evidence/native-backend07.json).
It compares the exact generated closures of the frontend, native emission and
IO classification, preserves the prior native16/source19/syscall7 provenance,
and separately binds current shared-entry evidence, fresh native3, exact C
outputs and the external collision diagnostic. The complete external selector
is prepared by `prepare-native-admission07-v2.py`; the unused first selector
draft and the first data-join grouping refusal remain preserved. The final
receipt retains all thirteen explicit native API gaps. Raw Phase66 artifacts
are no longer written by this lane.
