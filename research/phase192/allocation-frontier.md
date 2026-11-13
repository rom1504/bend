# Phase192 allocation frontier

**Per-definition register lifetimes are a real frontier; simply adding regional
allocation is not.** The current large-function fallback already allocates
call-free regions. The strongest concrete next witness is the mixed-use
floating temporary in the newly emitted Phase192 numeric loop: three immediate
XMM→GPR→XMM pairs remain after conversion dispatch and scratch staging disappear.
A bounded definition-versioned floating plan can remove those artificial
boundaries. Broader retention across unrelated integer operations and loop
backedges is needed to remove the full transport category. The existing Map
profile does **not** establish that frame traffic dominates a hot workload or
justify a broad allocator rewrite on its own.

This assessment ran no compiler, generated program, sampler or target job.
Inspection used source, existing profile JSON, ELF disassembly and section/hash
comparisons. No production files were edited.

## What the allocator actually does

`selfhost/src/back/x86/loop-liveness.bend:x190_joint_frame` admits setup plus body
of at most 256 statements, at most 64 parameters, and its existing safe-operation
whitelist. Its candidate limit is 32 names and its colors are four saved plus
five caller registers. Rejection calls `x190_allocate_legacy`, which first
installs the existing saved homes. `x190_liveness_frame` also rejects above 256,
then calls `x185_transient_frame`; this is not a stack-only fallback.

`transient.bend` already scans bodies below 4096 statements and allocates five
caller-register intervals. Its deliberately conservative invariants explain
what a new regional mechanism would have to improve:

* A name must begin with a write and remain in one call-free region. Parameters,
  setup definitions and reserved names are excluded.
* Each conditional arm and its continuation get separate regions. Observing
  the same name in another region permanently blocks the name, even when the
  observations concern independent definitions whose values never cross edges.
* Ordinary calls forbid all arguments and all results and then cut the region.
  This excludes arguments whose last read is the call and results born after
  the clobber, as well as genuinely call-live values.
* Inclusive endpoints forbid a destination from sharing a consumed source's
  home. Multiple definitions of one name form a single conservative interval.

The one-home-per-name frame representation is the constraint. More colors or a
larger whole-function bound do not remove false interference between unrelated
values sharing a mutable name. A regional rewrite needs reaching definitions,
local def/use intervals, and explicit publication at real boundary consumers;
it cannot merely relax the current blocking rules. Existing backedge, alias,
call-clobber and postcolor checks must remain effective.

No retained exact Map admission diagnostic was found. Large machine size and
hundreds of calls motivate checking the bound, but are not reported here as an
exact IR statement count or proof that every large function takes one particular
fallback path. Bodies above 4095 would also bypass transient allocation; that
must be diagnosed before attributing a particular missed home to regional rules.

## Final Map evidence: large static gap, small demonstrated leaf budget

The inspected selected ELF is
`selfhost/build/phase191/native45-02/coverage-map-churn-32/machine/program`,
SHA-256 `c78160cc20bd112b2dec064b9f71abc832022cc3740379a5a7c5abc25dc69089`.
Its `.text` is byte-identical to the sampled native45-01 product recorded by
`implementation/phase191/profile-evidence/assessment.json`. Reference paths and
source bindings are in `selfhost/build/phase191/references01/manifest.json`.
QBE is the retained phase186 `release-native45-acquire01` map product; C is
`selfhost/build/phase184/bend-products01/coverage-map-churn-32/bend-c/program`.

| Function | x86 instructions / RBP memory refs | QBE instructions / RBP memory refs | C instructions / stack memory refs | Final x86 leaf share |
| --- | ---: | ---: | ---: | ---: |
| Map.ins.go | 8078 /1891 | 6171 /933 | 5681 /671 | 5.752% |
| Map.seek.go | 4212 /941 | 3591 /352 | 4539 /396 | 5.257% |
| Map.put.go | 3932 /968 | 3024 /357 | 4680 /483 | 2.458% |
| borrowed Map.bit.go; C direct bit.go | 221 /31 | 108 /6 | 83 /0 | 10.958% |

