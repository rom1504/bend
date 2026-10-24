# Phase 131 final native compiler capsule

This is the qualified final combined research compiler, separate from the
[FAST checkpoint](../fast/README.md). [candidate.json](candidate.json) is the
machine-readable entry point; [receipt.json](receipt.json) pins the compressed
source and exact copies of the completed evidence. This capsule does not change
the installed compiler or production selector.

## What passed

The exact source is 2,667,581 bytes, SHA-256
`1bc5930edcf80cda6c3572645df3c846fa631a83c2b936f20c83b05e0a6728f9`.
Its independently checked API and native runtime are pinned in the candidate.
The admitted source includes algorithm changes and declared code-generation
changes; acquisition therefore used the qualified Phase 130 native producer
and a full additional generation:

| Step | Producer | Result |
| --- | --- | --- |
| N0(S) | Qualified Phase 130 N1 | Q1: 104,373,390 bytes; build N1 |
| N1(S) | New N1 | Q2: 107,059,385 bytes; build N2 |
| N2(S) | New N2 | Q3: 107,059,385 bytes; build N3 |

Q1 differs from Q2. Q2 and Q3 are byte-identical, SHA-256
`f3ff63b04b58e5a5b92be781d0d1cba8cc574a37765cbf66d817c3d38f4b576e`.
The final qualified image is N3,
`selfhost/build/phase111/p131-final-native01-n3/program`, SHA-256
`c00778cf4f79088b1ed015e763e42958dec92b0866f7de284469b18ce023a27f`.
This is a QBE output fixed point, not a claim that the ELF files are identical.

[Native qualification](native-qualification.json) binds the exact source,
checked API, producer, runtime, machine-build tools and all three native images.
Both N2 and N3 passed the focused 19-case gate (16 successful programs and three
expected refusals); N3 also passed all 45 ordinary program cases. The
[admission](acquisition-admission.json) retains the 98 finite controls, three
ordinary and four feature-transfer programs, inherited controls with their
source identity, and exact proof-body connections. Eleven declaration bodies
match five accepted proof receipts. That proof scope does not establish the
correctness of arbitrary term traversal, all callers, or the whole compiler.

## Measurements kept separate

The compiler timing blocks each contain three requests, three rounds and three
roles, with all 27 outputs correct and all 18 native QBE outputs matching their
reference. They measured **N2**, not N3:

- [Parent comparison](timing-summary.json): N2 compiler-request time is
  0.790787 times Phase 130 N1 (20.92% lower), and 1.443045 times upstream.
- [Same-source comparison](stage-timing-summary.json): N2 compiler-request time
  is 0.893647 times N1 (10.64% lower), and 1.426829 times upstream. Both native
  images implement the same final compiler source; their generation differs.

Those are separate measurement windows and a small three-request corpus.
Compiler-request time excludes the downstream machine build; the reports also
retain the distinct ready-executable clock. No N3 timing is inferred.

[Program equality](program-equality.json) independently emitted all 45 program
wrappers with N2 and found each complete QBE product byte-identical to the
checked-API product used for the [program runtime screen](program-runtime.json),
with the same cached runtime and exact measured binary. The runtime screen has
405 observations: 45 cases × three roles × three rounds. The equality join
connects the candidate role's 135 observations to N2-generated code; it does not
turn those program timings into compiler timings or into measured N3 timings.

## Restore and use

Run commands from the repository root. The gzip file uses an empty embedded
filename and zero timestamp. Restore into a fresh directory:

```sh
mkdir selfhost/build/phase131/restored-final01
gzip -dc implementation/phase131/final/compiler-source01.bend.gz > selfhost/build/phase131/restored-final01/compiler.bend
sha256sum selfhost/build/phase131/restored-final01/compiler.bend
```

The hash must equal the source hash above. [source.json](source.json) records the
exact decompression check and compression environment. This source capsule does
not bundle the native binaries, 100 MB QBE products, toolchain, or all raw
historical dependencies; those remain separately pinned at their recorded paths.

For an ordinary source request, use the authenticated request wrapper and a
fresh output directory. Replace `path/to/program.bend` with the requested source:

```sh
python3 -B selfhost/tools/performance/phase130/native-request.py \
  --image selfhost/build/phase111/p131-final-native01-n3/program \
  --source path/to/program.bend \
  --carrier-receipt selfhost/build/phase130/base-carrier01/receipt.json \
  --out selfhost/build/phase130/p131-user-request01 \
  --seconds 60
```

It retains the complete QBE stdout, diagnostics, source/image/runtime/carrier
identities and elapsed request time. The compact Base carrier and cached runtime
are inherited unchanged from the qualified Phase 130 selection. To make a
machine executable from that QBE:

```sh
python3 -B selfhost/tools/performance/phase123/build-aligned.py \
  --source selfhost/build/phase130/p131-user-request01/program.ssa \
  --runtime selfhost/build/phase128/runtime-borrow01/runtime.o \
  --out selfhost/build/phase111/p131-user-build01 \
  --seconds 60
```

To reproduce the full compiler QBE with the qualified N3 image, use the restored
source and a fresh output directory. This checks the entire raw QBE product:

```sh
python3 -B selfhost/tools/performance/phase130/native-request.py \
  --image selfhost/build/phase111/p131-final-native01-n3/program \
  --source selfhost/build/phase131/restored-final01/compiler.bend \
  --carrier-receipt selfhost/build/phase130/base-carrier01/receipt.json \
  --out selfhost/build/phase130/p131-user-self01 \
  --expected-qbe selfhost/build/phase130/p131-final-reproduce01/program.ssa \
  --seconds 600
```

The retained qualification established N2(S) = Q3; the command above is a new N3
request and is provided as a reproducibility recipe, not a previously run gate.
The frozen qualification binder at
`selfhost/tools/performance/phase131/native/qualify-final.py` can revalidate the
retained N0→N1→N2→N3 receipts without running compiler targets; the original
inputs and tool binaries must still exist.
