# Phase162: bendc frontend boundaries on identical input

Source audit at repository `6c645c34e789b3c7de9229b86e809a7d84dab55e`.
No compiler, benchmark or build was run for this audit. This is a measurement
proposal, not a speed attribution or a claim that the two checkers are equivalent.

Use the current capped seed's **parse-only and check-only modes on the same
source and the same 75,064-byte Base** first. These exercise the checker frontend
without C emission. An exact unsafe/foreign verdict on stderr with exit 1 is a
completed typecheck, whereas an arbitrary exit 1 is not. Do not use checked-C
emission minus unchecked-C emission as a checker timer.

## Pins and retained assets

Current bendc is `56edcc65b3527a75838011682c231072d5b46097`.
Paths below are repository-relative; line references refer to these exact files.

| Asset | Path | SHA-256 |
|---|---|---|
| Compiler source | `selfhost/build/phase158/current/bendc.bend` | `72be729fb5a27c528acc4d232314ac44c4595a86dc67d9dde47197956edabb99` |
| Checker source | `selfhost/build/phase158/current/check.bend` | `786514afc1804c00371356943ac6790c16c04c04551e7ab8e0d8f6468e22bf41` |
| Retained generated seed C | `selfhost/build/phase157/vendor/seed/bendc.c` | `b41edf49ccdb3846853955e5b89cf13c199b38e5d6fbe54d2c492a84fef519e3` |
| Original runtime header | `selfhost/build/phase157/vendor/rt/bendrt.h` | `b99a4c3d186b233b5ebbc70fe6923f2de422827ee1a1a22eaddcc768d340167a` |
| Private capped runtime header | `selfhost/build/phase159/refill-prepare01/bendrt.h` | `b24e7b51dcdc3645704cfccdc0c94133caf5a37fbdd5b2dc6c2195bbdbc45f49` |
| Capped seed executable | `selfhost/build/phase160/capped-seed01/bendc` | `1f41eadeb854ab06f2b81b8fb0d11ae7178c79022cd2e56494d700546f612f39` |
| Common Base, upstream `059266225b77c8ca256ac6b25ee5c21449bab151` | `selfhost/.bootstrap/upstream-phase66/bend2/base.bend` | `99ac43f2b2bb3e3f39acdcedcecbbd3cb44749ce13969c827d6973fa66f7facf` |

The capped seed changes the runtime free-block search bound, not the generated
compiler C. Phase160 retained its exact self-C and checked-self gates. Keep this
runtime policy fixed between input cases; the original seed exhibited a severe
allocator pathology on the larger compiler input. The current bendc self-source
uses a different matching 2.0.34 Base: that self-reproduction is a separate point,
not the common-Base same-input comparison.

The already qualified normalized request source is
`selfhost/build/phase160/request-prepare01/compiler.bend`, 1,562,535 bytes,
SHA-256 `d5df3c605d616f138ec1898884d6bf21e83c48a35dddedc6432c0b5d08c49d5b`.
Its original/normalized upstream spanless parsed books matched exactly in
`selfhost/build/phase160/parser-equivalence02/report.json` (4,890 rows).
This admission applies to that source only. A new normalization of the full
maintained source requires its own structural gate. Prefer unchanged qualified
full-source bytes if the checker parser accepts them.

## Modes and semantic work

The native runtime consumes its options before `--`. The concrete mode commands
are `SEED --threads 1 --gpu off -- --parse-only BASE SOURCE` and
`SEED --threads 1 --gpu off -- --check-only BASE SOURCE`. Keep
`BEND_RC=0`, `BEND_NO_FREE=1`, `BEND_AUTO_PAR=0`, and remove inherited policy
overrides as the existing Phase160 probe does. These are compiler-mode policy
settings; record them with the executable/runtime pins.

| Mode | Actual route in `bendc.bend` | Required observation |
|---|---|---|
| `--parse-only` | `Main.run3`, code 8, line 30869: `Main.chk.load` from an empty book, then Unit | Exit 0 and empty stdout/stderr; this establishes loader/parser acceptance, not AST identity |
| `--check-only` | `Main.run3`, code 3, line 30856: `Main.check` then `Main.check_only.fin` | Exact exit/stdout/stderr triple; clean proof text on stdout/exit 0, or exact unsafe/foreign report on stderr/exit 1 |
| ordinary checked emission | `Main.run2`, code 0, line 30838: same check, then `Main.checked` | Adds a separate emission frontend and backend; not a frontend-only timer |
| `--no-check` | `Main.run3`, code 4: `Main.build` | Skips the checker frontend; uses emission `P.file`/`Lex.all`, so it is not a parse-only substitute |
| `--ast`, `--tokens` | `Main.run2`, codes 2/1 | File-only emission frontend output, not the import-loaded checker Book |