Counts exclude LEA from memory references but include prologue, epilogue, cold
arms, buffers and all other frame references. C uses RSP as its principal frame
base; its numbers combine RSP and RBP syntax and are not a spill count. Instruction
counts include disassembled padding. Different public/private ABIs and product
representations prevent treating these as identical work or dynamic counts.
For example, x86/QBE/C insertion have 411/447/279 static calls respectively.

There is a concrete x86 frame roundtrip near insertion `0x4163e0..0x416422`:
load tagged state, shift 40, store `-0x8a8(%rbp)`, mask the same temporary, store
again, reload into `%r14`, compare 45 and materialize/test the predicate. Later
regions reuse the frame slot. This is a useful diagnostic target for definition
splitting, but slot reuse alone does not prove an IR-name identity or liveness
error. C's bit loop at `0x166e0..0x1672a` has no frame scratch; QBE's corresponding
loop around `0x406140..0x406220` still stages heap fields through a private frame
buffer. Some differences are representation transport rather than allocator
spills. The main repeated x86 bit traversal paths were already observed without
frame loads in the earlier machine audit; its 31 references are not 31 per step.

The final map profile pools 370 samples at 8000us and 223 at 13000us: total 593,
weighted denominator 5,859,000us, including 1.843% unknown samples. Joining exact
sampled ELF PCs to disassembly gives these descriptive observations:

* Generated-function frame-memory instruction PCs: **3.823%** of total weighted
  samples; generated functions collectively account for 62.178%.
* Insertion frame PCs: 0.546%; seek: 0.717%; put: 0.444%; borrowed bit: 0.273%.
* Entire insertion+seek+put leaves: **13.466%**. Even their impossible zero-cost
  elimination reduces total time by only 13.466% (about 1.156× speedup). Halving
  all their work would reduce total time by 6.733%.

To reproduce the PC classification, use each candidate role period's
`analysis.file`, map its `pcs[].elf_address` to `objdump -d --no-show-raw-insn`
instructions, require its mapping to equal the candidate executable, and sum
`samples * periodUs`. Match `(%rbp)` operands except LEA inside generated FID
symbols; retain every sample in the denominator. The corresponding sampled
frame weights for insertion, seek, put and bit are 32000,42000,26000 and 16000us.
These sparse leaf counts have substantial uncertainty. A sampled PC on a memory
instruction is **not** a memory-stall event, load count, or causal runtime
ceiling: earlier instructions and front-end effects can move attribution.
Consequently 3.823% cannot be used to promise 3.823% gain or to prove a hard cap.
It does, however, fail to support the assertion that measured Map runtime is
dominated by removable frame transport.

The rejected Phase191 call-move experiment is an additional negative control:
removing 1071 snapshot sites and 7036 static RSP instructions yielded only about
0.56% geometric improvement and worsened Map. Do not infer a new runtime budget
from another large static transport count.

## Stronger witness after Phase192 staging removal

The new, separately identified development assembly is
`selfhost/build/phase192/dev-emit01/coverage-numeric-recurrence-256/program.s`,
SHA-256 `679ce086b50bbad11bb3f2b83485413798cf954ab900f524555abeadca15765d`.
Its report binds candidate-api05/source05; it is not the frozen Phase191 product
and has no transferred profile guarantee. In `$direct.p37.numeric`, these exact
adjacent pairs remain:

```
3254–3255  movd %xmm0,%edi ; movd %edi,%xmm2
3260–3261  movd %xmm0,%edi ; movd %edi,%xmm1
3274–3275  movd %xmm0,%edi ; movd %edi,%xmm0
```

