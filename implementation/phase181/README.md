# Phase181 — a working Bend-written x86-64 assembly backend

**Implemented and retained as an experimental target.** The complete x86
compiler entry compiles itself through two native assembly generations, with
identical emitted assembly and object files. It does not replace the qualified
QBE compiler: generated execution is currently approximately twice as slow.

[Backend guide](../../docs/self_hosted/x86-backend.md) · [Design](../../design/phase181/README.md) ·
[Metrics](metrics.json) · [Replay](reproduce.md) · [Evidence index](evidence-index.json) ·
[Project status](../../docs/self_hosted/projects/x86-backend/STATUS.md).

## What now works

Eight Bend modules, 1,192 physical lines including comments/interfaces, implement
AMD64 SysV frame placement, integer selection, branches, ordinary and multiple
result calls, stack-safe local loops, static data/relocations, runtime dispatch
adapters and bounded assembly output. Four frequently read variables can retain
distinct callee-saved registers. Ordinary call arguments go directly to ABI
locations; tail argument reassignment retains a simultaneous snapshot.

The emitter consumes actual verified N111/P113 operations from `P169Prepared`.
It does not translate QBE text or implement a compiler in host tooling. The
existing frontend, native planning, final verifier and runtime remain in use.
GNU assembler and the GCC linker driver remain; no QBE machine stage or C
source compilation is used after acquiring the seed. Shared preparation still creates an unused legacy
QBE-forwarder text list. Avoiding that work remains future cleanup.

The native entry closure is **1,415,281 bytes / 4,254 declarations**, SHA256
`6d9408c2467f4d19731271569a501b94927556037605e11af1d48dce5e775366`.
This is the complete experimental x86 compiler entry, including its frontend
and optimization pipeline. It is not the 3.17MB multi-target production profile.
Do not compare its self-build time with the historical 175–180s production
build and call the difference an improvement.

Host Python/JavaScript adapters transport sources and checked APIs, invoke
tools, time requests and authenticate artifacts. The C/assembly control observer
checks the external machine ABI. Compiler transformations remain in Bend.

## Results and clock boundaries

All target execution is serial on CPU3, one runtime worker, GPU off, with the
same pinned runtime and prepared Base. Fresh processes are used; filesystem
caches are not flushed. Source checking and acquisition are separate costs.

| Observation | QBE-built executable | Assembly-built executable | Result |
| --- | ---: | ---: | --- |
| Selected parser/checker on real 656KB compiler source, paired medians | 8.310s | 17.1355s | 2.062× time |
| Whole process for that check, including Base/digest/teardown | 8.6723s | 17.9107s | 2.065× time |
| Same-source x86 compiler emitting itself, one run each | 108.510s | 217.811s | 2.007× time |
| Complete assembly self-build, including as/link, one run each | 117.811s | 226.417s | 1.922× time |

The checker comparison is baseline/candidate/candidate/baseline on identical
frontend source and input. Individual baseline samples vary; no confidence
interval is claimed. The self-emission comparison uses **identical compiler
source**, request input, runtime, output requirements and tool policy, changing
how that compiler executable was produced. Both emit the same 110,529,328-byte
assembly. It directly measures generated compiler quality, not a different
choice of compilation algorithm or backend on the output side.

The initial stack-home emitter measured 18.7425s versus QBE7.923s (2.366×)
in an earlier paired cohort. The selected register/direct-call version has a
smaller gap. Comparing those separate cohorts does not isolate a precise
optimization speedup. Its frontend assembly falls from58,048,566 to50,242,774
bytes and its ELF from13,246,320 to11,108,208 bytes.

The QBE-built seed acquisition took119.565s. Building the selected frontend
through that seed took51.602s:47.778s emission,3.294s assembly,0.108s link,
plus transport/authentication overhead. The earlier QBE frontend acquisition
was53.958s using a different producer. Those are acquisition observations,
not a controlled claim that the new target builds faster.

## Correctness and reproduction

- Unchanged upstream source checking accepts the final source with zero holes.
  `native-source02` and the maintained-source replay `native-source03` are exact.
  This is not a BendTT proof or an end-to-end compiler theorem.
