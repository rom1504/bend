# Experimental optimization policies in Bend

Phase149 adds an explicit QBE experiment entry to the maintained compiler.
It measures the cost and value of optional optimization groups. The ordinary
entry and installed release retain their existing policy. This is not a
qualified replacement compiler or a new debug-information format.

The policy parser, switches, stream adapter, timing output and finite controls
are Bend code. Existing host tools still assemble source, independently check
it, supervise resources, invoke QBE/assembler/linker and measure processes.
No new Python or JavaScript policy implementation is needed.

## Policies

The canonical decimal codes are 0–11. Flags compose as follows:

| Component | Value | Effect |
| --- | ---: | --- |
| Initial optimization | 1 | Omit the initial inlining **and scalar-cleanup group** |
| Late helper preparation | 2 | Omit optional late borrowed/owned helper preparation |
| Region policy | 0 | Current direct/H/R/G/extended-H/generic precedence |
| Region policy | 4 | Complete direct workers, original H query, then generic/fused |
| Region policy | 8 | Complete direct workers, then generic/fused |

Use one region value, optionally adding 1 and/or 2. The diagnostic sweep uses
0, 1, 2, 4, 8, 3 and 11. All twelve codes have parser/mapping controls; only
the seven listed policies have the main compiled-program experiment evidence.
Code 11 disables the most work exposed here; it is **not** an optimizer-free
compiler. Initial direct/SCC/array admission, shared registry/view construction,
mandatory lowering and the existing final verifier remain.

Code 0 delegates the ordinary pipeline and emission stream. The other policies
select existing verified paths or their existing fallbacks. They do not make
unchecked workers admissible. Source checking, ownership obligations, runtime
admission, namespace checks and stack-safe fallback rules remain in force.
These are implementation checks and finite tests, not a new BendTT proof of
semantic equivalence.

## Use

Assemble `selfhost/src/compiler.json` with profile `qbe-policy` (or
`qbe-policy-test` to include the test command), following the
[maintained workflow](workflow.md). Independently check the assembled source
and acquire an experimental image with an explicitly qualified native parent.
The Phase149 report pins the actual checked source and experimental image.

The native protocol is:

```text
IMAGE --threads 1 --gpu off -- phase149 CODE ABS_SOURCE ABS_BASE cache ABS_CARRIER STAMP [ABS_TIMING]
```

`live` replaces `cache` for live Base preparation; supply unused carrier/stamp
arguments as empty strings. Inputs and optional timing output use absolute
paths. Timing must name a fresh, distinct file, without symlink or normalized
path aliases of any input. The CLI rejects identical strings but does not
provide filesystem alias detection. Use explicit authenticated inputs and a
fresh guarded output directory, as with ordinary compiler requests.

Successful stdout is the complete QBE stream. Errors return nonzero with the
existing diagnostic. The optional timing file contains `reads_ms`,
`compile_emit_ms` and `request_ms`; compiler work includes checking, preparation,
lowering, rendering and completed output writes. These are coarse intervals,
not exclusive pass profiles. The external process clock additionally includes
startup, timing-file output and shutdown.

Non-policy requests delegate the ordinary native CLI. The test profile adds
`phase149-controls`, which prints one PASS/FAIL row per finite control and exits
nonzero on failure. The original default entry does not expose these commands.

## Measure before adopting

Use the same executing compiler, source, Base preparation, runtime, QBE toolchain,
CPU affinity and fixed-work inputs for every policy. Compare code 0 against a
qualified independent parent. Changed policies need independent program-output
oracles; matching a policy's own QBE reference establishes repeatability only.

Record compiler request time, machine construction, generated-program runtime
and complete edit/build/test cost separately. Omitting a pass changes downstream
work and layout too: subtraction is a causal group ablation, not an exclusive
pass timer. A policy that builds faster can produce a slower research compiler
and lose the saving during validation.

See the [Phase149 report](../../implementation/phase149/README.md) for exact
measurements, negative results, qualification limits and reproducible recipes.
