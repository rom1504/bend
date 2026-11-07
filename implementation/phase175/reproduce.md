# Reproduce the provisional Phase175 experiments

Start from the maintained source published by Phase174, with the unchanged
`assets-native.json` selecting the qualified Phase171 QBE compiler. The canonical
source hash is `74cd7de3e5076490e20ba0218d4c9254853be72562946b9ef66fed6c10c7a53a`.
The fixed timing input is `selfhost/build/phase170/source-final/compiler.bend`,
SHA256 `434edd1d56128f9480800573abf8a0ae21d910a547837af089f25cd1d0e89b71`.
Do not substitute a newer changing-source self-build and compare its time with
these fixed-input observations.

## Exact retained evidence

[`evidence-index.json`](evidence-index.json) lists the report path, SHA256 and
byte size for each recorded run, including failed attempts. The reports carry
exact source/image/runtime/toolchain identities and commands. Native comparison
reports additionally carry each process invocation and its separate clocks.
The index is a metadata snapshot, not an archive or a claim that every report
passed. Pending campaigns must acquire new reports rather than mutate these.
Lossless compact copies are indexed in [evidence/index.json](evidence/index.json).
They preserve original report bytes and absolute artifact references. Large
sources, generated products and multi-megabyte source-operation manifests remain
local; the copy set is intentionally not a self-contained reproduction capsule.

Historical method hashes are evidence of what ran, not a promise that those
exact method bytes remain at the live working-tree path. The precedence and
field value receipts precede comparator updates. The current comparator is
SHA256 `9eff7115e15dd1bfa5db5af56de3083a8a76c2cddcef62c90fd5ea4f627b7ea9`;
current method pins and the two historical mismatches are recorded in
`metrics.json.methodVersionLimitations`. Authenticate exact historical methods
if replaying that experiment version, or make a fresh receipt for the current
method. Do not rewrite old input pins to make a new method appear identical.

Core receipts under `selfhost/build/phase175/`:

| Purpose | Report directories |
|---|---|
| Full diagnostic service |`baseline-api03`, `baseline-native01`|
| Smaller parser service |`parse-baseline-api01`, `parse-baseline-native01`, `parse-route-values01`|
| Lookahead |`lookahead-api03`, `lookahead-values01`, `parse-lookahead-api01`, `parse-lookahead-values01`, `parse-lookahead-native02`, `parse-lookahead-pair01`|
| Precedence |`precedence-api04`, `precedence-values01`, `parse-precedence-native01`, `parse-precedence-pair01`|
| Field quantities |`field-api03`, `field-values01`, `field-native01`, `field-full-screen01`|
| Report names |`report-baseline-api01`, `report-api01`, `report-values01`, `report-native01`, `report-full-screen01`|
| Publication |`publication-baseline-api05`, `publication-api04`, `publication-probe01`, `publication-values02`, `publication-native01`, `publication-full-screen01`|
| Full frontend reference |`frontend-full-baseline01`|
| Selected combined frontend |`combined-source01/manifest.json`, `combined-api01`, `combined-values01`, `combined-values02`, `combined-native01`, `combined-full-pair01`|
| Full source preparation, not qualification |`full-source01`; proof-safety refusal in `full-source-check01-guard/process.json` and `stderr.log`|
| Independent full-source type acceptance |`full-source-check02`, with its completed guard; no candidate emission or execution|
| Incomplete C diagnostic |`upstream-c-ceiling01`|

The original publication comparison failure is `publication-values01`; the
corrected run does not count the parser-rejected duplicate-constructor input as
a compact-checker hit. API source failures and the disk-stopped native attempt
remain indexed separately.

## Recheck existing candidate values

These commands execute targets and belong to the single coordinating execution
lane. They use fresh output names; do not overwrite the retained evidence. The
job helper applies the existing CPU3, RSS, process-tree and disk guards and closes
each run. Check free space against the normal reserve plus the declared budget.

```sh
python3 -B selfhost/tests/phase175/job.py lookahead-values-recheck01 120 32 \
  selfhost/.assets/bin/bun selfhost/tests/phase175/compare-frontends.mjs \
  --baseline selfhost/build/phase175/baseline-api03/report.json \
  --candidate selfhost/build/phase175/lookahead-api03/report.json \
  --binding selfhost/build/phase175/baseline-source03/base-binding.json \
  --kind parser --modes parse,request \
  --out selfhost/build/phase175/lookahead-values-recheck01

python3 -B selfhost/tests/phase175/job.py report-values-recheck01 120 32 \
  selfhost/.assets/bin/bun selfhost/tests/phase175/compare-frontends.mjs \
  --baseline selfhost/build/phase175/report-baseline-api01/report.json \
  --candidate selfhost/build/phase175/report-api01/report.json \
  --binding selfhost/build/phase175/baseline-source03/base-binding.json \
  --kind report --modes request \
  --out selfhost/build/phase175/report-values-recheck01
```

