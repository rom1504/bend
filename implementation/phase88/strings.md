# Phase88: consuming equality for the native compiler host

Final phase results and integration decisions are in [README.md](README.md).
The audit/proposal narrative below records its original stage; statements about
what this lane ran are not the final root-run qualification or speed result.


Status: the safe standalone candidate passes checked acquisition, raw JS, native
O2 and all 1,444 differential/oracle comparisons. Root owns all acquisitions,
builds, execution and measurements. Full native-host integration is still under
test; no compiler-speed or production-promotion claim follows from these controls.
No production or upstream source was changed by this lane.

The first checked control rejected a computed comparison as a match scrutinee,
before code emission. Its source and error remain in
`selfhost/build/phase88/strings-control01/`. V2 added safe first-order Bool/Cmp
dispatchers but was rejected for calling the unfilled law involved in that helper
cycle; its receipt is in `strings-control02/`. `controls-v3.bend` now uses one
directly recursive worker per operation, carrying the comparison as its first
parameter, with wrappers seeding True/EQ. This was rejected by the safe
left-to-right decrease rule: its comparison changes before either string shrinks
(`strings-control03/`). V4 puts both strings first and matches the carried
comparison in the same match. The first recursive argument is a strict string
tail. Earlier LT/GT decisions are preserved for every remaining-string shape.
There is no law, helper cycle, closure or unsafe escape. These helpers pass V4's
check; the control then failed because `main` precedes the concrete corpus.
V5 moves that definition before `main` and passes. All five fixtures and their
source receipts are retained; the four prior failures occurred during source
checking, before target execution, and are not successful control runs.

The [final comparison](../../selfhost/build/phase88/strings-controls.json) records
38 strings and all 1,444 ordered pairs. Raw JS and native stdout match exactly:
85,349 bytes, SHA256
`06c0fd2c626a3d5d62cfc010ec05e5e7b38e16e3eea7ee5dc15f044c4f1a5df6`.
Every pair agrees with original Base and the independent lexicographic-codepoint
oracle for equality and ordering, on shared and copied inputs. All post-use
length and codepoint-sum observations also agree. The
[checked acquisition](../../selfhost/build/phase88/strings-control05/report.json),
[O2 build](../../selfhost/build/phase88/strings-control05-build-guard/process.json),
[raw JS](../../selfhost/build/phase88/strings-control05-js-guard/process.json) and
[native](../../selfhost/build/phase88/strings-control05-native-guard/process.json)
receipts are retained. This is finite correctness evidence, not a proof over
unbounded strings or invalid Unicode, and these control runtimes are not used as
a compiler-speed benchmark.

The ownership profile identifies disposal below `STRING_ORDER` during Base
preparation. The pinned Base implements `String.eq` through `String.order`,
which obtains a `(String & String) & Cmp` from `String.cmp` and discards the
returned strings. `String.cmp.rec` reconstructs every equal prefix while returning
ownership; that work is appropriate for the paired API, but the compiler's
Boolean equality calls do not need the reconstructed strings. This mechanism
explains a potential source of avoidable allocation and disposal. It does not
make the measured disposal sample percentage a removable-time estimate.

[The safe Bend helpers](../../selfhost/tools/performance/phase88/strings/helpers.bend)
match both strings, compare heads and recurse on tails only while equal. Equality
returns a Bool; ordering compares U32 codepoints and returns Cmp. No helper uses
`@unsafe`, host foreign code, an input-returning pair or a function-valued
continuation. Mismatch paths still have to dispose of remaining owned tails;
shared caller inputs still require reference accounting. Those costs are retained.

[Controls and commands](../../selfhost/tools/performance/phase88/strings/README.md)
cover 1,444 pairs from 38 strings, including a finite exhaustive four-character
alphabet, Unicode scalar/order boundaries and bounded common prefixes. Shared
and freshly copied inputs are checked against original Base, with later reuse
observed through lengths and codepoint sums. An independent Python oracle checks
every numeric output field using the frozen codepoint corpus. It executes no
compiler semantics for production and is not a performance benchmark.

The isolated integration tool rewrites exact `String.eq` identifiers only in
active compiler-module sections of a frozen source assembly, then inserts the
helpers after `import Base`, before their uses. The imported Base, user program
text, runtime-input Base, source strings
that contain emitted code and the entry remain untouched. The resulting complete
program must be checked again before C emission. It changes compiler-host code,
not emitted user-program semantics or the upstream Base map comparison API.
An offline derivative on the frozen Phase88 JS assembly changes exactly 2,891
identifiers. Removing the inserted helpers and reversing the identifier rename
recovers the original assembly byte-for-byte. Python AST checks pass. These
transport checks are not Bend correctness or performance evidence.

Ordinary JS retains its original assembly and explicit primitive-string equality
guard. This is an implementation experiment, not an identical-source native/JS
comparison. If promoted into common source later, a corresponding reviewed JS
primitive guard for the new helper is necessary; otherwise the new structurally
recursive helper bypasses the existing guard and may reproduce Phase86's JS
stack overflow on compiler-size input. Broad Unicode and complete emitted-C
identity are required before any such promotion.

With the component gate passed, the next gate is full emitted-C identity on the
native-host integration. Measure Base preparation separately and use the existing
small Numeric/Lexer/Map request screen, followed by the slower broad screen only
after a clear paired gain. No compiler rebuild or benchmark was run by this lane.
