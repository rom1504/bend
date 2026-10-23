# Phase130 dual-format cursor review

Independent source-only audit of the proposed backward-compatible Base decoder.
No compiler, API, native program or proof kernel was executed by this reviewer.
The selected parent remains Phase128 source02,
`6bd9de05e251180280a6761fa46be30dc2a22164cdb35c9ca48fd710911d0f4d`.

Reviewed:

| File | SHA256 |
| --- | --- |
| [mode-cursor-v02.bend](../../selfhost/tools/performance/phase130/base/mode-cursor-v02.bend) | `a0abb2b70418b44d21139fb2a90671d2881fd11d28019dea2e6967b5ad745837` |
| [mode-controls-v01.bend](../../selfhost/tools/performance/phase130/base/mode-controls-v01.bend) | `2473b0d530d52674af21b2820a7c1f7eeb859fee46619ca41f1dc497f2f940fa` |

No source-level semantic blocker was found for a bounded checked experiment.
The original v01 used a match directly on a computed Boolean; v02 moves that
condition through `p130m_initial_choice`. This review does not claim either
version passed source checking. The final checked source and gates must identify
the actual selected version.

## Change boundary

The module replaces17 declarations, including `P88Cursor`, and adds nine small
helpers. `P88Cursor{text,ok:Bool}` becomes `{text,mode:U32}`:

- 0: failed cursor.
- 1: original canonical decimal numbers.
- 2: two-scalar compact numbers.

Every concrete construction or match of the old cursor in the selected parent
is covered. Untouched helpers only pass the cursor through. Node roles, record
schemas, backward-reference rules, arrays, typed reconstruction, source-span
checks, readiness predicates and final prepared-state construction remain the
original operations. A source assembly receipt should verify that boundary.

Build from selected Phase128 source02, not the isolated compact-only
`base-source01`: the latter contains old `p130b_u32`/numeric controls using Bool
cursors. Carrying them unchanged into the new datatype would be a mismatched
source assembly. No new native layout, runtime object or untyped Term
construction is part of this proposal.

## Decimal compatibility

Under the mapping `False→0`, `True→1`, the decimal parser retains its old
arithmetic, canonical spelling and failure behavior. This includes its subtle
empty-number result: parsing `"\ntail"` returns value0 with the unconsumed tail
and failed cursor; later consumers reject it at their original gates. Other
invalid-digit/overflow failures reset to the empty failed cursor as before.

Numeric and string consumers accept mode1 or mode2 only. Invalid modes become
the same failure state or error category that an old false cursor produced.
The final roots gate still requires an exhausted input and valid cursor before
readiness checking. The following error categories stay at their old boundaries:
`cache stamp`, `cache header bounds`, `cache string`, `cache root`, and
`cache roots or trailing data`.

`p130m_status` can syntactically return its supplied mode on success, but its
production use supplies the constant1. Similarly, private text helpers preserve
a supplied mode; their caller validates it. The claim is an invariant of the
actual entry path, not that arbitrary manually fabricated calls to every helper
sanitize every U32.

## Routing is fixed once and is not authentication

The entry selects mode2 only when the first carrier scalar is in
U+10000..U+1FFFF **and** the expected stamp starts with `p130-word-pair-v1:`.
Otherwise it selects mode1. The whole parsed stamp must subsequently equal the
expected stamp. Compact numeric lanes are checked before arithmetic.

Decimal numbers start with ASCII digits, so an old decimal carrier remains
decimal even if its expected stamp happens to use the new namespace. That is
intentional backward compatibility, not automatic acceptance of its contents.
A compact carrier with an old expected namespace follows decimal parsing and
fails. Malformed compact input never falls back to another parser after a
numeric failure.

String payloads may contain any admitted scalar, including compact-alphabet
characters. They preserve the current mode and are never examined to switch
formats. Both mixed numeric sequences—decimal then compact, or compact then
decimal—therefore fail. Text lengths remain scalar counts, Base spans retain
the old UTF16-unit convention, and external byte limits remain UTF8 limits.

Neither namespace nor mode is a trust certificate. The caller still needs the
exact producer/cache/Base/path/version/carrier/consumer authentication described
in [contracts.md](contracts.md). Supplying a matching stamp for attacker-chosen
bytes cannot authorize fabricated checked-world state. The compiler's private
transport gate and the external admission receipt have different jobs.

## Ownership and stack

The cursor remains ordinary immutable Data. Node/string arrays stay affine
temporary decoder state and are threaded unchanged through the same operations.
The format probe observes the first scalar before ordinary decoding; any extra
input sharing must be accounted for in clean timing, but it grants no borrowed
native pointer or new ownership permission.

The compact numeric reader has constant depth. Existing string and record
traversals remain the same algorithms; no unbounded chain of direct native calls
is introduced here. Source checking alone cannot prove their native stack use
or the runtime representation correct. The decoder proxy and later native
qualification must retain resource guards and observe complete results.

Full structural equality does not establish preservation of sharing. Check
the exposed `world.prefix === seed.book` relationship and any other meaningful
old identity separately, then reuse/consume the native products. Do not invent
an alias assertion between `world.state` and `world.checked`: these are distinct
types/roles, and the separate checked root is not exposed by P86Preparation.

## Qualification gates

The module supplies26 finite predicates covering canonical decimal limits,
empty-number tail preservation, compact lane boundary values, invalid modes0/3/U32max,
both mixing orders, Unicode text and mode persistence, routing and original
stamp/header errors. These constrain examples; they are not a universal
backward-compatibility proof or cache authentication test.

The new test-only [base-equivalence-v2.mjs](../../selfhost/tools/performance/phase130/base-equivalence-v2.mjs)
extends the earlier whole-product oracle:

1. Bind checked old/new API receipts, exact source manifests, old/new carriers,
   producer assets, selected runtime and Phase129 frozen fixture/oracle pins.
2. Require exactly26 successful `p130m_controls` rows.
3. Compare **old decimal, candidate decimal, candidate compact and actual fresh
   preparation** through every P86Preparation field with iterative graph-aware
   equality. Record exposed aliases and require every true old identity to
   remain true. Save the two complete candidate graphs without duplicating
   unchanged old/fresh graphs on disk.
4. Run17 malformed decimal fixtures through both old and new APIs and compare
   the entire exact refusal result. These include canonical spelling, overflow,
   incomplete stamp/number, bounds, changed expected stamp, the new namespace
   with decimal framing, trailing data and a truncated final field.
5. Run15 compact fixtures against independent expected refusal categories:
   missing halves, each lane's bounds, incomplete/wrong stamp, old namespace,
   node/string limits, decimal numbers in compact mode, and trailing data.
6. Compile each frozen lexer/closures/Map request through old decimal, new
   decimal and new compact: all nine complete QBE products must equal the
   independently retained Phase129 native oracle bytes.
7. Reauthenticate all input pins and unchanged runtime after the run. Report
   actual errors and partial evidence if any gate fails; do not convert a source
   refusal or exception into a passing semantic control.

That oracle is implemented but was not executed by this reviewer. Its API
calls are target work for the coordinator's serial lane. Diagnostic API timing
is not a native performance measurement. Exact output equality on these requests
does not replace N1/N2 qualification before selecting a new native compiler.

A cheap future theorem would show the commuting diagram for the decimal reader:
mapping the old Bool cursor to modes0/1 before or after parsing gives the same
complete number/cursor result for every input String. A second theorem could
establish compact codec inversion with untouched suffix. Neither theorem has
been authored or checked here; authentication, native ownership and speed remain
separate obligations.
