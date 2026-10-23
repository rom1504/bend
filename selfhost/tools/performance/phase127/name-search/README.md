# Compiler name-search baseline

This ordinary Bend program extracts the **unchanged Phase126 computation**, not
an optimized candidate. It makes the full-compiler string equality and linear
membership hot paths cheap to profile before testing borrowed equality and an
index as two separate factors. No compiler image rebuild is required.

`prepare.py` only composes source and computes an independent Python set-membership
oracle. It does not check, compile or execute Bend. Run it from any directory to
verify/reproduce the frozen files; it refuses to replace changed outputs.

## Exact source and workload

The input is
`selfhost/build/phase126/observer-divmod-source32/compiler.bend`, SHA256
`40c469114c4d1c75dceab456e1979bb5c0278744a02e6dbe4a37e63667740abb`.
`oracle.json` records full-file and individual exact-span hashes:

| Unchanged function | Source lines, inclusive |
| --- | --- |
| `p88_string_eq_go` | 6–13 |
| `p98_eq_finish` | 15–16 |
| `p88_string_eq` | 18–19 |
| `has_name` including `@unsafe` | 6000–6009 |
| `has_name_next` including `@unsafe` | 6012–6016 |

No function is renamed. The remaining wrapper is in `workload.bend`. Its corpus
uses the first sixteen distinct actual `p113pl_*` declaration names, suffixed
with an increasing decimal index. Two Unicode names are appended. Fourteen
queries exercise shared head/middle strings, separately constructed equal
strings, late hits, misses, common prefixes, Unicode, and repeated aliases.
The list and query roots remain retained across repetitions. This intentionally
represents a shared compiler name catalogue; it is not representative of every
ownership regime or every compiler workload.

The digest starts at 2166136261 and folds each Boolean membership result as
`(digest * 16777619 + result) mod 2^32`. The host oracle uses Python set membership
and modular arithmetic, independently of the Bend equality and list traversal.
It records every query and expected Boolean. Equal digests at larger sizes are
expected because the hit pattern is unchanged; traversal volume must be
established from counters/profiles, not the digest.

## Checks and profiling

With no four-word trailing argument group, the program runs sizes 0, 1, 17 and
128. `expected.stdout` freezes the exact four-line ordinary output;
`expected.json` also requires exit status zero and empty stderr. `cases.json`
works with the existing Phase118 integrated emitter:

```sh
P118_CASE_MANIFEST=selfhost/tools/performance/phase127/name-search/cases.json \
P118_RUNTIME_REPORT=RUNTIME_REPORT \
node selfhost/tools/performance/phase118/emit-integrated.mjs \
  CHECKED_API_REPORT CHECKED_SOURCE_MANIFEST \
  selfhost/build/phase118/p127-name-search-emit01 compiler-name-search
```

Use the retained checked **live-bank-repaired producer** and aligned ordinary
build path. The installed Phase126 N1 producer still omits live-bank admission;
using its output would mix this kernel's cost with avoidable bank clearing.
Inspect the emitted descriptor and actual counters before interpreting a
comparison. Keep the original runtime for clean runs, then relink the same
program object against the generic diagnostic runtime for profiling.

Timed arguments after native runtime options are:

```text
-- REPEATS WARMUPS LIST_SIZE RESERVED
```

The reserved word is currently ignored. Output consists of the one-pass digest,
warmup digest sum, timed digest sum, and one elapsed integer line. The sums are
modulo 2^32. **These are not the success counts expected by the legacy 45-case
runner.** Use the generic profiler's `prefix-integer-line` output oracle.
`oracle.json` freezes three uncalibrated presets:

| Final arguments | Exact first three output lines |
| --- | --- |
| `32 2 64 0` | `192636846`, `385273692`, `1869411776` |
| `64 2 256 0` | `192636846`, `385273692`, `3738823552` |
| `128 2 1024 0` | `192636846`, `385273692`, `3182679808` |

Increase repeats for approximately one second of clean execution, preserving a
fresh manifest and deriving the expected sums **before** executing the chosen
repetitions. Source/list construction happens before the internal timer; total
process CPU and sampled startup may include it. Future index experiments must
report construction plus queries as well as query-only measurements.

## Cheap upstream reference