`Main.chk.go` (15961–16083) resolves/imports source files, blanks import lines,
checks namespace/path rules and cycles, and remembers loaded files.
`Main.chk.parse` (15881) joins those lines, then calls `Chk.parse_file`.
Only an actual `import Base` loads the CLI Base; it is not blindly prepended.
`Main.chk.parsed` (15865) marks declarations as Base when the loaded path equals
the supplied Base path. **Base marking does not skip checking.**

The checker parser is a character-cursor parser (`Cur`/`PS`, `check.bend:294`),
not the emission lexer. `P.decls.go` (5152) consumes declarations until its
peek-zero end condition; unrecognized trailing text fails. A source admission
should retain bytes/hash and reject embedded NUL before using that end condition
as a whole-file guarantee. `parse_file` (7973) stores source/namespace/aliases in
the Book's `files` table, so source-location retention is part of the measured
work. Parse-only's empty output cannot establish cross-parser tree equality.

`Main.check.fin` (16095) invokes `Chk.check_book` on the entire loaded Book.
`check_book` (8023) checks ordered declaration events and rejects remaining
holes/open laws. The scheduler builds per-event persistent Book views; it does
not select only definitions reachable from `main`. It checks datatype signatures
and constructors, definition signatures and present bodies, and foreign-return
restrictions. Earlier signature events can be bodiless by design; the final body
event is checked. `book_reset` (7448), `book_valid` (7829), and
`book_valid.jobs` (7627–7660) define that ordering.

`Chk.report` (8336) is a subsequent dependency traversal over non-Base names,
including imports. Its unsafe verdict is not a typechecking error.
`Main.check_only.fin` can only be reached through the Done result of
`Chk.check_book`; a parse/type failure instead takes `Main.chk.fail`.
Accepting the exact expected list and count therefore distinguishes completed
checking from an early failure with the same process status. Require the complete
report, not merely the common `SOME PROOFS FAIL` prefix. Compare the expected
name set with the independent qualified checker verdict, accounting explicitly
for ordering/format differences if they exist.

## Unsafe still checks bodies

`valid.def.check` (`check.bend:7671`) always checks the declared type,
calls `valid.foreign`, and calls `def_check` when a body exists. `SDefCheckGo`
(7353) submits that body to `STermCheck`; `Tld.du` only populates its checking
context. The sequential fallback `valid.def` (7581) does the same work.
Unsafe is **not** a body or typechecking bypass. It relaxes these specific rules:

* Self-call decrease: `infer.ref.self`, 6314, gates it with `not CL.u`.
* Live access to an unfilled non-Base law: `SInferRefLive`, 7055; template
  instantiation restrictions still apply.
* Multiplicity-kind demand: `lhs_kind`, 5855, changes a many demand to one
  for unsafe contexts; ordinary body/type checking continues.

Our maintained checker has corresponding unsafe branches in
`selfhost/src/check/kernel.bend:733`, `:798`, and `:1586`.
`check_definition_world:1435` checks the type;
`check_definition_type:1190` then checks the ADT, foreign declaration or body,
and `check_definition_body:1486` checks the body. This establishes the relevant
source-level unsafe boundary in both implementations, not full conformance
equivalence for arbitrary programs.

## Cheapest useful diagnostic image

Clean CLI observations come first. If their difference warrants work, wrap only
three **pure synchronous** generated-C functions. Rename each exact body to a
private internal name and put a return-preserving wrapper at its original name;
collect `CLOCK_PROCESS_CPUTIME_ID` totals/call counts and return-tag success counts.
Emit one diagnostic JSON record separately from the original program streams.
Use one worker so nested parallel accounting is not ambiguous. The following
anchors are in the pinned current generated seed C, not the historical seed:

| Clock | Exact C function and arity | C line | Scope |
|---|---|---:|---|
| Checker parser | `F_Chk_dparse__file_x37u`, 13 | 68491 | `P.decls` plus parse result; excludes header reading, import resolution and line joining |
| Typechecking | `F_Chk_dcheck__book`, 1 | 61706 | Book reset, jobs, checks, replay/fallback and final holes check |
| Proof verdict | `F_Chk_dreport`, 1 | 112252 | Unsafe/foreign dependency report, before rendering/writing it |

These clocks are inclusive; do not sum nested child clocks as extra work.
The parser clock aggregates Base and input files. Optional per-file grouping
should use the already known loader path, not rehash or render the source during
the timed region. Record total process time separately; its remainder includes
startup, loading/header work, text joining, reporting IO and runtime activity.

