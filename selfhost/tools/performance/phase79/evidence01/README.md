# Phase79 complete evidence

The manifest records all 2,792 regular files from the four candidate attempts,
two clean screens, two V8 profiles, held-out requests, restored release check and
experiment methods. All 667 unique objects and their unchanged input bytes/modes
were verified. The archive occupies 11,861,189 bytes; hashes are recorded in
`verification.json`. Historical phases, upstream and toolchains remain external.
Private quota telemetry is excluded.

```sh
python3 selfhost/tools/performance/phase79/restore-evidence.py selfhost/tools/performance/phase79/evidence01 /tmp/phase79-restored
```

The output directory must be new. Restore historical evidence without replacing
the current compiler. The report rejects the experimental implementation.
