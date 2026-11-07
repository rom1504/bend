# Reproduce Phase176

Run from the repository root. All output paths must be fresh. These commands
require the pinned assets, prepared Base and prior images identified by the
reports; they do not download or manufacture replacement compiler generations.
See Phase175's reproduction guide if its images need reacquisition.

## Screening throughput

The manifest contains the same four historical comparisons for every worker
configuration. Run serial and parallel batches one after another, not together.

```sh
python3 -B selfhost/tests/phase176/job.py --cpu 3 serial-FRESH 150 8 \
  python3 -B selfhost/tests/phase176/batch.py \
  --manifest experiments/phase176/calibration-small.json --cpus 3 \
  --out selfhost/build/phase176/serial-FRESH

python3 -B selfhost/tests/phase176/job.py --cpu 3,5 parallel-FRESH 120 8 \
  python3 -B selfhost/tests/phase176/batch.py \
  --manifest experiments/phase176/calibration-small.json --cpus 3,5 \
  --out selfhost/build/phase176/parallel-FRESH

python3 -B selfhost/tests/phase176/job.py --cpu 0,1,2,3 four-FRESH 120 8 \
  python3 -B selfhost/tests/phase176/batch.py \
  --manifest experiments/phase176/calibration-small.json --cpus 0,1,2,3 \
  --out selfhost/build/phase176/four-FRESH
```

The host has SMT siblings 0/4, 1/5, 2/6, 3/7. Reconsider affinities on other hosts.
The final runner admits only the documented nondetaching payloads. Older
calibration receipts used `experiments/phase176/batch-screen-v1.py`; the scheduling
loop is unchanged, with a subsequent payload restriction. Reproduce the historical
method explicitly if exact harness identity matters; use the maintained restricted
runner for new work. The first interrupted threaded runner was not retained.

## Native traversal experiment

The exact small workload source snapshots and full command receipts are retained
as `implementation/phase176/evidence/` members of `evidence.tar.gz`. Restore with
`tar -xzf implementation/phase176/evidence.tar.gz -C .` at the repository root.
To regenerate the single-loop source from maintained Bend:

```sh
python3 -B selfhost/tests/phase176/prepare.py \
  --module selfhost/tests/phase173/borrow-compiler-pattern.bend \
  --module selfhost/tests/phase173/borrow-consuming-controls01.bend \
  --module selfhost/tests/phase175/frontend-values.bend \
  --module selfhost/tests/phase173/borrow-compiler-digest-support.bend \
  --module selfhost/tests/phase176/pattern-native.bend \
  --module selfhost/tests/phase176/pattern-single.bend \
  --prelude selfhost/tests/phase176/pattern-single-prelude.bend \
  --replace f_pattern_sub --replace f_pattern_value --native-main \
  --export p173bfp_small --export p173bfc_result \
  --export p175fv_actual --export p175fv_expected \
  --export f_pattern_sub --export f_pattern_value --export p176pn_run \
  --out selfhost/build/phase176/single-source-FRESH
```

The measured source SHA is
`49d096d19ba2089c1da6c3120d8411094ca22b57e7d77768193787a8e83a2434`.
Source-map compaction changes metadata only, not the source or declarations.
The candidate native workload uses Phase175 N2 image
`88be8d8627ed84f5cf4ebb84bafa96c890b074fa49803056d6fd8a52fd8aaa02`.
Acquire through `native.py` directly inside `job.py`, with explicit image receipt,
`--host native --stage N2 --target qbe --mode cache --retain-ir`; use the recorded
native build commands with fresh outputs. Do not put native.py inside batch.py.

`pattern-controls.mjs` takes `--baseline`, `--candidate`, `--out` checked API
receipts. Both APIs must be independently acquired by the pinned upstream
`hosted.mjs acquire`. `pattern-oracle.mjs BASELINE CANDIDATE OUT` produces the
bounded native expected stdout from checked Bend execution. Then:

```sh
python3 -B selfhost/tests/phase176/job.py kernel-FRESH 30 8 \
  python3 -B selfhost/tests/phase176/native-screen.py \
  --baseline selfhost/build/phase176/pattern-native-baseline01/report.json \
  --candidate selfhost/build/phase176/pattern-single-native01/report.json \
  --expected selfhost/build/phase176/pattern-oracle01/expected.stdout \
  --rounds 6 --out selfhost/build/phase176/kernel-FRESH
```

## Real parser transfer

`prepare.py --snapshot-parser` authenticates the exact historical 358,267-byte
parser source (`3f104e77…`), keeping its declaration order. Add `parser-main.bend`,
the single-loop module and its prelude, with the same two replacements and
`--native-main --export p175fp_plan`. The measured candidate source is
`58fab5bd90460e342c7ddba345aad274800dda206ccb4e47ac1a547524024cfa`.

Build this candidate with **installed Phase171**, image
`8214b3f3400b0d0bead3ef137e6d8b75b8c8b18f6da012dfa4673e4468d9f2ac`,
matching the historical parser reference. This intentionally differs from the
producer used for the tiny native workload. Runtime and QBE machine policy match
within each comparison. Check the original request/image identities, not just
an image selector that may later change.

```sh
python3 -B selfhost/tests/phase176/job.py full-parse-FRESH 140 8 \
  python3 -B selfhost/tests/phase175/native-frontend.py \
  --baseline selfhost/build/phase175/parse-lookahead-native02/report.json \
  --candidate selfhost/build/phase176/parse-single-native01/report.json \
  --binding selfhost/build/phase175/baseline-source03/base-binding.json \
  --source selfhost/build/phase170/source-final/compiler.bend \
  --mode parse --rounds 2 --seconds 40 \
  --out selfhost/build/phase176/full-parse-FRESH
```

For complete parser values, acquire **both** checked APIs afresh against the
current manifest using `experiments/phase176/parser-exports.json`; the original
Phase175 API report has a stale compiler.json pin. Run
`phase175/compare-frontends.mjs --kind stages --modes parse` with these two receipts
and the prepared-Base binding. Do not edit an old receipt to make it pass.

## Evidence and storage

`metrics.py` reads finished runs only. `retain.py` captured exact reports, logs
and small source snapshots before sealing; the final byte-verified tar archive
replaces the loose capture at HEAD. Nested gzip files decompress normally. Large metadata source
manifests retain explicitly derived selected-declaration provenance summaries.
`evidence-index.json` records the archive hash, raw-evidence commit, restore command,
distinguishes original hashes from retained hashes and marks
`exact=false` for those summaries. Original source manifests remain local. No
whole compiler source, API, native image or machine product is duplicated here.

The generated parser sources and executing images remain build prerequisites.
Their identities and original construction inputs/commands are recorded. This
is not a claim that a fresh clone already contains every executable artifact.

`storage-applied.json` and its journal record exact hardlink deduplication of 45
Phase175 QBE copies to their original Phase169 references. Both paths still exist.
Never overwrite either alias; use fresh build roots. This storage action is
separate from compiler correctness and performance.
