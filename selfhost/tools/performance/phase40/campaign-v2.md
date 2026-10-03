# Versioned interrupted campaign accounting

`campaign-v2.py` preserves the original `campaign.py` and adds declared session
windows. All commands use the original append-only ledger. A window records
bounds and their evidence; it never proves continuously active work.

```sh
python3 selfhost/tools/performance/phase40/campaign-v2.py \
  --ledger selfhost/build/phase40/campaign.jsonl window \
  --label resumed-root --start 1791008315 --end UTC_EPOCH_CUTOFF \
  --basis 'Known resume2026-10-03 06:18:35UTC through report cutoff; session bounds only'
python3 selfhost/tools/performance/phase40/campaign-v2.py \
  --ledger selfhost/build/phase40/campaign.jsonl report \
  --end UTC_EPOCH_CUTOFF --out selfhost/build/phase40/accounting-NEW
```

The initial observed root window ends at the last local tool receipt. Agents
reportedly continued until about00:50UTC Oct2; the exact continuation end is
unknown. Time outside declared windows includes this uncertainty and the long
interruption. Report raw elapsed separately from declared-window duration,
summed tool duration and merged tool coverage. Unclassified time cannot be
attributed to model reasoning or latency. No30-hour active-work claim follows.
