# Phase157 bendc acquisition and comparison contract

Read-only source audit, 2026-11-04. No compiler, generated program, build,
bootstrap or benchmark was executed for this audit. Root owns the target lane.

Use bendc commit **56edcc65b3527a75838011682c231072d5b46097**. On Linux x86_64
the supported experiment is **Bend → C → Clang**. Its `--native` emitter writes
AArch64 instructions and AAPCS64 calls; choosing ELF does not make it x86 code.
The checked-in CI matrix is Linux arm64 and macOS, so it is not an x86 receipt.

## Authenticated inputs

The read-only scratch files in `/tmp/bend-ecosystem-20261104` have SHA256:

| File | SHA256 |
|---|---|
| `bendc.bend` | `72be729fb5a27c528acc4d232314ac44c4595a86dc67d9dde47197956edabb99` |
| `check.bend` | `e8bb83525fb0484bd12c33f60a2bb958a30aee9b4965828bb043f2d949870ad7` |
| `rt/bendrt.h` | `3062c77a06e4f0964c75a509e669da2d76e74ccdc92a67d948b4ab8febf3dfa6` |
| `Makefile` | `dbb85aa8a3375e85095a8058f8c82eaf77baa4cae0363ae3188945a72137b071` |
| `bootstrap.sh` | `90116a8e620f24d6a5e5c17f956c836cd6f6c063a5c038011b7cf3da15c8a58b` |

Scratch text is for inspection, not acquisition identity: its runtime has one
extra final newline. Root subsequently acquired Git-blob-verified bytes under
`selfhost/build/phase157/vendor/`; its `manifest.json` is authoritative:

| Build input | Bytes | SHA256 | Git blob |
|---|---:|---|---|
| `seed/bendc.c` | 4628175 | `b41edf49ccdb3846853955e5b89cf13c199b38e5d6fbe54d2c492a84fef519e3` | `b88f24da37066de9dc7ece24a51b92a761463820` |
| `rt/bendrt.h` | 196009 | `b99a4c3d186b233b5ebbc70fe6923f2de422827ee1a1a22eaddcc768d340167a` | `bd9ef1010fbf2afa167ec582969f51bcb07c2590` |

Our Base is `selfhost/.bootstrap/upstream-phase66/bend2/base.bend`, 75,064 bytes,
SHA256 `99ac43f2b2bb3e3f39acdcedcecbbd3cb44749ce13969c827d6973fa66f7facf`,
at upstream `059266225b77c8ca256ac6b25ee5c21449bab151`. The manifest and actual
file hash agree. Do not select historical `.bootstrap/upstream`: its checkout
and Base differ. Keep Base beside its exact `effs/` directory; emitted C reads
and embeds the relevant effect files after resolving constructor/function IDs.

bendc's `tools/install-bend.sh` pins upstream **2.0.34**. Its reported seed
selfcheck and frontend receipts therefore do not establish compatibility with
our Base pin. Do not run its installer or change our pin. The inspected pinned
Base has the expected Unit/Bool/Maybe/Result/String constructor shapes, ordinary
U32/Nat definitions and File/IO signatures; that is useful static evidence,
not a successful end-to-end compatibility check.

## Smallest acquisition and build route

Root acquired `seed/bendc.c` and `rt/bendrt.h` from the same commit, and owns
building the committed seed directly. The Makefile seed target requires those
two files and a C compiler; seed acquisition does not require official Bend,
Bun, `boot.bend`, a new upstream install or the full bootstrap chain. The exact
vendor seed's includes confirm `bendrt.h` is its only non-system include when
`BEND_RT_SPLIT` is absent; its SHA256 was independently recomputed above.

For retained C products, the monolithic header path is the smallest independent
route. For the normal reusable runtime path also retain `tools/rtsplit.py`,
`rt/bendrt_split.h`, `rt/bendrt_impl.c`; generate them from the pinned header if
necessary and hash the products. `rt/cc.c` implements bendc's `-o` convenience
driver. `rt/native.c`/`natives.o` are for the AArch64 route and are unnecessary
for the proposed x86 C route. Base effects are still needed at emission time.

Command shapes below are a plan, **not executed**. Root must put each bounded
job under the maintained retention guard with its complete output roots and
disk/time/RSS budgets. All output paths are fresh, and all tool paths/versions
must enter the receipt.

