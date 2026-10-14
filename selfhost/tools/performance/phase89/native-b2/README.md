# Native B2 falsifiers: root-run protocol

These methods are offline-prepared candidates. No Bend control has been newly
checked or executed as part of their preparation. Root runs all compiler, Clang
and program targets serially under the existing execution guard. Use fresh
directories and preserve failed source/check/build/run evidence.

The three controls are:

1. `argv.bend`: prints the complete IO.args list with indexes. This does not
   assume a program-name element, so it directly exposes the known upstream
   versus retained-runtime convention.
2. Existing `phase88/base/fixtures03/controls.bend`: unchanged standalone pure
   decoder control, SHA256 `3c1d8ebea28c3e7ebe952a144c064f40824fc322bcb0d663e0e6f9dcb42fa619`.
   All16 assertions must produce exactly `True{}\n`. No new wrapper/import is
   needed; avoiding another import also fits native B1's single-source contract.
3. `file-io.bend`: copies Phase88's bounded read/EOF/close/write helpers, only
   renaming p86_ to p89_, plus the unchanged `kc` choice helper. Its entry tests
   File.open/read/size/write/close, IO.args/now/print_err/print and IO.die. Empty
   and Unicode copies verify complete contents and nondecreasing clocks. Missing
   input, deliberately short initial read and a sparse17MiB input must refuse.

No production source, native runtime, effect permission or Phase88 artifact is
modified. `file-io.derivation.json` records the copied helper/source identities.

## Prepare and emit

Run from the canonical repository root. Example path variables below identify
fresh outputs; choose a new suffix for retries.

```sh
P89_ROOT=$PWD
P89_METHOD=$P89_ROOT/selfhost/tools/performance/phase89/native-b2
P89_RUN=$P89_ROOT/selfhost/build/phase89/native-b2-controls01
P89_NODE=/home/ai/.nvm/versions/node/v24.18.0/bin/node
P89_CLANG=/home/ai/.elan/toolchains/leanprover--lean4---v4.32.0/bin/clang
P89_INCLUDE=/home/ai/.elan/toolchains/leanprover--lean4---v4.32.0/include/clang
P89_GUARD=$P89_ROOT/selfhost/tools/performance/phase86/guard.py
python3 -B "$P89_METHOD/prepare.py" "$P89_RUN"
```

Preparation writes frozen argv/file sources, tiny input files, one sparse file,
and `manifest.json` with exact expected observations. It references the existing
decoder source rather than duplicating it. It launches nothing. Never reuse a
control output path from a previous execution.

The ordinary current JS B2 emission command for **each** case (`argv`, `decoder`,
`file-io`) is:

```sh
python3 -B "$P89_GUARD" --out "$P89_RUN/file-io-emit-guard" --seconds 60 --cpu 3 -- \
  "$P89_NODE" --max-old-space-size=1024 --stack-size=4096 \
  "$P89_METHOD/emit-b2.mjs" "$P89_RUN/manifest.json" file-io "$P89_RUN/file-io-b2"
```

`emit-b2.mjs` uses the frozen Phase83 role that names installed Phase82 genuine
B2 (`098320e8…`), its existing prepared driver/project and canonical Base. It
calls `D.inspect(source,{mode:'native',withReport:true})`, writes complete C only
after checking succeeds and input hashes remain unchanged, and records all four
emitted representation-policy macros. It compares frozen runtime/template/effect
assets byte-for-byte to the current retained assets. It neither patches the API
nor sets an effect permission. The ordinary driver marks file effects unsafe
for scalar/observer permission; file-io and decoder outputs must have all four
macros0. A missing source/asset, changed frozen identity or unexpected policy
fails the method rather than silently acquiring another compiler.

This is the exact way to test file IO today without extending native B1's
allowlist or paying for another full compiler build. `phase86/reference.mjs b2`
uses the same API/driver route, but the new method adds frozen input/output and
conservative-policy assertions. A successful JS-B2 emission is not yet a
native-B1-produced B2.

For argv and decoder, also emit through actual native B1:

```sh
python3 -B selfhost/tools/performance/phase88/native.py \
  "$P89_RUN/argv.bend" --image selfhost/build/phase88/compiler-native02 \
  -o "$P89_RUN/argv-native.c" --seconds 120
python3 -B selfhost/tools/performance/phase88/native.py \
  selfhost/tools/performance/phase88/base/fixtures03/controls.bend \
  --image selfhost/build/phase88/compiler-native02 \
  -o "$P89_RUN/decoder-native.c" --seconds 120
```

