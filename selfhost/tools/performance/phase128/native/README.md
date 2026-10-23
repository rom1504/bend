# Phase128 native entry binding

`prepare.py` is an artifact binder, not a compiler or a qualification runner.
It connects a previously checked combined Phase128 experiment to the existing
native entry after the hosted measurements justify native acquisition. It does
not execute Bend, compile native code, or change the installed selection.

Root-run invocation, using the actual frozen combined-source and checked-API
receipts (replace the capitalized paths):

```sh
python3 selfhost/tools/performance/phase128/native/prepare.py \
  --source-manifest COMBINED_SOURCE/manifest.json \
  --api-report CHECKED_COMBINED_API/report.json \
  --runtime-report selfhost/build/phase128/runtime-borrow01/report.json \
  --out selfhost/build/phase128/native-source01
```

The input must be a direct declaration composition from the exact Phase127
live-bank parent, with the shared-preparation/borrow combination present and
`p128raw_emit_admitted` exported by its checked API. The binder authenticates the
complete ordered module replay, snapshots and input identities. It then checks
the protected original verifier declarations and the inherited runtime/library
contracts. The scalar-borrow runtime must be the exact Phase126 runtime plus
the unchanged scalar-root guard, built with the same compiler and flags.

The sole source change is the exact original `p111_emit_admitted` declaration:

```bend
@unsafe
def p111_emit_admitted(+request: NR_Request, +error: String) -> P111Emission:
  p128raw_emit_admitted(request,error)
```

The output manifest records its old/new declaration bytes, a reversible
whole-source identity check, unchanged verifier inventory, input identities,
and a source-bound runtime contract. **The output remains unchecked and
unqualified.** The old Phase126 ABI receipt supplies inherited contract
authority; it is not qualification of this new source.

Next acquire a **new checked API of this exact output source**, including the
manifest's `requiredNextExports`, and rerun the finite controls and relevant
byte-identical emitted-QBE comparisons against the original admitted entry.
Only then use the separately documented hosted → N1 → N2 acquisition and
independent native gates in
[`native-acquisition-notes.md`](../../../../../implementation/phase128/native-acquisition-notes.md).
The pending runtime contract must be combined with that fresh checked-source
evidence before being treated as admissible by an acquisition tool. It does
not itself grant ABI admission or permit installing the candidate.

See [MEASURE.md](MEASURE.md) for early N1 timing, complete native qualification,
N1/N2 timing, and native acquisition of the historical runtime wrappers.
