# Next direction: native-first, compact and incremental compiler development

Status: **proposal saved from the user's 2026-10-24 direction**. Finish Phase131,
its running experiments, qualification, evidence and pushes first. This note
does not claim an incremental compiler, compact-symbol result or completed size
census. The user permits selective early work but does not require a new broad
implementation campaign now.

The central question is why a small edit to a roughly57,000-line Bend compiler
requires regenerating and rebuilding about105MB of QBE, and how much of that
work can be eliminated safely. Optimize validated improvements per complete
research budget, not file size or compiler execution in isolation.

## Established starting point

Use the [Phase131 qualified capsule](../../implementation/phase131/final/README.md),
[native measurements](../../implementation/phase131/native-results.md),
[fresh profiles](../../research/phase131/final-profiles.md),
[full-source profile](../../implementation/phase131/full-profile-results.md) and
[current frontier](../../experiments/STEERING.md). Recheck HEAD before execution.

The final source is2,667,581 bytes and57,842 physical lines. Q2/Q3 reproduce
107,059,385 QBE bytes. The full N2 inventory examined in the identity audit has
63,239 functions; this is not yet a complete categorized census. Native QBE/as/
link builds take about15s, while full native source-to-QBE requests take several
minutes. Source, IR, ELF, allocated machine sections and runtime performance are
different quantities. Do not infer inefficient machine code from large text.

Phase131 already acquires complete candidates through a qualified native
producer, after independent source/API checks. It retains hosted execution for
cheap differential experiments and validation. Its same-source N1/N2 gain is
10.64% less request time, but it has not measured reduced discovery time in a
controlled research-feedback experiment. Historical hosted/native acquisition
times are different observations, not an isolated estimate of native-first gain.

## 0. Audit the complete loop before changing architecture

Record a common timeline and exact source/tool/runtime identities for:

1. Source checking and preparation.
2. Semantic analysis and lowering.
3. Independent IR verification.
4. QBE rendering and file writing.
5. QBE parsing, optimization and machine-code generation.
6. Assembly and linking.
7. Complete native compiler acquisition and self-reproduction.
8. Incremental rebuild, when a prototype exists.
9. Peak memory and retained artifact storage.
10. Independent correctness, ownership, ABI and regression qualification.

Keep clean timing separate from diagnostic instrumentation, generated-program
runtime, agent effort and failed experiments. Internal phases require actual
instrumentation or a causal experiment; an active-owner profile is not an exact
exclusive stage timer. Use one controlled heavy measurement lane and bounded
agents for independent investigations.

Identify every remaining use of JavaScript and what property it establishes.
Distinguish checking Bend source, BendTT proof checking, executing the compiler
through JS, native execution, N1/N2 agreement, product equality and independent
semantic gates. Native agreement can preserve a common bug. Retain JS as an
independent bootstrap, differential and recovery path, especially for risky
backend/runtime changes, but do not require expensive complete hosted emission
for every ordinary development edit. Quantify genuine savings with comparable
inputs and include the acquisition/validation cost of adopting a native producer.

## 1. Produce a precise QBE size and structure census

Stream the actual qualified QBE and bind the census to its hash. Attribute text,
functions, blocks, instructions, calls and data by mutually exclusive categories,
then give overlapping semantic views separately:

- Ordinary bodies and continuation/scheduler segments.
- Specialized private workers and generic fallback implementations.
- Forwarders, public adapters and other wrappers.
- Runtime calls, ownership operations and ABI transitions.
- Static data and dispatch tables.
- Function/global/local identifiers and their repeated occurrences.
- Exact or normalized repeated bodies and optimization-induced duplication.

Report the largest contributors and authenticated source origins. Keep unknown
origins visible. Count syntax correctly around strings, data and indirect calls;
textual name occurrences alone are not a call graph. Compare IR and machine-size
contributions. Separate necessary fallback code, unreachable code and merely
similar code. The census itself should be cheap and reproducible.

## 2. Compact-symbol falsifier

Test replacing long encoded **internal** function symbols, such as
`p111_FID_36_100_105_114_101_99_116_...`, with compact deterministic identities.
First use a frozen-QBE experiment with a bijective map and exhaustive reference
rewriting. This measures the ceiling before editing the Bend emitter. Preserve
foreign/runtime-visible names, exported ABI, relocations, dynamic tables and
namespace separation. Retain a source/debug map; compact names must not destroy
profiling attribution.

Measure text bytes, render/write time, QBE parse/codegen time, link time, ELF
sections and generated runtime independently. Compare actual allocated code and
data, not only whole ELF hashes. A shorter string table is not a runtime speedup.
If only text size improves, avoid a large refactor.

Existing numeric FIDs may be sufficient for one build but unstable after an edit.
Test insertion, deletion, reordering, specialization and worker-admission changes.
Do not mistake compact build-local IDs for stable incremental unit identities.
Move a useful experiment into checked Bend emission only after demonstrating an
end-to-end benefit and preserving identity/ABI contracts.

## 3. Final reachability and redundant implementations

Investigate whether admitted private workers leave unnecessary generic workers,
forwarders, continuation segments or equivalent implementations behind. Inspect
the actual verified graph and runtime references after final selection. Include
function pointers, closures, effects, fallback edges and dispatch-table entries;
absence of a direct textual call is not a deletion proof.

