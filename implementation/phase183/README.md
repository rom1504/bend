# Phase183 — assembly is a maintained, qualified target

[Design](../../design/phase183/README.md) · [User guide](../../docs/self_hosted/ASSEMBLY.md) · [Selected release](../../selfhost/manifests/current.json)

The direct AMD64 assembly target is installed as a fourth component alongside
JS, C and QBE, on upstream Bend2.0.40 (`9a4223d577ba56a0cb53d1fd952d2b481c38930f`).
The actual assembly-built N2 passes the current finite64 catalog and ten runtime
controls. N1/N2/S3 reproduce the complete assembly. This is a supported
sequential Linux AMD64 SysV route, not a claim of performance parity, unrestricted
foreign support, GPU execution, parallel qualification or end-to-end proof.

```sh
selfhost/bend --target x86 input.bend -o output.s
selfhost/bend --target x86 input.bend -o output
selfhost/bend --target x86 input.bend --run -- application-arguments
```

The first command emits real assembly; the second assembles/links an ELF.
The JS launcher delegates the same target. An implicit `.s` destination also
selects assembly. Both public help paths describe it, outputs are published
without overwriting existing files, and program arguments retain their boundary.
The default C/JS routes remain available.

## What changed

The canonical source manifest owns an `x86` profile and native entry. It adds
backend modules explicitly and retains a conservative reachable declaration
closure. The five pre-existing source profiles are byte-identical. The x86
profile is 1,416,804 bytes/4,281 declarations, SHA256
`49409f730473d87b03e378ffbcfb999ffcf083a68baa707f2de65e3585a52455`.
It has its own source identity; it is not relabelled as the3,179,190-byte QBE
profile. All compiler algorithms and assembly emission remain in Bend.

Maintained request/build/bootstrap/qualification tools understand target `x86`
and protocol `native-x86-source-v1`. Direct builds invoke the assembler/linker,
without looking up or executing QBE. Reports distinguish assembly from QBE
products and infer the correct output protocol when omitted. Explicit overrides
still support a QBE-built assembly seed. Host Python/JS code transports commands,
bytes, identities and independent observations; it does not implement lowering.

Benchmark acquisition, fixed native catalogs, syntax/machine inspection and
profiling accept assembly artifacts. Profiling can validate actual ELF function
pointers against the emitted tables and attach exact maintained source locations.
Release admission independently binds the source profile, QBE→N0→N1→N2 chain,
complete reproduction, exact current catalog IDs and current runtime cases.
The three existing compiler binaries and their prior gates are preserved. The
new component and operational maps were installed with authenticated rollback.

The current descriptor already carries ABI11102 through shared verified native
preparation. The audited emitter supports its new F32.from_nat word-call ABI;
no special SSE calling convention was missing. Updating the entry/RTS/cache
protocol and qualifying the current runtime were essential. See the
[ABI audit](../../selfhost/tests/phase183/abi-audit.md).

## Independent gates and their limits

| Gate | Result |
| --- | --- |
| Independent upstream source check | Accepted, zero holes,5.275s |
| Raw machine ABI controls |17 functions and10 namespace observations pass |
| QBE-built assembly seed |19 focused cases and10 current runtime cases pass |
| Actual assembly N2 |64/64 catalog cases,0 failures,0 unsupported |
| Actual N2 current runtime |10/10 pass, including numeric conversion, argv, files and exit statuses |
| Actual N1/N2/S3 |111,074,856 assembly bytes identical |
| N1/N2 objects |Byte-identical |
| N1/N2 executables |Whole bytes differ only in `.strtab`; all allocated sections identical |
| Installed public commands |14 pass, including ordinary C/JS emission/execution |
| Actual N2 profiler |Independent complete lexer output reproduced;37,045 ELF FID entries verified |

Assembly SHA256 is
`217f2355dac240e1c47878e909e1919338d369bcf32900772113810487f51d60`.
Selected N2 is 24,343,264 bytes, SHA256
`ce78a662ea3312b38dbab294522cd26bcaa8cd932c1eaf4e9620dd4d236c897b`.
The 64 cases contain 61 executions and three stage-specific refusals. These are
finite independent controls, not full language conformance. Self-reproduction
can preserve shared bugs and does not replace the output/ABI/runtime gates.
Zero-hole source acceptance is not an independently checked BendTT theorem.

The short profiler capture delivered 199 samples without loss,99.49% main-thread
CPU coverage, and eight exact source-owner observations. It remains **below**
the 500-sample analysis threshold: `originalProfileUsable=false`. This proves
integration of the actual assembly binary, sampler and owner maps; it is not
accepted evidence for quantitative hotspot percentages.

## Compilation measurements

One observation per build, same maintained x86 source, authenticated prepared
Base, sequential CPU3, current runtime and recorded assembler/linker policy:

