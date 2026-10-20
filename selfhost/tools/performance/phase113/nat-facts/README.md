# Optional full-width Nat ownership facts

This profile adds `N_Imm64` after the three existing `N_WordKind` constructors.
It means a valid runtime immediate with no reference-count ownership. It is not
`N_W32`, and never authorizes truncation. `nl_c_type(N_Imm64)` is exactly `Term`;
`nf_param_type` already returns `Term` for every non-W32 kind. N111 arguments,
locals, captures, scratch, returns, and private output slots remain U64.

The exact runtime04 premise is Nat=Term with `NAT_IMM=2^48-1`. Zero, Succ and
all admitted Nat arithmetic preserve that range on successful execution.
Add/double sum at most two valid 48-bit values, so cannot wrap U64 before
`nat_chk`; multiplication checks the quotient bound before multiplying.
Subtraction stays bounded. CPU overflow reaches `err_post` then `_exit(1)`.
Every valid Nat has zero RFC bit and zero heap-tag bits, so keep returns the
same word and sink does nothing. This profile changes neither operation
execution nor overflow checks. It does not classify arbitrary U64 bits as Nat.
Foreign providers retain their existing checked-type/runtime ABI obligation.

Origins are the original canonical builtin Nat ADT with no type/region
arguments, authenticated exact-arity `u32_to_nat`, `nat_add`, `nat_sub`,
`nat_mul`, `nat_double`, canonical Zero/Succ, fully saturated nondependent
checked callee results, and existing aliases/captures. The original
`nf_scalar_kind` and global `nk_value` are unchanged. One exact `nf_kind_head`
replacement uses `p113n_type_kind`; the original live-arity check and telescope
traversal remain. This supplies Nat parameter facts to generic, direct and
product entry producers through their existing `nf_worker_kinds` calls.

Match-field extension composes with `direct-fields/model.bend`. The optional
`p113df_field_env` replacement preserves validated mature mask facts, exact
IDs/words, and field order. Additional Nat facts require an exact encoded
constructor identity, matching live field count, at most eight original
constructor binders, and a closed unparameterized result ADT. Domains that do
not normalize independently to canonical Nat stay opaque or retain the mature
mask. Generic ADT fields and virtual flattened bundle fields gain no new Nat
fact in this prototype; their existing kinds remain safe. No matcher declaration
is replaced here. Raw KTerms, forged books or masks are not ownership proofs.

Composition requires the existing Phase113 facts and Phase112 typed ownership
consumers. Replace `N_WordKind` using `model.bend`; append `helpers.bend`; apply
`overrides.bend`; optionally apply `field-overrides.bend` after the direct-fields
helper. Controls require that field overlay. Preserve the unchanged original
verifiers. `overrides.json` lists every replacement and its source identity.

`p113_nat_control_report()` has finite classifications, refusal cases, retained
opaque/boxed ownership, alias/capture behavior, full-word constants at 2^32,
2^40 and 2^48-1, and both C type consumers. Reuse
`p113_fact_control_report()` and `p113_field_control_report()` as well. Their
W32-only Nat classifications and mature scalar-field mask stay unchanged.
The older Phase112 `typed-nat-conservative` expectation intentionally changes:
Nat is now nonowning Imm64, so do not claim that old report passes unchanged.

Six native source fixtures are frozen in `fixtures/manifest.json`: high values
and captured aliases; mixed Nat/String record transfer with retained String
alias; strict unused add/double/mul/Succ overflow. Positive stdout and negative
status/stderr expectations are explicit. Reflected U64 preservation checks do
not replace these actual native observations. No compiler, API, native, proof,
or benchmark targets were run by the preparing agent.
