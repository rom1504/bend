# Phase173 bounded storage review

This review ran only metadata inspection and exact-byte hashing. It did not run a
compiler, create an archive, prune files, change retention state, or modify an
installed compiler. The inspected HEAD is recorded in
[storage-proposal.json](storage-proposal.json).

The defensible initial tranche is **358.8125 MiB allocated**: the eight generated
assembly/object leaves from four completed Phase171/172 cold comparisons. A
smaller older tranche adds **60.546875 MiB** from four completed Phase156 checker
emissions. The complete proposal contains **12 files in eight roots, 419.359375
MiB allocated**. These are raw allocations, not measured net recovery.

| Priority | Experimental roots | Exact selected leaves | Allocated MiB |
| --- | --- | --- | ---: |
| Initial | Phase171 `full-baseline01`, `full-candidate01` | Each `program.s`, `program.o` | 179.40625 |
| Initial | Phase172 `static-cold-baseline01`, `static-cold-candidate01` | Each `program.s`, `program.o` | 179.40625 |
| Optional older | Phase156 `pilot01/compiler-checker-0-{old,uses,publication,both}` | Each `program.ssa` | 60.546875 |

Every proposed leaf is an ordinary exclusive file, has no extended attributes,
and has a fresh SHA256 plus stable device/inode/size/mode/link/mtime/ctime
metadata. Its bytes match its original successful report. Every producing guard
is terminal and successful; each lifecycle is sealed/completed, not qualified.
The four Phase156 child files are recorded by their parent pilot report, whose
per-call output pins and independent byte-exact checks were inspected. The
shared `oracle-compiler-checker/program.ssa` remains hot.

## Why this is smaller than the requested 1–3 GiB

The bounded metadata scans covered Phase150–172 to depth three, and selected
older Phase111/134/137/144/146–149 roots to depth two. They did not walk the shared
filesystem or the complete historical build tree. Nearly all remaining large
products in that scope are qualified compiler generations, current profiler
inputs, or multiply linked files whose individual removal releases no allocation.

In particular, **both Phase170 `native-chain` and `native-chain-final` are
protected**. The initial chain has an explicit qualified retention classification;
being superseded for installation does not authorize stripping its artifacts.
Phase152/168/169 references, Phase171 `native-candidate01`, all profile objects,
ELFs, owners, unwind tables and samples, and Phase172 experimental runtime/link
products also remain hot. Legacy failed Phase111/134 products were inspected but
are not proposed: the existing bounded capture method requires a successful
completed original writer, and there is no need to relax it for this tranche.

The Phase172 archive receipt and prior recovery are not counted as new space.
No broader deletion is justified merely to meet a round recovery target.

## Operational references

A bounded scan of **281** current manifests, build/native/profiler methods and
Phase166–173 method files found no literal reference to a selected file. The one
matching root reference was reviewed directly:
`experiments/phase171/tools/candidate-profile.py` reads
`full-candidate01/report.json`, which remains hot. Its subsequent object/SSA
verification targets `native-candidate01`, not the selected cold-output object.
Those executable and profiler dependencies remain untouched.

This is a scoped operational audit, not a proof that no historical script can
refer to these products. Exact historical reproduction may require restoring the
archived members. All source, APIs, executable evidence, reports, original
requests, timing output and unlisted files remain available.

## Root-operated archival and recovery

The JSON is compatible with the unchanged
`experiments/phase169/archive-selected-v02.py`. The helper accepts a successful
parent report for the Phase156 child emission; the exact selected leaf remains
directly within the declared child root. Its output directory must still be
beneath `selfhost/build-retention/phase169/`; use fresh `p173-` names.

Serialize each capture/apply with the execution lane. The frozen helper's internal
floor is 4 GiB, so the root controller must independently require the current
**5 GiB reserve plus the 32 MiB per-root archive budget** before capture and
recheck the reserve afterward. No compiler target should run concurrently.

For one reviewed row:

```sh
python3 -B experiments/phase169/archive-selected-v02.py \
  --proposal experiments/phase173/storage-proposal.json \
  --name p171-full-baseline01 \
  --out selfhost/build-retention/phase169/p173-p171-full-baseline01
```

The method authenticates inputs, captures only the selected leaves, reopens and
hash-verifies every archive member, verifies unchanged source identities/modes,
and emits a precise plan. It does not delete. Inspect `capture.json` and
`verified/plan.json` before root applies the selected plan:

```sh
python3 -B selfhost/tools/build-retention/archive-v02.py apply \
  --plan selfhost/build-retention/phase169/p173-p171-full-baseline01/verified/plan.json \
  --out selfhost/build-retention/phase169/p173-p171-full-baseline01/applied
```

Restore exact members with a fresh receipt directory:

```sh
python3 -B selfhost/tools/build-retention/archive-v02.py restore \
  --plan selfhost/build-retention/phase169/p173-p171-full-baseline01/verified/plan.json \
  --out selfhost/build-retention/phase169/p173-p171-full-baseline01/restored-01
```

Apply only approved rows and stop when there is adequate room. Preserve capsule,
plan, original lifecycle, restoration location and apply/free-space receipts.
A changed file, shared inode, exhausted archive budget or reference ambiguity is
a refusal; it is not permission to weaken checks. Only the apply receipt can
establish actual net recovery.