An existing checked TypeScript/Bun → C worker accepts arbitrary source. Its
exact tools and inputs are pinned by
`selfhost/build/phase114/native-final02-transport-manifest.json` under
`roles.upstream` and `tools.clang`; the invocation is reused in
`selfhost/tools/performance/phase125/native/timing-run.py`:

```text
BUN WORKER UPSTREAM_MANIFEST benchmark.bend FRESH_PREFIX
CLANG -isystem CLANG_PARENT_PARENT/include/clang -O2 FRESH_PREFIX.1.c \
  -o FRESH_BINARY -lm -pthread
```

Require the worker's `.json` receipt to be complete, checked and hole-free,
then check the same independent output. This uses the retained compiler and
does not rebuild its image. The ordinary frozen 45-program runtime reference
uses Clang `-O3`, whereas this native-request harness uses `-O2`: record the
chosen flags and avoid mixing their ratios. This is a proposed acquisition
route, not evidence that this fixture has already passed upstream or QBE.

## Status and next experiment

Preparation verified exact source spans, input identities and Python syntax.
No Bend checking, builds, target runs or timing calibration were performed by
the preparer. The first unexecuted extraction truncated the multiline
`has_name` signature; its files are retained at
`selfhost/build/phase127/name-search-preparation01` with the failure reason.
The corrected extraction is frozen before execution.

The coordinator's first checked-emission attempt then rejected a computed
match scrutinee in the new list-position wrapper, before any build or program
execution. That source/oracle is retained in
`selfhost/build/phase127/name-search-preparation02`; the refusal receipt is
`selfhost/build/phase118/p127-name-search-emit01/report.json`. The wrapper now
passes the comparison to a separate Bool-parameter helper. All five extracted
compiler definitions and all independent expected results are unchanged.
The second checked attempt rejected missing affine-use annotations in the
wrapper. Its files are retained in `name-search-preparation03` under the same
build directory, with the receipt at
`selfhost/build/phase118/p127-name-search-emit02/report.json`. Five repeatedly
used scalar parameters now have explicit `+` quantities; a static review of
the other wrapper parameters found no further repeated affine uses. These
preparation failures provide no performance evidence.

After the root coordinator qualifies the baseline, compare equality strategy
and catalogue data structure independently. Preserve Bool's nonowning result
proof, retained roots, aliases, Unicode, early-return semantics, fallback and
bounded native stack behavior. A scalar word is not generally a nonowning
value. An improvement here would justify testing an actual compiler request;
it would not establish whole-compiler speedup by itself.

## Coordinator qualification and profiling results

The final scaffold passes checked hosted emission at
`selfhost/build/phase118/p127-name-search-emit03/report.json`, including the
independent parent IR verifier. Both QBE and pinned upstream C/Clang O3 pass
the four-line ordinary oracle. The original128-repeat calibration takes0.383s.

The final512-repeat recipe, frozen before execution, is
`selfhost/build/phase127/name-search-recipe02.json`; the sealed manifest is
`name-search-manifest02.json`. Its exact output prefix is independently derived
in `name-search-timing-oracle02.json`, with the original oracle pinned too.
`name-search-profile01` retains three clean rounds, counter captures and the
rejected2ms/3ms profiles. `name-search-profile02` retains the successful8ms/13ms
QBE resampling. Use a fresh output directory for replay:

```sh
python3 -B selfhost/tools/performance/phase111/guard.py \
  --out selfhost/build/phase127/name-search-replay-guard --seconds 60 \
  --rss-mib 2048 --available-mib 16384 --file-mib 64 --cpu 3 -- \
  python3 -B selfhost/tools/profiler/run.py \
  --manifest selfhost/build/phase127/name-search-manifest02.json \
  --out selfhost/build/phase127/name-search-replay \
  --modes clean,sample,events --rounds 3 --periods-us 8000,13000,8000,13000
```

This checks the exact fixed queries and outputs, then profiles them. It does
not build a candidate or optimize anything. All executable/source/method pins
must still be available and unchanged. See the
[analysis](../../../../../implementation/phase127/name-search-proxy.md) for the
14.65× narrow workload gap,54.20% destruction/reclamation share, generated C
borrowed reads versus QBE owning takes, and limitations. No full-compiler
speedup or broad benchmark ratio is inferred from this proxy.