The helper authenticates both checked APIs, compares complete constructor values
and diagnoses failures independently of the candidate digest. For fields, use
`--kind semantic --modes request`; for publication use `--kind publication
--modes check,request --case-prefix publication-` with its corresponding baseline
and candidate receipts. Do not replace exact value comparisons with equal hashes.

The selected combination's final complete-value gate is reproduced by using
`combined-api01` as candidate and `--kind stages --modes parse,request`, with no
case-prefix filter. That checks all 14 ordinary source cases and their unchanged
request reference. The earlier `combined-values01` deliberately selected only
three transfer cases; it is not the final combination coverage.

## Repeat the native parse pair

```sh
python3 -B selfhost/tests/phase175/job.py lookahead-pair-recheck01 180 8 \
  python3 -B selfhost/tests/phase175/native-frontend.py \
  --baseline selfhost/build/phase175/parse-baseline-native01/report.json \
  --candidate selfhost/build/phase175/parse-lookahead-native02/report.json \
  --binding selfhost/build/phase175/parse-baseline-source01/base-binding.json \
  --source selfhost/build/phase170/source-final/compiler.bend \
  --mode parse --rounds 2 --seconds 60 \
  --expected selfhost/build/phase175/parse-lookahead-pair01/report.json \
  --out selfhost/build/phase175/lookahead-pair-recheck01
```

The historical pair used `--rounds 1`; this example uses two rounds to reverse
role order on the second cycle. The complete process includes reads, Base,
frontend, digest and teardown. `frontendSeconds` deliberately excludes the
separately measured digest. The complete frontend request mode's roughly
eight-second digest is substantial and must remain visible in cost reporting.

For a frontend candidate screen, select mode `request` and use the full
diagnostic service. To obtain a genuine paired result, supply both baseline and
candidate receipts in the same run. The retained field/publication/report
screens instead use separate single-image runs and remain labeled as such.

The complete combined frontend pair uses the same runner, with
`baseline-native01` and `combined-native01`, the full-service binding
`baseline-source03/base-binding.json`, and `--mode request --rounds 2 --seconds 90`.
Use a fresh output and a 360-second outer job budget. The retained
`combined-full-pair01` establishes the supplementary full-input observation.
Its baseline/candidate/candidate/baseline sequence is a component benchmark,
not a full cold source-to-executable build.

## Reacquire source and native services when needed

`selfhost/tests/phase175/frontend-prepare.py` is metadata-only. It composes the
exact maintained source with explicitly listed overrides and protected-declaration
checks, then extracts the requested dependency closure. Recorded source
manifests preserve module lists, replacement hashes, exports and Base binding.
For the smaller parser service use `frontend-parse-plan.bend`,
`frontend-digest.bend`, and `frontend-parse-native.bend`; the complete service uses
`frontend-plan.bend` and `frontend-native.bend` instead. Never accidentally root
the complete request API when measuring parser-only acquisition.

Use the maintained `hosted.mjs acquire` for independent API source checking and
`native.py --assets selfhost/manifests/assets-native.json --image-key qbe-n2
--host native --stage N2 --target qbe --mode cache` for diagnostic executable
construction. Copy the exact remaining arguments from the relevant retained
acquisition receipt, substituting fresh output paths. Native acquisition's
`wallSeconds` includes emission and machine construction; `emitAndQbeSeconds`
alone is not the complete cost.

`full-source01/report.json` is a metadata-only full-source composition receipt.
The source is 3,163,584 bytes with SHA256
`a0e953a84de73aa22403dde7ec2144540197633857a0f7b5b9784f9e66f5ad04`.
It retains the canonical program and native main, replaces three frontend
definitions, inserts 19 declarations and records exact inverse reconstruction.
This source has not yet passed full native qualification. The first upstream
CLI attempt refused its proof-safety policy because of unsafe/foreign
dependencies; do not classify that as a source type error or a successful
source-only check. The separate `full-source-check02` then passed unmodified
upstream `book_load`, `book_valid` and zero unresolved holes; it explicitly does
not assess proof safety or invoke BendTT. Follow the separate
[full-candidate protocol](../../experiments/phase175/full-candidate.md) for the
remaining independent checks; no installed selector is changed by preparation.

No full compiler acquisition, candidate installation, broad runtime campaign or
storage pruning is required to repeat these component experiments. Those are
separate decisions after the pending whole-request and generated-code gates.
Historical storage restoration commands and exact archive receipts are in
[storage-recovery.md](../../experiments/phase175/storage-recovery.md).