The native launcher already runs the serial guard and retains its request log.
Compare each complete native C byte-for-byte against the corresponding JS-B2 C,
then build only one copy. A refused emission is evidence, not permission to skip
the control. The current native B1 must still refuse file-io; its existing
allowlist lacks the six additional providers. Do not run the full self-compiler
to rediscover that known refusal.

For an upstream C reference, root may separately use
`phase88/component.mjs SOURCE NEW_OUT` under the guard. It checks with pinned
upstream and emits both JS and C. Retain its exact source and asset identities;
only the C execution is needed for this argv/effect ABI comparison. This is
optional reference acquisition, not the JS B2 emission route above.

## Build and execute small programs

Build each passing complete C with the exact Clang used in Phase88:

```sh
python3 -B "$P89_GUARD" --out "$P89_RUN/file-io-clang-guard" --seconds 60 --cpu 3 -- \
  "$P89_CLANG" -isystem "$P89_INCLUDE" -O2 "$P89_RUN/file-io-b2/program.c" \
  -o "$P89_RUN/file-io-program" -lm -pthread
```

Apply the same small build recipe to argv and decoder. No full compiler build
or increased Clang RSS allowance is needed for these controls.

Run argv for all three payload lists in `manifest.argvCases`, with
`--threads 1 --gpu off --` before the payload. The retained program must print
only payloads; upstream's program must print its actual argv0 first. For example:

```sh
python3 -B "$P89_GUARD" --out "$P89_RUN/argv-many-guard" --seconds 10 --cpu 3 -- \
  "$P89_RUN/argv-program" --threads 1 --gpu off -- alpha 'two words' 'λ🙂'
python3 -B "$P89_METHOD/verify-run.py" "$P89_RUN/manifest.json" \
  "$P89_RUN/argv-many-guard" argv --convention retained --case-index 2
```

For upstream verification add `--convention upstream --program EXACT_BINARY_ARGV0`.
Do not insert a sentinel for the argv observation itself: that would obscure
the convention. Empty and one-argument cases are required as well.

Run the decoder with no payload; `verify-run.py MANIFEST GUARD_DIR decoder`
requires exit0, stdout `True{}\n` and empty stderr.

The file control intentionally uses Phase88's leading-program argument pattern.
For a retained-runtime program, insert the explicit `phase89-file-control`
sentinel after `--`. An upstream-built program gets argv0 naturally and must
receive **no sentinel**. For the retained empty-file case:

```sh
python3 -B "$P89_GUARD" --out "$P89_RUN/file-empty-guard" --seconds 10 --cpu 3 -- \
  env LC_ALL=C "$P89_RUN/file-io-program" --threads 1 --gpu off -- \
  phase89-file-control copy "$P89_RUN/empty.txt" "$P89_RUN/empty.copy"
python3 -B "$P89_METHOD/verify-run.py" "$P89_RUN/manifest.json" \
  "$P89_RUN/file-empty-guard" file --id empty
```

Use the exact mode/input/output triple from every `manifest.fileCases` entry.
All five cases are required. `verify-run.py` checks actual exit/stdout/stderr,
successful output SHA or failed-output absence, and rejects `stoppedFor` resource
or deadline stops. The guard itself returns nonzero for expected program refusals;
run the offline verifier even then. Do not treat the guard's `complete:false`
alone as proof of a correct refusal, and do not suppress arbitrary failures.

If comparing upstream execution, prepare a separate fresh fixture directory so
its output paths do not collide with the retained run. Freeze and verify hashes
before/after; retain commands and exact executable identity in every guard.

## Concrete pitfalls and interpretation

- Read byte count is File.size's UTF-8 byte size, not String.length. The Unicode
  case includes non-BMP text, forcing the correct full read and round-trip.
- The entry reader does one size-bounded read plus an EOF probe. It refuses a
  partial read, rather than silently accepting a prefix; this control preserves
  that contract. It is not a newly generalized streaming reader.
- Error paths must close File handles before forwarding the Result. The helper
  copy preserves this ownership order. Missing-file ENOENT expects exit2 on Linux;
  LC_ALL=C pins the diagnostic substring used by the verifier.
- The sparse oversize case must refuse before allocating/reading its payload.
  It is17MiB logical length but has negligible physical data at preparation.
- The known argv mismatch is deliberately observed first and adapted only in
  the private file-control invocation. It is not a production runtime fix.
- Root should preserve any initial syntax/check failure under its original
  source identity; make a new fixture revision rather than changing sealed runs.
- The decoder checks small synthetic products. Passing it does not admit the
  full prepared Base or prove native B2; follow the separate feasibility report's
  full-product, live/cache and C2/C3 gates after these falsifiers pass.
