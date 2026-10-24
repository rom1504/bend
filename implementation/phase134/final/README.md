# Phase134 qualified research checkpoint

This capsule preserves the no-copy streaming writer and unchanged-function
verification reuse. It is native-qualified but **not installed or selected as
the production compiler**. The existing Phase131 selection remains intact.

[candidate.json](candidate.json) pins the source, toolchain, native images,
runtime, carrier, qualification receipts and both measured compiler generations.
The archived source SHA-256 is
`a00019246b5181b288ab4d3e09e616bd41415fe6381e89a96185c05efa19fb57`.
The final N2 image SHA-256 is
`9909f18fb9470e5d2a4f54775e8cb7df2345e6f2e8886037adeee2612a57d21b`.

## What is established

- The independently checked source passes all 59 finite controls. The original
  final verifiers and protected proof declarations are preserved.
- The qualified Phase131 N3 produces Q1; the resulting N1 emits byte-identical
  Q2 from the same complete compiler source: 107,316,480 bytes. This establishes
  the stated QBE fixed point, not an ELF fixed point.
- N1 and N2 each pass the focused 19-case gate, including three expected
  refusals. N2 additionally passes all 45 ordinary independent-output cases.
- N2 emits all 45 frozen benchmark wrappers byte-identically to Phase131's
  measured products, with the same runtime. This preserves generated-code
  quality for that corpus without another runtime campaign. The archived
  Phase131 runtime measurements are historical, not a fresh Phase134 score.

Fresh three-round, three-request CPU3 blocks give these geometric ratios:

| Compiler image | Request time / same-block Phase131 N2 | Request time / upstream | Request + machine-build stage sum / upstream |
|---|---:|---:|---:|
| Phase134 N1 | 0.98166 | 1.41736 | 0.70450 |
| Phase134 N2 | 1.00255 | 1.41377 | 0.70314 |

The final N2 request result is effectively unchanged, not an established speed
gain. The stage sum uses the existing differing native/upstream build policies;
it is separate from compiler request latency. Neither three-round block
establishes a confidence interval.

The same-source full-emission observations record 366.836 seconds for Phase131
N3 and 384.281 seconds for Phase134 N1 (+4.76%). Those observations overlapped
CPU6 correctness work and are not a clean timing comparison. Sampled peak
descendant RSS falls from 2,918,051,840 to 1,008,922,624 bytes (65.43%); descendant
RSS can double-count shared pages. Both original observation reports and every
raw sample are retained.

`evidence.tar.gz` contains 86 authenticated metadata members, including native
qualification, raw timing blocks, summaries, wrapper requests, the failed guard
path collision and successful resumed schedule, memory samples, and native
writer failure evidence. The second newline write's failure is checked directly;
this does not add a guarantee for delayed errors from the runtime's unchecked
`File.close` result. Rejected batching and range-reuse experiments remain in the
phase's separate reports.

## Restore and use

From the repository root, restore source into a fresh temporary directory:

```sh
phase134_restore=$(mktemp -d /tmp/bend-phase134.XXXXXX)
gzip -dc implementation/phase134/final/compiler.bend.gz > "$phase134_restore/compiler.bend"
sha256sum "$phase134_restore/compiler.bend"
```

Check the resulting hash against the source hash above before compiling it.
Source and metadata are archived here; native binaries, QBE, runtime objects
and toolchain are separately pinned build artifacts, not embedded distributions.
On the existing authenticated workspace, use the final image explicitly:

```sh
python3 -B selfhost/tools/performance/phase130/native-request.py \
  --image selfhost/build/phase111/p134-selected-n2/program \
  --source /absolute/path/to/program.bend \
  --carrier-receipt selfhost/build/phase130/base-carrier01/receipt.json \
  --out selfhost/build/phase130/my-fresh-phase134-request --seconds 60

python3 -B selfhost/tools/performance/phase123/build-aligned.py \
  --source selfhost/build/phase130/my-fresh-phase134-request/program.ssa \
  --runtime selfhost/build/phase128/runtime-borrow01/runtime.o \
  --out selfhost/build/phase111/my-fresh-phase134-program --seconds 30

selfhost/build/phase111/my-fresh-phase134-program/program --threads 1 --gpu off
```

Both output directories must be fresh. These commands select a compiler for
one request; they do not modify the installed default. For the qualification
and replay commands, see the [validation adapters](../../../selfhost/tools/performance/phase134/validation/README.md).