They bridge F32 operations through the integer home even though the consumer
immediately wants the floating bits. The positive path has no frame access or
real call. Its 15 MOVD instructions include these six cross-domain transfers;
others implement constants, recurrence input, or conversion semantics and must
not all be classified as redundant. Removing the three pairs could require
same-bank copies depending on placement; six transfers removed does not imply
six instructions removed.

`float-registers.bend` explicitly excludes a name with **any noncanonical
definition**, globally. `x186_x_plain` records that exclusion for integer writes;
`x186_x_node` and `x186_x_homes` use the same region/name scan as the transient
allocator. Thus an unrelated integer definition or another region's independent
F32 definition can deny an otherwise closed floating value its XMM home. This
confirms root's mixed-use-temporary concern as a mechanism. The emitted assembly
proves the roundtrips, but no new typed-row dump was acquired here to attribute
each individual pair to the literal source spelling `value` rather than another
exclusion. The next diagnostic should emit per-definition rejection reasons.

A bounded next experiment should version values in the existing private float
plan, distinguish each write from the mutable name, and allocate closed canonical
F32 lifetimes independently. Resolve reads before rebinding an in-place write.
Keep the original word home at boundary consumers and publish the exact
zero-extended 64 word when required. Closed internal results can remain in XMM;
real calls, unresolved branch joins and Again remain conservative initially.
Do not add a general SSA/phi framework just to test these three pairs.

This is separate from the 32-candidate/256-statement GPR gate: XMM placement has 14
homes and its own scan under the existing 4096 float-function bound. Globally
renaming every IR write before GPR allocation could inflate candidate count,
trigger fallback, grow the frame and regress other paths. Prefer a private
per-definition XMM plan, or narrowly rename only proved closed float values and
record whether GPR admission changes. Fallback must be chosen before producing
an inconsistent partially rewritten plan.

Definition splitting alone still leaves the recurrence parameter in a GPR,
publishes the recurrence before the unrelated integer hash computation, and
reloads it for the later multiply and next iteration. Removing that complete
category requires keeping proven canonical float state live across unrelated
integer operations, followed by an explicit loop-entry/Again XMM contract.
Preserve full-word integer consumers, parallel backedge semantics, real-call
clobbers, arbitrary mixed-width rewrites, F32 rounding order and NaN behavior.
Those extensions have medium-to-high implementation risk and require independent
alias/cycle/branch/call controls. They are not a safe relaxation of a single
blocked-name test.

## Economic decision and falsifier

The final Phase191 numeric1024 profile assigns 64.488% to the recurrence and
35.373% to `p111_rt_op`; root's current conversion experiment targets the latter.
These shares cannot be reused as the post-conversion shares or as a MOVD cost
estimate. The mature C loop retains floating recurrence state in XMM, hoists
constants and unrolls by two. Its advantage is broader than the three pairs.
QBE likewise provides a reference for allocation, but Map's QBE counts above do
not establish a floating runtime gain.

**Recommend the closed-F32 definition-splitting experiment over a general Map
regional rewrite**, provided it is small and the post-conversion candidate wins
first. Its falsifier is exact: all three immediate roundtrips should disappear
without changing arithmetic order or introducing frame transfers; compare the
same conversion/staging candidate with splitting off/on. If they remain because
of genuine boundary uses, stop and diagnose instead of raising bounds. Only
measure broader XMM lifetime extension after obtaining that structural witness.

No evidence here supports promising >2% whole-suite gain from those pairs alone.
Only five of 44 eligible catalog cases are explicit F32 families. A 2% geometric
suite reduction requires about 16.3% average time reduction across all five, or
about 35.9% across the two numeric cases alone, assuming all others unchanged.
A 30% improvement across all five gives about 3.97%; halving them gives 7.57%.
These are coverage arithmetic, not predicted performance. More general GPR
per-definition splitting may expand coverage, but needs actual admission and
hot-use diagnostics first. It could remove false interference as an entire
work category; present Map data does not quantify that category well enough to
justify a broad implementation now.
