# Phase172: test the missing inlined runtime boundary

Status: experimental Bend emitter overlays, independently source-audited. The
root execution lane's `runtime-api02/report.json` records successful checked
API acquisition (14.515s), and `runtime-controls02/report.json` records27/27
finite controls plus both complete instruction-graph comparisons, including
comparator mutation controls. Its8-function oracle is8,466 QBE bytes. These
receipts live under `selfhost/build/phase172/`; native validation and speed are
separate, still required gates. No installed source/runtime was changed.

## Why this experiment

The [Phase166 machine comparison](../phase166/code-shapes.md) found that both
mature C and bendc inline small allocation fast paths, while QBE's actual
complete-record consumer has 91 out-of-line constructor sites and a 2,632-byte
frame. Those are machine-code observations, not 91 dynamic calls per request.
The mature C scanner uses a 120-byte frame; bendc uses72. This suggests testing
whether removing a runtime boundary also removes caller spills and repeated
publication checks. Existing borrowed-field, Nat, and frame templates do not
generally inline ordinary owning constructors.

This is a small falsifier of that mechanism, not a promised route to100s.
The [older full-request profile](../phase169/runtime-boundary.md) places only
1.56% of physical samples in `p125_rt_ctorN` itself. The small lookup's46.7%
ctor/take figure must not be treated as full-compiler headroom. Inlining retains
the necessary allocator traffic and may increase QBE size, register pressure,
emission time, and machine-build cost.

## First hypothesis rejected before execution

The first overlay preserves checked constructor `hot` metadata in the existing
emitter index and inlines capability8/cold, warm-pool construction. An offline
census of the **actual Phase170 Q3 compiler** falsified its full-compiler scope:

-703 constructor descriptors, all703 hot.
-Descriptor capabilities5, so bit8 is absent.
-8,681 sized constructor calls:784 width1,5,676 width2,1,155 width3,1,066 width4.
-Zero cold sites.

[Exact input identity and census](inline-runtime-census.json). The data were
obtained by streaming the retained QBE, reading its `p111_cid_hot` byte table,
and matching actual `p125_rt_ctor1..4(state, literal-cid, local-buffer)` calls.
These are static sites, not invocation counts. Preserve the cold overlay as a
negative attempt; do not build a full compiler from it.

The [permission audit](cold-permission-frontier.md) explains why all-hot is not
evidence that every constructor intrinsically requires sharing: File effects
currently block the cold-analysis permission gate. Allowing new effects is a
separate semantic investigation, not part of this runtime template.

## Selected variant: already sealed fields

`inline-runtime-sealed.bend` intercepts only already verified ordinary
`p111_rt_ctor` calls with literal constructor identity, exact metadata arity1–4,
the exact state argument, and an authenticated local scratch buffer. Existing
constructor indices are unchanged. Admission is structural, never based on a
user function or benchmark name.

At execution time it reads each field from the disjoint local buffer and checks
that `rfc_seal` would return it unchanged. The runtime's exact predicate is:

```
tag != TAG_CTR || RFC
```

This is equivalent to `(field >>56) !=2`: raw constructors have top byte2 and
RFC constructors have byte130. Packed/scalar, closure/task, buffer/array,
static, and hole words retain exactly the existing `rfc_seal` behavior; this
does not claim they are all trivial or freely duplicable.

The second condition is that the appropriate allocator pool is nonempty.
Only then does the fast branch load the free-list successor, pop one block,
decrement the exact size-class credit, store the cached fields in order, and
construct the normal tagged result. Class/credit pairs are0/1,1/2,2/4 for
widths1,2,3–4. A field requiring sealing or an empty pool reaches the original
helper before any mutation. Refills, error behavior, raw-child sealing, and
all other slow-path behavior remain in that helper.

The selected variant does not need cold metadata or capability8. It never
changes reference counts, frees an object, moves a continuation, or changes
the allocator. It preserves the full final verifier and the previous emission
chain on fallback.

## ABI and correctness boundary

-Pinned P111Program ABI11101 and the current ordinary standalone CPU runtime.
  `p111_rt_main` rejects unsupported GPU/multi-mutator configurations. This is
  not a device, concurrent, or alternative embedded-runtime template.
-P111State's heap and allocator pointers are at bytes0 and8. Host allocator
  lane stride is1. Pool head is at `8*class`; credit is at `8*(32+class)`.
-The final counted-call verifier proves the real local buffer's capacity.
  The extra existing `p114t_buffer` admission is conservative. Local storage is
  disjoint from the allocator/heap; therefore moving read-only field snapshots
  before allocation is valid. Cached values are written in original order.
-There is no payload read from `H[0]` on an empty pool. Every mutation follows
  the complete guard. The original helper is rendered through the prior path
  directly, preventing recursive expansion of its own fallback.
-Fresh names use the existing independently reserved `p114t_` namespace and
  fresh-site budget. No verifier namespace or memory capability is widened.

The retained cold variant additionally depends on the active descriptor being
the generated `$p111_program`, which is what the standalone main activates.
The selected sealed variant does not load a program descriptor.

[Independent source audit and file hashes](inline-runtime-audit.md).
These are source-level arguments under a pinned ABI, not BendTT proofs.

## Assembly and fast gates

Use the existing Phase171 metadata-only API assembler with:

```
--module selfhost/tests/phase172/inline-runtime.bend
--module selfhost/tests/phase172/inline-runtime-sealed.bend
--module selfhost/tests/phase172/inline-runtime-sealed-override.bend
--module selfhost/tests/phase172/inline-runtime-controls.bend
--module selfhost/tests/phase172/inline-runtime-sealed-controls.bend
--prelude selfhost/tests/phase172/inline-runtime-sealed-laws.bend
--replace p111q_stmt
--export p172is_controls
--export p172is_guard_observation
--export p172is_fast_observation
--export p172ir_oracle_module
```

Do not include `inline-runtime-override.bend`, which belongs to the rejected
cold variant. The shared original file contributes only reachable common
helpers to the selected extracted compiler.

1. Check Bend source. Run27 finite admission/rendering controls. Compare both
   full structured IR observation pairs, not only rendered substrings.
2. Use the tiny emitted oracle module against the unchanged runtime helpers:
   widths1–4, raw and sealed child terms, retained aliases, pool miss/refill,
   ordered payloads, and correct resulting allocator state. Cold-enabled and
   cold-disabled descriptors must both preserve results. No malformed pointers
   or unchecked hostile runtime states are required.
3. Compile the existing complete-record lookup and actual recursive verifier
   workloads through both APIs. Preserve their independent full-value oracles,
   toolchain, input, preparation, output, and clean runtime. Compare actual
   caller assembly and complete runtime, with QBE/build cost separate.
4. Where an existing diagnostic runtime can count helper entries, baseline
   sized-constructor entries are candidate opportunities; entries remaining in
   the variant are fallbacks. Their difference is actual fast-path use, provided
   the unchanged workload's allocations and outputs agree. Keep diagnostic
   counter timing separate from clean performance.
5. Only a material verifier gain that transfers beyond the lookup justifies a
   full compiler acquisition. Poor coverage, extra spills, or neutral complete
   runtime rejects the hypothesis despite a successful helper microbenchmark.

No full-image campaign is authorized by static-site counts alone.
