# Phase37 final-image integration

These planners execute nothing. Root selects the completed final checked B1
attempt, then runs acquisitions and gates serially on CPU3 with Node24.18,
heap1024MiB, process-tree RSS2048MiB and free-memory floor2048MiB. Every output
directory must be new. A failed attempt is retained and never becomes an
integration input merely because its compiler file exists.

The commands below use checked02 as a prospective example, not a claim that it
passed. Set the two input paths to the actual selected attempt and its completed
45-point preparation before running. The preparation must belong to that exact
API/runtime/Base/driver; rebuilding the compiler invalidates earlier candidate
preparations and owner outcomes.

```sh
P37_ATTEMPT=selfhost/build/phase37/checked02
P37_CANDIDATE=selfhost/build/phase37/candidate02/manifest.json
P37_HISTORICAL=selfhost/build/phase37/historical02
P37_FINAL=selfhost/build/phase37/final-plan02
P37_OWNERS=selfhost/build/phase37/phase36-owners02

python3 selfhost/tools/performance/phase37/derive-integration-tools.py
python3 selfhost/tools/performance/phase37/historical-subset.py \
  "$P37_CANDIDATE" "$P37_HISTORICAL"
python3 selfhost/tools/performance/phase37/final-integration-plan.py \
  "$P37_ATTEMPT" "$P37_FINAL" \
  --added-module src/back/js/jpure.bend \
  --added-module src/back/js/fold.bend \
  --added-module src/back/js/producer.bend \
  --added-module src/back/js/finite.bend \
  --prepared "$P37_HISTORICAL/manifest.json"
python3 selfhost/tools/performance/phase37/phase36-owner-plan.py \
  "$P37_ATTEMPT" "$P37_HISTORICAL/manifest.json" "$P37_OWNERS"
```

Run `derive-integration-tools.py` only once: its new generated sources and JSON
derivations are retained phase inputs. It verifies the exact Phase36 planner,
its Phase35 parent and Phase35 corrected auditor before applying counted text
changes. The extra compiler module is permitted only immediately after
`producer.bend`; the previous66-module order and nonmodule manifest fields stay
exact. With all four named additions the layout is70modules.

The historical-subset adapter avoids13 duplicate compilations. It verifies all
15 original source hashes, source bytes and exact points against the expanded
catalog, then copies the original modules and checked emission receipts without
changing their bytes. It records both catalogs, the original45-point acquisition
and the metadata-only subset mapping. The complete-row observer keeps its
original adapter provenance. Its preparation is explicitly a derivation, not a
claim that those compilations ran again.

The auditor has one narrow historical-tool rebinding: the live reference packer
is pinned at its Phase37 `--catalog` implementation while the archived Phase32
packer, adapter, provenance and archive hashes retain their original exact
checks. No old compiler path is resolved through a new release. The maintained
historical15 catalog and its run/support readers remain pinned unchanged.

## Inherited correctness and owner groups

```sh
python3 selfhost/tools/performance/phase35/final-integration-run.py \
  "$P37_FINAL" --stage preinstall --out selfhost/build/phase37/final-launch02
python3 selfhost/tools/performance/phase37/final-gate-audit.py \
  "$P37_FINAL" selfhost/build/phase37/final-audit02 \
  --owner-controls "$P37_FINAL/owner/report.json" --require-closed

python3 selfhost/tools/performance/phase35/final-integration-run.py \
  "$P37_OWNERS" --stage owner --out selfhost/build/phase37/phase36-owner-launch02
```

Do not wrap either complete serial runner in the shared-lock bounded runner:
its commands already acquire the lock. The same applies to `prepare.py` and
`cohort-acquire-v2.py`. All unsupervised JS/closure commands in both plans receive
their own bounded-run wrapper. A campaign-wide monitor must use a distinct lock.

The inherited plan retains3,026 main and196 broader exact frontend observations,
81 backend rows (69pass,8N/A,4shared failures),56,205 primitive observations,
3,759 worker observations,144 nested checks,1,129 primitive guards,15 upstream
execution witnesses,23libraries/127points,40worker refusal guards/two witnesses,
22component observations and42exact HVM stdout bytes. All15 Phase35 owner groups
run again on checked candidate emissions. Neither source-layout migration nor
the expanded program benchmark substitutes for these gates.

