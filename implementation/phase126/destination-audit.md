# Private destinations versus persistent typed regions

Offline audit of the Phase125 qualified frontier, started from `3c94d98` while
the parent prepared Phase126. No compiler, generated target, build or profile was
run. This document proposes a bounded alternative; it does not implement it.

## The endpoint exists, but its ownership certificate does not cross the call

The selected producer already knows both values that append later rediscovers:

- [trmc-v4.bend:10](../../selfhost/tools/performance/phase118/trmc-v4.bend#L10)
  carries `p118_root` and `p118_parent` through every self backedge. `root` owns
  the unpublished chain; `parent` is a borrowed raw cursor protected by that root.
- [p118t_extend:83](../../selfhost/tools/performance/phase118/trmc-v4.bend#L83)
  allocates each new node and installs it as the next parent. It does not scan
  for an endpoint. The prefix/recursive arguments retain their original sequence
  through [ntr_sequence:59](../../selfhost/tools/performance/phase102/fusion/trmc_helpers-v2.bend#L59).
- [p118t_finish:38](../../selfhost/tools/performance/phase118/trmc-v4.bend#L38)
  fills the final destination, returns one owning Term, and discards `parent`.
  The public wrapper at line 123 preserves the original one-result interface.
- [Phase125 typed append:15](../../selfhost/tools/performance/phase125/producer/runtime-concat-typed.c#L15)
  subsequently traverses the entire prefix, checks raw/RFC uniqueness and dynamic
  locations, and rediscovers that final cell before attaching the suffix.

This is a lost interface fact, not a missing pointer computation. However,
**existing TRMC admission alone does not prove a fresh complete list**: it also
allows other constructor layouts and arbitrary terminal results, including an
existing suffix. A capability-carrying clone needs the stricter closed list type,
exact Empty terminal, and fresh Link-only spine. Reuse the actual append owner
certificate in [model-v3.bend:22–54](../../selfhost/tools/performance/phase125/producer/model-v3.bend#L22),
then independently prove the producer's terminal and constructor behavior.

The ordinary RLE path is especially concrete. In the retained
[ready QBE](../../selfhost/tools/performance/phase124/ready-call/evidence/rle01/ready.ssa#L99),
`expand` calls `lrepeat`, captures its completed result at lines 180–183, descends
to expand the suffix, then restores that prefix at lines 200–208 and calls
`lconcat`. The recorded [private producer](../../selfhost/tools/performance/phase124/ready-call/evidence/rle01/private-helpers.ssa#L89)
has the root/parent formals and final finish. Phase125 replaces concat's repeated
construction with the scan; it does not carry the producer's endpoint.

## Smallest general experiment: complete value plus private endpoint

Start with a completed-list certificate, before exposing open holes across calls:

```text
private producer(args, out_endpoint) -> owned complete List
    same producer, same prefix evaluation, same finish-to-Empty
    out_endpoint := borrowed raw final node, or zero for the proved Empty result

local resume capture: [owned complete root, borrowed endpoint, original captures]

private attach(root, endpoint, suffix) -> owned complete List
    zero endpoint: return suffix under the proved Empty case
    nonzero endpoint: replace that node's proved Empty tail once
```

The internal endpoint must be tied to this exact root and single consumer. It is
not a second owning Term and must never receive `keep`, `drop`, sealing, source
projection or generic publication. The new producer clone keeps its public
one-Term wrapper and remains an acyclic private helper with self-tail loops.
Original programs, generic continuations and fallback paths stay available.

For RLE's explicit recursive owner, the minimum *data* addition is one raw
machine-word capture alongside the existing owning-prefix capture. A private
out-slot can transport the endpoint from the producer; load it before scratch
reuse, then copy its value into the exact local resume frame. Never store a
pointer to that mutable out-slot across descent: deeper calls would overwrite it.
The continuation's derived push/pop counts and capture restoration must change
together. Source/general FIDs and their original arities must not be redefined.

The existing physical frame is raw-word transport: `p111_rt_frame` copies words,
and stack pop/get do not retain or release them. That makes one borrowed field
possible, but it does **not** make it already verified. The current
[P124Callable admission:33](../../selfhost/tools/performance/phase124/ready-call/model.bend#L33)
requires one public owning result, and
[P114RResumeReady emission:171](../../selfhost/tools/performance/phase124/ready-call/model.bend#L171)
routes only that result through the old unwind. A separate private capability
descriptor and exact derived-frame adapter are necessary. Do not weaken result
width checks globally or manufacture a source product to hide the borrowed word.

Admission should require the producer result's only use before append to be
transport through that recognized private frame. Reject a duplicate/keep,
escaping result, capture by a source closure, shared tail, unknown observer or
unclosed effectful call. Payload aliases remain legal: fresh spine ownership does
not imply unique String/record heads. The suffix may share those heads, but must
not alias the fresh prefix itself. Preserve producer → suffix → attachment order,
same parent-CID hot/cold sealing policy, original complete error behavior, and
the existing explicit owner stack. Restrict the first test to pure closed calls.

Expected removed work is the append scan and its per-cell ownership checks.
Constructor/take counts should stay at Phase125's reduced level; finish-to-Empty
still executes. One extra frame word and an out-slot may cost more than scanning
RLE's short 3/1/2 prefixes. That is the intended falsification, not a reason to
relax the proof. Compare the varying-value 256-cell map/append transfer as well.

## Open-hole carry is a second experiment, not a free extension

Returning `(owned incomplete root, borrowed parent)` without `finish(Empty)`
could additionally avoid closing then replacing the last tail. The caller would
evaluate the suffix first and call the existing finish exactly once afterward.
This preserves source operand order but introduces a value that ordinary source
code, generic destruction and continuation interpretation may not observe.

It therefore requires a distinct linear private capability, definite completion
on every admitted path, protected root lifetime, and exact behavior across error
and fallback edges. Do not treat an incomplete root as an ordinary owned List.
The selected runtime's `TERM_HOLE`, dynamic raw-parent and constructor checks
remain relevant; the old unselected destination-slot cursor is not a prerequisite.
Phase118 already found that cursor representation neutral/mixed on list, lexer
and map. Carrying its lifetime across composition is the genuinely new capability.

## Priority relative to typed F32

The final [Phase125 results](../phase125/results.json) show RLE at 1137 ms versus
208 ms upstream: 929/17531 ms, or **5.30% of positive corpus excess**. The three
ray cases contribute 4664/17531 ms, **26.60%**. These are shares of this frozen
batch diagnostic, not attainable whole-program speedups. One extra map/append
fixture establishes transfer, but is outside that score. No evidence yet says
the endpoint rule reaches tree sort, map updates, lexer core or compiler hotspots.
The compiler's reverse/reverse `nt_append` is not this structural append equation.

The numeric path has a wider measured deficit and a concrete representation loss:
[Phase122 numeric audit:29–45](../phase122/numeric-audit.md#L29) records integer
private signatures, repeated F32 casts and backedges, and the larger/spill-heavier
untyped inlining attempt. A typed ABI alone, then typed loop state, is a better
main experiment than implementing both destination variants simultaneously.
Destination carry remains a bounded follow-up if the typed route stalls or if
its necessary capability plumbing is already being added for another measured use.

## Independent semantic witnesses supplied

[Controls](../../selfhost/tools/performance/phase126/typed/controls/README.md) and
[cases.json](../../selfhost/tools/performance/phase126/typed/controls/cases.json)
pin two ordinary sources with thirty complete output lines. The author ran only
the host oracle generator; checked admission and target execution remain pending.

- Exact native F32 bit transport: zero signs, infinity signs, quiet-NaN payloads,
  least subnormal, and a U32 with the same raw carrier as F32 one.
- Binary32 rounding and non-fused multiply/subtract counterexamples, retained
  aliases and rebinding; ordered `first`/`second` IO prevents effect reordering.
- Parallel mixed F32/U32 backedges at depths 0, 1, 2, 17 and 4096, with independent
  closed-form coordinates and modular-exponentiation stamp oracles.
- A retained `Parcel{U32,F32,String,F32}` alias across helper calls/deep updates,
  printing both the complete result and complete original record. Narrow refusal
  is acceptable; silently treating heap fields as numeric lanes is not.

These witnesses supplement existing identity, unsupported-call and namespace
controls. Passing them does not prove either new region admission or complete
compiler correctness; inspect which companions actually execute before attributing
a result to the new transformation.
