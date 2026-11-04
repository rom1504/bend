# Phase160: the same compiler implementation under two backends

At `e2b707d`, try the existing complete Phase156 request closure first. Its
`old` route runs our maintained compiler algorithms from live Base preparation
through complete QBE writing. Building that **same Bend implementation** with
bendc and QBE separates executable/backend costs from the much larger difference
between bendc's own compiler algorithms and ours. The historical checked 8.8 s
self-compilation and our 205–215 s requests compile different programs and emit
different products; their ratio alone cannot identify the cause.

Current bendc's ability to build this closure is **not yet established**. The
cheapest decisive first gate is checked C emission, before any Clang work. This
note and the preparation scripts execute no compiler, checker or benchmark.

## Exact ready inputs

Paths below are relative to the repository root.

| Item | Path | Bytes / SHA256 |
| --- | --- | --- |
| Frozen complete request implementation | `selfhost/build/phase156/request-prepare01/compiler.bend` | 1,565,433 / `6020f680fd96e59b5a629e3ba898aacfc7f85895e9b2b22f3f1426084f656ce3` |
| Preserved exact copy | `selfhost/build/phase160/request-prepare01/original.bend` | Same bytes/hash |
| Common compatible source, pending structural gate | `selfhost/build/phase160/request-prepare01/compiler.bend` | 1,562,535 / `d5df3c605d616f138ec1898884d6bf21e83c48a35dddedc6432c0b5d08c49d5b` |
| Existing QBE executable | `selfhost/build/phase156/request-prepare01/native/program` | 17,334,192 / `3d6c7ec0acf162bc5872358c9ccdbad42af3d9ada45a4dc59ceb1b3bf36ad7f9` |
| Current bendc seed executable | `selfhost/build/phase157/seed01/bendc` | 4,308,872 / `1b47426657fcaaf93288a2f9825b1d4ee065da59d86740de763b717747d44993` |
| Common Base | `selfhost/.bootstrap/upstream-phase66/bend2/base.bend` | 75,064 / `99ac43f2b2bb3e3f39acdcedcecbbd3cb44749ce13969c827d6973fa66f7facf` |
| First substantial compiler input | `selfhost/build/phase156/inputs01/checker.bend` | 182,039 / `a33aface7ce9002c95063978f98387e9b4b6d7d51f6a1a57fffc45c559188a1a` |
| Full compiler input | `selfhost/build/phase152/production-source02/compiler.bend` | 3,085,157 / `027e15041035522ed7e40ef971eff75f24a09ef6a00e3f8fe335839f94bcb8a8` |

The implementation closure contains 4,055 top-level `def`/`type` lines. It is
dependency extraction plus original ancestor clones, not the entire 3.085 MB
declaration collection. `p156h_plan("old",...)` calls `p156o_p86_plan`;
`p156h_emission("old",...)` calls `p156o_p134e_plan`. `p156h_request` reads the
actual Base/source files and calls `p86_prepare`; the original cursor writer
drains every emitted chunk. Errors and failed writes exit unsuccessfully.
See the exact [driver](../../selfhost/build/phase156/request-prepare01/compiler.bend:40032),
[extraction method](../phase156/tools/prepare.py), and
[original checked acquisition](../../selfhost/build/phase156/request-prepare01/checked-api/report.json).

The 182 KB checker input is useful **as input to that complete compiler**. Its
own `main` checks an empty book; building and running it alone would not measure
a meaningful full checker operation. The Phase156 input manifest counts 645
declaration records; a simple textual `def`/`type` count is 494. Neither count is
evidence of runtime work.

## Compatibility boundary and independent gate

Phase157 proved current bendc `56edcc65b3527a75838011682c231072d5b46097`
can check and compile a 387,345-byte kernel extracted from this compiler. It did
not test this request closure or the complete maintained declaration collection.
Its original source failed on a multiline expression lambda followed by a comma.
The successful repair only joined newline/indentation immediately after lambda
arrows inside parenthesized expressions. See
[Phase157 method](../phase157/bendc-method.md) and
[checked emission receipt](../../selfhost/build/phase157/gc03/report.json).

