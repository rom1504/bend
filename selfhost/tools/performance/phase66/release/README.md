# Phase66 release qualification

These tools prepare or inspect a release. Only the root executor may run the
installation or Node controls, after final compiler qualification and preservation
of the previous release. Producing a plan does not admit a release.

1. `release-qualification-plan-v1.py CHECKED_ATTEMPT FRESH_OUTPUT --plan FRESH_JSON`
   binds the selected checked snapshot, upstream `0592662`, Bend `2.0.36`, and
   35 exact JavaScript effect providers. Its exact parent derivation is recorded
   in `derivation-v1.json`.
2. `prepare-commands.py --plan PLAN --out FRESH_JSON` converts that plan to five
   serial guarded commands: install, verify, legacy42, default24, and verify
   again. The maintained 42 and 24 expectations are unchanged. Each command
   already has its sole resource guard; the serial launcher must remain unpinned.
3. After installation, `helper-integrity-v1.mjs SELFHOST CHECKED_ATTEMPT FRESH_OUT`
   checks the installed graph helper against the selected checked provenance,
   verifies a copied release, and rejects modified, missing, or unbound helpers.
   It changes only the fresh copied release. The exact seven-edit derivation
   preserves the prior five assertions while replacing a historical patch hash
   with the selected strict checked attempt and its frozen packager.
4. A selected-release data join must bind the actual closed plan, execution,
   helper controls, installed inventory, checkout files, and final compiler
   qualification. It must also verify all seven previous installed files in
   both release history and raw copies, plus all 110 inherited protected files.

`join-installed-v2.py` is the reviewed generic successor. It takes explicit
`--attempt`, `--plan`, `--commands`, `--execution`, `--helper`, `--admission`, and
fresh `--out` paths. Its receipt includes the seven current installed file
identities for archival verification. The earlier `join-installed.py` remains
an unconsumed 05-specific proposal. Keep previous plans and reports intact.
No missing test, native change, platform refusal, or upstream oracle failure
becomes a pass merely because an API hash matches.

For selected 07, the root launcher consumes `release07-commands.json`, then
`release-helper07-plan.json`, with separate fresh execution directories. Run
the serial launcher without an outer guard or CPU pin. The compiler join is
separate from root admission: `release-admission.json` must pin the completed
qualification and fresh preservation checks for seven previous installed files
and 110 inherited files before installation. The installed join rechecks those
files, both copies of the previous release, and all installed inventory entries.
Checkout entries present in the checked snapshot must match it; `cli.mjs` is
outside that snapshot and is bound by the installed inventory and release tests.

The final 07 root execution sequence, after the compiler receipt closes, is:

```sh
# Root first runs preinstall-preservation.py and writes release-admission.json.
python3 -B selfhost/tools/performance/phase55/run-retention-plan.py \
  selfhost/build/phase66/release07-commands.json \
  selfhost/build/phase66/release07-execution
python3 -B selfhost/tools/performance/phase55/run-retention-plan.py \
  selfhost/build/phase66/release-helper07-plan.json \
  selfhost/build/phase66/release-helper07-execution
```

Both launchers must finish successfully before the data-only installed join:

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase66/release/join-installed-v2.py \
  --attempt selfhost/build/phase66/checked-b1-07/attempt.json \
  --plan selfhost/build/phase66/release07-plan.json \
  --commands selfhost/build/phase66/release07-commands.json \
  --execution selfhost/build/phase66/release07-execution/report.json \
  --helper selfhost/build/phase66/release-helper07/report.json \
  --admission selfhost/build/phase66/release-admission.json \
  --out implementation/phase66/evidence/installed-release07.json
```

The admission record uses `complete: true`, `pass: true`, a `qualification`
file/hash identity, and two `preservation` file/hash identities carrying
`verifiedFiles: 7` and `verifiedFiles: 110`. The qualification path is
`implementation/phase66/evidence/compiler-qualification07.json`. These are
requirements for a future execution; commands in this document are not evidence
that installation has happened.

Selected 07 is now closed: the actual completed result is
[`installed-release07.json`](../../../../../implementation/phase66/evidence/installed-release07.json).
It records successful five-job release execution, 42/24/helper5 checks, and exact
current/prior/inherited identities. The above recipes remain unchanged records;
rerunning them requires fresh output paths and appropriate new admission.
