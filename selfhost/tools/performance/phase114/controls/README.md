# Phase114 ordinary positive controls

These controls use ordinary Bend sources, complete expected outputs and the
existing checked frontend, build and observation tools. Root owns execution.
The control author runs no compiler API or target program. No malformed memory,
ABI inputs or custom native failure experiments are part of this directory.

`manifest02.json` is the nine-source core gate: six unchanged qualified Phase113
fixtures plus three new sources. `manifest03.json` additionally includes ordinary
String append and recursive fallback fixtures. New fixtures require frontend
preflight before backend qualification. The initial preflight accepted
`two-owned-fields` and `same-names-other-layout`; `nested-owned-fields` v1 failed
because its affine List field was placed in a duplicable Data record. V2 uses
`List<&2,String>`; the old source, manifest and failed receipt remain unchanged.

The core sources cover unique-shaped and shared two-field constructors, literal
roots, retained String aliases, nested List/String ownership, partial projection
and drops, field permutation, ordinary loops, escaping captures and non-tail
fallback. Static/unique/shared fastpath admission is a separate code-shape
observation; the source spelling alone does not establish a physical path.

Root first runs:

```
BUN frontend-preflight.mjs CHECKED_API manifest02.json FRESH_PHASE114_OUT
```

For exact complete-output execution, `prepare-jobs-v2.py` accepts `--api`,
`--runtime`, `--prefix` beneath `selfhost/build/phase111`, `--out`, optional
`--manifest` (default02), and `--names` or `--all`. Its default pipeline is array.
It prepares existing staged emission, build and observation jobs without running
them. The Phase111 output namespace is required by those established tools.

`session-sequence.mjs BASELINE_API CANDIDATE_API MANIFEST FRESH_PHASE114_OUT`
compiles A/B/A/C/A within each API using one immutable prepared Base seed. A and
B reuse Packet/Pair/consume names while changing constructor and function
arities. C has a different constructor catalogue. Every request uses the normal
checked frontend and final verifier. All repeated/reference/candidate QBE hashes
and catalogue entries must agree for the same source. Use an isolated
verification-reuse candidate for this gate; code generation changes intentionally
change QBE and must not be interpreted as a session-reuse discrepancy.

The two recursive additions exercise String.append on empty, literal, allocated,
Unicode and shared suffixes, a 257-character prefix, ordinary two-child recursion,
a recursive result in the first constructor field and post-call projection.
Unsupported specialization remains a successful ordinary fallback, not a source
rejection. Their literal oracles are independent of compiler output.
