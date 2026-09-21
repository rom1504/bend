# Compatibility matrix

This is a measured **unchecked-prototype** baseline, not a claim that the
full compiler has been ported. The corpus contains **1378 tests** across
**24 namespaces**: 919 positive and
459 with an `Error:` expectation. All files were inventoried; no test
was removed to improve the result. A test in the `check` or `proof` namespace
can fail during parsing, so namespace membership alone proves no checker rule.

Pinned upstream: `6018e28ecc67cf1fffc0c20c64b11023474c2df8`.
Run: 2026-09-20T21:11:28.154Z–2026-09-20T21:12:56.035Z; v24.19.0 on
linux/x64; 8 workers;
5000 ms per isolated probe. Full-suite verdict:
**incomplete**.

## Measured lanes

| Lane | Pass | Fail | Timeout | Unsupported | Hardware-gated | Observation only |
|---|---:|---:|---:|---:|---:|---:|
| parse | 829 | 90 | 0 | 0 | 0 | 459 |
| check | 0 | 0 | 0 | 1378 | 0 | 0 |
| interpreter | 0 | 0 | 0 | 900 | 0 | 0 |
| js | 498 | 236 | 1 | 0 | 0 | 0 |
| native | 0 | 0 | 0 | 719 | 0 | 0 |
| metal | 0 | 0 | 0 | 0 | 14 | 0 |
| cuda | 0 | 0 | 0 | 0 | 14 | 0 |

Parse passes cover positive syntax only. Negative parse observations are excluded
from pass counts. There are **0 demonstrated
checker rejections**. The **498 unchecked JS
execution passes** establish exact output for those programs, not type/proof
soundness, and do not satisfy their missing checker/interpreter/native lanes.
GPU syntax executed sequentially in JavaScript is not GPU coverage.

## Every namespace

| Namespace | Total | Positive | Error expectation | Positive parse pass | JS eligible | JS pass | JS nonpass |
|---|---:|---:|---:|---:|---:|---:|---:|
| base | 27 | 23 | 4 | 23 | 23 | 23 | 0 |
| check | 221 | 75 | 146 | 67 | 65 | 52 | 13 |
| compile | 105 | 95 | 10 | 95 | 95 | 95 | 0 |
| comptime | 50 | 28 | 22 | 27 | 28 | 26 | 2 |
| cost | 5 | 4 | 1 | 4 | 4 | 4 | 0 |
| eval | 39 | 35 | 4 | 32 | 34 | 14 | 20 |
| flatten | 240 | 186 | 54 | 186 | 57 | 11 | 46 |
| gfx | 4 | 4 | 0 | 4 | 4 | 2 | 2 |
| grade | 17 | 2 | 15 | 2 | 1 | 1 | 0 |
| halt | 35 | 9 | 26 | 9 | 9 | 9 | 0 |
| import | 28 | 14 | 14 | 9 | 10 | 6 | 4 |
| io | 109 | 93 | 16 | 70 | 90 | 41 | 49 |
| page | 23 | 4 | 19 | 3 | 2 | 2 | 0 |
| parse | 144 | 81 | 63 | 72 | 65 | 36 | 29 |
| printer | 7 | 7 | 0 | 2 | 7 | 0 | 7 |
| proof | 78 | 45 | 33 | 19 | 34 | 9 | 25 |
| reg | 93 | 88 | 5 | 83 | 87 | 77 | 10 |
| rfc | 9 | 9 | 0 | 9 | 9 | 9 | 0 |
| run | 75 | 69 | 6 | 69 | 69 | 64 | 5 |
| show | 8 | 8 | 0 | 8 | 7 | 3 | 4 |
| spec | 15 | 2 | 13 | 2 | 2 | 1 | 1 |
| state | 16 | 8 | 8 | 5 | 3 | 0 | 3 |
| stats | 5 | 5 | 0 | 4 | 5 | 4 | 1 |
| stuck | 25 | 25 | 0 | 25 | 25 | 9 | 16 |

Compiled eligibility follows upstream's `gates/test.ts`: a positive fixture
imports Base, declares main and has a matching foreign C/JS twin if applicable.
Other positive programs still require checking and interpretation. Import and
foreign fixtures are preserved in their original directory trees. Native and GPU
lanes remain visible even when unavailable; missing implementations never pass.

## Port obligations

| Area | Upstream implementation | Required equivalence | Baseline limitation |
|---|---|---|---|
| Syntax and elaboration | bend.ts parser, binders, terms, bodies, flattening | All accepted/rejected forms, source locations, patterns, dependent syntax | 90 positive parse failures |
| Core representation | bend.ts terms, quantities, persistent maps, contexts, substitution | Capture avoidance, binder identity, graded uses, definitional equality | Prototype syntax AST does not implement the trusted core |
| Evaluation | bend.ts weak/strong normalization and comparison | Open terms, type values, neutral terms, readback | 900 required interpreter probes unsupported |
| Checking | bend.ts inference, checking, kind fitting, datatype validation | Dependent types, affine quantities, recursion descent, holes, proofs | All 1378 checker probes unsupported |
| Modules and laws | bend.ts book loader, main.ts proof rules | Namespaces, dependency order, foreign signatures, LAWS/PROOF handling | Module and foreign imports not implemented by prototype |
| Erasure and specialization | comp.ts term analysis, templates, layouts, ownership | Type-directed live arguments, closures, borrowing, specialized templates | Prototype executable erasure is incomplete |
| JS backend | comp.ts JS emitter and runtime | All eligible outputs, effects, numeric/array semantics, readback | 236 failures and 1 timeout |
| Native CPU | comp.ts C emitter and shared runtime | Reference counting, scheduler, arrays, closures, native foreign ABI | 719 native probes unsupported |
| Metal and CUDA | comp.ts device code and GPU runtime | Actual device compilation and execution, ownership, synchronization | 28 hardware-gated probes; no GPU implementation |
| Base and effects | base.bend, effs/*.c, effs/*.js | Complete library and backend-specific effect behavior | Runtime provides only a subset |
| CLI and tooling | main.ts | Checking/running/emitting, import loader, report rendering | Conformance adapter is separate from end-user CLI |
| Mechanized theory | bend.lean | Specification reference, not an executable compiler target | Not claimed ported or reverified |

## Source inventory

| Upstream source | Lines | Exported declarations |
|---|---:|---:|
| bend2/bend.ts | 3870 | 188 |
| bend2/comp.ts | 6494 | 8 |
| bend2/main.ts | 681 | 1 |
| bend2/base.bend | 2908 | 0 |
| bend2/bend.lean | 20981 | 0 |
| gates/test.ts | 228 | 0 |

The JSON inventory includes all exported names and source SHA-256 hashes,
**80 backend effect files**, and **30
non-Bend support fixtures**. Benchmarks, demos, documentation generation and
cluster/performance gates are outside the 1,378-test compatibility corpus; test
success alone would not establish performance parity, hub/publishing behavior,
installation/release parity, or verification of the Lean development.

## Reproduce and extend

Run `node tools/conformance/run.mjs` with `BEND_UPSTREAM` pointing to the
pinned checkout. It intentionally exits nonzero for this incomplete baseline.
See `tools/conformance/README.md` for adapter contracts, separate frontend/core/
backend adapters, timeouts, hardware gating and selected development runs.
The full evidence is `tests/conformance/prototype-baseline.json`.

Compiler SHA-256: `298f5f7fd944a4aff42e8a91e3a66f6b716bf7f3a6f80547aea064af943be325`.
Runtime SHA-256: `9c736ef7e2f6856e84b47239353c378b2642019ec441af8067b443e1d1801349`.
