# Phase41 campaign accounting

Reuse `selfhost/tools/performance/phase40/campaign-v2.py`; it already writes an
append-only JSONL ledger, accepts absolute intervals, and emits canonical JSON
and Markdown reports. Do not add a second accounting framework. Phase40 used
the same tool / schema boundary: merged machine-job intervals, declared
observation windows, and unclassified wall time remain separate quantities.

The current portable bundle manifest inspected for this design is
`selfhost/tools/performance/phase40/current/manifest.json`: complete schema-1
`bend-program-bundle`, upstream `018751270e800bc222a93dad7f257083ee53a5f7`,
45 cases, SHA-256
`59f74c5e4d7ccbfa50a9e84e8430ed08dda2ff1e42c319f544da666e45c2f94d`.
Record this manifest as an input to the root's opening event.

## Recording recipe

Root owns the raw ledger at `selfhost/build/phase41/campaign.jsonl`. Start a
fresh campaign once, at the actual beginning of the root job:

```sh
python3 selfhost/tools/performance/phase40/campaign-v2.py \
  --ledger selfhost/build/phase41/campaign.jsonl start
python3 selfhost/tools/performance/phase40/campaign-v2.py \
  --ledger selfhost/build/phase41/campaign.jsonl event \
  --label opening-inputs --decision 'Phase41 portable bundle input' \
  --file selfhost/tools/performance/phase40/current/manifest.json
```

For a bounded command, let the existing bounded runner write `run.json`, then
append its exact interval and command. For an unwrapped command, capture its
actual start and end epoch seconds at launch/completion, then append one event
with `--start START --seconds ELAPSED --command 'exact command'`; label this
interval operator supplied. Do not add a parent command interval on top of
nested receipts. Event intervals describe machine jobs only; overlapping job
intervals are unioned for wall coverage.

At each root or agent stage boundary, capture UTC epoch seconds and later add a
`window`, which describes the observed session span, not compute time. Example
for a completed stage (substitute captured numeric values):

```sh
python3 selfhost/tools/performance/phase40/campaign-v2.py \
  --ledger selfhost/build/phase41/campaign.jsonl window \
  --label 'agent-A:source-review' --start START_EPOCH --end END_EPOCH \
  --basis 'Observed stage bounds from agent timestamps; includes any reasoning/waiting'
```

Record one window per root/agent stage and identify the owner and stage in its
label. Capture timestamps at the boundaries; do not estimate them afterward.
Windows may overlap. The report unions them. Do not classify the residual as
model thinking, idle time, or model latency. It includes reasoning, editing,
waiting, unrecorded work, and interruption. Without token data, make no causal
model/effort comparison or claims about model speed.

After the root job's final stage, capture its actual end epoch and use the same
value for report cutoff. This closes the root wall interval; do not use the
later report-generation time as a substitute:

```sh
python3 selfhost/tools/performance/phase40/campaign-v2.py \
  --ledger selfhost/build/phase41/campaign.jsonl window \
  --label root-job --start ROOT_START_EPOCH --end ROOT_END_EPOCH \
  --basis 'Observed root job start through final stage boundary'
python3 selfhost/tools/performance/phase40/campaign-v2.py \
  --ledger selfhost/build/phase41/campaign.jsonl report \
  --end ROOT_END_EPOCH --out selfhost/build/phase41/accounting
```

Use `accounting/report.json` as the canonical totals and `report.md` as the
generated table. Keep wall elapsed, summed recorded tool duration, merged tool
coverage, unclassified wall time, declared-window union, and outside-window
time as separate rows. The final report must retain the tool's scope statement.
