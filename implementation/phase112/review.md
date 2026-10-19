# Phase112 independent source review

This records the independent source review by `/root/p110_laws`, including the
final `fusion/modules02.json` composition. The reviewer read source, prepared
controls, and existing receipts, and checked file hashes. The reviewer ran no
Bend/compiler, generated-program, benchmark, or proof targets. No concrete
correctness defect remained in the reviewed source. This conclusion is scoped
to the predicates and runtime assumptions below; it is not a whole-compiler or
arbitrary-IR ownership proof.

The exact review anchors are below. Paths are relative to the repository root;
the linked inventories/receipts retain individual module hashes and, where
applicable, composed-source identities.

| Reviewed boundary | SHA-256 anchor |
| --- | --- |
| [Worker/failstop/wide32/early/fusion inventory](../../selfhost/tools/performance/phase112/workers/conjunction-modules02.json) | `d4fef0b6f02a616e7501e9b9921268b504ef19b6d17499499c98d236badf745f` |
| [Fusion modules02 inventory](../../selfhost/tools/performance/phase112/fusion/modules02.json) | `79d17efc8f17ce889549511f91c085417629775d32e993938c619accc1f77eef` |
| [Wide32 override](../../selfhost/tools/performance/phase112/workers/wide32-entry.bend) | `3b59171e9a5c829770ce286c7b6156f9a6b913cee14b279d131ea26ebc17a47b` |
| [Static source admission02](../../selfhost/build/phase112/static-admission02/report.json) | `2443ca0ff1ab82a54506a811a57160bd8f744ce656e44140e0073578d50e4367` |
| [Float source admission02](../../selfhost/build/phase112/float-admission02/report.json) | `653b93ea979523297ef8df2a7c1cdf8324b29c32a7259caef98252f3f2144b5d` |
| [Parameterized float emitter](../../selfhost/tools/performance/phase112/float/emit.bend) | `0b842701cbb315255945f420576457747613540b7a9aad14013549ecf8817ceb` |
| [Fusion conjunctive admission02](../../selfhost/build/phase112/fusion-admission02/manifest.json) | `911e70723173f2b65fca49973c56f75f8226e499f448de65c2f114efdadde6a7` |

The final conjunction and float admission bind `fusion-source02/compiler.bend`
SHA-256 `074f4abd8001c0f04ae9551a678bd8bcfb5377622306712251ca638da328927f`.
Static admission02 records the earlier `failstop-source01` composition; its
static module bytes still match the reviewed files. These receipts authenticate
source, not execution. The conjunction requires separate static/float receipts
on the same composed source before claiming their combined admission.

All runtime arguments here refer to CPU ABI11101, runtime04 source SHA-256
`c0fc18aabb2749cc85b5040c29756d8d73d90b73bb954d10ed1d0d410528aa50`, object
`560bbec83395b6a4b2be247e14b362fc1e803ee0a86c680f3797d895ed67c23e`, and header
`fa91b9a250ce735aaaa59e5515efebd42b9544da825841021887406193c1d5c1`.
The unchanged N111 verifier hash is
`c2131760ea5e064394368101c12e59ae79142be453da297822ed6904dd3c51c0`.

- **Workers and failstop.** Exact preludes, complete terminal suffixes, and
  ordered scratch stores delimit the rewrite. Self-loop operands are all
  snapshotted before parameter rebinding. Non-self private calls use three
  immutable admission passes; public return conversion retains `rt_return`
  and its pending-frame work. Returning private paths cannot inspect or change
  the transport register bank, `rn`, `next`, or continuation stack. The initial
  symbol-only helper check admitted state as a secondary buffer; this concrete
  gap was fixed by requiring every secondary pointer to be exactly scratch.
  Complete failure suffixes may retain frames only under the pinned CPU
  `err_post -> err_fail -> _exit(1)` implementation. Their raw Reply return is
  unreachable; the DEVICE behavior is outside this profile. Exact declaration
  admission, including the final emission hook, replaced weaker substring
  checks.