`tools/prepare-request.py` makes an exact original copy and performs that narrow
edit at **768** sites. Its scanner protects strings, characters and comments,
requires enclosing parentheses, rejects obvious statement-body forms, checks
balanced delimiters, and verifies identical non-layout lexical payload. Every
edit retains whitespace between the same non-whitespace characters. The manifest
records each changed interval (Python string character offsets), prior/next text
and hashes. This is a layout audit, not an AST-equivalence proof. The initial
rough count of 510 consumed following lines and missed nested occurrences; it
was corrected before preparation completed.

Before machine construction, the root should execute the independent gate:

```sh
selfhost/.assets/bin/bun experiments/phase160/tools/compare-parser.mjs \
  --manifest selfhost/build/phase160/request-prepare01/manifest.json \
  --out selfhost/build/phase160/parser-equivalence01
```

Use the maintained resource guard around this command, with a fresh output
root. The script imports the pinned `upstream-phase66/bend2/bend.ts`, loads both
complete books through `book_load`, lowers the parser's higher-order syntax with
`term_lower`, and compares **exact serialized bytes for every declaration and
constructor**, plus declaration/table order and book metadata. It removes only
term `s` source spans; it retains names, quantities, literals, unsafe/foreign
markers, arities, types and bodies. It refuses leftover callable values and
unexpected template instantiation. It requires the original checked receipt and
verifies all pinned inputs before/after. No `book_valid`, code emitter or target
program is invoked. This gate can inherit the original source-checking evidence
for unchanged parsed semantics; it does not manufacture a new checking result
or a machine-code correctness theorem.

The two sources import only Base and declare no additional native definitions.
The existing pinned Base includes foreign effects. Its callbacks use two-argument
`io_eff`, while current bendc's runtime requires a third pre-wait mask. The exact
nine Phase157 registration replacements append `0`, preserving the callbacks'
existing `io_work` scheduling. Use that strict allowlist **only if the newly emitted
C has exactly the same registration set**. More/fewer registrations must be
audited explicitly. `IO.now`/print in the parser fallback require their own
registration accounting. Do not apply a global arbitrary-zero substitution.

The runtime header is
`selfhost/build/phase157/vendor/rt/bendrt.h`, SHA256
`b99a4c3d186b233b5ebbc70fe6923f2de422827ee1a1a22eaddcc768d340167a`.
It remains unchanged. No new host-side native implementation is proposed.

## Bounded execution proposal for the root

1. Run the structural gate and checked current-bendc emission of the common
   compatible source. Clear inherited `BEND_*` variables, then set
   `BEND_NO_FREE=1 BEND_RC=0 BEND_AUTO_PAR=0`; leave default optimization policy
   intact. The emission command is the existing seed followed by
   `--threads 1 --gpu off -- ABS_BASE ABS_COMPATIBLE_SOURCE`. Capture stdout as C
   and require exit zero/empty stderr. Root's `tools/emit.py` provides this lane.
   `--no-check` is a separately labeled admission fallback only; it must not
   silently replace checked emission. It skips bendc's source checker, not the
   compiled program's own checker or final QBE verifier.
2. If admitted, adapt only the proven effect registrations and use the pinned
   Phase157 Clang policy: `-std=c11 -O3`, recorded Clang include directory,
   `-I selfhost/build/phase157/vendor/rt`, `-lpthread -lm`. Keep C, adapted C,
   binary, hashes and complete command. Do not use bendc's hidden `-o` cache.
   The native backend is AArch64-specific; x86_64 uses the C backend.
3. First run `old` on the checker input, requiring the complete
   15,869,272-byte QBE oracle, SHA256
   `c13a5640042944c42d323c8515d8c2c170692d608ae61c4c5ab4567511ae400f`, at
   `selfhost/build/phase156/pilot01/oracle-compiler-checker/program.ssa`.
   Add the existing Map input and malformed/invalid-mode failure as cheap
   ordinary-output/error controls. No timing claim precedes these gates.
4. Then one complete full-source request per executable gives the direct answer
   the user needs. Its entire 118,227,421-byte output must equal
   `selfhost/build/phase152/native-n3/program.ssa`, SHA256
   `1032c6a6495ca86bb26ad2bcd7ae639ed49dc987765dfe567dce7ac6224bf7bb`.
   Record fresh-process wall/CPU/RSS, source loading, live Base preparation,
   all compiler passes, full output writing and teardown. Repeat an alternating
   pair only if necessary to resolve a meaningful difference. Keep acquisition
   separate from execution.

