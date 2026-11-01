# Compact unit admission experiment

Final disposition: root-owned source/finite/native gates pass after the ownership
repair. Performance does not justify integration. The checkpoint notes below are
historical; see the [final report](../../implementation/phase148/README.md).

`selfhost/tests/phase148/verify.bend` implements the consuming interface
`p148v_check(unit, ids, ready) -> P148Checked{unit, error}`. Its compatibility
adapter `p148v_function(unit, ids, ready) -> String` consumes that result and
discards the returned unit. It consumes the optimized instruction/value tape directly. It does not
call the decoder or rebuild `N111Stmt`, `P113DStmt`, `N111Arg`, or argument/value
lists. The independent comparison entries are **`p147d_function`** (Phase147
compact-map implementation) and **`p113e_function`** (original named verifier).
The initial interface document's `p147v_function` spelling is not a maintained
public entry.

This document describes an implementation awaiting source/semantic/native gates;
it makes no performance, proof or production-adoption claim. The canonical
compiler and its protected raw/final/session checkers are unchanged.

## Native ownership repair

The original hosted API checks passed, but the first native codec path failed
with `ERR_RFCS`. The diagnosed mechanism is sharing an enclosing `Type` wrapper
whose children include raw array handles: a shared constructor take can apply
`span_fade` to an unsealed array child. This is not a counterexample to a verifier
rule, and normalizing reference counts or changing the runtime would not establish
that the representation transport is correct.

The exact original verifier is preserved at
`selfhost/build/phase148/method-history/ownership-v01/verify.bend`, with
`verify-pin.json`. Its replacement unpacks the unit/tape affinely once, then passes
`words, values, names, used, valueUsed, nameUsed` as explicit raw arguments.
There are no borrowed `P148Unit`, `P148Tape`, `P148VS`, `P148VF` or `P148Checked`
parameters. Schema and flow result wrappers are consumed immediately into flat
helpers carrying raw arrays and scalar state. Branches may borrow the raw handles,
but never a wrapper around them. The original tape handles are reconstructed into
one returned unit only after admission completes.

The harness must consume the returned `P148Checked` once and decode its returned
unit. Retaining an old unit alias to call verification and decoding independently
would reintroduce the failure. Scalar optimization must follow the same ownership
protocol. These source changes require new hosted and native gates; the earlier
hosted pass does not qualify the ownership successor. The runtime is unchanged.

## Storage and ownership

The private codec guarantees well-formed forward instruction spans, value
references and interned dictionary identities. The optimizer must preserve that
contract while appending values and introducing splice/omit tags. `P148Good` is
not an externally trusted certificate; arbitrary forged arrays are outside this
initial consumer's contract. A separate structural checker is needed before any
future public/deserialized boundary accepts these units.

The admission consumer allocates two numeric arrays indexed by name identity:

| Table | Slots per dictionary identity | Meaning |
|---|---:|---|
| Schema | 3 | Width (`0` means undeclared), allocation kind, declared capacity |
| Flow | 2 | Definitely assigned bit, dynamic pointer capacity |

IDs zero and one are ordinary valid identities for `state` and `scratch`.
A value reference of zero is also valid. An interned but undeclared name has
zero schema width and does not become assigned by appearing in the dictionary.
A definitely assigned zero-capacity pointer remains distinct from absence.
The name dictionary may include globals, operations and deleted locals; these do
not contribute to the declaration count unless their names occur in a live
local declaration or seeded parameter.

`nameUsed <= 349525` bounds `3 * nameUsed` and `2 * nameUsed` below the codec's
1,048,576-word per-array admission bound before multiplication/allocation.
Array access otherwise relies on the private producer's checked indices, not on
native array index wrapping. An absent argument uses a guarded invalid value
reference; it never turns offset zero into a sentinel. Capacity and count
arithmetic retains the original unsigned checks before acceptance.

All schema changes are sequential. Schema is frozen before flow. Each branch
uses `p148w_clone`, returning original and physically independent backing storage;
there is no copy-on-write assumption. Flow join reads each complete pair of rows
before writing the continuing result. Discarded terminal/error branches are
released. Read-only borrowed handles may occur during a scalar observation,
but the algorithm never observes an earlier mutable flow version after updating
it. Only explicit branch clones supply simultaneously live versions.

The typed arrays may occupy eight-byte scalar Term slots in the selected native
runtime. Four-byte packing and good generated worker admission are measurements
to establish, not properties inferred from the Bend type spelling.

## Schema and error ordering

