# P47-002: bounded private calls followed by value cleanup

Date: 2026-10-04. Pre-build status: unchecked, unmeasured, investigate.
Owner: IR implementation agent; separate controls and review agents; root builds
and measures. [Design](../../design/phase47/research-guided-optimization.md).

Select the existing typed JW worker as the first shared-facts consumer. It has
explicit evaluated slots, calls, constructor layouts and branch scopes, but its
current simplifier only removes unconditional tuple/Char cases. RLE already has
workers; Map and record profiles retain allocation. This offers a general place
to test the Rust/LLVM pattern of exposing a small helper body and then removing
the now-visible temporary aggregate. It does not address unsupported higher-order
or Array graphs by itself, and V8 may already perform the same cleanup.

Bounded scope: small linear Assign/Return helpers, stable evaluated arguments,
fresh slot renaming, immutable local copy/constructor facts, exact tuple/tagged
projection forwarding, and removal only of a proven unused private allocation
shell. Keep all field computations and their order, original graph dependencies,
public guards, function indices and fallback behavior. Unknown calls and host
operations confer no discard/move permission. Branch facts never flow into a
sibling or join. Limit expansion and fact retention; record source and output
growth and compiler request cost.

Falsification: semantic disagreement, unbounded/code-growth cost, material
canary regression, or no useful gain after the causal opportunity is confirmed.
Run independent renamed fixtures and host-boundary controls before affected
family timing; five maintained canaries precede broader screens. Promote only
after integration gates. Results and failed attempts belong in Phase47's report.

## Outcome: defer; preserve the experiment

Worker01 failed parsing because computed `match` scrutinees are unsupported.
That attempt remains preserved. Worker02 corrected the syntax without changing
the transformation, passed checked compilation, 18 independent IR controls,
72 source oracles, 11 public/error boundary controls and the five canaries.
These are scoped controls, not full conformance or release qualification.

The three-round short screen found Map 128 improving from 1.441868ms to 1.386127ms
(1.04021× baseline/candidate) and records 256 from 1.971195ms to 1.933893ms
(1.01929×). Within-sample drift exceeds these proposed gains; there was no
longer confirmation. RLE, bitonic, expression and closure-chain emitted modules
are exactly unchanged. Compiler cost was not measured in a controlled comparison.

Complete generated-assignment analysis explains the modest outcome: only the
two `bench` assignments change. The pass removes 9 static private call sites
in Map and 16 in records, primarily by copying `Map.lo`/`Map.hi` into callers.
The original helper declarations remain, as do the corresponding persistent
nodes and transported result pairs. No affected corpus aggregate shell is
shown eliminated. Emitted bytes increase 450 and 920 respectively. Synthetic
projection cleanup activates, but receives no corpus speed credit.

**Decision: do not promote the 405-line pass.** Its module and integration are
removed from maintained source. The full independent
[worker-cleanup.patch](patches/worker-cleanup.patch) preserves the experiment
(SHA256 `6107b3ac3642dad134c29126b594ffe2395bb04e66755f7ee96defdf9dcde1fe`);
`selfhost/build/phase47/source-worker02/` retains the full checked raw source.
The source module hash is
`80f3639c8f8aa13d3ae0a85fa97115887e82821cef0995f94143678de5f3f12d`.

See the [outcome report](../../implementation/phase47/worker-outcome.md) for
exact receipts, module identities, generated-code deltas and smaller possible
consumers. The [fact-contract proposal](../../implementation/phase47/shared-facts-proposal.md)
and independent controls remain reusable evidence. Future consideration needs
a consumer with demonstrated allocation/dispatch benefit; infrastructure value
alone is not a measured optimization result. No replacement pass is implemented.
