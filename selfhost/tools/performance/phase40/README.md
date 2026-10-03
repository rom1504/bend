# Phase40 reusable evidence tools

Run from the repository root. Root owns compiler builds and program executions;
these tools only package saved bytes or record evidence. Preserve all closed
Phase39 directories and choose new outputs.

## Starting baseline

Repackage the portable Phase39 checked05 modules as the incremental baseline,
with the unchanged pinned TypeScript modules. This derivative of Phase39's
freezer uses the maintained bundle verifier and does not depend on the ignored
checked05 build. It retains the complete original manifests, provenance and
archives, reopens every output archive member, and checks input identities again.

```sh
python3 selfhost/tools/performance/phase40/freeze-baseline.py \
  --current selfhost/tools/performance/phase39/current/manifest.json \
  --reference selfhost/tools/performance/phase39/baseline/manifest.json \
  --catalog selfhost/tools/performance/phase37/catalog.json \
  --expected-api 04d9ebf417a20297598bb6b047936a02228f3b8fb3a3b0cc4b59eeea04bad49f \
  --out selfhost/tools/performance/phase40/baseline
```

Reuse [the existing execution guide](../phase39/README.md) with this new
`--baseline`, Phase37's explicit catalog, and fresh `selfhost/build/phase40`
outputs. Reuse `programs/prototype.py --from phase39/current/manifest.json`
for saved-output screens (supply full paths and the explicit Phase37 catalog).
Prototype output remains unchecked. Reuse `programs/prepare.py --attempt ...`
for actual checked emissions. Every timing selection needs an unchanged-byte
control. Preparation and timing own the resource lock; do not nest a supervisor.

Use the existing checked development workflow for builds. The unchanged
`phase39/development.json` is reusable because its paths resolve against that
file. The maintained Phase37 final-integration planner accepts `ATTEMPT OUT
--prepared MANIFEST`; its frozen plan lists the exact serial gates. It and the
existing final gate auditor preserve historical assertions and source boundaries.
New semantic controls remain explicit evidence; this accounting tool is not an
auditor and does not create an admission decision.

## Append-only campaign accounting

`campaign.py` records decisions, exact bounded-run receipts and module/report
hashes. It never starts a command. Record small commands with their observed
UTC epoch start and elapsed seconds; omit an interval when unavailable rather
than guessing. `start --at` can capture a known earlier campaign boundary.
Reports use a fresh output directory, preserving prior summaries and events.

```sh
python3 selfhost/tools/performance/phase40/campaign.py \
  --ledger selfhost/build/phase40/campaign.jsonl start
python3 selfhost/tools/performance/phase40/campaign.py \
  --ledger selfhost/build/phase40/campaign.jsonl event --label checked01 \
  --receipt selfhost/build/phase40/checked01-supervisor/run.json \
  --decision 'Focused checked gate completed; execution admission remains open' \
  --file selfhost/build/phase40/checked01/attempt.json
python3 selfhost/tools/performance/phase40/campaign.py \
  --ledger selfhost/build/phase40/campaign.jsonl report \
  --out selfhost/build/phase40/accounting01
```

Elapsed tool seconds are summed; overlapping intervals are merged separately
for wall coverage. Unclassified wall time includes reasoning, editing, waiting
and tools not recorded. It is neither token generation time nor a model speed
measurement. This campaign alone cannot establish an effort/model comparison.
Command failures and rejected decisions can be recorded with their original
receipts. Raw intervals, module hashes and exact command arrays remain in JSON;
the Markdown tables are a convenient view of those records.