For this driver, the actual Bend argument list must be
`["transfer", ABS_BASE, ABS_INPUT, "old", ABS_OUTPUT]`.
QBE omits native `argv[0]`, whereas bendc includes it. Use the same bash wrapper
with `exec -a transfer`: QBE receives the additional positional `transfer` after
`--`; bendc receives only the four paths/mode arguments after `--`. Paths must be
absolute and the output distinct/fresh. Passing both argv0 and a positional
sentinel to bendc will fail the five-argument contract.

Existing QBE construction emitted 109,340,121 bytes of IR and took **198.868 s**
(`native/report.json`). Its existing executable can be reused after the
independent source-equivalence gate, with the bridge explicitly recorded;
fresh normalized QBE emission/build is a stronger optional identity check, not
a prerequisite to discovering whether bendc admits the source. Do not claim
that the existing binary's original source hash is the normalized source hash.
The maintained original request controls already verify the old route's output.

Phase157's 387 KB workload needed 19.185 s/1.05 GiB for checked C emission,
generated 1,445,154 bytes of C, then needed 56.409 s for Clang. These are measured
scale points, **not reliable linear predictions** for this 1.56 MB closure. A
first 180 s emission cap and explicit 5 GiB RSS/32 MiB C-output budget are bounded
discovery limits. Current source admission, C size and machine-build cost remain
unknown; stop on a compiler refusal or resource cap instead of beginning an
unbounded compatibility effort. RC previously failed the ordinary Phase157
output gate and is not an admitted alternative for this comparison.

## Fallback with a narrower answer

If the whole closure is unsupported or too costly, reuse the complete parser
at `selfhost/build/phase150/source-scalar01/parser.bend`: 355,695 bytes, SHA256
`7ac02c2c79cb40ac250133b69c82bed6d28608bacb8d2476ffc9d9ee13511a2f`.
Its QBE executable is `selfhost/build/phase150/parser-scalar-native01/program`,
SHA256 `669d797e43b9c0ef2b8fc030ae190be49021f98c951345c440fc29151dc79640`.
It runs actual complete parsing, retains the resulting book, and observes every
definition/type/body/constructor through `p144pn_*`; failures exit nonzero.
Its source has only six candidate lambda-newline edits. Existing acquisition
took 45.591 s and produced 28,379,597 bytes of QBE. Runtime parse time was roughly
27–28 s on the earlier full compiler input, with separate prepare/observe clocks.
The hash is a complete-consumption check, not byte equality of every AST field;
the Phase150 exact finite graph controls remain the stronger finite semantics
evidence. The source predates Phase152 integration, so describe it as that frozen
parser implementation, not a fresh exact extraction of all current modules.

This fallback identifies backend/execution differences in one large stage. It
cannot attribute the whole 205–215 s compiler request or prove a whole-build
speedup. The full Phase156 closure is therefore the preferred first attempt.

## After first admission gates: establish current bendc's own baseline

Root reports the independent parser gate passed: 4,890 exact structural rows,
about 35.2 MB canonical data. Checked current-bendc emission hit the 180 s cap
around 1.1 GiB RSS; this is a timeout, not a source rejection or RSS exhaustion.
The separately reported 10.7 s `--parse-only` result exercises `Main.chk.load`
(the checker parser). Unchecked emission uses `Main.build` → `Main.load` /
`Main.parse`, a different parser. Checked emission checks first and then invokes
that same build/parser path. Subtracting 10.7 s from emission would therefore
misidentify the remaining work. Source: current `bendc.bend:30816–30870`.

Before attributing the timeout to a general current-bendc regression, run one
bounded current self-emission using the already acquired current seed. Its
[Makefile selfcheck](../../selfhost/build/phase158/current/Makefile:51),
`bootstrap.sh`, `tools/reseed.sh` and diverse-double-compile script all require
`BEND_NO_FREE=1 --no-check` and compare the result to committed `seed/bendc.c`.
This is an explicit upstream exact-output contract; local reproduction remains
pending. The historical 4.5 s unchecked / 8.8 s checked values are for
`9c54842eb5756803af599583ca49870d1e09186a`, not current `56edcc65…`.

