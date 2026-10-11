# Native facts and ordinary fallback

Design: `design/phase68/native-facts-and-calls.md`; hypotheses P68-019–021.
All target execution belongs to one guarded CPU3 lane. Source work uses CPU0.

- `count-current.py --out FRESH`: instrument saved compiler20 and upstream C
  for four slower families. Counts compare 1 and17 repetitions with independent
  oracles. Instrumented timings are never speed evidence.
- `inspect-workers.mjs ATTEMPT INPUT FRESH`: append a private read-only export
  to a checked image, intercept the maintained checked native entry and record
  candidate errors/dependencies/bodies. No compiler logic is replaced.
- `compare-native.py --candidate ACQUISITION... --out FRESH [--cases lexer]`:
  identical to the preceding `scalar-layout/compare-native.py` protocol except
  that saved compiler20 replaces installed Phase67 as the baseline. This avoids
  repeatedly spending14seconds per array observation on the obsolete version.
  Three balanced rotations, same source/Clang, independent checksums and100ms
  floor; old emission receipts keep their actual producer identity.

Use the existing checked development workflow, native acquisition factory,
37-case integration selection and B1/B2 clean-request factory. Fresh output
paths are mandatory; historical failures and snapshots remain untouched.