- **Wide32.** The optional override changes only the private arity limit from
  eight to 32. Result width remains one, incoming continuation count zero,
  flags zero, and the three-pass dependency bound is unchanged. Fusion remains
  limited to eight arguments independently. Prepared 9/16/26/32-argument
  fixtures use two permutations and read back every boxed tuple field; their
  descriptor offsets and constructor ID match the fixture catalogue. The
  33-argument case refuses private admission. These immediate-word fixtures
  address positional ABI transport; owning aliases have separate controls.
- **Static image.** Admission is closed-only, with canonical immediate words
  or previously validated immutable children, a 65,536-word cap, contiguous
  layout, and no forward references or cycles. Unsupported/budget-exceeding
  parents fall back while valid static children remain usable. Shallow markers
  survive the intended lowering path, and the descriptor updates the original
  static-size/image slots. Runtime04 treats the image as immortal and excludes
  static shells from physical freeing. This is a review of the typed producer
  and its image checks, not certification of arbitrary forged raw pointers or
  a mutated constructor catalogue supplied outside that producer.
- **Float expansion.** IDs 23 and 26–35 load the same full64 operand words,
  discard upper32 bits, compute binary32 arithmetic/comparisons or unsigned
  conversion, and zero-extend the result. Both binary operands are read before
  assigning the destination. The shared temporary counter reserves all nine
  possible names. A verified local buffer, including a fusion-renamed buffer,
  is preserved; the first state argument remains exact. Even state-as-buffer
  performs the same pure reads under the original capacity gate. Unsupported
  shapes use the original accessor fallback. QBE's NaN comparison handling
  matches the selected C operations. Arithmetic NaN controls check class and
  zero upper bits, **not exact generated NaN payloads**; no broader IEEE
  payload, floating-environment, or cross-platform equivalence is claimed.
- **Continuation fusion.** Capture snapshots precede the frame-result zero
  assignment; argument snapshots follow it. Inlined pop-result zero, capture
  bindings, and result binding preserve prefix order. Removing the temporary
  frame/jump/return/pop restores the same live stack pointer at continuation
  entry and retains outer frames. Transport registers, `rn`, and `next` may
  differ temporarily, but admitted private bodies/copied suffixes cannot
  observe them, and returning terminal transfers refresh them. Each site has
  separate scratch and a reserved namespace; all continuation locals are
  renamed. Private eligibility, target discovery, and private bodies use the
  original graph, so fusion creates no new private dependency or recursive
  machine-call cycle. The existing CPU-only failstop restriction still applies.

Existing root-executed evidence is distinct from this review. The complete
[direct-worker jobs](../../selfhost/build/phase112/direct-controls-jobs01/report.json)
record 15 planner controls, eight buffer controls, and four baseline/candidate
native fixtures with expected output. The complete
[failstop jobs](../../selfhost/build/phase112/failstop-controls-jobs01/report.json)
record eight failstop controls, four owning-loop fixture pairs, and three
baseline/candidate status/stdout/stderr observations: success returns `7`, and
the two reachable failures exit 1 with their exact diagnostics. The
[static controls](../../selfhost/build/phase112/static-controls02/report.json)
record 20 passing helper outcomes; earlier
[static jobs](../../selfhost/build/phase112/static-controls-jobs01/report.json)
also built and checked the semantics fixture's expected output. The
[early-refusal comparison](../../selfhost/build/phase112/early-controls01/report.json)
records 18 checked-API comparisons of admission, valid plans, and emission;
it explicitly does not run generated fixture executables.

At this review snapshot, wide32, float, and fusion native qualification is not
inferred from preparation or source-admission receipts. The prepared float set
contains 21 structural controls and 104 observations (100 eligible expansions,
four fallbacks). Fusion prepares six paired witnesses, 18 planner controls,
and 222 lookup plus six additional index controls. The earlier
`fusion-check-jobs01` receipt is incomplete and records a source-check failure;
modules02 corrects its match order, but that correction is not itself a passing
target result. Later coordinator receipts must establish any further execution
claims. None of these finite controls proves arbitrary input ownership or
whole-program semantic equivalence.
