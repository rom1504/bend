# Phase164 — remove duplicate backend work from mixed computations

Start: `d708eef`, 2026-11-05. User asks to keep working toward a five-second
full cold compiler build. The qualified observation is 249.222 seconds; reaching
five seconds would require roughly 50×, not another small request improvement.
This is a research target, not a forecast. Preserve ordinary semantics, generated
program quality, independent verification and a working qualified compiler.

## Chosen experiment

Phase163's closed direct route saves 23–35% on two actual compiler requests but
refuses six of eight unrelated computations. Its useful capability is avoiding
an entire generic representation; the next step is to make that capability
compose with the real language and compiler.

Build a mixed route in Bend. Compute existing admitted direct candidates first.
For eligible owners, retain real factories/public entries and introduce a real,
independently checked adapter to the direct worker. Skip only their redundant
generic worker and owned continuations. Nonadmitted owners retain the original
generic lowering. Preserve verified direct-import calls from generic callers,
all later ownership/optimization facts and final required-target checks.

Do not fake empty bodies, successful verifier results, private region plans or
signature evidence. Do not turn non-tail recursion into unbounded native calls.
Keep QBE and the existing runtime. Production source/selection stays unchanged
until the new boundary passes its relevant qualification.

## Intermediate gates and cost discipline

1. Independent source audit plus small malformed adapter/import controls.
2. One real mixed computation, including a generic caller, a direct callee and
   a retained factory/closure use. Complete output must match independent oracles.
3. Several unrelated original workloads, including the six Phase163 refusals,
   IO, non-tail recursion and long tail loops. Measure actual native execution.
4. Compare the same source and optimization policy: preparation, raw generic
   work, optimizer/registry/verifier work, rendering, machine build and memory.
   Count omitted owners/continuations and final code. No source-size-only claim.
5. If the economics and coverage hold, acquire one native mixed-route compiler
   and measure a real compiler subset, then full exact source. Full native
   reproduction is a promotion gate, not required for every early candidate.

Root owns the only resource-intensive lane. Reuse authenticated baseline APIs,
native images, inputs and runtime assets. Agents own bounded implementation,
independent audit and competing headroom analysis. All new compiler jobs use
guard.py with explicit fresh roots, disk/RSS/deadline limits and a 5GiB reserve.
Keep failed attempts, restore/archive exact artifacts, and close every run.

## Ambition and falsification

The first result should support mixed programs and demonstrate disappearing work,
not simply another closed kernel. The larger result is eliminating redundant
representation construction and its downstream passes across the compiler.
Generic lowering alone was only 11.59 seconds in Phase161; even deleting that
whole stage cannot justify a large total gain. Retained work must be measured.

In parallel, challenge whether this route can ever approach five seconds. Identify
the next largest structural gap to bendc from actual code and operation counts.
Prefer eliminating repeated semantic work and ownership-heavy intermediate state
over another representation conversion, text compressor or cache campaign.
Do not retry compact App without new frequency/consumer evidence.

Stop or narrow a candidate when admission is unsound, new verification cancels
saved work, broad execution regresses materially, or the measured whole-build
ceiling is too small. Report a negative result plainly and use it to select the
next architecture boundary. Cold build, warm reuse, generated-program runtime,
compiler executable speed and research throughput remain separate metrics.
