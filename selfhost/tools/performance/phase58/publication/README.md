# Final preservation and archive procedure

The root agent runs these data-only jobs outside all compiler/program timing.
They do not install a release or run generated code. Final CLI qualification
still comes from the unchanged release42/default24 workflow.

Before installation, preserve the existing seven-file inventory and byte copies.
Phase58 already records them in `installed-start.json` and `prior-release/`.
After the selected install, verify the old copies, the actual new release and
closed historical inventories with the reviewed audit:

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase58/publication/preservation.py \
  --installed selected --attempt selfhost/build/phase58/checked-choice01 \
  --out selfhost/build/phase58/preservation-final.json
taskset -c 0 python3 -B selfhost/tools/performance/phase51/check-protected.py \
  selfhost/build/phase58/protected-final.json
```

For an earlier pre-install audit, use `--installed unchanged` without an attempt
and a different fresh output name. The audit reads the exact Phase54–57 file
set from the starting inventory, checks every saved byte, verifies all103
protected files and staged status, and retains the seven original installed
copies. Selected mode separately binds the new release to the chosen checked
attempt, including its exact derivation receipt. File counts come from the
actual inventories. This audit can be I/O intensive: never run it during a
measurement window.

The source-accounting producer reads only manifest-listed source modules,
compiler images and runtime/driver inputs. Its completed choice01 receipt is
`build/phase58/source-accounting-choice01.json`; the readable source counts are
in `implementation/phase58/source-complexity.md`. These counts are independent
of preservation and runtime performance evidence.

Finish all reports and accounting, then explicitly stop every raw writer.
The root writes the final `writers-closed.json` with `complete: true`,
`writersClosed: true`, the absolute `rawRoot`, and exact `attempt` and `api`
identities. The archive tool requires those declarations; elapsed time or an
idle target slot is not writer closure. The protected receipt must be the
unchanged Phase51 tool's `checked: 103` schema, rather than the larger
preservation report.

After closure, reuse the unchanged streaming archive tool directly:

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase42/validation/archive-campaign-v1.py \
  --raw selfhost/build/phase58 \
  --out selfhost/tools/performance/phase58/artifacts/raw \
  --writers-closed selfhost/build/phase58/writers-closed.json \
  --protected-final selfhost/build/phase58/protected-final.json
```

Do not wrap this command in a ledger/job launcher that writes into the closed
raw directory. Keep its stdout, final publication index and any failure logs
outside raw. The destination must be fresh. The adjacent `archive-method.json`
pins the exact inherited producer and command without executing it.

The tool hashes members as it streams deterministic tar/gzip, reopens and
checks every member, verifies that the raw file set and stat tokens are stable,
and finally rehashes raw content before publishing its staging directory. It
uses 1MiB hash chunks and explicit 2GiB/file, 64GiB/total and 500,000-member
limits. The archive and metadata remain outside raw; all failed and partial
campaign evidence inside raw is retained. Its historical `phase42` receipt
kind identifies the method, not this campaign's execution date or scope.