```sh
# BENDC_TREE: frozen source/assets; PHASE157_OUT: fresh guarded run directory.
clang -O2 -w -I "$BENDC_TREE/rt" "$BENDC_TREE/seed/bendc.c" \
  -o "$PHASE157_OUT/bendc-seed" -lm -lpthread -ldl

# Emit with checking. PHASE157_BASE is the exact Base path above.
# PHASE157_SOURCE is the same frozen source used by the original compiler.
env BEND_NO_FREE=1 BEND_RC=0 BEND_AUTO_PAR=0 \
  "$PHASE157_OUT/bendc-seed" --threads 1 --gpu off -- \
  "$PHASE157_BASE" "$PHASE157_SOURCE" > "$PHASE157_OUT/program.c"

# Monolithic runtime: retain the complete emitted C and build it separately.
clang -O3 -fno-tree-slp-vectorize -falign-loops=16 -w \
  -I "$BENDC_TREE/rt" "$PHASE157_OUT/program.c" \
  -o "$PHASE157_OUT/program" -lm -lpthread -ldl
```

The C flags in the last command match `rt/cc.c`'s program optimization settings.
They differ from the seed's `-O2` acquisition flags. If using the split route,
compile the runtime at `-O2`, add `-DBEND_RT_SPLIT`, and link `bendrt.o`. Its
header asserts exact Base constructor IDs; do not remove this assertion.
Upstream explicitly prescribes the monolithic path if the IDs differ.

The convenience `-o` path locates `bendrt.o` beside the executable and the runtime
sources in `../rt` or `BENDC_RT`. Its cache invalidation uses mtimes, not hashes;
use a fresh private directory/object. It builds missing runtime code inside the
request, so distinguish first acquisition from warm-runtime requests. Explicit
C emission/build avoids that ambiguity and retains the intermediate.

Start with a small IO/file control, a refusal control and the same complete small
compiler request before attempting our full source. Compare full generated QBE
bytes from the resulting compiler with the independent qualified image, including
exit code and stderr. A compiling seed or matching stdout alone is insufficient.
Do not add a full bendc self-bootstrap merely to acquire this bounded experiment.

## Checking and runtime modes are different axes

`BASE SOURCE` executes `Main.check`, then (for ordinary IO mains) reparses and
emits through `Main.build`. `--no-check BASE SOURCE` goes directly to
`Main.build`; it is a separately labelled unchecked frontend experiment. It
does not bypass the independent verifier implemented *inside our compiler* when
that generated compiler later runs, but does omit bendc's source admission.
Do not silently substitute it for a checked timing. `--parse-only` only loads;
`--check-only` also reports dependence on unsafe/foreign code and can exit 1 for
that reason. It is not an independent BendTT kernel verdict.

Non-IO mains whose result may contain functions or dependent families can be
normalized by bendc's checker into a constant-printing program (`Main.normalized`
and `Main.emit_value`). Use the genuine IO compiler entry for execution timings.

| Setting at C emission | Actual source behavior |
|---|---|
| `BEND_NO_FREE=1` | Disable early match freeing; tracing GC remains. Any **nonempty** value, including `0`, disables freeing. |
| `BEND_RC=0` | Explicit tracing selection; suppress automatic RC/hybrid classification. |
| `BEND_RC=1` | Generate RC; tracing normally disabled unless hybrid/trace is requested. Not equivalent to merely changing GC policy at runtime. |
| Unset `BEND_RC` | Input-dependent automatic RC+tracing for admitted bounded numeric/effect programs. |
| `BEND_AUTO_PAR=0` | Disable implicit parallel-call generation. With no explicit setting, no-free also disables it. |
| `BEND_UNBOX` | Unboxed parameters enabled unless exactly `0`. |
| `BEND_OPT` | Defaults to `i..spufwhtm`; even an empty supplied value replaces that default. |

The above emission variables affect the **new image**, not retroactively the
already-built seed. Record seed and target image policies separately. Fix the
compiler-image experiment to tracing/no-early-free first; an RC ablation would
be a later separately checked image, not a runtime toggle.

The exact vendor seed was also inspected: `Main.emit.c`'s generated continuation
at78714–78844 implements the same environment reads and free/RC choices;
`F_HY_ddefault` at108410 suppresses automatic selection for any supplied RC
value. Seed `main` at113073 calls `bend_run` without setting `bend_rc_req`.
There are no direct generated `bend_take`, `bend_share`, `rc_drop` or `rc_dupn`
call statements in this seed. This is consistent with its documented compiler
tracing/no-early-free policy; no generated code was executed for this audit.
For a later explicit RC image, use `BEND_NO_FREE=` (empty), `BEND_RC=1`,
`BEND_AUTO_PAR=0`, with `BEND_RC_TRACE` absent at execution. Such an image needs
its own complete-output and memory-safety controls before performance comparison.

