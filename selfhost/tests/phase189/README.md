# Direct-object default qualification

Run from the repository root. The compiler algorithms are unchanged from
Phase188. These scripts select, authenticate, qualify and publish its x86 N2;
they do not implement code generation. Read the [design](../../../design/phase189/README.md)
and [report](../../../implementation/phase189/README.md).

The retained N1 is `selfhost/build/phase188/native-image05/program`, produced by
the qualified Phase186 QBE N2. It built
`selfhost/build/phase188/native-self-object05/program` (actual x86 N2) from
`selfhost/build/phase188/source05/compiler.bend`. The retained Phase189 N3 uses
that actual N2 and the identical source, with `native.py --emit object
--expected-object selfhost/build/phase188/native-self-object05/program.o
--output-stage N3 --output-protocol native-x86-source-v1`. The completed
`native-n3-01/report.json` records the actual command and exact object identity.
Its tools were copied from commit 2c5b759 before concurrent adapter edits.

Freeze `selfhost/manifests/assets-native.json` into
`selfhost/build/phase189/assets-gates.json` before qualification. The image
selection remains explicit; publication later cannot invalidate this input.
Use fresh output roots for a rerun. Every target job uses one outer resource
and disk guard; `job.py` also records retention closure and enforces the 5GiB
reserve. Do not run these jobs concurrently.

```sh
python3 -B selfhost/tests/phase189/job.py --rss-mib 3072 \
  native64-01 600 256 \
  python3 -B selfhost/tools/build/qualification.py \
    --assets selfhost/build/phase189/assets-gates.json \
    --image selfhost/build/phase188/native-self-object05/program \
    --image-receipt selfhost/build/phase188/native-self-object05/report.json \
    --host native --stage N2 --target x86 --emit object --mode cache \
    --suite all --seconds 45 --build-seconds 45 --execute-seconds 15 \
    --out selfhost/build/phase189/native64-01

python3 -B selfhost/tests/phase189/job.py --rss-mib 3072 \
  runtime10-01 300 128 \
  python3 -B selfhost/tests/phase183/runtime-controls.py \
    --assets selfhost/build/phase189/assets-gates.json \
    --image selfhost/build/phase188/native-self-object05/program \
    --image-receipt selfhost/build/phase188/native-self-object05/report.json \
    --host native --stage N2 --mode cache \
    --out selfhost/build/phase189/runtime10-01
```

The second adapter intentionally omits `--emit`; nested build receipts must
show that the executable builder's default produces objects. The release audit
checks these receipts. Source acceptance, these finite semantic gates and
native self-reproduction establish different properties; none is a theorem of
compiler correctness.

`release-inputs.json` binds the actual current-generation evidence and the
previous canonical source snapshot. Preparation authenticates the old selected
release, preserves its JS/C/QBE components and gates, independently assembles
the x86 source profile, and audits the concrete object lineage. It stages exact
rollback copies and proposed operational maps, but does not install anything.

```sh
python3 -B selfhost/tests/phase189/prepare-release.py \
  --recipe selfhost/tests/phase189/release-inputs.json \
  --out selfhost/build/phase189/release-proposal01
python3 -B selfhost/tools/build/release.py install \
  --manifest selfhost/build/phase189/release-proposal01/promotion.json \
  --out selfhost/build/phase189/install01
python3 -B selfhost/tests/phase189/publish-assets.py \
  --proposal selfhost/build/phase189/release-proposal01/report.json \
  --out selfhost/build/phase189/publish-assets01
```

Installation retains all replaced files and the old selector in `install01`;
its report maps original paths to rollback files. Publication retains all three
old operational maps and restores them on failure. The old selector's missing
`defaultEmission` means assembly, so restoring both selector/files and maps
restores its original behavior. Never restore only half of that binding.

Finally run `selfhost/tests/phase183/public-x86.py --out
selfhost/build/phase189/public01` under `job.py` (128MiB disk, 3GiB RSS and
600s wall allowance). It tests real public assembly/ELF/run routes, arguments,
C/JS compatibility, type refusal and output protection. Then `collect.py`
checks completed receipts and unchanged component identities and writes the
committed evidence. Collection executes no target.

Metadata-only controls:

```sh
python3 -B selfhost/tests/phase189/test_object_gates.py
python3 -B selfhost/tests/phase189/test_public_object.py
selfhost/.assets/bin/bun selfhost/tests/phase189/public-shell.test.mjs
python3 -B selfhost/tests/phase189/test_release_preparation.py
python3 -B selfhost/tests/phase189/test_publish_assets.py
python3 -B -m unittest discover -s selfhost/tools/build -p 'test_release*.py'
```

The build tests use synthetic process fixtures and mocked target execution.
They cover exact-object bootstrap failures, binary/text separation, all 64
catalog cases, refusal stages, output/argv/status behavior, independent source
checking, actual producer execution, admission mismatches and transactional
rollback. They complement the real gates above.
