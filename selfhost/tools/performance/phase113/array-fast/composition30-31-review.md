# Exact source30/source31 admission boundary

These compositions retain the guarded array, identity and stable-base contracts,
branch analysis, and modulo-2^32 rendering reviewed in composition26-27-review.md.
They include the fixture termination correction in composition28-29-review.md.
The original branch24 complete-output failure and earlier admissions remain
preserved; a source-binding receipt is not retroactive semantic qualification.

The additional bool-width manifest is an ordinary emitter canonicalization.
It recognizes only two pure singleton arms assigning the same U64 destination
the constants1/0 or0/1. The verified U32 condition is explicitly compared with
zero, then the resulting word is extended with extuw into the original U64
destination. This preserves arbitrary nonzero conditions, not just0/1 inputs.
The condition is read before assigning the destination, including aliases.
Any additional statement, effect, different destination/type or other constant
keeps the original branch emitter. Scalar and direct hooks use the same rule.

The `%p113_bool_N` temporary is disjoint from source locals and machine-width
temporaries. It consumes the existing shared counter. Counter exhaustion,
terminal state and existing errors keep the original emission path. The typed
IR, original verifier, runtime ABI and owning effects remain unchanged. This
review records the finite rule; it makes no new compiler/backend proof claim.

Source30 retains192/512 inline limits; source31 retains384/1024 with all other
admission, stack, arity, result, hygiene and rollback bounds unchanged. Both
admissions require the exact completed API check for their source, byte-exact
ordered composition replay and the original runtime source/object. Standard
compiler qualification supplies complete-output evidence separately. No custom
native experiment or target is executed by these admission methods.
