# Hardware-aware prediction: bounded retrospective, stopped before modeling

Status at the user's request to conclude: four authenticated before/after pairs
prepared; no model tool acquired, installed or executed; no benchmark or hardware
counter run. Root's download attempt was aborted before dispatch. No security or
host settings changed. The requested roughly ten-pair evaluation is incomplete.

## Host and smallest tool acquisition

Nonprivileged inspection identifies Debian11, Intel Xeon E3-1245 V2,
GenuineIntel family6/model58/stepping9: Ivy Bridge,4 cores/8 threads, AVX but no
AVX2. The root-owned execution lane is CPU3. No llvm-mca, uiCA or OSACA executable
was found on PATH or in the bounded `/usr/lib`, `/usr/local/bin`, `/opt` and
`selfhost/.assets` search. `objdump` and `perf` exist; counter permissions were
not changed or tested. Existing libraries include LLVM11, z3, tinfo6 and zlib.
No libpfm shared library appeared in the inspected glob; whether llvm-mca itself
requires it remains unverified.

Local `apt-cache show llvm-11` gives this exact official package:

```
Version: 1:11.0.1-2, amd64
URL: https://deb.debian.org/debian/pool/main/l/llvm-toolchain-11/llvm-11_11.0.1-2_amd64.deb
Bytes: 8463020
SHA256: 1dd51ffbda01aa2440dca7336d11a8b1410655151ccaf9fbe135c6f41e0d947a
Member: ./usr/lib/llvm-11/bin/llvm-mca
```

Debian lists llvm-mca in `llvm-11`, not `llvm-11-tools`; the full installed package
is about32MB. Workspace-only extraction of that member could reuse the existing
LLVM11 library without installation. Authenticate the archive first, then inspect
the binary's actual dependencies and pin the binary/libraries. Package-wide
dependencies also include libc, libgcc, libstdc++, libpfm and the LLVM runtime;
they are not a verified single-binary dependency list.
[Debian package](https://packages.debian.org/bullseye/llvm-11),
[official file list](https://packages.debian.org/bullseye/amd64/llvm-11/filelist).

## Four prepared pairs

`pairs-v1.json` binds full ELF hashes to retained runtime receipts, original
disassembly, exact selected instruction addresses and generated model inputs.
`prepare-retrospective.py` reproduces metadata/disassembly extraction only.
It rechecks binary and witness hashes; the closure pair is tied to the original
authenticated runtime summary. No products are executed by preparation.

| Pair | Historical static observation | Recorded after/before runtime, approximately |
| --- | --- | ---: |
| Phase194 pressure-few, selected→commutative |89→67 positive-path instructions;22 moves removed; no spills |0.774167 |
| Phase194 pressure-many, same roles |83→83 instructions;12 explicit stack accesses unchanged |0.999562 |
| Phase194 value-rebind, same roles |19→19 loop instructions; complete kernel bytes unchanged; header alignment changes |0.913586 |
| Phase191→192 closure256 |Complete102-byte callback unchanged; placement changes |1.26367 |

The timing figures are existing whole-workload observations, not standalone loop
clocks or model results. Their raw case records, sample dispersion and receipt
identities remain in the manifest. A changed instruction count is not a causal
explanation of an observed speedup. In particular, identical hot code appears
with both an apparent improvement and a regression.

Model inputs are **straight-line positive-path projections**. Exit instructions
are omitted and branch targets become symbolic labels; the closure exit target
is redirected to the path continuation for this representation. Original
addresses/disassembly remain preserved. These inputs retain instruction order
and register dependencies but do not reproduce original byte layout. They are
appropriate for a limited backend scheduling comparison, not an exact uiCA
frontend/alignment experiment.

Frozen qualitative expectation for a resumed first run: pressure-few offers
real removable work; pressure-many is neutral; the two byte-identical kernels
are backend-neutral with unresolved layout/environment sensitivity. No numeric
fit or model-output-based region selection has occurred. Historical outcomes
were already known to the reviewer, so this is explicitly **not a blind study**.
No exact historical paired profile fractions were found for these four inputs;
`profileImportance` is null. Source repetition establishes relevance but does
not supply a measured Amdahl weight. A model-plus-profile ranking is therefore
pending, not established.

The six proposed extensions are not yet prepared/authenticated as new model
pairs: Phase190 local-pair address-spill regression; Phase191 Map call snapshots;
Phase193 compiler index-composition owners; Phase194 numeric float identities;
Phase194 editdist predicate fusion; and the Phase194 dependent-memory diagnostic.
The call-rich and branching cases may require abstention or per-path modeling,
rather than flattening whole functions into artificial loops.

## Primary-source tool assessment

LLVM-MCA uses LLVM scheduling models for throughput/resource estimates. Its
memory model does not model cache hierarchy or store-to-load forwarding and
defaults to assuming loads do not alias stores. The pinned LLVM11 documentation
supports explicit CPU, iteration and alias options; use `-mcpu=ivybridge`, not
the host default or an AMD model. Unknown instructions or warnings must be
retained, not silently dropped.
[LLVM11 documentation](https://releases.llvm.org/11.0.0/docs/CommandGuide/llvm-mca.html),
[LLVM memory-model limitations](https://llvm.org/docs/CommandGuide/llvm-mca.html).

uops.info supplies measured operand-specific latency, throughput and port data,
including Ivy Bridge and several AMD Zen generations. It is instruction data,
not a whole-program prediction: summing reciprocal throughputs ignores
dependencies and competing execution resources.
[uops.info methodology and architectures](https://uops.info/background.html).

uiCA combines those data with an Intel pipeline model, supports `IVB`, and
offers alignment-offset controls. Its documented architectures are Intel;
using it as an AMD predictor would be unjustified. It assumes cache hits. A
future layout test must preserve actual bytes/alignment, unlike the current
spliced path inputs.
[uiCA primary repository](https://github.com/andreas-abel/uiCA).

OSACA supports `IVB` and AMD `ZEN1` through `ZEN5`, with throughput, critical-path
and loop-carried-dependency analysis. It assumes optimal scheduling; it refuses
overall results for unknown instructions unless explicitly told to ignore them.
Do not use `--ignore-unknown` to obtain an artificially favorable estimate.
[OSACA primary repository](https://github.com/RRZE-HPC/OSACA).

For all tools, branch prediction, cache misses, instruction placement, dynamic
path frequency and call/runtime work limit extrapolation to the measured
program. Intel/AMD register names being identical does not make their timing
models interchangeable. Prediction informs a hypothesis; paired runtime remains
the performance authority.

## Bounded resume, not executed

After root authenticates the extracted tool, run each of the eight `.s` inputs
inside one guarded CPU3 job, with a30-second whole-job budget and per-process
timeout. Candidate base argv, with TOOL and INPUT replaced by pinned paths:

```
TOOL -mtriple=x86_64-unknown-linux-gnu -mcpu=ivybridge -iterations=100 -noalias=true INPUT
```

Repeat only pressure-many's two inputs with `-noalias=false` as a declared
sensitivity check, yielding at most10 model processes. Retain full stdout,
stderr, exit status, exact argv, source/tool/library pins and both alias settings.
Compare total-cycle ratios and block reciprocal throughput separately. Neither
is automatically a workload ratio; do not select whichever happens to match
the historical result. The prepared inputs, acquisition coordinates and this
bounded protocol are the complete handoff at this stop point.
