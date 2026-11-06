# Phase172 cold-constructor inline template: independent source audit

**Follow-up:** the complete compiler's all-hot metadata gives the first template
zero static coverage. The independently reviewed sealed-field variant below
removes that prerequisite. Preserve the initial audit as negative evidence.

Read-only review by the bounded bendc investigator, 2026-11-06. No compiler,
runtime, benchmark or malformed-state target ran as part of this audit.

Reviewed:

- `selfhost/tests/phase172/inline-runtime.bend`, SHA256
  `fd6ba8460dc33a2323151b309984e619d1c7d5d192b33c6091ec09f4fd31035a`.
- `selfhost/tests/phase172/inline-runtime-override.bend`, SHA256
  `05f4da89aa6f1793a5abc553ffd261d7e87f84fe99ca049aba2f19535cd928af`.
- Selected `runtime.c`, SHA256
  `aa95d2c0426c05bcc4d34244dd8b22b79ebcaf6d30634569201961f60b57f333`;
  `runtime.h`, SHA256
  `9b19b8d6ae1c8f07759041201c2692c20d9612393819e2bbc597deba44679d12`.

## Conclusion and scope

No semantic blocker found for the stated contract: a previously verified
ordinary constructor operation emitted into a standalone executable using the
pinned sequential host runtime. This is a source-equivalence argument, not a
BendTT proof or execution qualification. Source checking, generated-code
checking, valid-state differential controls and performance measurements remain
separate gates owned by the main experiment.

The experiment inlines only cold constructors of arity 1–4 on a nonempty
allocator free list. It does not inline take, shared-reference handling, refill,
reclamation, or failure paths. It does not change runtime source or the
independent final IR verifier.

## Why the admitted arm has the same state transition

Let `c = ceil(log2(arity))`, `s = 1 << c`, and let the old nonzero class head be
`h`, with `H[h] = next` and class credit `length`. The original `heap_alloc` warm
arm performs exactly:

1. `alc[c] = next`.
2. `alc[32 + c] = length - s`.
3. Return location `h`.

The cold publication arm of `p125_rt_ctorN` then copies `fields[i]` to `H[h+i]`
in increasing order and returns `(2 << 56) | (cid << 40) | h`. The experimental
arm emits these same operations in the same order. Its class mapping is exact:
arity 1 uses class 0; arity 2 class 1; arity 3 or 4 class 2. The unused fourth
word of an arity-3 allocation remains untouched, as in the runtime.

The source buffer is an authenticated local allocation. The final verifier's
buffer-capacity check derives nonzero capacity from allocation declarations;
ordinary pointer assignment does not manufacture capacity. The additional
`p114t_buffer` restriction admits only existing ordinary/fusion scratch
factories. It therefore does not introduce a source/destination alias that
could invalidate the ordered field loads and stores.

There is no allocation refill, native recursion, stack-pointer update, counter
wrap policy change, reference-count operation, child sealing, reclamation or
error emission in this successful arm. All such behavior, where applicable,
remains in the original helper fallback. In particular, cold publication is
allowed only when capability bit 8 is enabled; hot constructors still seal
their fields through the original runtime.

## Authentication and fallback

`p172ir_admit` requires the exact original `p111_rt_ctor` signature, state local
`state`, an authenticated buffer, a literal zero-high-word count in 1–4, and a
literal constructor identity. `p172ir_cold` additionally requires:

- Exact `N111Id` metadata kind.
- Numeric constructor ID below 65536 and exact matching live arity.
- `du(entry) == True` as a new metadata-presence marker.
- `db(entry) == False` as the copied constructor hot flag.

The presence marker is useful: legacy `False/False` metadata cannot silently
claim the constructor is cold. Both flags are otherwise unused by the existing
`N111Id` emitter consumers. The same ordered `N_Constructor` list produces the
numeric IDs and runtime hot/arity tables. This metadata does not enter the
checker Book or alter its interpretation of native/unsafe definitions.

The runtime guard reads only immutable descriptor data, state pointers and the
allocator head. It reads `H[head]` only after proving the head nonzero. On a
disabled capability or empty pool, it performs no mutation before invoking the
existing rendering chain. That chain retains the original helper selection;
it bypasses the new matcher and cannot recursively expand its own fallback.

## ABI and identity obligations

The template depends on `P111State.e.mem` at byte 0, `.alc` at byte 8,
`P111Program.capabilities` at byte 88, `NCLS_ALL=32`, host `LANE_STEP=1`, and
64-bit word locations. These match the pinned runtime and existing ABI static
assertions. The emitted `33554432` high word equals `2 << 56`; shifting the
authenticated 16-bit constructor ID by 40 reproduces `term_ctr` metadata.

