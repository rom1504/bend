# Fixed product shells, source candidate v1

Registered prospectively as [P68-007](../../../../../../experiments/phase68/P68-007-flat-products.md).
The original registration was committed in `ee726e4` before implementation.
This directory contains source only. No compiler, C compiler, or target was run
by the product lane. Root owns the checked build and all execution.

Apply the relative [candidate.patch](candidate.patch) only against the exact
`baseSha256` values in [manifest.json](manifest.json). The source-only patch check
and live/candidate hash check passed at handoff. `baseline/` preserves the
original worker-v3 files; `integration-baseline/` is the later root source with
short-circuit worker admission and occurrence-summary-v1. The candidate retains
`nc_prepare_env` and `nc_lower_partition` unchanged except the separate NC_Code
call metadata extension where applicable. The patch adds 413 net lines.

`build-proposal.py` deterministically composes candidate copies from the frozen
integration baseline, `product-source.bend`, and the frozen admission helpers.
It performs no compiler/target execution. `product-source.bend` is a composition
template: the script supplies the fifth `NC_Code.calls` field. Compile the
candidate files, not that template. `product-layout.bend` is owned/reviewed by
the native/correctness lanes; its SHA-256 is
`b47d4c1f22dbff4ad4a206dbad21c94495dd012e715be6fbc74b9cd01eddf99f`.

The ordinary `NF_` worker family retains boxed inputs and one-word results.
Private `$product.` worker variants can accept/return vectors of opaque Term
fields. Calls select a variant only when every product argument is an actual
matching virtual bundle. An arbitrary typed boxed argument is never unpacked
by the new calling adapter. Constructor identity and exact live count must
match a descriptor established from a source type before erasure. Array storage
and each product field retain the existing one-word ABI.

Source-level parameter/let substitution carries already evaluated fields in
`NQBundle` nodes over the ordinary scalar ownership environment. Supported
matcher success consumes those fields directly. Shared sequential uses, unknown
calls, opaque fields/stores, and unsupported match shapes materialize the
existing constructor. The ordinary scheduler rejects the new internal nodes.
All generated error checkpoints, polling, self-tail parameter staging, and
status-return behavior remain in place.

There are two separately reviewable implementation costs: private variants can
duplicate body text, and `NC_Code` now records the exact emitted worker-call
graph. Readiness uses those calls, not the source definition's reference list.
This makes a boxed-to-product transition visible and rejects unsupported
variant cycles. Self-tail calls remain local gotos. Scheduler effect metadata
continues to use its existing source facts.

The intended structural witness is a constructor/primitive result entering a
private consumer or loop without a Tuple allocation/take at that boundary. In
the array state loop this requires both getter-result and recurrence-state
bundles; a result seam that simply repacks before every call is insufficient.
Do not count whole-program constructor strings: boxed scheduler/device fallback
and ordinary worker code remain present. Inspect the admitted active worker
graph and use the parent's operation-counter/runtime plan.

Independent controls from the correctness lane include the ordinary record
producer/consumer with weighted output `1131`, owned Array result transport,
shared aggregate materialization, callback escape, and an unused malformed
boxed product whose original raw program returns `7n`. Keep the existing raw
precedence, bang, primitive override, arity, and foreign controls unchanged.
The latest ordinary-record fixture still needs the parent's frontend smoke.

Source checks performed: relative patch applicability; exact live/candidate
hashes; lexical delimiter balance; references to backend helper names;
whitespace; and source review of query, fresh IDs, ownership boundaries, and
selected-call metadata. These are not a checked Bend build. No performance,
code-size improvement, or parity result is claimed.