Distinguish late emission-only elimination from avoiding earlier analysis and
verification. The former may reduce QBE/build cost without reducing most compiler
execution. Record whether a dispatch table artificially keeps every function live,
and what semantic evidence would permit pruning it. Preserve behavior on dynamic
and unknown targets. Avoid generic identical-code folding until representation,
identity and address-observation obligations are understood.

## 4. One realistic incremental rebuild experiment

Choose a small real compiler edit whose behavior and dependency impact are clear.
Freeze a full rebuild as an independent reference. Then attempt to identify the
changed unit and its transitive affected units, reuse validated unchanged units,
regenerate the rest and link a complete executable.

First measure artifact stability after a full rebuild. A narrow machine-object
reuse experiment can expose unstable names and dispatch identities cheaply, but
is **not** an incremental frontend if the whole compiler still ran. Report that
limitation explicitly. The eventual useful experiment must avoid actual repeated
checking/lowering/emission work, with validation and linking included in its time.

Exercise changes that challenge the dependency model: callee body/type, erased or
template arguments, constructor layout, ownership summary, private admission,
optimization policy, runtime ABI, removed symbols and globally fresh names.
Record which stages are inherently global and which can have independently
checked boundaries. Compare full/incremental semantics and relevant code products
with independent oracles. Deliberately stale dependency entries must be rejected;
a fast cache with incomplete invalidation is a failed experiment.

## 5. Candidate unit architecture, conditional on the experiment

A small immutable compilation unit might bind:

```text
semantic key and source identity
checked interface and dependency fingerprints
layout / ownership / effect / specialization facts used by lowering
optimization and backend policy identity
runtime ABI and relevant toolchain identity
verified IR, generated code and optional machine object
explicit invalidation edges and independent verification receipt
```

This is a sketch, not a required new universal IR. Stable identity and content
fingerprint are different. Global reachability, fresh names, specialization and
profitability can invalidate units beyond ordinary source-call dependencies.
Rebuild final linking/dispatch metadata when needed; retain deterministic output
semantics. Measure construction, fingerprinting, storage, lookup, destruction and
amortization. Avoid introducing an open-ended general cache before reuse pays.

Research Go, Rust, Zig, LLVM/Clang and other successful systems through primary
sources and the existing repository research. Look for compilation-unit boundaries,
stable IDs, query/dependency invalidation and interprocedural tradeoffs, not a
backend switch. Record exact versions and distinguish implemented behavior from
plans. Do not presume another compiler's cache design fits Bend quantities,
specialization or ownership semantics.

## 6. Internal representation and rendering are separate questions

Profile immutable String construction/destruction, instruction formatting,
function joins, write traffic and QBE parsing separately. Test token/chunk pieces,
streaming admitted units, reuse of rendered unchanged units and avoiding text
later discarded. Preserve order and refusal behavior; streaming must not publish
unverified output inadvertently.

QBE remains the backend. Do not invent a binary QBE format, modify QBE or migrate
to LLVM, Cranelift, TPDE or custom assembly merely to shrink serialization. A
compact structured representation is justified by measured work elimination or
reusable semantic boundaries, not architectural elegance alone.

## 7. Bend-native reusable contracts

Test one small theorem about a real dependency or analysis summary. Bind it to
the exact production implementation, its source/interface assumptions and its
invalidation domain. An immutable checked unit could retain executable facts
while proof terms erase. Erasure does not remove the cost of computing facts or
make a stale cache correct.

Distinguish mathematical proof, source typing, finite admission checks, native
semantics and end-to-end correctness. Use a wrong-summary/dependency mutation to
challenge the unchanged theorem and validation path. Do not try whole-compiler
correctness or dependent types on every IR node as a prerequisite.

## Deliverables and decision gates

Publish the size census; complete-build cost profile; measured compact-symbol
result; redundant-function assessment; source-grounded incremental architecture;
one working prototype or precise falsifier; full/incremental cost comparison;
ranked research-productivity recommendations; native-first workflow assessment;
and opportunities for Bend-native verified reusable units.

Order by information value: audit/census, compact-name ceiling and artifact
stability, one bounded reuse experiment, then an architecture decision. Retain
negative results. Keep the qualified compiler and current independent gates.
Commit and push completed work with reproducible evidence. Do not label repeated
self-compilation or successive commits recursive research acceleration without
a controlled effect on validated improvement rate.


## Late Phase131 evidence to reuse

The full context profile identifies `nc_ctor_owned` at7.48% of self-build active
samples, with a repeated book scan and nested lookups; `lookup` and `f_find` are
also prominent. This offers a concrete first reusable semantic summary: bind
constructor ownership facts to the exact checked-book version, preserve first
match/duplicate behavior and raw fallback, and measure total construction plus
lookup cost. It does not by itself establish a complete incremental unit.

Likewise, scalar selector fusion became much more effective when composed with
wider borrowed layouts. That result argues for preserving semantic facts across
boundaries; simply moving code into another function did little. Keep the
qualified compiler and these experimental kernels distinct while planning reuse.
