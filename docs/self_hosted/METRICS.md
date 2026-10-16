# Compiler metrics and the current scoreboard

Read the [Phase91 scoreboard](../../implementation/phase91/README.md) for the
installed JS-hosted compiler and the [Phase92 native-chain scoreboard](../../implementation/phase92/README.md)
for native-hosted B1/B2. These are separate host configurations. Its definitions follow the
[Phase66 five-axis design](../../design/phase66/upstream-and-five-metrics.md).
A ratio is **our elapsed time / the reference elapsed time**: 1 is parity,
0.5 is twice as fast, and 2 is twice as slow. Ratios describe the named corpus,
engine, configuration and clock; they are not universal language properties.

| Axis | What is measured | What is excluded or reported separately |
| --- | --- | --- |
| Compiled-program speed | Execution of complete generated computations, compared with the upstream compiler's programs for the same target | Compiler requests, C compilation, imports and warmup, according to the corpus recipe |
| B1 compilation speed | Fresh requests to the checked, upstream-built compiler image, including an explicitly qualified equality-derived image | API/import cost has its own clock; preparing reusable Base artifacts is a separate setup cost |
| B2 compilation speed | The same requests to the independently identified compiler emitted by B1 | B1 measurements do not stand in for B2; full compiler self-emission is a separate workload |
| Conformance | Frontend observations and selected backend executions against pinned reference or fixture expectations | Exceptions, unsupported APIs, environment limits, unrun tests, GPU and proof-kernel coverage remain explicit |
| Simplicity | Manifest-listed maintained Bend modules, separate host/runtime support, generated-image sizes and architectural obligations | Test/evidence files and generated assembled source are not added to the compiler-source count; declarations are not semantic concepts |

## Keep three dimensions separate

- **Generation:** B1 was built using upstream; B2 was emitted by B1. The release
  records the exact parents, source and image hashes.
- **Compiler host:** our Bend algorithms can run as generated JavaScript under
  Node, or as a native executable. Upstream's implementation is TypeScript and
  runs under Node or Bun. Using the JS-hosted compiler to emit C is ordinary
  cross-compilation; it does not make the generated C program a JS program.
- **Output target:** JS and C have separate generated-program and compiler-request
  benchmarks. The C request clock ends after C emission; Clang time is separate.

Phase92 builds native B1 from the exact native07 Bend source using pinned
upstream C and the same Clang/O2 flags. Its full self output equals native07's
existing build C, so that native B2 binary is reused. This content link does not
claim a freshly rebuilt ELF or rewrite the historical diagnostic-seed lineage.
The matched six-source native B2/B1 ratio is1.203× request /1.444× process;
full-source self compilation is140.3s/152.2s for B1/B2 versus48.4s TS/Bun.
Prepared Base is essential to the small-source results: the uncached Small
control takes3.26×/3.68× TS process time. See the report's precise clock boundaries.

The comparable Phase91 B1/B2 campaigns use Node for all three compiler roles,
with the original JS23 and C3 input sets. The Phase90 six-source native-host
screen compares different host runtimes, including upstream under Bun, and has
explicitly different Base and process-clock boundaries. Do not combine their
ratios. A full native compiler reproducing its own C is another valuable,
separately reported scaling test.

## Complete application workflows

The [Phase100 applications](../../selfhost/apps/README.md) add source indexing,
complete image rendering and dependency planning. Their
[scoreboard](../../implementation/phase100/README.md) measures full process runtime
including input/output, compiler request/process time, Clang build time, memory,
generated-code size and CPU-worker scaling. Runtime compares the same Bend source
compiled by our native B2 and upstream's C backend. B1/B2 emit identical C.

Keep this separate from Phase93's fixed-input kernel batches and full compiler
self-emission. Prepared Base is used by our compiler requests; upstream checks
Base within its request. Clang belongs in the reported end-to-end application
build cost. Small applications and few samples do not establish universal parity.
No mean combining these unrelated application ratios is reported.

The [application loop](../../selfhost/tools/performance/phase100/README.md)
offers cached acquisition and `--fixtures` replay of verified input/output
contracts. Fresh independent references remain available when deliberately
changing an application contract. Use this loop before broader integration gates.

## Fast validation without repeating all timings

For fresh **native generated-program runtime**, use the
[Phase93 original45 suite](../../selfhost/tools/performance/phase93/README.md).
Both actual native stages emit identical C for all 45 batch sources. The
[results](../../implementation/phase93/README.md) cover 264 final samples across
44 measurable points: 1.114840× upstream C with equal-point weighting and
1.139377× with equal-original-source weighting. Both backends optimize away the
zero-work control, so no full-45 runtime mean is defined. The measured interval
includes full-result validation and batch overhead, excludes compiler/Clang
work and startup, and uses matching C11/O3 builds. A six-point saved-product
screen occupied 16.7 seconds; the full measured corpus occupied 99.9 seconds.
Keep the original JS45/C12 historical ratios separate from this new C corpus.

First verify the installed release and freeze the compiler, source, reference,
Base, runtime and harness identities. Use the
[JS23/C12 continuity gate](../../selfhost/tools/performance/phase91/continuity/README.md)
to check whether the exact previously timed programs still apply. Phase91's
complete gate took about 33 seconds for both B1 and B2.

Byte-identical JS modules preserve the program artifact. For C, Phase90 changed
formatting and two runtime clauses; identical complete preprocessing under the
historical Clang `-O3` recipe establishes the relevant translation-input boundary.
That does not claim identical ELF bytes, fresh speed samples or other flags/GPU
coverage. Historical timings carried through such an identity check must retain
their original date and scope. If the relevant output changes, run the affected
program's correctness and timing checks before broader qualification.

For fresh compiler latency, use the
[balanced JS23/C3 campaign](../../selfhost/tools/performance/phase91/compilation/README.md).
It prepares role-specific Base artifacts once, then runs three rotated fresh
processes per source/role and verifies every complete emitted output. Request
and imports-plus-API-plus-request times remain separate. Median ranges describe
observed variation; three samples are not a statistical confidence interval.

Root runs target processes serially under the execution lock. Offline preparation
and review can run in parallel. Use fresh output directories, bounded memory and
time, and the disk reserve. Preserve failed attempts and avoid rerunning full
self-hosting when unchanged identities already establish the relevant boundary.