At execution, `--threads 1 --gpu off -- <program args>` prevents the default
CPU-count worker pool and cleanly separates runtime flags. Do not use upstream
`+RTS ... -RTS` syntax: this runtime does not strip it. Pass the same runtime
prefix to the seed and resulting compiler. Linux has no Metal path here.
Pin process affinity separately; do not confuse one worker with one process
thread (runtime helper/event-loop threads can still exist).

Clear inherited `BEND_OPT`, `BEND_UNBOX`, `BEND_RC_TRACE`, `BEND_GC_*`,
`BEND_FORK_DEPTH`, and debug/stats settings before the controlled job. Preserve
the explicit emission settings above. `BEND_RC_TRACE` and `BEND_GC_MAJOR` test
presence, so setting them to `0` does not mean off. GC statistics contaminate
stderr; changing heap thresholds also changes the measured policy. Use external
RSS/time accounting for the clean comparison.

## Primary sources

- [Pinned Makefile](https://github.com/Lulzx/bendc/blob/56edcc65b3527a75838011682c231072d5b46097/Makefile), [bootstrap](https://github.com/Lulzx/bendc/blob/56edcc65b3527a75838011682c231072d5b46097/bootstrap.sh), [upstream install pin](https://github.com/Lulzx/bendc/blob/56edcc65b3527a75838011682c231072d5b46097/tools/install-bend.sh).
- [Compiler](https://github.com/Lulzx/bendc/blob/56edcc65b3527a75838011682c231072d5b46097/bendc.bend): `Main.free/rc/auto_par` around15329, `Main.check/normalized` around16101, `Main.emit.c`30747, CLI30836–31031, native backend26475.
- [Runtime](https://github.com/Lulzx/bendc/blob/56edcc65b3527a75838011682c231072d5b46097/rt/bendrt.h): GC initialization577–598, effect ABI4130+, CLI4840–4888.
- [C driver](https://github.com/Lulzx/bendc/blob/56edcc65b3527a75838011682c231072d5b46097/rt/cc.c), [runtime split](https://github.com/Lulzx/bendc/blob/56edcc65b3527a75838011682c231072d5b46097/tools/rtsplit.py), [CI matrix](https://github.com/Lulzx/bendc/blob/56edcc65b3527a75838011682c231072d5b46097/.github/workflows/ci.yml).

## Existing runtime diagnostics and stack boundary

Additional source-only audit of the exact vendor runtime above. These options
need no compiler modification or rebuild. Keep their runs separate from clean
wall/CPU/RSS results and retain their stderr as diagnostics, not oracle failure
output silently discarded by a filter.

| Runtime environment | What it reports | Cost and limits |
|---|---|---|
| `BEND_GC_STATS=1` | Each collection: index, major/minor, live/freed/heap MiB, next threshold, rescans, collection elapsed ms, mark-drain ms and participating threads; exit heap and bytes handed out since the last collection. | Two additional clock reads and stderr formatting/write per collection, plus exit print. Allocation policy is unchanged directly, but timing/IO can perturb execution. |
| `BEND_RC_STATS=1` | At exit, allocated objects/slots remaining after subtracting unissued cache slots and thread free lists. Only prints for an RC image. | No added per-dup/drop counter; exit scans block bitmaps, caches and free lists. Includes retained constants; it is not a leak verdict, allocation count or RC-time counter. |
| `BEND_GC_STATS=2` | Everything from `1`, plus exit small-block counts/free slots by pool and size class. | Additional full block census and output. Defer unless fragmentation is the specific question. |

The cheapest useful diagnostic follow-up is one same-input/repetition run of
the existing GC binary with `BEND_GC_STATS=1`, and one of the RC binary with
`BEND_GC_STATS=1 BEND_RC_STATS=1`, **without** `BEND_RC_TRACE`. The explicit RC
image normally has no tracing collections; enabling `BEND_RC_TRACE` changes
the policy rather than revealing an existing cost. Never set it merely to
obtain collection lines. `BEND_GC_STATS=0` is also nonempty and enables output;
unset it for clean runs.

Collection elapsed time starts before stop requests and ends after tracing,
sweeping and resume handling (`gc_collect_locked`,2470–2588); it is not exclusive
collector CPU. The printed marking interval covers `gc_drain_par`, excluding
earlier root scanning. The collector already maintains its own elapsed intervals
for adaptive heap sizing even with stats off. MiB values are integer-truncated.

`gc_since` is batched in64KiB per-thread increments (`gc_handed`,736–748), resets
after collection, and hybrid occupancy rejection can reset it without collecting
(628–648). Therefore the exit field is neither exact total allocation traffic
nor a count of logical allocations. The runtime exposes no environment option
for total allocations, dup/drop counts, reclamation CPU, or RC work-stack high
water. Do not infer these from retained occupancy. `BEND_DEBUG_FREE` and
`BEND_DEBUG_POISON` require rebuilding and change memory operations; the former
retains poisoned freed nodes and records backtraces. They are correctness tools,
not low-overhead counters.

For the selected workload, large runtime-loaded books, linked lists and nested
terms do **not** imply recursive RC destruction. `rc_drop` calls
`rc_free_obj`(1694–1738), which loops through dying children and pushes remaining
work onto dynamically grown `Thr.rcs`(1660–1678). Large objects stream fields
using explicit parent/index continuations. `rc_publish`(1944–1979) is iterative
too. Pending destruction work is traced as a root if tracing is enabled. Resource
exhaustion of this heap worklist remains possible, but it is not native call-stack
growth proportional to object depth.

There is a narrower recursive path: `rc_immortal`(1914–1937) recursively visits
all but the last field, then loops through the last. It is called when caching
string literals and `KONST` values (`str_cache`/`konst_cache`,3326–3357). A deeply
left-nested cached constant can therefore use a deep machine stack; ordinary
string/list tails iterate. Our178,345-node captured book is read and decoded at
runtime by `p157w_open`, not embedded as one cached constant. This source fact
does not prove every smaller emitted constant or generated helper call safe.

Generated computation can still recurse, and RC call wrappers can contain
post-call drops (`RC.wrap.one/call` in bendc source5709–5735). Do not equate the
iterative reclamation implementation with universal stack safety or assume every
source tail call remains a machine tail call. The Linux runtime maps an aligned
4GiB virtual stack region per Bend worker, with a guard and metadata
(`thr_stack`,2635–2669); this is virtual reservation, not resident RSS. Its generic
SIGSEGV/SIGBUS message, `memory fault (machine stack overflow?)`, also covers
other memory faults and is not a diagnosis. If a finite control fails, retain
the failure and inspect that image before attributing it to RC or stack depth.

## First emission refusal: expression-lambda line breaks

Root's original checked-emission receipt `selfhost/build/phase157/gc01/emission.stderr`
refuses the comma in `jd_raise`, original workload line2262. The error text comes
from bendc's separate token/layout emission parser (`PsPrimarySym`,2335), not
its `Chk` character parser. `Lay.toks.go`676 treats a line-final `=>` as a block
opener, and `Lay.line` can emit `KIn` inside an enclosing call. `PsLamBody`2352
then parses an indented statement block. The argument-separator comma after
`jd_raise_typed(...)` does not decrease the enclosing bracket depth, so the
block remains open and the comma reaches the statement parser.

Smallest proposed compatibility transform: replace the newline and indentation
immediately after a **bracketed, single-expression lambda's** line-final `=>`
with one space. For the first refusal this joins only the breaks after lines2260
and2261. Keep the argument commas, parentheses and all other non-whitespace tokens
unchanged. This avoids `KIn` and selects `PsIexpr` instead. Do not flatten genuine
lambda blocks containing local declarations, `do`, `match` or sequential statements.

A source-only census finds368 line-final arrows, with no intervening blank/comment
lines. The following expression starts with `nt_choose`316 times, `p151_choose`19,
and `kc`5; none starts with `do`, `match`, `case` or `return`. These counts are an
admission screen, not an AST-equivalence proof. Use a string/char/comment-aware
scanner; do not rewrite a textual `=>` inside emitted-code string literals.
Preserve the original source, record every edited offset, and require the pinned
upstream parser's original/normalized ASTs to agree after removing locations,
plus independent source checking and the complete existing output oracle. Use
identical normalized bytes in every compiler lane. No transform or target run
was performed in this audit; a further unrelated parser refusal should stop this
bounded workaround from becoming an open-ended compatibility project.

## Legacy effect registration adapter

The normalized source passes bendc emission, but `gc02/machine.stderr` records
nine C arity errors: the unchanged pinned Base effects call two-argument
`io_eff(cid, callback)`, whereas this bendc runtime requires a third argument.
The raw `gc02/program.c` is1,445,154bytes, SHA256
`117919168cbfca89b370d02576a716b0ab1fb228f751b03eaa979ae411657cd6`.
This is a narrow foreign-runtime ABI mismatch, not a reason to change the common
Bend source or replace pinned Base effect implementations.

**Source-grounded adapter:** add `, 0` to exactly these registrations in retained
generated research C, with exact-match/count assertions and a separate patched
file. The nine constructor tags are distinct in this emission.

| Constructor | Callback | Low tag |
|---|---|---:|
| `CID_FILE_CLOSE` | `file_close_run` |24|
| `CID_FILE_WRITE` | `file_write_run` |22|
| `CID_FILE_WRITE_BYTES` | `file_write_bytes_run` |23|
| `CID_FILE_OPEN` | `file_open_run` |17|
| `CID_FILE_READ` | `file_read_run` |18|
| `CID_FILE_READ_BYTES` | `file_read_bytes_run` |19|
| `CID_FILE_READ_AT` | `file_read_at_run` |20|
| `CID_FILE_SIZE` | `file_size_run` |21|
| `CID_IO_ARGS` | `io_args_run` |4|

This zero is not guessed. The exact pinned
[bendc seed](https://github.com/Lulzx/bendc/blob/56edcc65b3527a75838011682c231072d5b46097/seed/bendc.c)
already registers these same nine effects with zero (3745–3958 and4206).
A source-only extraction compared all30 associated callback, helper and
registration definitions against `gc02/program.c`: every definition is
byte-identical after only the nine proposed registration additions. The seed
and runtime hashes rechecked during this audit match the vendor identities above.
This does not authorize zero for arbitrary additional effects.

In the pinned [runtime](https://github.com/Lulzx/bendc/blob/56edcc65b3527a75838011682c231072d5b46097/rt/bendrt.h#L4214),
`io_eff` stores `need` in `IoEff.ask` (4214–4225). `io_step` (4605–4635)
uses it only to request a pre-dispatch descriptor-readiness or millisecond-timer
wait, interpreting the first request field accordingly. Zero dispatches directly
through `io_exec`. It is not an allocation budget, field count, collector-root
declaration or ownership mode. The pinned upstream runtime's old `io_step`
also invokes registered effects directly before honoring their returned
`IO_PARK` (`selfhost/.bootstrap/upstream-phase66/bend2/comp.ts`,5850–5880).
Current upstream effect sources inspected at
`ea66e0044fc1632c28e35b7b0f0d2263d77e3449` also retain two-argument registration;
newer file bodies have unrelated behavior changes and are not this adapter.

The allocation/ownership boundary is unchanged. `io_exec` copies request fields
to its local array, releases only the request shell in RC mode, preserves its
continuation in `IoAct.cont`, and transfers arguments to the callback (4544).
File open/write callbacks copy Bend strings or bytes into owned host buffers
before parking; read callbacks allocate host buffers. Their `IoWork` state holds
host handles, scalars and buffers, not pending Bend values. `io_work` (4526)
runs only the host operation on a helper thread; `io_take` (4498) invokes the
packing callback on the event loop to construct the Bend result and free host
buffers. Thus zero does not make these host operations run synchronously on the
Bend loop. File close and IO.args are synchronous in both seed and old Base.
`io_hook` (4741) traces every live activity's continuation and item; active
callback locals are covered by normal Bend-thread stack/register tracing
(`gc_collect_locked`,2470 onward). `io_cstr`/`io_cbuf` already consume their
input ownership in RC mode (4349–4405). None of these mechanisms reads `need`.

Retain original and adapted C, both hashes, and a manifest containing the exact
nine before/after lines. Reject missing, duplicated or unexpected two-argument
registrations; do not install a variadic macro or globally default new effects.
Apply the same allowlist to the separately emitted GC and RC C, checking their
actual callback definitions again. Leave the runtime header, pinned Base and
common normalized Bend bytes unchanged. Ordinary compilation and the complete
173,582-byte QBE oracle remain required gates; this source audit itself ran no
target and does not establish the rest of the foreign ABI correct.

Runtime argument comparison also needs the same effective `IO.args` values:
bendc deliberately preserves `argv[0]` (`bend_start`,4853). Root's common
`exec -a compiler-work` wrapper plus lane-specific sentinel handling addresses
this difference without changing program source; retain the final exact command
vectors in run receipts.
