# Phase127: live register-bank admission audit

This is a static, independent audit of the pinned Phase125/126 products and
Phase126 source32. No target program was executed, compiler source changed,
capability bit enabled, or qualified selection replaced during this audit.
[Exact product observations](live-bank-evidence.json) preserve the input
identities and all 45 descriptor comparisons.

## Main finding

Phase126's new `p126_rt_nat_divmod` helper is independently verified, but is
absent from the separate live-bank transport whitelist. Its presence in any
direct worker therefore makes the **whole program** ineligible for live-bank
transport. This is a concrete missed admission, not evidence that the helper
violates the transport contract.

The full compiler contains three such calls, in `$p126scc.1866`,
`$direct.Nat.show`, and `$direct.j_nat_text`. A formatting optimization can
therefore restore register clearing and bank copying throughout unrelated hot
compiler computations. These are static call sites, not dynamic hotness counts.

| Product | Phase125 capabilities | Phase126 capabilities | Register width | New divmod call sites |
|---|---:|---:|---:|---:|
| Full native compiler | 5 | 1 | 26 | 3 |
| tree-bitonic | 15 | 11 | 7 | 2 |
| variation-tree-bitonic-6-17 | 15 | 11 | 7 | 2 |
| variation-tree-bitonic-9-123 | 15 | 11 | 7 | 2 |
| test-morning-program | 5 | 1 | 7 | 4 |
| test-rle-roundtrip | 11 | 11 | 5 | 2 |

The live-bank flag has value 4. Of the frozen 45 products, **44 lose exactly
this flag**; all 45 contain the new helper. RLE already lacked it in Phase125:
its `p125_rt_concat_typed` helper is also absent from the whitelist. That older
omission is a separate candidate requiring its own runtime-contract audit.

## Exact admission path

References below are to
`selfhost/build/phase126/observer-divmod-source32/compiler.bend`:

- `p111v_signature` (40315) does not include `p126_rt_nat_divmod`.
- `p118z_runtime` (51791) adds only array-pair, extend, finish and borrowed-field
  helpers to that signature set; it does not add the new divmod helper.
- `p118z_scalar` (51804) requires `p118z_runtime(symbol)` for every scalar call.
- `p118ns_direct` / `p118ns_functions` (52065/52074) inspect all direct workers,
  including nested conditional bodies.
- `p118z_eligible` (51851) requires both all original segments and all direct
  functions to pass. It is one program-wide Boolean.
- `p113a_admitted_chunks` (47868) chooses `p118z_bundle` only when that Boolean
  succeeds. The alternative is `p118z_original_chunks`.
- `p118z_cap_items` / `p118z_cap_item` (51875 onward) add flag 4 to descriptor
  field 11 only on the eligible route.

The source generates the divmod call at `p126dp_code` (54856), and the emitted
full-compiler QBE contains the three concrete call sites above. Thus the new
helper is a sufficient refusal witness. Static inspection alone does not prove
that it is the only refusal; an instrumented predicate or narrowly extended
certificate should confirm that before making a performance claim.

## Why the refusal can be expensive

The pinned `selfhost/build/phase126/runtime-divmod01/runtime.c` has three
relevant differences when flag 4 is absent:

1. `p111_set_regs` clears every unused word after each outgoing register copy.
2. `WL_BANK` selects a local register array instead of the existing worklist
   bank; `WL_INIT_BANK` clears it.
3. `WL_READ_STATE` and `WL_WRITE_STATE` copy the complete transport width between
   the two banks.

The full compiler's transport width is 26 words in both phases. A one-result
transfer therefore requests another 25 words (200 bytes) of clearing when the
flag is off. Tree and morning have width seven, so their analogous transfer
requests six words. Actual dynamic totals and CPU cost require the parent's
runtime counters and address-resolved profiles. This mechanism could explain
part of the native-request and tree/morning regressions; it does not establish
how much of each regression it explains.

## Conditions supporting a narrow legal extension

The proposed extension is to recognize this one verified runtime import in the
existing certificate. It is **not** to force the descriptor flag or waive the
independent final verifier.

The independent obligations are already visible in source:

