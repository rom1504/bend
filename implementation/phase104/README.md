# Recursive improvement: assessment and initial baseline

Research and measurements, 2026-10-17. The [design](../../design/phase104/recursive-improvement.md)
contains the technical assessment, mathematical model, causal protocol and
roadmap. The [literature survey](../../research/compilers_architecture_and_techniques/recursive-self-improvement.md)
reviews primary sources and novelty. Compiler code, optimization policy and
installed releases are unchanged.

## What we learned

The project can support a meaningful recursive-improvement experiment. It has
source-bound native stages, precise correctness controls, useful applications,
local proof infrastructure and archived successes/failures. It does not yet
have evidence of accelerating research yield or an isolated autonomous evaluator.

Repeatedly compiling unchanged source is unlikely to supply the feedback:
candidate04 already reproduces its full self-C and diagnostic. Improvements
need new source, profiles, optimization decisions or search state. The strong
question is whether adopting such improvements buys more independently
validated progress than keeping the research tools frozen.

The largest immediate limitation is the full build envelope. Historical B2 self
emission took 150.846 seconds; Clang construction took 374.033 seconds. Under a
fixed-cost assumption, doubling the Bend part yields only **1.168×** cycle speed
(14.4% less time). Eliminating it entirely yields at most **1.403×**, before
agent work or tests. This conditional calculation is not a measured campaign
speedup. Reducing emitted C/build cost can improve a much larger component.

## Baseline implementation and actual run

Added a small [auditor and optional request screen](../../selfhost/tools/performance/phase104/README.md).
It streams artifact hashes, authenticates selected chain links, retains distinct
request/process/launcher clocks, fails on mismatches and never rebuilds or
promotes a compiler. The baseline completed in **11.594 seconds** including its
historical audit and 16 fresh guarded requests. See [raw structured results](baseline.json).

The audited lineage is:

| Generation | Actual evidence | Self-request time |
|---|---|---:|
| B1 | Upstream-built native Bend; same-source self emission | 126.584s, historical single observation |
| B2 | Built from B1 C; same-source self emission | 150.846s, historical single observation |
| B3 | C build input emitted by B2 and identical to B2's build input | Executable not built; no timing |
| B4–B5 | Not executed | No timing |

Both self emissions contain exactly **30,373,059 C bytes**, SHA-256
`ed60e46ccb281b6aa2a0764bd418f0f01057b060fe7d90ef6160ddf1afe11498`.
The source is `63ef222c…cda237`. Full clock-stripped diagnostics agree. We checked
the actual files against their recorded identities, not merely the prose report.
This is an emitted-C fixed point; it is not a newly measured ELF fixed point or
a new B3 build. Historical single timings cannot establish a generation trend.

The fresh screen uses two existing development cases, four alternating rounds,
one worker, GPU off, CPU3, prepared Base and fresh processes:

| Case | B1 request median | B2 request median | B1 process median | B2 process median |
|---|---:|---:|---:|---:|
| Small | 47ms | 46.5ms | 136.2ms | 156.2ms |
| Lexer | 311ms | 303ms | 410.2ms | 410.8ms |

All **16 complete C outputs and 16 diagnostics match** their frozen oracle.
These tiny differences are not evidence of recursive acceleration or a general
B1/B2 performance ranking. They illustrate why compiler-request and process
clocks must remain separate. `launcherWallMs` additionally includes authentication,
supervision, publication and capture-log writes; it is not a compiler timer.

The two auditor control groups pass when executed directly: clock extraction
preserves complete diagnostics and rejects missing/duplicate/invalid clocks;
artifact checks reject modified bytes, lengths and missing files. An intentional
failing assertion separately confirmed that the test runner returns nonzero.
Read-only agent review found no blocking issue; no additional compiler campaign
was needed. These tests protect measurement mechanics, not language semantics.

## Evidence scope and preservation

[evidence.tar.gz](evidence.tar.gz) retains 150 files: the baseline report/method,
four historical build/emission receipts, and all 16 new request directories,
including raw clocks, generated C and resource receipts. The archive's checksum
is in [evidence-receipt.json](evidence-receipt.json). Original large historical
compiler products remain in their preceding phase evidence; the new bundle is
not a standalone native release. Paths retain their historical checkout identity.
Extract into an isolated directory, never overwrite the live checkout.

The auditor is ordinary independent development tooling in this workspace. It
is not an evaluator protected from an agent with workspace write access. The
design proposes a separate evaluator account/container and immutable corpus;
no such isolation is claimed to have been implemented here. Existing 45-program
and application sets have repeatedly informed optimization and are not holdouts.

No new full self compilation, B3 native build, PGO training, optimizer search,
autonomous campaign, backend migration or generated-program speed optimization
ran. Free disk at investigation start was only about 864MiB; repeated large
Clang builds were both low-information and an unnecessary disk risk. No files
were deleted for this study. The public Phase103 CLI's bridge boundary remains.

## Recommended next experiment

First instrument real short optimization attempts, then replay a fixed candidate
sequence with the same compiler under normal and deliberately delayed compiler
service. This separates latency from changed code generation and proposal quality.
If faster service materially reduces complete experiment cost, compare frozen
versus updating builders in replicated autonomous campaigns. Charge upgrades,
rejects, agent use and validation; evaluate final candidates on unseen families.

For optimization search, start with PGO of the existing emitted C and bounded
legal inline/worker choices. No new LLVM backend is necessary. Then prioritize
smaller emitted C and ownership/continuation work if measured marginal research
value supports them. Local laws should constrain actual transformations, not
replace behavioral testing or silently weaken acceptance criteria.

The potentially new result is a causal, cost-accounted demonstration of feedback
in research yield, including generalization beyond compiler self-source.
Self-hosting, self-PGO and agent-driven code evolution are already established.
Our present evidence establishes a suitable platform and a baseline, **not
sustained recursive research acceleration**.