The second plan makes fresh Phase35-baseline/final-candidate/TS emissions for
four corrected Phase36 fixtures. It also prepares one fresh Phase35 ray module:
this preserves the unchanged checked-guard adapter's strict producer identity
instead of relabeling an old receipt after maintained emit-worker changes. Its
seven groups remain independent of the inherited15:

| Group | Actual final-API observations required |
|---|---|
| guardcolf | 57oracles and200boundaries; diagnostic counters in the actual ray tree branch |
| guardscope | 10observations; proof lifetime, mutation and cleanup |
| error | 16oracles and4Error callback/reentry boundaries |
| array | 16oracles and4native-array refusal boundaries |
| producerfixture | 175oracles and5admission observations |
| producerreviewed | 108complete trees,36alias checks,9entries,27boundaries,3structure checks |
| selector | 243oracles,10admission checks,6boundaries |

The last command invokes the unchanged Phase36 closer and writes
`$P37_OWNERS/report.json`. It recursively binds each named report to checked
emission receipts and this selected API/runtime/Base/driver. A passing earlier
Phase36 report is comparison history, not a substitute final-API result.

The actual `phase36-owners01` campaign passed all seven control groups, but that
unchanged closer failed while treating a pinned Git source path as a file under
the historical catalog directory. Its failed report and consumed tools remain
unchanged. The reviewed Phase37 successor repairs only identity traversal,
retaining all original semantic/checked-emission assertions and exact owner
counts. It verifies catalog-relative paths and pinned Git blob bytes explicitly;
it does not skip missing provenance. See the
[audit-repair note](../../../../implementation/phase37/inherited-owner-audit-repair.md).
After independent review, root closes those same controls with a fresh output:

```sh
python3 selfhost/tools/performance/phase37/phase36-owner-close-v2.py \
  selfhost/build/phase37/checked03 \
  selfhost/build/phase37/historical-subset01/manifest.json \
  selfhost/build/phase37/phase36-owners01/cohorts \
  selfhost/build/phase37/phase36-owners01/mapping.json \
  selfhost/build/phase37/phase36-owner-close02/report.json
```

Use the same bounded serial supervisor for this auditor. Do not rerun or rewrite
successful controls merely to conceal the failed audit, and do not infer a pass
until the successor's report closes all seven groups.

## Phase37 admission and release

Keep new finite-selector, Bool-native, cast and DataView owners separate. Require
the controls for every retained change on this same final API, plus independent
review and a closure that reaches their checked acquisition receipts. The finite
controls must exercise actual private entries and refusal, complete constructors
and alias identity, raw/partial/getter/mutated public entries, left-to-right
argument errors and Error callback reentry, and deep self/mutual tail cycles.
Historical15 and Phase36 owner reports cannot discharge these new obligations.
Saved-output ablations are hypothesis evidence only.

Before installation, admit complete output oracles across45 frozen points and
the32small application controls, separate heldout results, clean paired runtime
measurements, normal checked-request compilation cost and emitted/source size.
Retain all failed attempts and any shifted/overlapping timing ranges. A profiler
or diagnostic counter copy does not provide a clean timing result. Record which
retained patches survived their scoped controls; do not carry rejected proposals
into the selected canonical source.

Only after both inherited closures, new owner closures, source identity and
performance admission pass:

```sh
python3 selfhost/tools/performance/phase35/final-integration-run.py \
  "$P37_FINAL" --stage postinstall --out selfhost/build/phase37/postinstall-launch02
python3 selfhost/tools/performance/phase37/final-gate-audit.py \
  "$P37_FINAL" selfhost/build/phase37/postinstall-audit02 \
  --owner-controls "$P37_FINAL/owner/report.json" --require-closed --post-install
```

That stage installs the selected checked B1 derivative, verifies it, and executes
all42 ordinary/relocated CLI assertions. Canonical files must still match the
attempt snapshot. This does not create a self-emitted fixed point or establish
full backend/GPU conformance; shared failures retain their historical verdicts.

Authoring status: no planner, compilation, assertion or install was executed by
the coverage agent. Root records actual attempt names and successful or failed
outputs in the Phase37 implementation report.
