# Direct owning result ABI, bounded Phase125 ablation

`model-v2.bend` is a complete alternative overlay to `model.bend`, not an additional overlay. All source admission, type/constructor checks, candidate ordering, preserved fallback, dependency handling, and local namespace conditions are unchanged. The only changed interface is the explicitly different symbol:

```
uint64_t p125_rt_concat_value(P111State *, uint64_t left, uint64_t right,
                             uint32_t empty_cid, uint32_t link_cid);
```

Failure returns zero and leaves both inputs untouched/unconsumed, exactly as before. Success transfers both inputs to its returned owning Term. The wrapper tests that result against zero and returns it directly; refusal executes its exact old body. This removes the one-slot alloca, its pointer argument, and the success load. The derived import verifier now requires exactly `[Ptr,U64,U64,U32,U32] -> U64` and the unchanged distinct real constructor IDs with arities zero/two. It does not require a buffer that no longer exists.

Zero cannot be a valid result under the unchanged source certificate: it proves an inductive two-constructor list-like ADT, including exact native List specializations, not U32/Nat/Bool scalar functions. The native runtime defines `TAG_PAK=1`, `TAG_CTR=2`; either tag makes a Term nonzero, and adding the RFC bit does not change that. Empty-left returns right, whose same checked ADT result type is essential to this argument. No generic "zero means failure" convention is introduced for other helper result types.

Root reports the raw-only V1 screen was about 5.8% slower; the fully qualified RFC1 screen was about 0.3% slower despite eliminating six constructor/take pairs per RLE invocation and achieving three of three append successes. These are root-run observations, not runs performed by this author. The ABI variant tests whether avoidable call/output transport obscures that allocation reduction; it does not establish the reason for the neutral result. Reuse the existing 12 pure controls and complete ordinary String/alias outputs; inspect actual helper calls and native code. Retain V1 and its measurements even if V2 is faster.
