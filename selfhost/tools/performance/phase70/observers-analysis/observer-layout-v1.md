# Bounded observer schema discovery

`observer-layout-v1.bend` is a source-only proposal. It has not been parsed,
typechecked, emitted or executed. No production source was changed. Root owns
any compiler query and later qualification.

The entry is `no_schema(book, definition, firstFresh)`. `NO_Layout` belongs to
the emitter proposal; this file adds `NO_Spec` and `NO_Schema`. The eight
`no_schema_*` accessors expose the schema without repeating its record layout.

* `params` are fresh `Var` nodes in live argument order. Their names identify
  canonical, zero-parameter ADT types. IDs are `nc_id(firstFresh + offset)`.
* `roots` contains zero-based live parameter indices, in source argument order.
* `wrapper` uses only native-identity `Ctr` nodes, those root Vars and one fresh
  result Var. The body analysis must prove that exact wrapper for every return.
* `result` is the observation Var ID; `observation` is its canonical scalar type.
* `specs` adds constructor storage, owner and ordered canonical field types.
  The list contains accepted roots plus scalar constructor readers from the
  actual book. Repeated root types can produce equivalent duplicate specs.
* `fresh` is the next unused counter, after allocating the observation Var.
  A nonempty `error` declines the whole schema.

Discovery accepts at most four live parameters, thirty-two telescope binders,
eight fields per constructor and thirty-two constructors per enum. Existing
layout helpers bound each alias expansion to sixty-four steps and substitution
growth to 4,096 nodes. Native representation names are permitted only through
actual native ADT declarations. They never select candidate function names.

A root has no type parameters/templates, exactly two constructors, one nullary
constructor and one constructor with two to eight fields. Exactly one field
has the root type and every other field has an accepted scalar type. The only
native root admitted is String; a nonnative renamed Tape uses the same rules.
Native Nat, Word, Array, IO and function-shaped values cannot become roots.
Prior field dependencies and indexed constructor results decline.

The result has one or two fixed constructor shells, each with one to eight
fields, and must contain every root exactly once and exactly one scalar
observation. Roots currently map left-to-right to input root order; a different
permutation is conservatively declined. The body proof still checks real origin
identity, so equal types never permit swapping same-typed roots.

Result discovery specializes actual constructor telescopes using
`nq_layout_specialize`. It checks field dependencies and constructor result
indices itself. It deliberately does not use `nq_layout`: that helper rejects
the outer `Sigma` in `((String, String), Cmp)` because an inner field has the same
owner name, although it is a finite, nonrecursive instantiation. A global
two-shell budget safely bounds this traversal. A single polymorphic Tuple
field-type spec would be ambiguous, so wrappers retain structural children
instead. Virtual known-constructor matching must consume those actual children.

Scalar kinds include native Nat/Char/U32/F32 and finite zero-field enums.
The reader list includes native Nat Zero/Succ and Char Chr, allowing helpers to
match them even when they do not occur as direct entry arguments. Boxed Word
destructuring and general primitive layouts are absent. Whole-book scalar reader
collection occurs only after the result schema succeeds; a rejected candidate
does not pay that scan. A later integration can share immutable scalar specs
within one checked compilation if profiling justifies it.

This descriptor is not optimization permission. In particular, native Nat may
have a large representation: a scalar kind is insufficient to prove the emitter's
immediate-value operations. The parent admission/guard layer must establish the
representation domain, and the body analysis must establish purity, demand,
ownership, identity and supported scalar operations. Raw checked-marker input
must not bypass those obligations; malformed raw constructor declarations cannot
grant permission. The caller must choose `firstFresh` so its generated IDs are
disjoint from source and existing runtime binder IDs. The schema checks actual
live parameter count against `nd_arity`, but does not establish global freshness.
Root-owned controls should exercise nested
Sigma, a renamed Tape, duplicate/missing/reordered roots, extra observations,
dependent fields/results, unsupported native roots and budget exhaustion.

Source-only validation performed: balanced delimiters outside strings/comments,
unique helper names, and inspection against root-produced core03 records for
Map.bit.go, String.cmp and their native ADT declarations. These checks do not
claim Bend syntax or type correctness.
