# Phase177 frontend experiments

The selected combination is core substitution (`subst`, `subst_node`) plus
exact declaration lookup reuse (`p140p_def_header`). Its complete extracted
frontend improves 56.186→54.0595 seconds in two balanced rounds. The selected
full-source N1 passes native64 and preserves 45 timed QBE products. See the
[reproduction guide](../../../implementation/phase177/reproduce.md) for exact
source identities, raw receipts, commands and remaining closeout.

`prepare.py` is metadata-only dependency extraction pinned to the Phase175
maintained source. `full-prepare.py` composes explicit replacements while keeping
every original declaration, native main, signature and protected declaration.
Both deliberately reject a changed parent after integration; retained
experimental source files remain the reproduction inputs. Do not reapply the
overlays to an already integrated compiler.

The checked combined API uses `front-combined-source01`, whose additional
`p175fp_reference` export supports complete comparison. Native timed acquisition
uses the smaller `front-combined-source02`; they share selected algorithms but
are different extracted roots. Full composition uses
`substitution/selected.bend`, which retains the original `subst_node` parameter
name, instead of the extracted pilot's `single.bend`.

The bounded workflow remains:

1. Prepare an explicit closure and independently source-check it through
   maintained `hosted.mjs acquire`.
2. Compare complete values, including errors, order, spans and retained aliases.
3. Build the small native service with an explicit producer; inspect actual
   private workers and run existing native frontend screens.
4. Compare a survivor on the unchanged full input in isolated request mode.
5. Only then acquire the full native compiler and run maintained finite gates.

Use `job.py` for fresh process/disk-guarded runs and retention closure. Root owns
the serial CPU3 performance lane. Phase176's `batch.py` and this directory's
`screen-batch*.json` files provide explicitly bounded concurrent screens on
different physical cores; batch throughput is not final timing. Never nest
guards or overwrite immutable sources, receipts or duplicate QBE aliases.

Selected controls and experiments are grouped under `substitution/` and
`parser/`. `material-single/`, `publication/`, `reach/`, and `profile/` preserve
independent experiments and their limits. Keep rejected source versions,
failed API/ABI attempts, mismatched-export comparisons and profile retries;
later success does not retroactively turn them into passing observations.

The full N1 build omitted `--output-stage`. Its original build report is
unchanged; `bind-native.py` created a separate authenticated
`full-native-n1/image-binding.json`. Use that binding with the explicit binary
and `--stage N1`, as shown in [qualification/README.md](qualification/README.md).
The image supports native QBE only. No N2/self-reproduction, installed selector
change, JS/C image qualification or new generated-program runtime score is
claimed by these tests. Source type acceptance and finite semantic comparisons
are distinct from proof-safety assessment and independent BendTT proof.

The fixed-input cold pair completed: 178.7954→176.8633s, with exact QBE,
assembly and object bytes. Maintained integration is recorded in
`integration-applied01`; canonical source equals the measured selected source.
The installed compiler remains unchanged. See the final report and evidence
archive for completed decisions and receipts.