| Operation | Complete build | Assembly emission |
| --- | ---: | ---: |
| Qualified QBE N2 builds assembly compiler N0 through QBE |127.774s |Not a separate assembly-emission clock |
| QBE-built N0 emits/builds assembly N1 |128.527s |119.661s |
| Assembly-built N1 emits/builds assembly N2 |244.027s |234.689s |

The complete N1/N2/S3 chain takes 610.141s, with about 1.51 GiB peak process-tree RSS.
The assembly-built compiler takes 1.90× the seed's complete build time and1.96×
its assembly-emission time. These are single observations, not paired medians.
They use the smaller x86 entry profile and prepared Base; they must not be
compared directly with historical full-profile cold-build numbers.

## Generated-program benchmark

The retained native45 `fast` set, exact wrappers and independent outputs were
acquired freshly for upstream C, selected QBE and assembly N2. All15 product
checks pass. Acquisition takes44.034s and is excluded from execution timing.
The first20-second timing campaign exhausts its deadline on assembly local-fold;
completed samples are correct. It produces **no admitted aggregate**. A fresh
300-second campaign uses the same artifacts, same five cases and three rotated
rounds; no workload counts or correctness oracles are reduced.

The larger campaign completes all45 observations (five cases × three roles ×
three rounds) in 119.885s. The three fully resolved cases show:

| Kernel | QBE/upstream time | Assembly/upstream time | Assembly/QBE time |
| --- | ---: | ---: | ---: |
| local-pair |1.265× |63.06× |49.79× |
| local-fold |2.000× |89.20× |44.55× |
| scalar-region-8192 |1.710× |42.70× |24.96× |

These are paired median time ratios; larger is worse. The zero-work scalar case
is correctly excluded. `complete-generic-row32` returns correct results, but its
upstream batch is below the timer-resolution threshold, so its upstream ratio
and the set-wide aggregate are **not admitted**. No geometric mean is claimed.
The benchmark integration exposed much larger deficits on these kernels than
the roughly2× compiler-workload gap. Preserve both observations; neither
summarizes all Bend programs.

These small kernels are diagnostic and are not a representative full45 score.
Assembly should not replace QBE for performance-sensitive workloads yet. The
known missing late QBE tag/borrow/constructor expansions are a strong next
candidate for shared structured lowering; first-class integration does not
make those optimizations appear automatically. Use measured hot generated code
before adding register-allocation machinery or claiming a general cause.

## Negative attempts and resource discipline

Two public test attempts assumed empty C compilation stderr, then omitted its
trailing print newline. The unchanged C frontend intentionally prints its
existing59-byte proof-status banner. The adapter now checks those exact bytes;
all fourteen controls pass. No compiler semantics or rejection gates were
weakened. Initial synthetic release controls also exposed missing catalog,
producer-chain, nested-request and runtime-row bindings; admission was tightened
before any publication. The benchmark timeout and short-profile quality refusal
remain recorded as failures/limits, not successful measurements.

One controlled CPU3 target lane was used, with process-tree/time/disk guards,
a5GiB disk reserve and no nested guards. Eight immutable Phase182 product pairs
were compared byte-for-byte and hardlinked, recovering584,200,192 bytes; three
identical Phase183 assembly/object products recovered253,431,808 more. Every
path, byte and mode is retained. Future builds must use fresh paths, never write
into these shared immutable products. Native images and rollback copies remain
available. See the [exact evidence index](evidence/index.json) for receipts, resource counts and methods.
Nineteen guarded jobs used 1194.427s (19.91min), including the three failed
adapter/deadline attempts. Minimum observed free disk stayed above5GiB. These
clocks exclude agent effort and are not a quota estimate.

All 247 Python metadata/mocked transport tests and JS shell-selection controls
pass; see [metadata controls](evidence/metadata-tests.json). Runtime evidence is
separate: [native64](evidence/n2-all.json), [runtime10](evidence/n2-runtime.json),
[public14](evidence/public-qualified.json), [bootstrap](evidence/native-chain.json),
[benchmark](evidence/benchmark-completed.json) and [profiler](evidence/profiler.json).

## Reproduction and next step

[ASSEMBLY.md](../../docs/self_hosted/ASSEMBLY.md) gives maintained source assembly,
explicit requests, native acquisition, bootstrap, finite qualification, benchmark
and profiler commands. Phase183 adapters are in
[`selfhost/tests/phase183/`](../../selfhost/tests/phase183/); historical Phase181
files supply only committed fixture/oracle data, not the active build workflow.

Prioritize the missing optimizations shared with QBE using actual emitted hot
loops. Keep this qualified assembly image available as the baseline. Do not
replace the selected QBE compiler or claim all-target parity from this phase.
