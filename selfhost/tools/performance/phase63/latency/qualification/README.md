# Phase63 final qualification methods

`make-method.py` is a data-only successor of the frozen Phase61 frame2 package.
It records exact textual derivations, preserves the semantic and byte oracles,
and writes only to a fresh direct child of `selfhost/build/phase63`.

The selected snapshot supplies `base-cache-graph.mjs` when it exists; the ordinary
copy/input receipts pin it. Frame3 files go through that snapshot's decoder and
must still decode to the admitted version4/version6 records. Checked export roots
are joined to the actual bootstrap, admission and historical-root reference;
there is no fabricated checked sidecar on B2. Unsplit B3 reproduction follows
`jd_plan_selected`/`jd_plan_library`, matching the Phase63 split producer.

This factory binds tool identities only. Run it after `prepare-bootstrap.py` is
stable. It does not freeze current compiler source, build, test, install or run
Node. Root selects the final checked attempt and admits each execution stage.

From the repository root, materialize the methods on CPU0:

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase63/latency/qualification/make-method.py --out selfhost/build/phase63/qualification-method01
```

After root selects a genuine checked attempt and its export admission, create
the final stage plans (replace the selected paths below with actual evidence):

```sh
taskset -c 0 python3 -B selfhost/build/phase63/qualification-method01/qualification/final-plan.py plan --methods selfhost/build/phase63/qualification-method01 --attempt selfhost/build/phase63/SELECTED_CHECKED_ATTEMPT --admission selfhost/build/phase63/SELECTED_EXPORT_ADMISSION/admission.json --out selfhost/build/phase63/SELECTED_FINAL_OUTPUT --plans selfhost/build/phase63/SELECTED_FINAL_PLANS
```

If a selected B2 and its tiny split/unsplit/driver checks already exist, add
`--bootstrap-pins PATH_TO_IMAGE_PINS_JSON` to revalidate and reuse them. This
avoids a second B2 emission while preserving the source/API/admission join.

The generated `index.json` contains exact `rootLaunch` argv for checked-B1,
bootstrap, B2 and release-preparation stages. Root runs them serially after each
recorded barrier. Parent launchers stay unpinned and unguarded; each target owns
one CPU3 guard with 1 GiB Node heap, 2 GiB process-tree RSS, a 4 GiB available
memory floor and a 4 MiB stack. The checked stage preserves source96, numeric34,
composition18, overapplication2, direct26, maintained8, native3 and program45
oracles. B2 fresh own-source type acceptance, unsafe trust refusal, B2/B3 bytes,
semantic96/34/18/2 and raw23/program45 equality remain separate gates.

Release preparation creates commands only. Installation remains behind root's
final source, correctness, program-speed, compiler-cost and preservation decision;
this package does not promote a candidate or change the installed compiler.

No compiler targets have been executed by this factory's author. Python syntax
and deterministic derivation checks are data-only checks, not gate passes.
