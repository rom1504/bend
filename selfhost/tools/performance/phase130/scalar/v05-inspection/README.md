# Why the first scalar source ceiling did not improve

The coordinator measured the checked v05 pair at prefix64/repeats16384 and
reported median133ms baseline versus149ms scalar (approximately12% slower).
The immutable timing report is
`selfhost/build/phase130/scalar-timing01/report.json`. Its original timer-unit
label was incorrect; the coordinator is preserving that receipt and correcting
the derived interpretation. This note uses the reported milliseconds and ratio,
not that label. The implementation agent ran no benchmark or profiler.

**The proposed explanation that Cmp prevents borrowed admission is false.**
The actual candidate contains a private borrowed `p130s_order_go` reader, a
scalar guard/owning fallback and a hot digest call into that adapter. The
observation type Cmp was admitted. Source-only artifact inspection is reproducible
with `../inspect-v05.py`; `summary-v02.json` pins the exact QBE and ELF inputs.

The rewrite changed more than result transport:

- Existing `String.cmp` reader:245 SSA body lines and227 machine instructions.
  Candidate scalar Cmp reader:299 SSA lines and265 machine instructions. These
  are static totals including cold failures, not dynamic instruction counts.
- Both readers execute generic `p111_rt_op` opcode22 (`U32.cmp`) on their
  common-prefix loop path. Scalar source did not remove this per-character call.
- The scalar rewrite carries the previous Cmp through a third loop lane and
  tests it after entering/matching the next string nodes. The existing comparison
  decides whether to recurse immediately after comparing current characters.
- The existing product observer returns its original roots through its adapter.
  The new consuming scalar adapter adds a shared-root guard and final sinks.
  Aliased roots or unique ownership can select its newly written owning
  traversal. This fallback differs from the original product-producing code.
- The hot scalar digest bypasses the thin `p130s_query` wrapper and calls
  `$direct.p130s_order_go` directly. It still reaches the guarded observer, so
  this is not the old Phase128 complete observer bypass failure.

These observations explain why v05 is not a clean measurement of deleting only
the existing reader's two product shells. They identify credible costs, but do
not causally apportion the12% regression without an ablation or dynamic profile.
Do not turn static call counts into a runtime percentage.

The next source discriminator returns U32 codes directly and uses primitive
unsigned equality/less-than predicates, avoiding Cmp transport in its loop.
Its paired baseline also returns U32, preserving the same external workload.
The corpus, exact code vector, Unicode boundary and ownership controls remain.

If that discriminator succeeds, a narrower general compiler opportunity is to
inline authenticated `U32.cmp` into the existing reader, preserving its loop and
fallback rather than rewriting String ordering. The runtime operation truncates
both operands to32 bits and returns a packed nullary LT/EQ/GT constructor. A
candidate needs exact request-bound constructor identities, arities and original
fallback; neither arbitrary full-word comparison nor assumed global IDs is
equivalent. This remains a proposal, not an implemented improvement.

The earlier `machine-summary.json` was an exploratory extraction that counted
objdump continuation rows and missed the `callq` mnemonic. It is retained as
negative tooling evidence. Use `summary-v02.json`, which fixes both issues.
Readable `.ssa` files decode symbol names for inspection and are not build inputs.
