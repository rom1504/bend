# Current runtime classifier controls

`runtime-classifier-prepare.py` extracts the actual `p118z_runtime` declaration
and its dependencies from the maintained QBE source. There is no alternate
implementation in this test directory. `runtime-classifier-cases.json` retains
the independently reviewed 25-name contract and all 677 original finite cases:
positives, proper prefixes, single-character mutations, suffixes, case changes,
and Unicode/NUL near misses. Changing production does not regenerate the oracle.

From the repository root, prepare a fresh run without executing targets:

```sh
python3 -B selfhost/tests/phase147/runtime-classifier-prepare.py \
  --out selfhost/build/phase147/classifier-current01
```

The resulting `jobs.json` contains two serial guarded commands: checked API
acquisition, then complete finite checking. Execute each command once, in order,
with the normal exclusive target lane. Each command already contains the disk,
memory, CPU and time guard; do not wrap it in another guard. The checker binds
the acquisition to the exact extracted source, verifies all input hashes before
and after evaluation, and checks all 677 Boolean values. Preparation alone is
not a pass. These finite controls are not a universal theorem or native
ownership proof. Normal native/compiler qualification remains separate.

The initial performance experiment and its native full-output controls are
archived in
[`runtime-classifier-history01`](../../../implementation/phase147/evidence/runtime-classifier-history01/README.md).
That capsule contains all exploratory source/method versions, the failed
forward-reference attempt, accepted API/native controls and timing receipts.
Restore it into a separate directory when reproducing historical measurements;
its old method paths intentionally do not designate this current test anymore.