The entire optimized body is scanned before flow. Tags 14 and 15 are interpreted
as decoding would interpret them: a splice contributes only its selected child
range; an omit contributes nothing. Schema is rebuilt from that logical body,
not reused from pre-optimization declarations.

The scan preserves original declaration order and exact messages. Both branch
schemas are visited yes-before-no, before checking a condition's assignment.
Repeated declarations preserve width/allocation restrictions. A comparison
result is U32 regardless of its operand width. `state` is reserved; `scratch`
is a seeded allocation; parameter identity comes from its exact word rather
than `NC_Binding.id` or `kind`.

Direct and nested raw scalar blocks have different original count behavior.
Direct flow checks the final count against 65,535. A raw scalar block checks
before each actual statement, while its empty suffix returns the current scan
unchanged. The implementation preserves this distinction, including a final
declaration reaching 65,536 versus that declaration followed by a statement.
Artificial splice/omit records do not introduce additional count checks.

Header checks retain their order: function identity/ready duplication, ABI
parameter/result limits, public wrapper compatibility, then local preparation.
The private capacity refusal is an explicit unsupported-unit outcome, not an
original verifier diagnostic. A caller must use the original **whole-function**
path for `P148Bad` or this capacity refusal; it must not treat either as successful
admission or silently disable checks. Valid units within the private bounds are
the exact-diagnostic comparison domain.

## Flow and call contracts

Assignment copies the final schema's capacity, exactly as the original verifier
does; copying a pointer does not inherit its source's dynamic capacity. Only
`Offset` transfers residual bounded capacity. Memory checks preserve pointer
width, definite assignment, access size, alignment and subtraction bounds.

A two-continuing-arm join intersects assigned identities. Equal capacities are
retained; unequal capacities become zero. One terminal arm leaves the other
arm's complete flow; two terminal arms retain the yes flow. Yes errors precede
no errors. Statements after terminal paths retain their distinct raw/direct
messages. Removed/spliced statements do not introduce artificial terminal edges.

Global function/constructor tables and the ordered direct-ready prefix remain
original metadata. Their namespaces never collapse into local numeric IDs.
Direct calls retain result-destination distinctness, argument/result counts,
assigned U64 values and no forward/cyclic target admission. Public ABI checks
retain original arity, incoming-frame and flag/result conditions.

Scalar runtime contracts use the original signature/arities and global metadata
helpers while reading argument payloads directly. Small immutable signature
lists returned by those existing helpers are permitted; no argument or statement
list is reconstructed. The full extension chain is included:

- `p126_rt_nat_divmod`, with a bounded 16-byte output buffer;
- `p125_rt_concat_typed`, with distinct zero/two-field constructor identities;
- `p118_rt_extend` and `p118_rt_finish`, including constructor arity and input capacity;
- `p113_rt_array_pair`, including original buffer-origin restrictions and output count;
- ordinary runtime imports, including counted constructor/closure/frame/jump
  contracts and exact special-operation/primitive bounds.

As in the original, direct scalar safety is distinct from raw scalar verification.
A nested scalar `If` first has its whole subtree checked for direct safety, then
uses the raw scalar flow rules. Extension-call interception occurs only at the
direct statement boundary. This subtle distinction must not be flattened into
one permissive call classifier.

## Gates and laws

The harness should compare complete diagnostics to both original implementations,
then compare the whole compact pipeline's decoded transformed body with
`p113k_function`. The final verifier establishes legality and ABI consistency;
it cannot prove that a well-typed arithmetic rewrite preserves semantics.

Required controls include late schema errors versus early undefined uses,
yes/no error precedence, 65,535/65,536 count edges, duplicate/reserved parameters,
unknown-but-interned names, sparse IDs after optimization, all branch terminal
combinations, zero/unequal capacities, pointer copy versus offset, unsigned bounds,
ready-prefix changes, runtime/global identity changes, and every extension import.
Independent scalar tests must retain epochs, predicate provenance and invalidation
when assignments/calls overwrite values. Reuse the Phase147 actual Map, Lexer and
compiler function captures, plus independent negative controls.

Useful narrow mathematical laws are numeric lookup/update separation and the
assigned/capacity join rule. Encoding roundtrip and admission observations should
commute under the private representation invariant. Executable differential
controls are not a BendTT theorem; no theorem has been added by this implementation.

All performance evaluation must include packing, side-table allocation, name
resolution, schema/flow, explicit branch copies, decoding, and destruction. The
cold name table and clone cost remain real costs. The same physical compact tape
must be consumed by scalar optimization and admission without decoding between
them. Rejection, redesign or original fallback remain valid experimental results.
