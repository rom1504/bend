# Remaining native-runtime gap: Phase122

[Design](../../../../design/phase122/remaining-gap-profiles.md) ·
[Report](../../../../implementation/phase122/README.md) ·
[Results](../../../../implementation/phase122/results.json).

The compiler is unchanged. These tools authenticate and execute existing products
on the frozen45 source/count/oracle contract. Ten selected cases compare current
experimental Phase121 QBE, mature Phase102 selfhost C and pinned upstream C.
Compiler vintages and machine toolchains differ: this does not isolate the QBE
optimizer. Python handles measurements and receipts; it is not a compiler stage.

`survey.py freeze` creates `selfhost/build/phase122/manifest01.json` once. Existing
artifacts must be present; missing inputs fail rather than rebuilding implicitly.
Fresh clean measurements use three rotated rounds and identical counts for all
roles. Profiles scale counts independently to about5.5s, use8/13ms periods and
never enter timing ratios. Every run checks complete outputs and batch counts.

Run serially, using fresh paths:

```sh
python3 -B selfhost/tools/performance/phase111/guard.py \
  --seconds 120 --rss-mib 2048 --available-mib 16384 --file-mib 64 --cpu 3 \
  --out selfhost/build/phase122/NEW-clean-guard -- \
  python3 -B selfhost/tools/performance/phase122/survey.py clean \
  --out selfhost/build/phase122/NEW-clean

python3 -B selfhost/tools/performance/phase111/guard.py \
  --seconds 480 --rss-mib 2048 --available-mib 16384 --file-mib 64 --cpu 3 \
  --out selfhost/build/phase122/NEW-profile-guard -- \
  python3 -B selfhost/tools/performance/phase122/survey.py profile \
  --clean selfhost/build/phase122/NEW-clean/report.json \
  --out selfhost/build/phase122/NEW-profile
```

Both modes accept `--names` to restrict the loop. The original complete screen
took47s and profiling333s. No compiler image or generated program was rebuilt.

`analyze.py` is the frozen analysis for `manifest01`, `clean01`, `profile01`.
It checks150 outputs, replays60 physical-PC analyses, verifies zero loss and
sample coverage, and writes results only to a fresh destination. To analyze a
new campaign, version the method with new input/output paths. Do not overwrite
the committed result. Categories are convenience labels for exclusive leaves;
inlined work has different boundaries in the three products. No caller identity,
allocation count or causally removable share follows from these labels alone.
The exact local libc identity guards the inherited copy/fill address ranges.

The small evidence capsule keeps raw outputs, sample PCs, mapping tables,
analysis receipts and methods. It omits external ELF/source/toolchain artifacts,
whose identities remain in the manifest. Integrity replay works without those
artifacts; rerunning machine attribution needs the exact originals:

```sh
python3 -B selfhost/tools/performance/phase122/seal.py replay \
  implementation/phase122/evidence/receipts01.tar.gz
```

The wrapper reuses the Phase121 bounded archive implementation. Its original
method and the Phase122 wrapper are both included. Static source/machine audits
are committed alongside the report. Historical JS analysis is used only for
semantic-plan reuse; no fresh JS speed claim is made in this phase.
