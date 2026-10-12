# Preserve scalar literal kinds before observer analysis

Use `nc_definition_plain(book, definition, fresh)` for the entry and every helper
expansion. For ordinary definitions this calls `nc_erase`, whose first branch
preserves the `KLiteral` variant. `nc_compact` deliberately replaces Nat/U32/F32
literals with indistinguishable `NWord` nodes and therefore loses a fact needed
by the observer's exact scalar argument checks.

`observer-literals-v1.bend` supplies three small queries:

* `no_literal_typed` recognizes actual KLiteral variants with native
  Nat/U32/F32 types. It returns `NO_TypedWord{ name = exact kind, id = payload,
  kids = [NWord(decimal payload)] }`, or Absent. An evaluator can form its typed
  OA value from the name and child. Constant origin keys should include both
  kind and payload; equal bits of different types are not the same typed value.
* `no_literal_string_step` optionally expands one native String literal step.
  The evaluator must re-enter through its normal fuel-spending entry. It must
  not expand an entire String before checking its global budget.
* `no_literal_demanding_ctor` identifies native Succ/U32/F32 constructors that
  must be refused before virtual construction. Succ performs `nat_chk`; U32/F32
  perform `term_word`. Eliminating those operations merely because the virtual
  result is discarded could change demand or error behavior. Constant source
  literals need neither operation and retain their existing immediate encoding.

Reject incoming NWord in observer analysis and remove all wildcard-kind
admission in primitive arguments, loop arguments and result checks. The NWord
child created after successful typed analysis is only an emitter operand.
Nat payloads are U32 values and therefore below the native 48-bit immediate
limit. F32 payloads are already raw IEEE bits and must not undergo conversion.
Native Chr may be virtualized only with exactly one value whose proven scalar
kind is U32; its resulting kind is Char. Enum constructors retain their exact
declared owner type. Refusing dynamic Succ is deliberate and may be relaxed only
when checked increment demand/overflow is represented in the observer IR.

The helpers do not traverse source trees and add no new normalization pass.
This source-only recommendation follows `book.bend:nc_definition_plain`,
`erase.bend:nc_erase`, and `bridge.bend:nc_compact_plain`/`nc_constructor_value`.
No compiler, Node or native target was run. Parent owns integration and checks.