- Seventeen direct functions pass the unchanged IR verifier and literal external
  ABI observations: widths, wraparound, signed/unsigned comparisons, memory,
  spilled arguments, register preservation, branches, multiple results and
  100,001-iteration tail permutation. One control combines multiple results,
  overwritten argument homes, hidden output state and spilled tail arguments.
- Ten namespace observations admit legal IR then require the appropriate x86
  refusal/acceptance. The audit found and fixed hidden `__x181` local collisions.
- Nine existing source programs match literal/frozen complete stdout through
  both QBE and the selected x86 emitter. These cover closures, aggregates,
  strings, arrays, non-tail reconstruction, arithmetic and local recursion.
- Both assembly-built generations compile and run three independent smoke
  programs: captured closure, nested aggregates and long tail permutation.
- The same real656,302-byte compiler workload produces matching checker
  observations. Its structural digest supplements the independent finite
  controls; it is not a complete semantic-equivalence oracle.

The chain is qualified Phase175 N2 → **X0** (QBE-built x86 compiler) → **X1**
(assembly-built compiler) → **X2**. X1 and X2 have identical assembly and object
files. Every loaded ELF section matches. Whole ELF hashes differ only because
the non-loaded `.strtab` records the respective absolute `program.o` path;
the raw mismatch is retained, not normalized away. Each ELF is24,224,120 bytes.

This establishes bounded native reproduction and execution. It does not qualify
all45 benchmark inputs, GPU/multiple-worker execution, other architectures, the
public installed selector, arbitrary later edits, or production replacement.
The installed Phase171 compiler and qualified QBE references remain intact.

## Why generated execution is slower

The most useful finding is that some important optimizations happen inside the
existing QBE renderer, after the structured program has been prepared. Sharing
that program therefore preserves semantics but does **not** inherit all of its
machine-quality improvements.

The retained three-function audit compares real checker helpers selected using
earlier physical sample evidence. These are static full-symbol counts, including
cold paths, not dynamic instruction counts or an attribution of current time:

| Function | Selected x86 instructions | QBE instructions |
| --- | ---: | ---: |
| Borrowed string equality | 511 | 220 |
| Borrowed index hash | 190 | 71 |
| Index lookup | 1,820 | 485 |

QBE replaces tag calls with shift/mask operations, performs guarded borrowed
field reads inline, specializes constructor/take helpers, removes impossible
branches/copies and reduces word widths. The new emitter retains generic
runtime calls and more temporary moves. QBE also retains roughly2KB scratch
frames here; simply removing that reservation is not the distinctive mechanism.
Exact disassemblies, binary hashes, commands and counts are sealed under
`machine-inspection01` in the evidence archive.

**Next step:** reuse existing structured runtime-call expansions before x86
frame placement. Start with `p112a_expand` tag extraction, then the guarded
`p128bf` borrowed-field statement producers, preserving their signature checks,
fresh names, ownership and slow fallback. Run the ABI/source controls and the
real checker before another full bootstrap. Subsequently address copy/constant
simplification and liveness-based register reuse. Direct ELF emission should
wait: removing assembler time cannot repair the observed2× execution deficit.

## Rejected attempts and research cost

The first combined hosted API acquisition exceeded the2GiB process-tree limit
and was stopped by the guard. Instead of raising the memory ceiling, testing
reused an authenticated semantic API plus a separately checked small emitter
API; final native source still received its own independent source check.
Early source attempts exposed a missing forward law and an affine alias error.
The ABI corpus initially used operations not admitted in direct scalar blocks;
those fixtures were corrected without changing the verifier. Two extraction
attempts lacked a dependency or declared a constructor after its first pattern
use; these failures and a dependent invocation failure are retained.

No rejected artifact was promoted. All32 target jobs have resource and retention
receipts:975.396s total guarded time (16.26min), including24.174s across eight
failed jobs. Successful native assembly generations peak at about1.50GiB RSS;
the combined hosted API was stopped at the2GiB limit. Exact accounting is in
the evidence index. Guard time
includes tool execution/waits, not all agent research or quota usage. Four
bounded existing agents contributed modules, controls, audits and documentation;
only root ran target builds/timings. There is no invented billing estimate.

The compiler, tests and guide are committed separately from this final evidence
report. The native experiment is usable from the documented explicit commands;
the production source manifest, release assets and installed selection are
unchanged. Architectural capability is the result of this phase; speed parity
remains work to do.
