# Native emission scaling evidence

The preregistration was written at 2026-09-23T03:19:29.420129UTC, before the three compiler requests. All 32/64/128-field checked native emissions passed; the run closed 03:21:14.457UTC. The 255-field C is the earlier broad-gate anchor. No fresh Clang build or generated-program execution occurred.

`raw.tar.gz` is 716,290bytes, SHA-256 `cd8a71742a7ef11552cbc484568b5291477e1131c50beb3373cf2500499e0e05`. All 58members were read back and verified against `manifest.json`. Members include the actual preregistration, consumed wrapper SHA `1d041c98af4f0eff247db44b2882cffe1c1dffe300cabc5ef1c39d125daa6ec2`, all three source/C files and checked-result records, captured logs, input identities, and the earlier 255 C/TS binary/build report. The fixture generator mechanically truncates fields/matcher bindings/literal arguments and renames the record; an independent static audit checks that source shape and the emitted size counts.

Extract from the repository root with `tar -xzf implementation/phase6/native-scaling-evidence/raw.tar.gz`, into a separate empty reconstruction directory when preserving an existing checkout. Verify each member SHA-256. Also recover [the broad archive](../../phase5/broad-backend-evidence/README.md), which supplies preparation04 and complete checked-parent/derivation history. Absolute paths in old reports remain historical identities: reconstruct those paths or make an explicitly new preparation rather than rewriting old provenance. The recorded Node binary and upstream Git checkout metadata remain external prerequisites.

For a new observation, from `selfhost/`, create a **fresh** directory and timestamp a new plan, preserving the old preregistration separately:

```sh
mkdir build/phase6/native-scaling-replay
python3 - <<'PY'
import datetime,json,pathlib
old=pathlib.Path('build/phase6/native-scaling/preregistration.json')
plan=json.loads(old.read_text())
plan['replayOf']=str(old)
plan['registered']=datetime.datetime.now(datetime.timezone.utc).isoformat()
plan.pop('stopBy',None)
pathlib.Path('build/phase6/native-scaling-replay/preregistration.json').write_text(json.dumps(plan,indent=2)+'\n')
PY
timeout --kill-after=5s 300s taskset -c 1 \
  /home/ai/.nvm/versions/node/v24.18.0/bin/node \
  --stack-size=4096 --max-old-space-size=4096 \
  tools/performance/phase6/native-scaling.mjs run \
  build/phase6/native-scaling-replay \
  > build/phase6/native-scaling-replay/run.stdout \
  2> build/phase6/native-scaling-replay/run.stderr
```

The wrapper verifies genuine derivative lineage and uses the frozen preparation04 API/host/Base/cache. Each fresh worker has a 90-second deadline within the 300-second whole bound and calls checked native **emission** only. Failure stops the sequence and remains recorded. Static reinspection of the historical run uses `python3 implementation/phase6/native-scaling-audit.py` from the repository root; it does not run a compiler. See [the report](../native-arity-wall.md) for results and limitations.
