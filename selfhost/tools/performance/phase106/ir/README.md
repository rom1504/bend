# Phase106 structured native execution IR

This is a bounded experimental Bend implementation, separate from the selected
compiler/release. Its verifier, constant folding, workload construction and both
text emitters are written in Bend. The second consumer reads the emitted JSON
and builds a Cranelift object. C and JSON consume the same verified typed graph.

Assemble `import Base` followed by `model.bend`, `optimize.bend`, `verify.bend`,
`json.bend`, `c.bend`, `workloads.bend`, `../laws/bridge.bend` and `main.bend` into one source. The driver
accepts `MODE WORKLOAD raw|fold`, with mode `json`, `c` or `verify`. Ordinary
workloads are `text`, `list`, `tree`, `closure`, `tail` and `many`.
Additional `classify`, `shift` and `law_bridge` programs expose semantic controls.
The held-out `shared`/`shared_borrow` mechanism pair measures retained versus
borrowed observation of a live parent/child aggregate, with final reference counts
included in the result. It is a fixture ablation under an explicit owner lifetime,
not a new generic ownership optimization or a production runtime equivalence proof.
Each emitted program exports `uint32_t phase106_entry(const uint64_t *args)` and
`const uint32_t phase106_arity`; the common external runner owns main/measurement.

## Contract

Types are wrapping unsigned `u32`, wrapping unsigned `u64` and host `ptr`.
Literal payloads in the Bend constructor are U32-sized; `u64` calculations can
produce larger results. A pointer literal is zero only. Add/subtract/multiply,
bitwise and/or/xor and shifts preserve operand width. Shift counts are explicitly
masked by width minus one; this lower-level operation is **not** a direct mapping
of Base `U32.shln`/`shrn` when counts reach the word width. Equality and unsigned
less-than return U32 0/1. No division or signed arithmetic is in this slice.

All local variables start at typed zero. Statements are assignment, if, while,
return, store and free. Calls, allocations, loads and indirect calls may occur
only as the root of an assigned/returned expression. Pure operands and argument
lists avoid unspecified C argument evaluation order. `ptradd` adds an unsigned
U32 byte displacement to a pointer; load/store also carry a constant byte offset.
Allocation is zeroed, allocates at least one byte, and aborts on allocation failure.

Functions use the normal platform C ABI. A lowered self-tail recurrence is an
explicit while loop. Arbitrary/mutual return-call chains have no constant-stack
guarantee. An indirect call supplies its exact parameter/result signature and an
explicit environment pointer; this demonstrates a closure-shaped path but does
not implement the installed Bend closure or reference-counting ABI.

The verifier rejects unknown variables/functions/operators, invalid types,
duplicate names, malformed identifiers, argument arity/type mismatches, effectful
nested expressions, missing returns and unreachable statements after a guaranteed
return. Identifiers use lowercase ASCII letters or underscore initially, followed
by lowercase letters, digits or underscore. `bad_identifier` exercises a leading
digit refusal; this subset is also accepted by the Cranelift consumer.
It checks structure and types, not pointer lifetime, allocation bounds,
alignment, indirect-target signature agreement or ownership. Fixtures establish
those remaining obligations by construction; arbitrary untrusted IR is unsupported.

## Current compiler connection

The text workload contains an exact algorithm slice of
`selfhost/src/front/lexer.bend`'s `f_ascii_ident_code` and `f_ascii_space_code`.
`<=25`, `<=9`, and `<=4` become unsigned `<26`, `<10`, and `<5` respectively.
It retains U32 wraparound and full-codepoint rejection. This is a direct typed
IR reconstruction of those helpers, **not** a general KTerm frontend or a claim
that the installed compiler has migrated to this IR.

Text scanning/hash and allocated list construction/folding are training workloads.
Allocated tree traversal and explicit closure environments are held-out families;
inputs must be frozen before timing. `tail` tests an iterative recurrence and
`many` tests 128 helper boundaries. Dynamic n/seed parameters prevent whole-input
constant evaluation. Every allocation is released on the valid fixture paths.
The law bridge adds literal-fold and dynamic arithmetic observations separately.

`nx_fold_bin` is the small safe helper used by `nx_simplify`. Independent Phase106
laws check its actual body. The recursive pass, verifier, emitters, memory model,
Cranelift adapter and whole compiler remain outside that proof scope.
