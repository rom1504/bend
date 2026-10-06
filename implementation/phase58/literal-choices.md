# Literal choices and direct continuations

The choice01 checked build and strict 36-case source gate passed. The focused
three-image controller then passed **36 value/error oracles, nine host
observations per image and eight function-level activation/refusal checks**.
These are overlapping checks over two source files, not 53 independent programs.
The images were checked-scalar01, checked-choice01 and pinned TypeScript.
No performance benefit is claimed from these correctness runs.

The controller ran with the default Node stack, a 1 GiB heap, CPU3 and the existing
2 GiB process-tree RSS / 4 GiB available-memory guard. Supervisor wall time was
9.6474 seconds; controller time was 9.1735 seconds. Peak tree RSS was 564,293,632
bytes. Both Bend attempts record `strictExact: true`; the choice01 source gate
reported 36 passes and zero exact differences. The checked build plus source
gate took 61.0092 seconds. These durations include qualification work and are
not generated-program throughput measurements.

## General rule

[choices.bend](../../selfhost/src/back/js/direct/choices.bend) reuses the existing
`j_choice_definition` structural proof from the ordinary JS backend. It recognizes
a checked selector whose Bool match invokes exactly one of two callbacks once,
with Unit. Direct admission additionally requires four source arguments, no
specialization parameters, complete saturation, literal live lambda callbacks,
and the canonical Bool and Unit callback types. The selector's name is irrelevant:
the fixture's renamed `switchboard` qualifies; its changed-body `kc` does not.
Ordinary calls fail the structural checks before type normalization.

`jd_choice_body` places each selected callback body in the current return
continuation. `jd_choice_calls` applies the identical admission rule while
collecting both possible callback tails. Consequently recursive branches use the
existing self/mutual SCC transfers rather than making a new recursive JS call.
The condition remains non-tail and is evaluated once. Source captures retain
their lexical bindings; a demanded callback Unit gets a fresh ordinary object.

`jd_choice_ordered` preserves the condition's existing prefixes and temporary
ordinal in the surrounding ordered expression. Its pending value uses a local
IIFE with `jd_expression_env`, so a branch cannot continue an outer SCC loop.
Only the selected branch runs. Partial calls retain eta expansion; surplus
application retains the existing application path, while a fully saturated
inner call can independently qualify. Nonliteral callbacks and altered bodies
remain calls.

The implementation adds **99 physical lines / 15 helpers in one module**, plus
two net lines each in `core.bend`, `ordered.bend` and `calls.bend`, and one manifest
entry. It adds no runtime, analysis cache or general inliner. Callback scanning
uses the existing 8,192-node per-body budget. Compiler cost still needs separate
measurement; fewer emitted closures alone do not establish fewer V8 allocations.

## Executed witnesses and limits

The 36 catalog cases cover both Bool branches and U32 wrapping, wrong-body refusal,
Unit results, partial and surplus application, captured returned functions,
selected versus unselected Nat overflow, ordered tuple composition, and ordinary
user datatype selection. Self and mutual recursion each reach 100,000 steps at
the default stack. Nested non-tail recursion is checked through depth 128.

The nine additional host observations cover both nonliteral callback branches,
fresh Unit identity, capture survival across a later call, exact thrown-object
identity from the condition and either selected callback, sibling-prefix order
when a later callback throws, and source-callback reentry. These preserve source
effects; they do not promise reflective equivalence of private closure wrappers
or trampoline packets. Inherited `Function.prototype.j` / `f` hooks fall outside
the direct backend's standard-builtin contract.

The eight complete-function AST checks found:

| Function | Observed candidate mechanism |
| --- | --- |
| `selected`, `composed` | Two `jd_clo` call sites become zero; one choice branch site |
| `countdown` | Two closure sites become zero; two loop transfers |
| `orbit.a` | Two closure sites become zero; a two-member switch with four transfers |
| `nested` | Two closure sites become zero; non-tail choice stays in expression scope |
| `counterfeit`, `nonliteral`, `partial_make` | No literal-choice marker; original refusal paths |

These are static syntax witnesses paired with successful execution, not dynamic
allocation counts. The ordinary-user-datatype module additionally has no choice
marker and returns the independent expected constructors.

Independent review caught an ordering bug before any choice compiler build:
the first draft hid a condition's prefixes inside its pending IIFE, allowing a
later sibling prefix to run first. The reviewed implementation propagates them
outward; `composed` checks probe(1) before later(2), including the throwing case.

The first acquisition accepted the main source, then rejected `non-native-v1`
because the frontend reserves `Bool` for the compiler's encoding. That failed
acquisition and all consumed v1 inputs remain intact. The v2 negative fixture uses
legal `OpaqueBool` / `OpaqueUnit` names. It tests ordinary object-layout refusal;
it does not pretend that a valid reserved-name shadow was compiled.

## Evidence and reproduction

[The isolated patch, inputs and commands](../../selfhost/tools/performance/phase58/choices/README.md)
retain the source change and both fixture/controller generations. The successful
controller verifies the genuine checked attempts, copied API/runtime/Base/driver
identities, exact source/catalog/producer joins and final input hashes. Acquisition
uses private Phase58 caches. No closed historical cache is reused for writes.

| Receipt under `selfhost/build/phase58/` | SHA-256 |
| --- | --- |
| `choices-controls02/report.json` | `352299ffed7541455475a94c067c3e3741a6210f2a725c84305d98d12be2d902` |
| `choices-controls02-supervisor/run.json` | `961a0dbcd6f770721363fc06c694588b258c768ccdff1cea122468d025c981f4` |
| `choice-fixtures02/manifest.json` | `864951ff8f8ba1ede172969ceb5027ad1d4ad1143f8d248112740b493ab334d5` |
| `choices-typescript02/manifest.json` | `fc43f75e6c8f3b256b5817504a52f5e689ea8132ee6571e82fef40ea33706b1b` |
| `checked-choice01/validation-001/report.json` | `053b39758ebfa0d1133a615657acdbb0404a0837be09b1336b33e1add89913c2` |

The candidate API is `0c6d310f9cee99d40df914f04dba3881146d18a62fa7fca7f7e87793a0d648f7`;
its checked source is `8ef122b3156a94916e83531d4924ef1a746b92eef9ea269b7238ea730e04c8cf`.
Broader qualification, compiler-image reproduction, measurement and promotion
remain separate from this focused result.