For parsed declaration counts, the 13 parser arguments flatten the input Book
into `a0..a7`; `a2` is its reverse `order` list. `a8/a9` are source/text,
`a10/a11/a12` namespace/directory/aliases. On Done (`IS_N(result,1)`),
`FLD(result,0)` is the output Book and its field 2 is the order list.
Counting these lists before/after, outside the parser clock, gives declaration
events added, not token count or unique-definition count. List Nil is `IMM(0)`;
Cons is tag 1, tail field 1. A traversal is diagnostic overhead; run it only
with counters enabled. Do not read consumed inputs after the wrapped call.

Add cheap counts, not per-job clocks: `F_Chk_dVJob_drun` (61811) distinguishes
VADT tag 0 from VDef tag 1 and returns status 0 pass, 1 pass with template
instances, 2 failure. `F_Chk_dVJob_dredo` (66734) records replay. Count fallback
selection at `book_valid.par.fin` / `.redo`, not every recursive entry to the
sequential worker. A first failing job can suppress later jobs, and a failed
speculative batch/redo can invoke sequential fallback; therefore job attempts
are not necessarily unique declarations checked. Successful check_book plus
event/attempt/status/replay counts is the useful combined evidence.

Do **not** time `F_Main_dcheck` (61701): it constructs an IO bind; the checking
actually runs later in `L22831` (61697). Likewise, `F_Chk_dterm__check` (66170)
returns a checking monad, not a completed check. Hooking only a boxed `F_` or
`W_` wrapper can miss destination-passing/unboxed calls: for example the
normalizer has `D_Chk_dwnf_drun`, and the header parser has `U_Chk_dheader`.
The three coarse pure hooks avoid those pitfalls.

The historical `experiments/phase159/tools/stage-seed.py` demonstrates exact
hash/signature checks and return-preserving wrappers, but pins historical 9c
and cannot be applied to current C without new explicit anchors. This proposal
does not require Bend recompilation; it **does require one private Clang rebuild
of the retained C**. Instrumentation cannot be added to the existing executable
for free. Keep diagnostic timings separate from clean timings and require the
original exact exit/stdout/stderr contract after removing only the explicitly
identified diagnostic record.

The precise current-C proposal is `bendc-frontend-hooks.json`: three stage
wrappers and 34 scoped insert-after counters, with input/function hashes and
unique needles verified by host-side text inspection. It includes parser
declaration completion, consumed cursor characters, dispatcher tail-loop steps,
checker trie visits, persistent map update steps, job attempts/replay/fallback,
and optional native intrinsic counters. It has not been applied. Dispatcher
steps measure work performed while building/running checking continuations;
they are not a census of completed unique term proofs. Root's subsequent
uncapped/capped observations must be kept separate: a large runtime-policy
effect on identical input would rule out attributing the entire timing gap to
frontend algorithms merely from these counts.

## One concrete operational difference to count

`check.bend:1738–1765` gives memo-cell fallback/stub declarations. The native
runtime supplies actual `F_Chk_dmemo_dnew/has/get/set/same/link` implementations
at `bendrt.h:3085–3124`; the generated C calls these directly. They allocate a
two-cell mutable array, retain/share the cached value, compare term/cell identity,
and merge already evaluated memo values. This is real native checker work and
is absent from a naive interpretation of the Bend stubs.

If coarse checking is the remaining question, count memo allocations, probes,
hits, stores and successful links behind one runtime flag, with no per-event
clock or logging. Pin this modified runtime separately. Do not infer its profit
from source alone, and do not claim running the Bend stub implementations under
another compiler executes the same memo algorithm. Our checker also has explicit
memo machinery; this is a representation/operation boundary to measure, not
evidence that our checker lacks memoization.

## Comparison and runner limits

Our `selfhost/src/host/native-plan.bend` separates `p86_prepare:37` (load/check
Base) from `p86_plan:92` (user loader/parser) and `p86_plan_loaded:143` (checking
against prepared Base), then `p86_plan_checked:159` performs the proof report.
Fresh bendc check-only includes Base parsing/checking. Compare cold complete
frontend work including `p86_prepare`, or expose/count those components on both
sides. A prepared-Base stage time against fresh bendc is not an identical boundary.

Checked emission subsequently invokes another parser/backend and can special-case
normalized value mains (`Main.normalized:16120`, `Main.checked.go:30822`). Hence
two independent CLI times subtracted from each other do not isolate pure checker
CPU or allocation lifetime. The separate check-only clock is the direct measure.

`experiments/phase160/tools/probe.py` accepts explicit source/seed/Base pins and
the modes above, but its expected product is stdout-only and its success contract
normally requires exit 0. It cannot honestly qualify an expected unsafe verdict
without an explicit expected exit/stderr contract. The older `bendc-mode.py`
also hardcodes the uncapped original seed. Reuse their guard/pinning conventions,
not those unsuitable admission assumptions.