The generated entry point passes `$p111_program` to `p111_rt_main`.
`p111_bind` validates it, enforces one program per process, and sets
`p111_program_active` to that pointer. The emitted descriptor load therefore
matches the runtime helper's active descriptor in this standalone pipeline.
Do not extend this conclusion to an embedding that runs the same emitted
segments with a different descriptor.

The selected runtime rejects `threads != 1` or GPU execution. An atomic,
parallel, device, differently laid-out or independently replaced provider must
not inherit this template without a new review.

`p114t_` is an independently checked reserved local namespace. Each constructor
template advances the emitter's site/label counter before allocating its three
branch/join labels. The successful arm contains no recursively expanding calls.
The bounded site check leaves enough room for these increments.

## Controls and measurement obligations

Recommended existing-harness controls are valid constructors of all four
arities, cold and hot metadata, capability-enabled and capability-disabled
rendering, retained live children, warm-pool and genuine refill paths, and
multiple/nested expansions checking namespace/join behavior. Compare complete
values and independent expected outputs, not only a scalar shortcut. Structural
refusal controls should cover legacy/missing metadata, wrong arity, wrong
signature and unauthenticated buffer names without executing malformed heaps.

Any allocator/constructor counter inserted solely in runtime C helper bodies
will miss inlined fast operations. Physical sampling is still meaningful, but
logical operation counts need explicit inline coverage or must be labelled
incomplete. Fewer helper calls do not mean fewer logical allocations.

Larger emitted bodies can increase QBE machine-build time, code size and
instruction-cache pressure. A runtime win alone does not establish a cold-build
win. Require transfer from the frozen complete lookup consumer to the real
verifier before acquiring another full compiler image.

## Separate take-path warning

An earlier suggested take-inline bound used 256 as the host hand-off threshold.
The actual `corpus_setup` sets host `KEEP_WORDS=CAP_WORDS=32768`; 256 is the
device chunk size. A conservative `old_length + class_size < 256` bound would
still be safe but incomplete. Merely `old_length < threshold` is insufficient.
This issue does not affect the reviewed constructor-only implementation, which
neither frees nor hands off a pool.

## Sealed-field variant

Reviewed subsequently:

- `inline-runtime-sealed.bend`, SHA256
  `68ad5bb80200ab57c0d23658956e517dea35cb3a9728d9eb32dea3fc591d197b`.
- `inline-runtime-sealed-override.bend`, SHA256
  `da57df160f6d9ae45c07410531bb4fc22b42bc04573c3263a44ac0f7c86e87f4`.

After source-check feedback, only the two emitter declarations changed to
bare-name law fills; their bodies and behavior are unchanged. Refreshed hashes:
`inline-runtime.bend` is
`5d2d7cf7b162ad9414ff3a35bef85e64ea88275364dda8696285001133054ad8`, and
`inline-runtime-sealed.bend` is
`01499ccaae33ef1da09810430edc323accdd78c7cfa5117c00b4c7597698350d`.
The override hashes above remain current. Earlier hashes identify the reviewed
pre-source-check declarations, not the current files.

This variant overrides only `p111q_stmt`. Constructor metadata, its identities,
hot flags, the descriptor and all capability flags remain unchanged. It reuses
the initial template's class/word calculation, branch join and fallback renderer.

For every 64-bit Term `t`, the pinned `rfc_seal` returns `t` unchanged when
`term_tag(t) != TAG_CTR || term_rfc(t)`. Since the tag is bits 56–62 and RFC is
bit 63, this is exactly `(t >> 56) != 2`. An RFC constructor's upper byte is
130, so it passes. An ordinary unsealed constructor's upper byte is 2, so it
falls back. This equation applies regardless of the enclosing constructor's
hot flag or capability bit 8. Rejecting a raw child of a cold constructor is a
conservative missed opportunity, not an incorrect transformation.

The variant snapshots each authenticated local field once, combines these
identity predicates, and checks the free-list head. It mutates nothing until
all predicates pass. The successful arm copies the cached values after exactly
the allocator pop described above. The fallback receives the original state,
original scratch buffer and original operation.

Moving those local reads before allocation is valid under the checked buffer
and single-mutator premises: the reads are valid, nonfaulting and disjoint from
allocator/heap writes. They have no observable effects. The ordinary warm path
does not mutate scratch, and no caller or helper executes concurrently. Even
when refill would fail in the fallback, these additional valid reads do not
change that failure. They must not be generalized to arbitrary foreign pointers
or heap aliases using only a name comparison.

No source-level semantic blocker found. This variant no longer needs the
descriptor-identity/cold-metadata proof for its guard, although the ordinary
generated program still depends on the unchanged standalone runtime contract.
The previously stated namespace, layout, allocator, qualification and operation
counter caveats remain. Runtime wins are unmeasured in this audit; extra field
guards and code growth can make a semantically correct transformation slower.
