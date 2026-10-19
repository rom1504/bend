# Exact combined worker profile

The current recipe is `conjunction-modules03.json`, admitted by
`admit-conjunction03.py`. It combines private argument bound32, three immutable
admission ranks, the exact CPU fail-stop path, early planner refusal and fusion
with its separate argument bound8. The final emission hook comes from the frozen
fusion `modules03.json` inventory, SHA256
`7b7c157bc6b0d0b86b2971cafe4af0c63c1178f4fa4d75ffb82b4d2db95f368d`.
Recipes01/02 and their methods remain preserved. Fusion01 failed binder order;
fusion02 exposed missing unrestricted pattern annotations. Fusion03 preserves
the interfaces and bounds while making those annotations explicit.

Root reports that fusion03 compiled and all controls plus 22 paired native
float/wide/fusion builds passed in
`selfhost/build/phase112/fusion-qualify-jobs03`. This records that qualification;
the new source-admission method still needs to bind the exact composed compiler
and runtime bytes used by each subsequent runner. Preparing this recipe executed
no compiler or native target.

```sh
python3 selfhost/tools/performance/phase112/workers/admit-conjunction03.py \
  --runtime-source selfhost/build/phase111/runtime-source04/runtime.c \
  --runtime-object selfhost/build/phase111/runtime-source04/runtime.o \
  --compiler COMPOSED/compiler.bend --out FRESH_ADMISSION
```

The method requires fixed hashes for its inventory, every worker/fusion module,
the original model/verifier and selected CPU runtime source/object. It compares
the resulting final declarations with the supplied compiler, including the
actual segment-emission hook and the complete worker/early/fusion namespaces.
Seven in-memory changed-source controls must be refused. No compiler or native
target is executed by this admission tool.

The runner must bind the admitted compiler and runtime object bytes. If the
compiler includes float or static modules, their own admission receipts are
required against this same compiler source. Those independent overlays do not
change the worker admission signatures or the `p111q_segment_chunks` hook;
this recipe does not silently claim their semantics.

For the early-refusal comparison, export `p111_verify_program`, `p111q_ids`,
`p111q_chunks`, `p112t_plan`, `p112t_admitted`, `p112w_index`, `p112w_plan`,
`p112w_admitted`, `p112w_program_counts` and `p112w_segment_chunks`. No `p112e_`
helper export is needed. Old and new APIs must otherwise select the same
profiles. Count actual private workers/fusion sites before native acquisition,
then require exact emission identity when comparing only early refusal.
