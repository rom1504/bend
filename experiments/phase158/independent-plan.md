# Phase158 independent reproduction and resource audit

**Supersession, after measurement:** the initial plan below proposed reusing
Phase157's October6 `56edcc65` seed. Historical publication research replaced
that proposal with bendc **`9c54842eb5756803af599583ca49870d1e09186a`** and the
verified **upstream2.0.32 Base/effects**. Root built that historical seed and
measured it; the Phase157 executable, its larger C oracle and its Base were
not the measured compiler/input pair. The authoritative reconstruction is
[published-method.md](published-method.md); the final receipt audit at the end
of this file states the measured boundary. Earlier recommendations remain
proposal history, not the executed method or a record of completed pruning.

Read-only audit, 2026-11-04. No compiler, benchmark, machine build, deletion or
new target was run. Root owns measurements and any reclamation. This audit read
`AGENTS.md`, the current frontier, Phase157 methods/results, the retained bendc
source inspection files, and the existing Phase157 closure plans.

## Smallest meaningful result

Reproduce bendc's **no-check self-emission** first. Its pinned
[Makefile, lines48–50](https://github.com/Lulzx/bendc/blob/56edcc65b3527a75838011682c231072d5b46097/Makefile#L48)
runs `BEND_NO_FREE=1 build/bendc --no-check BASE bendc.bend` and compares the
complete output with `seed/bendc.c`. That is a useful exact output oracle and
requires **no new stage2 Clang build**. The retained seed executable was already
built successfully in Phase157; reuse it with its original receipt and exact
binary identity rather than pay its 88.38s acquisition again.

The expected complete output is the Git-blob-authenticated public seed:

- `selfhost/build/phase157/vendor/seed/bendc.c`: 4,628,175 bytes,
  SHA256 `b41edf49ccdb3846853955e5b89cf13c199b38e5d6fbe54d2c492a84fef519e3`.
- Seed executable: `selfhost/build/phase157/seed01/bendc`; construction receipt
  `seed01/report.json`. Bind its current binary identity into the new request.
- Vendor commit: `56edcc65b3527a75838011682c231072d5b46097`; retain the Phase157
  vendor manifest and exact runtime header used to construct this executable.

Successful gate: process exits0, complete stdout byte-equals the public seed,
and stderr satisfies the explicitly recorded clean diagnostic policy. Bind the
source/import closure, Base, effect files, compiler executable and generation
policy before and after the campaign. A hash is convenient for every sample;
the complete seed bytes remain available, so this is not a checksum-only oracle.
Retain at least one complete new emitted product and the comparison receipt.
Do not adopt a new nonmatching output as its own oracle.

This establishes reproduction by a third-party seed built with our toolchain.
It is **not** an independent correctness proof, diverse double-compilation,
successful execution of the newly emitted compiler, or the full bootstrap/test
chain. Those stronger claims require their own gates. A source/Base mismatch
can prevent exact reproduction without demonstrating a compiler semantic bug.

## Published boundaries that must stay distinct

The pinned [bootstrap script](https://github.com/Lulzx/bendc/blob/56edcc65b3527a75838011682c231072d5b46097/bootstrap.sh#L16)
uses `--no-check` for both stage emissions, then builds both products and runs
tests. The exact-output-only gate above intentionally establishes the narrower
Makefile selfcheck boundary.

The pinned README mixes historical observations:

- Its [benchmark table](https://github.com/Lulzx/bendc/blob/56edcc65b3527a75838011682c231072d5b46097/README.md#L869)
  reports **8.1s source-to-binary**, versus70s official Bend, on an Apple M4 Pro.
  That section describes an earlier16,000-line compiler/checker and upstream
  2.0.25. This is not an emission-only target or the current source-size claim.
- Its [automatic parallelism discussion](https://github.com/Lulzx/bendc/blob/56edcc65b3527a75838011682c231072d5b46097/README.md#L543)
  reports1.75s versus0.85s while producing the same C. That paragraph does not
  supply a fully bound timing receipt or state every command/environment detail;
  treat a current pinned local self-emission run as a controlled reproduction
  of the operation, not a claim to reproduce its absolute hardware timing.
- `--check-only` is separate from emission. In the inspected source,
  `Main.run2` invokes `Main.check`, then `Main.checked`; for ordinary IO `main`,
  that proceeds to `Main.build`, which loads/parses for emission again.
  `Main.run3` mode4 (`--no-check`) goes straight to `Main.build`.
  See [bendc.bend, lines30816–30864](https://github.com/Lulzx/bendc/blob/56edcc65b3527a75838011682c231072d5b46097/bendc.bend#L30816).
  Measure checked emission independently if desired; do not label the faster
  no-check number ordinary checked compilation or subtract separate medians to
  manufacture an exclusive checker cost.

No result from this compiler's own source directly compares with our much larger
compiler's self-build. Our current qualified Phase152 source is3,085,157bytes /
8,265declarations; Phase157 instead measured one extracted five-owner program.
Keep compiler execution, generated-program runtime and source-to-machine build
clocks separate.

## Inputs, policy and inexpensive sample protocol

Acquire the complete bendc source closure at the same commit as the seed. The
root source imports `check.bend`, `core.bend`, `rt/rtjs.bend`, `rt/rtchan.bend`
and `asm.bend`, plus Base. Follow their imports and foreign-code references;
`Main.load` resolves relative paths, while generated self-C can embed foreign
effects such as `rt/cc.c`. The earlier `/tmp/bend-ecosystem-20261104` files were
inspection copies, not a complete authenticated acquisition. Some scratch files
have an extra final newline. Do not build a pin from those copies silently.

The exact Base used for public seed generation is a separate identity from our
Phase157 upstream-phase66 Base. bendc's installer version alone does not prove
which Base generated a committed seed. Prefer a source-grounded published pin;
otherwise record the tested Base and let complete seed equality decide the
reproduction boundary. Preserve any mismatch, its first differing region and
full identities. Do not normalize nonmatching C or patch Base to force equality.

Use a sanitized environment: clear inherited `BEND_*`, then set the published
`BEND_NO_FREE=1` policy. The source makes automatic parallelism default off when
no-free is set; leave other generation defaults pinned unless recording a
separate ablation. Explicit `BEND_RC=0` / `BEND_AUTO_PAR=0` may be equivalent for
this source, but seed equality must establish that before treating them as the
same result. These variables are read by the emitter to choose **output code**;
they do not retroactively regenerate the already-built seed's own memory policy.

For the local serial baseline use the retained seed with runtime
`--threads 1 --gpu off --` before compiler arguments. The pinned Makefile does
not supply these restrictions, so label this a controlled single-worker result,
not a reproduction of an unspecified default-core wall time. The compiler
itself removes `argv[0]` in `Main.args`; unlike Phase157's cross-runtime workload,
this one-role seed run needs no extra synthetic program argument.

One complete-output pilot should establish admission before repeated samples.
Then use a small fixed number of fresh processes, same CPU3/seed/input/policy,
and retain all times, CPU, RSS, exit statuses and product hashes. Perform output
comparison outside the timed child. Emitting each sample to a regular file and
comparing it is inexpensive at the expected4.6MB; a `/dev/null` campaign would
still need exact full controls before and after and must disclose its output
sink. Do not silently reuse a checked result in a nominally fresh checked run.
No OS cache flushing is implied. A subsequent parallel ablation needs a declared
CPU mask and aggregate resource accounting; it is not necessary for this first
gate.

Keep ordinary guard limits:2GiB RSS,16GiB host headroom,5GiB disk reserve, explicit
child/campaign deadlines and fresh run roots. Source acquisition plus a few C
emissions can be budgeted far below a new native image build; inspect acquired
sizes before choosing the actual whole-run budget. Close failures as well as
successful samples. No new self-host chain or broad runtime suite is needed to
answer the first reproduction question.

## Already sealed Phase157 reclamation candidates

The existing close reports are complete/sealed and each inspected guard's
`retention.json` names its matching closure. The existing verified plans record
exact archived bytes and current exclusive regular files. A metadata-only census
found link count1 for all listed hot files. This audit did **not** rehash every
archive or delete anything; maintained `archive-v02.py apply` authenticates the
plan and every current member again before unlinking. Recheck current ownership
and ensure no Phase158 request dynamically reads a selected historical receipt.

| Closed root under `selfhost/build/phase157/` | Existing plan's allocated MiB |
|---|---:|
| `qbe01` |47.840|
| `qbe02` |47.840|
| `upstream01` |10.141|
| `upstream02` |10.141|
| `rc01` |9.977|
| `gc03` |4.633|
| `gc02` |1.391|
| Other completed/failed control and measurement roots combined |3.176|
| **All closed Phase157 roots except `seed01`** |**135.137**|

The two QBE workload roots alone supply95.680MiB. They are workload executables,
not the qualified Phase152 compiler. Their exact IR/assembly/objects/binaries
and receipts remain in separate verified archives. They are no longer needed
for the bendc self-emission operation. Pruning them makes historical Phase157
reruns require explicit restoration, not a compiler rebuild. The same applies
to the other listed workload/control roots if root confirms no active consumer.

For each selected name, the already verified plan is:

`selfhost/build-retention/phase157/NAME-guard-close/root-00/verified/plan.json`.

Example **plan only, not executed**:

```sh
python3 selfhost/tools/build-retention/archive-v02.py apply \
  --plan selfhost/build-retention/phase157/qbe01-guard-close/root-00/verified/plan.json \
  --out selfhost/build-retention/phase158/prune-phase157-qbe01
```

The tool obtains the shared lock, rejects stale identities, records intent and
journals removals. Use a fresh receipt directory per plan. Do not rerun `close`
over an already sealed guard, remove whole directories, or delete archive bytes.

**Keep hot:** `phase157/seed01`, `vendor`, `methods`, all guard directories,
all retention archives/plans, and every actual Phase158 input. Preserve qualified
Phase152, installed selectors, prepared Base/runtime assets, original captured
books/oracles and the shared Phase32 lock. The seed's closure says prunable but
its new Phase158 use overrides that historical classification.

Phase157 alone cannot supply200MiB while retaining the seed: the bound is about
135MiB, before small journal/metadata costs. Recover the smallest useful tranche,
measure actual free-space change, and admit a smaller emission-only budget if it
fits. Otherwise root needs another separately reviewed closed artifact; this
audit does not authorize broadening deletion or reducing the5GiB reserve.

## Final independent receipt audit

Read-only follow-up, 2026-11-04. This agent ran no targets. Reviewed
`selfhost/build/phase158/timing01/report.json`,
`default-workers01/report.json`, `check-oracle.json`, the independent upstream
checker receipt, and the exact-output gates in `tools/self-compile.py`.
No blocking inconsistency was found in these completed measurement claims.

Both timing reports are complete and bind the **same182 input identities**,
including the historical source closure, seed, source/runtime assets and checker
oracle. The measured executable is `phase158/seed01/bendc`, 2,928,752 bytes,
SHA256 `6eadbd111a78fd2f89a41cd42647e1bd9655a00ecfa04baf240b3eeec18d0847`.
Its expected emitted C is the historical committed seed, **2,802,777 bytes**,
SHA256 `039673e7cd0a3f8534b30b44af6256b1e957e473814a6337b43e4ba687e90db2`.
Both checked and unchecked emission reproduce those complete bytes, rather than
only printing an abbreviated result or accepting a newly generated oracle.

| Local boundary | One worker / CPU3 median | Eight workers / CPUs0–7 median |
|---|---:|---:|
| Unchecked self-C emission |4.498990s, nine samples|not repeated|
| Check-only report |5.044285s, five samples|5.061557s, five samples|
| Checked self-C emission |8.810187s, nine samples|9.634829s, five samples|

All23 serial and10 eight-worker observations pass their declared gates. Every
emission exits0 with empty stderr and exact committed-seed stdout. Each
check-only observation instead has **expected exit1**, empty stdout, and the
same392-byte stderr as the independently run upstream2.0.32 source checker:
`SOME PROOFS FAIL`, followed by the24 definitions that transitively rely on
unsafe or foreign code. Its digest is
`4a7b079d2f478493c707f83feda7a055c7303d68b6e501d5c4ad949c6899f4c7`.
This is successful reproduction of the expected trust-boundary report, **not**
an all-proofs-pass claim or an ignored type error. The generic process receipt
uses `complete:false` for exit1; the enclosing harness explicitly validates the
exit and both complete output streams against the independent oracle before
setting `passed:true`. These expected status1 observations are not timeouts.

The eight-worker follow-up changes both worker count and permitted CPU set;
its182 pinned inputs and generation environment are unchanged. It does not show
a wall-time improvement: checker time is approximately unchanged and checked
emission takes about9.36% longer in this block. Median CPU rises from5.043s to
22.837s for checking and from8.809s to36.471s for checked emission. These are
separate serial and parallel blocks, not interleaved worker-policy pairs or
confidence intervals; do not generalize the result to all hardware/workloads.
The historical unchecked entry bypasses the sole checker fork chain, so its
omission from this follow-up follows the source audit rather than an unmeasured
claim of parallel acceleration.

The result is a local reconstruction of historical **compiler execution and
self-C output**, including child output writing and teardown. No new emitted
compiler was built/executed, and no full bootstrap, DDC, native AArch64 compiler,
or3.5s/20s source-to-executable comparison was completed by these receipts.
The published M4 table lacks full run identities and flags; this x86 Linux host
cannot reproduce its absolute2.13s/2.55s figures or its AArch64-native lane.
Report local bests/medians alongside the published scope, without asserting a
hardware-normalized ratio. The receipts establish useful exact reproduction,
not that bendc's absolute published times were false or that our much larger
compiler ought to share this self-build time.