1. `p113e_stmt` (45058) routes this exact symbol to `p126dp_import` (54876).
   The import requires a U64 result and exact argument types
   `[Ptr, U64, U64, Ptr]`; both arithmetic operands must be defined values.
2. `p113e_runtime_args` (45001) requires the first argument to be exactly the
   `state` pointer. Every other pointer must be a local with a name other than
   `state`; a symbol, null constant, or literal state output is rejected.
3. `p111v_memory(output, 8, U64, ...)` requires a live pointer with capacity at
   least 16 bytes. This checks the second eight-byte write as well as the first.
   `p111v_memory` is at 40281 and capacity propagation at 40275.
4. `p118z_scalar` separately rejects pointer assignments, pointer arithmetic,
   pointer loads and every `N111Offset`. Direct arguments are seeded as U64
   (`p113e_seed_params`, 44946). Apart from the state argument, allowed pointer
   roots are the local scratch buffer and verified allocations. Allocation
   names cannot be reassigned as nonallocation locals (`p111v_decl`, 40217).
   In this admitted subset, an alias to `state->regs` cannot be constructed and
   passed as the output. It is the combination of the transport restrictions
   and ordinary verifier that establishes this, not merely the output name.
5. The pinned helper implementation (`runtime.c:4739`) explicitly ignores
   `state`, reads the two integer arguments, writes only `out[0]` and `out[1]`,
   and returns zero. It performs no allocation, ownership operation, register
   access, transition, callback or re-entrant dispatch. Zero divisors preserve
   the existing Bend arithmetic behavior. Its non-null check cannot fail for
   the verified stack-buffer invocation.

These facts support a narrow extension for the pinned runtime contract. They
do not justify admitting arbitrary runtime symbols, changing the generic
segment calling convention, or weakening pointer and transition restrictions.

## Minimal diagnostics and tests

Before a large rebuild, use the existing checked hosted API on one retained
program and keep the assembled IR available. A diagnostic should preserve the
admission decision and return the first refusal: original segment or direct
worker name, nested node path, and reason (`unknown-runtime-import`, forbidden
pointer operation, direct register read, nonterminal transition, or forbidden
segment width). A bounded count of refusals by symbol is useful; printing every
node is unnecessary. In particular, distinguish a cold formatting refusal from
a frequently executed helper.

The smallest falsification is to add only the audited symbol to the certificate
in an experimental checked Bend overlay, then ask whether the existing program
becomes eligible. If it remains ineligible, retain the next refusal rather than
expanding the whitelist without review. For the broad products, compare every
emitted QBE byte except the descriptor flag: an admission-only change should
not otherwise alter instructions, tables or semantics.

Existing `p126dp_controls` (54923) already exercises a correct 16-byte output,
an eight-byte output, state output, missing output, and wrong result width.
Reuse these controls and the existing `p118z_controls`, then add:

- Valid divmod call accepted by the transport predicate after full verification.
- Unknown runtime symbol still refused by `p118z_scalar`.
- Divmod with state output refused by both the runtime-argument predicate and
  `p126dpc_import(16, "state", N111U64{})`.
- Wrong argument count/type refused by `p126dpc_verified`, using its ordinary
  function-verifier path rather than expecting the transport predicate alone
  to validate an ABI signature.
- State-to-output pointer assignment and a state-relative pointer offset
  refused by the transport certificate, including inside a conditional.
- Existing post-transition read, direct register-read, multi-result and
  multi-input-continuation refusals remain unchanged.

Then run a small independently checked runtime sample and matched request
timings, measuring requested register words copied/cleared and resolved libc
CPU samples. A target-level counter result plus controlled A/B timings would
test the causal explanation. Broad/native qualification belongs after that
evidence; the installed qualified selection remains unchanged meanwhile.

## Architectural lesson

A valid new helper can silently revoke an older whole-program optimization.
The immediate remedy is a narrow certificate repair with negative controls.
The useful general profiling feature is to expose the selected descriptor
capabilities and the first admission refusal alongside physical and dispatch
CPU attribution. This makes lost capabilities observable without inventing a
new logical-call profiler or adding another optimization framework.

No runtime speedup, corrected regression, or native qualification is claimed
by this static audit.