Use these inputs, without normalizing bendc's own source:

| Input | Exact local path | Bytes / SHA256 |
| --- | --- | --- |
| Current root source | `selfhost/build/phase158/current/bendc.bend` | 1,187,548 / `72be729fb5a27c528acc4d232314ac44c4595a86dc67d9dde47197956edabb99` |
| Matching Base 2.0.34 | `selfhost/build/phase158/upstream-2.0.34/bend2/base.bend` | 71,530 / `c742fae9c49b14f0cc9128429a2c6109364c8a933a142f2c90b9f2e5fd976661` |
| Expected complete C | `selfhost/build/phase158/current/seed/bendc.c` | 4,628,175 / `b41edf49ccdb3846853955e5b89cf13c199b38e5d6fbe54d2c492a84fef519e3` |

The root imports `check.bend`, `core.bend`, `rt/rtjs.bend`, `rt/rtchan.bend` and
`asm.bend` beside it; those modules import only Base. All six total 1,640,596
bytes. Pin their entries in `selfhost/build/phase158/current-manifest.json`, plus
the Base effect sources in `upstream-2.0.34-manifest.json`. The release archive
SHA256 `78106a97af242429dcc057258eb8d10f69cddebcd5e263022185a52d003e09bf`
matches the repository's exact `tools/install-bend.sh` Linux-x64 2.0.34 pin.
The current seed/runtime bytes exactly equal the Phase157 vendor inputs used to
acquire `selfhost/build/phase157/seed01/bendc`; no new seed build is needed.

After clearing inherited `BEND_*`, the serial emission command arguments are:

```text
selfhost/build/phase157/seed01/bendc --threads 1 --gpu off --
  --no-check ABS_2_0_34_BASE ABS_CURRENT_BENDC_SOURCE
```

Set `BEND_NO_FREE=1`. Explicit `BEND_RC=0 BEND_AUTO_PAR=0` selects the same
generated policy as their unset defaults under `NO_FREE=1`: `free=false`,
automatic parallelism false, hybrid/counting false. Leave `BEND_OPT` and
`BEND_UNBOX` unset, giving `i..spufwhtm` and unboxing enabled. The seed's actual
`F_HY_ddefault` returns immediately when `free=false`
(`vendor/seed/bendc.c:108410`); choosing explicit RC=0 does not skip an otherwise
performed whole-program eligibility traversal in this configuration. These
variables control the emitted program's policy; they do not recompile the seed
being timed. Runtime diagnostic/GC tuning flags should remain cleared.

Recommend one 60 s capped unchecked run with the existing resource guard,
empty-stderr/exit-zero gate, and exact equality to all 4,628,175 expected C bytes.
If it finishes comfortably, one checked emission (remove `--no-check`) with the
same exact-output gate supplies the missing current checked baseline. Keep both
as single observations initially. This is C emission only: no effect adapter,
Clang, native object construction, new runtime, or workload execution is needed.
The expected seed contains Base's current effect source, so retain the matching
2.0.34 Base for this self-reproduction gate; using our older maintained Base
would intentionally change the output and defeat that oracle.

Historical 9c's existing executable is
`selfhost/build/phase158/seed01/bendc`, SHA256
`6eadbd111a78fd2f89a41cd42647e1bd9655a00ecfa04baf240b3eeec18d0847`.
It is a plausible second admission attempt on **our identical normalized closure
and unchanged maintained Base**: its parser handles unsafe definitions, erased/
many binders, templates and IO entry points, and there is no identified required
new surface syntax in this closure. That is a feasibility observation, not
acceptance evidence. Its optimizer default is `i..spf`; it lacks current
unboxing/headerless/word-leaf pipeline additions, so successful output would be
a different C program and still need the full QBE-output oracle after building.
Do not compare it to the current seed-C oracle on our workload. A short unchecked
admission cap is reasonable only after the current-self baseline informs that
choice; retain explicit source-checking provenance and do not relabel unchecked
emission as checked. Historical 9c also requires three-argument `io_eff`
(`historical/rt/bendrt.h:1825`), so later machine construction would still need
an independently audited legacy-Base registration bridge for that exact runtime.
Stop on a language/ABI refusal rather than expanding this into a migration.
