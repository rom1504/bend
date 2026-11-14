# Phase194 diagnostic F32, predicate and product machine audit

The three source pairs remain useful after lowering, with different interpretations. The new float pass removes internal transfers but does not keep loop state in XMM across backedges. Predicate selection improves the mask fixture while leaving the real branch fixture unchanged. The product pair exposes a larger representation gap: the shared case still constructs a heap product from fields that were already scalar, then retains and observes it; the unique case reduces to scalar arithmetic.

This audit inspected completed linked products from `diag-baseline-build04`, `diag-selected-build02`, and C/QBE `diag-references02`, all under `selfhost/build/phase194`, using catalog-v3. Each acquisition report is complete for12 cases. Only the6 F32/predicate/product cases are analyzed here. No compiler, target or timing job was run by the auditor. Exact report/binary hashes and metrics are in [diagnostic-float-products.json](diagnostic-float-products.json); selected disassembly is preserved in [diagnostic-float-products-witness.zip](diagnostic-float-products-witness.zip). Earlier provisional emit03 findings were confirmed against the completed build04 products.

| Hot function | Baseline→selected instructions | Other observed change |
|---|---:|---|
| closed F32 `direct.p194.floop` |59→56|MOVD9→5; frame2320→2336 bytes|
| mixed F32 `direct.p194.floop` |81→81|MOVD15→13; frame2320→2368 bytes|
| predicate branch `direct.p194.kernel` |45→45|SETcc remains; no CMOV|
| predicate mask `direct.p194.kernel` |69→65|SETcc1→0; one CMOV remains|
| unique product `direct.p194.kernel` |43→43|No hot calls or product construction|
| shared product `direct.p194.kernel` |45→45|One call to step per iteration, with substantial work below it|

These are whole-function static counts, including prologues, cold paths and padding. MOVD counts do not include MOVQ transfers between GPR and XMM. A small caller instruction count does not include its callees' work. Frame reservation does not mean the whole reserved area is touched each iteration.

## F32: internal identities help; loop representation remains

Closed F32 preserves all three scalar arithmetic operations. Selected code keeps the intermediate add/multiply results in XMM, then publishes the final subtraction into esi at0x408462. The next iteration reloads esi twice, at0x408439 and0x408457. Constants0.25 and2.0 are reconstructed with MOVABS/MOVD inside every iteration. The two counter tests also survive: materialize `n==0`, test its Boolean, then materialize `n!=0` and test again. The successful steady path executes33 baseline instructions and30 selected instructions;14 selected instructions belong to those two compare/materialize/test sequences. There are no stack-memory accesses on this steady arithmetic path.

QBE's corresponding loop executes11 instructions per iteration. It has one counter branch, direct memory-source arithmetic constants, and still transfers the loop value through a GPR using MOVQ. The C reference keeps the value in XMM, hoists the constant and unrolls4 iterations into18 instructions; it implements multiplication by2 as an addition. These actual instruction sequences substantiate a remaining representation/control gap, not a prediction that speed scales with instruction count.

Mixed F32 intentionally adds two scaling operations and an F32→U32→F32 roundtrip per iteration. Both conversions and range handling survive all backends. Its initial three arithmetic operations already happened to form an XMM region in the baseline, unlike the closed fixture. The selected pass removes two MOVDs but exchanges other moves, leaving81 whole-function instructions. This is a useful boundary control, not equal-work evidence that conversion overhead could simply be deleted.

A next falsifiable hypothesis is canonical loop-value placement with exact entry/exit publication: remove the repeated GPR transfer on the closed recurrence without changing zero-iteration/raw-word behavior, floating status, NaNs or calls. Separately, retaining the first counter-test fact should eliminate its contradictory second test. These are broader changes than the selected closed-region rename; neither was implemented here. Runtime benefit and workload coverage remain unmeasured.

## Predicates: mask improves; a comparison still becomes a Boolean before a real branch

The branch fixture still emits CMP→SETB→MOVZX→zero-extension/copy→TEST→JE before computing the chosen arithmetic arm. The selected pass only covers copy/select arms; this fixture's arms perform different arithmetic, so its unchanged result is an expected coverage boundary. QBE directly branches on the comparison. C if-converts and unrolls this small recurrence.

The selected mask fixture instead emits CMP followed by loading0/1 and CMOVB, eliminating its old Boolean materialization/decode. It still negates that0/1 to a word mask and evaluates both arithmetic alternatives, then AND/OR combines them. C recognizes a conditional selection and uses CMOV; QBE retains a longer mask/dataflow sequence. Thus the intended branch-versus-mask distinction survives direct x86 and QBE but is substantially simplified by C. The source mask intentionally performs additional work, so pair timing cannot be labeled pure branch overhead.

The cheap next falsifier for ordinary branch predicate forwarding is this existing branch fixture: can exact comparison flags cross the intervening width/copy operations and reach JE without materializing a Boolean? General flag/clobber and use-count safety is required; no new pass is proposed for promotion on this evidence alone.

## Products: sharing forces scalar fields back into a heap object

Unique-product `direct.p194.kernel` computes the complete recurrence in registers; the loop has no calls, allocation or reference-count operation. The shared kernel calls `direct.p194.step`, which passes scalar fields to `product.p194.observe`. That product worker stores the two fields into scratch, unconditionally calls `p125_rt_ctor2`, calls `p111_rt_keep`, then invokes `direct.p194.left` and `direct.p194.right`. The latter observation wrappers retain ownership/borrow checks. This is actual reconstruction and ownership work in the loop's call chain, not merely a larger static frame. Both Phase193 and selected Phase194 retain it.

QBE shows the same ctor2→keep→left/right sequence. C's apparent small direct kernel is a wrapper into `NF_p194.kernel`; inspecting that body reveals heap allocation/reuse, ownership/tag checks and cleanup, including heap/term helpers. Therefore the paired distinction survives all three backend families. It exposes a shared representation limitation; comparing only the small caller would miss it.

The useful general hypothesis is to preserve a product's scalar fields through multiple known, nonescaping observations. Existing specialization creates a scalar product worker but then reconstructs the object when it must share that product. This fixture provides a cheap falsifier: the shared hot call chain should lose ctor2/keep while retaining exact ownership behavior for escaping/unknown/duplicated uses. Full program effect remains unknown until representative real workloads show the same dynamic reconstruction pattern. It would be misleading to claim an entire-suite ceiling from this tiny diagnostic.
