# Verified sized-runtime ABI: constructor proof is stronger than take proof

Status: source-only candidate. `model.bend` overrides only `p118xs_original`, the existing post-verification sized-helper projection. The original structured calls remain `p111_rt_ctor` / `p111_rt_take`; every existing generic/direct/array program verification gate runs before this selector emits the derived helper calls. There is no verifier extension or weaker original admission.

## Exact split of proved and dynamic facts

`p111v_counted_call` (parent `ready-source02/compiler.bend:40377`) proves a literal count, an allocated local buffer of at least count×8 bytes, and, **for ctor**, a real `N111CtorId` whose bound metadata arity equals count. `p111v_decl` rejects reassignment of allocas or allocation/type changes; pointer copies have no inherited capacity, and bounded offsets/branch joins retain capacity conservatively. Therefore a selected positive-count field/output buffer cannot be a null pointer. Program metadata is bound independently at startup.

For **take**, that same verifier does not prove the actual input Term's constructor ID, arity, or tag. Its target lookup is irrelevant because the second argument is an owning U64 Term rather than a CID. Removing the term-shape tests from all takes would overclaim the verifier's proof. Source match lowering knows more, but that information is not explicitly retained in this call interface; a separate matched-owner certificate would be required.

| New derived helper, N=1..4 | Proved checks removed | Runtime behavior retained |
|---|---|---|
| `p125_rt_ctorN(state,cid,fields)` | count==N, cid bounds, descriptor arity==N, fields!=NULL | exact allocation/class, all field reads, cap8/cid_hot decision, every required rfc_seal, ordinary CTR result |
| `p125_rt_takeN(state,term,out)` | count==N, out!=NULL | actual cid bounds and arity==N, N==1 PAK extraction, required CTR-tag check, ctr_take, all static/RFC/shared ownership cases, spare_free, result N |

The new symbol names and three-argument ABI make the stronger contract explicit. Root owns additive C definitions and declarations; implementations should copy the current `runtime-extend01` sized-helper bodies literally except for those listed checks and the removed count parameter. In particular, do not reuse the old unconditional-seal Phase118 draft: the selected runtime has the capability-eight cold-constructor branch.

The selector requires the exact original four-argument shape, U64 result, `state` first argument, a nonstate local buffer, a low-word literal count1..4, and an actual `N111CtorId` for construction. All nonselected cases delegate to an exact copy of the old sized selector, including the old helper symbols. Existing extend/divmod/F32 projections still delegate through this hook unchanged. The source projection does not authenticate arbitrary calls on its own; it is valid only after the existing complete-program verification gate.

## Applicability and falsification

Parent45 static sites (including duplicate/alternate paths): ctor1=561, ctor2=2883, ctor3=1130, ctor4=70; take1=175, take2=1709, take3=234, take4=37. Authenticated per-file counts are in `static-sites.json`. These establish broad emitted applicability, not dynamic shares or expected speedup.

`p125vc_controls()` provides11 pure shape controls for positive cases, wrong counts/high word/state/buffer/CID kind, and unrelated imports. Fabricated analysis calls are never targets. Existing ordinary complete-output/sharing/depth tests must still pass; measured machine code should show removal of only proved checks/one argument. Compare constructor-only, take-transport-only, and combined if runtime ablation is cheap, because remaining dynamic take checks may dominate and the compiler can already optimize some constant ABI work. No speed gain is claimed before root-owned measurements.

The highest-value next step *if* take shape checks remain measured hot is to carry a small checked matched-constructor witness into derived lowering. That would preserve information the semantic lowerer already has, instead of globally assuming every U64 take operand has the requested shape. It is a separate experiment, not a premise smuggled into this one.
