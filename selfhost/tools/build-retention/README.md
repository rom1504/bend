# Build disk admission and retention

For new work, use the disk guard below. The original Phase111 guard and support
module are immutable historical dependencies. The successor uses their same
execution-lock inode and process supervision, with disk admission/accounting.

## Run with a budget

```sh
python3 -B selfhost/tools/build-retention/guard.py \
  --out selfhost/build/my-campaign/request-guard \
  --run-root selfhost/build/phase130/my-request \
  --seconds 600 --disk-mib 1024 \
  --rss-mib 3072 --available-mib 16384 --cpu 3 -- \
  COMMAND_WITH_EXPLICIT_OUTPUT_DIRECTORY
```

Both paths must be fresh, nonoverlapping and under `selfhost/build`. Declare
every artifact location with additional `--run-root` options. Budget includes
guard logs and all outputs, not just the maximum single file. The default reserve
is 5 GiB. Admission occurs after acquiring the unchanged shared Phase32 lock.

The guard monitors mount headroom, net filesystem consumption and allocated
blocks within declared roots. A failure stops the owned process tree and emits
receipts. External writers can trigger a conservative refusal; sampled accounting
is not a filesystem quota and cannot attribute all external activity. Never nest
this guard around another guard; invoke the underlying target directly.

`process.json` is execution evidence. `retention.json` tracks `active → finished`
and a pending close. A zero exit status is not compiler qualification.

## Close a run

```sh
python3 -B selfhost/tools/build-retention/close.py \
  --run selfhost/build/my-campaign/request-guard \
  --classification completed \
  --out selfhost/build-retention/my-campaign/request-close \
  --prune
```

Use `completed`, `rejected` or `failed` explicitly. The tool archives declared
output roots, verifies every member and current file, and only then performs
optional pruning. `--keep-root PATH` keeps a complete declared root online.
Without `--prune`, it seals the evidence but removes nothing. Guard logs remain
online. The closure capsule and recovery plan are outside the pruned directories.

For a qualified compiler, use `--classification qualified --qualification REPORT`
and omit `--prune`. All roots remain hot. A complete receipt is required, but the
retention tool does not establish compiler correctness itself. Installed/current/
fallback release roots must also remain explicit protected policy roots.

The initial close implementation bounds each root to 1 GiB of raw file bytes and
100,000 files. Split larger experiments into declared units. It reserves worst-
case archive scratch plus 512 MiB for maintenance and monitors I/O. It refuses
symlinks. Shared inodes, unusual ownership or extended attributes are retained
by the pruning verifier. Qualified roots bypass packing and remain online.

Successful close writes an immutable report, then atomically points the guard's
retention record to it with `state: sealed`. Check that pointer: a report alone
is not the lifecycle commit after an interrupted close. Partial failures leave
their capsules and intent/recovery metadata available. `process.json` stays exact.
No unattended age-based deletion or cron job is installed.

## Recover an archived artifact

Every capsule has a verified `plan.json` and exact archive/member bindings:

```sh
python3 -B selfhost/tools/build-retention/archive-v02.py restore \
  --plan selfhost/build-retention/my-campaign/request-close/root-00/verified/plan.json \
  --member program.ssa \
  --out selfhost/build-retention/my-campaign/restore-01
```

This restores at the original path. Add `--destination PATH_INSIDE_REPOSITORY`
for an isolated restoration. Omit `--member` to restore every pruned member in
that plan. Existing exact files are accepted; different existing files or modes
are refused. Verify original output against its independent oracle if rerunning
a historical experiment. The same archive on the same disk is recoverability,
not an independent backup.

## Historical cleanup

`initial-policy.json` is a fixed reviewed allowlist for existing full capsules,
with Phase66 prerequisites and current compiler identities protected. It is not
a rule to remove all old phases. `campaign.py` is a one-shot record of the initial
application and refuses to overwrite its receipts. Do not reuse it as a generic
garbage collector.

`archive-v02.py verify` authenticates whole compressed streams, every member and
all selected current files, producing a file-level plan. `apply` authenticates
that plan again, rejects stale input before any unlink, durably records complete
intent and journals the removals. Only exclusive regular files are pruned.
Directories remain. Plans record current mode, owner and timestamps even where
an old archive normalized modes to 0644. Restoration preserves mode and mtime
for the current owner; inode, ctime and original atime identity are not promised.
Archive transport parts are streamed without
creating a second joined archive.

`archive.py` is the preserved predecessor used for the first read-only Phase61
plan. All real pruning/restoration uses `archive-v02.py`, which additionally
fsyncs receipt-directory ancestors before unlinking. It accepts the authenticated
predecessor verification plan; both exact method sources remain available.
Interrupted applies are not silently resumed: the durable full intent plus
archive permits restoration/reconciliation. Do not rerun against an existing
apply output directory or edit a consumed plan/method.

Run the bounded controls with:

```sh
python3 -B -m unittest discover -s selfhost/tools/build-retention -p 'test_*.py' -v
```

Tests use temporary files and injected disk availability, never disk-filling
experiments. The [policy](../../../docs/self_hosted/build-retention.md) explains
protected dependencies, evidence classes and migration limits. Global 30/40 GiB
project thresholds remain review targets while old storage is retired; only the
mount reserve and per-run budgets are currently enforced.
