# Virtual projection of a verified product observer

The completed bounded experiment and current reproduction paths are in
[RESULTS.md](RESULTS.md). Source06, `prepare-late-v03.py` and `cases-v05.json`
are the tested versions. The initial source03 flow described below established
semantic eligibility but emitted identical QBE; actual worker readiness had to
move before retry through the retained raw-candidate entry. Closure-only and
product-projection variants now both have independent native output gates and
separate clean timing. Earlier source/fixture revisions remain negative evidence.

This prototype preserves the selected Phase130 reader's actual computation.
It extends the existing `P128BRHelper` summary with the exact checked result
wrapper and observation binder. Product observers enter only through the
unchanged `p118b_eligible` gate and successful `p118b_functions` lowering, with
the expected private reader present in that emitted bundle. The integrated
`p128br_scan_ready` seeds its summary from **the same actual workers** that it
appends to the output, preserving worker order and the original retry rules.
No second lowering is needed. Ordinary scalar summaries retain their existing
admission path. Product bundles may contain the pre-existing optional flat
worker; their reader and boxed adapter stay in their original order.

At a call, existing argument typing and held-origin checks still apply. The
reader executes eagerly through existing `NO_ReadCall`; its checked `Ctr`/`Var`
result wrapper becomes `OC` virtual constructors whose leaves are the same held
argument origins and the fresh scalar result. Existing symbolic evaluation can
then project that product. The generated scalar caller still passes existing
residual checks, independent direct verification and the existing alias guard;
its exact original owning worker remains the fallback. No String name is
recognized, no comparison loop is rewritten and no runtime ABI is added.

Only wrappers of at most two known constructor levels with bound parameter or
result leaves are admitted. Result/parameter binder collision is refused.
Unsupported escapes and effects remain rejected by the unchanged NO analyzer.
Summaries are seeded only from original checked product/scalar observers; new
composed readers do not recursively seed further summaries in this experiment.

Prepare without running Bend:

```sh
python3 -B selfhost/tools/performance/phase131/projection/prepare-v03.py \
  --out selfhost/build/phase131/projection-source-fresh
```

Root should acquire the checked API with the existing `phase111/check-api.py`
under its guard, exporting `p88_cache_prepare p86_plan p111_emit_admitted
p111_compile_source p128br_diagnose p131p_controls p128br_call_controls`.
The existing regions finite runner accepts this source manifest:

```sh
node selfhost/tools/performance/phase131/regions/finite.mjs API_REPORT \
  selfhost/build/phase131/projection-finite01 \
  '{"p131p_controls":14,"p128br_call_controls":10}'
```

Require `String.cmp` to appear as a product helper and the scalar consumer's
diagnostic plan to be admitted. Compare original reader QBE bodies across the
parent/candidate artifacts; output equality alone could mean fallback. Native
tests must include shared/unique roots, equal aliases, shared suffixes, Unicode,
long equal prefixes and an unrelated retained-root/product observer. Measure
root-construction, take/sink and scheduler work, not only private helper count.

This is an experimental overlay, not native qualification or production
selection. The current clean native profiles place String.order plus String.eq
at 10.08% lexer / 12.56% Map active context; that is an overlapping diagnostic
ceiling, not a promised speedup. A cheap reader/projection experiment is needed
before full compiler acquisition.

Retained attempts: source01 exposed missing types on finite-control local
bindings, not a production-transform error. Source02 fixes those annotations.
Inspection then found the current integrated path uses `p128br_scan_ready`,
whereas the older `p128br_summaries` is diagnostic; source03 adds the actual
scan hook and accepts the optional existing flat-worker extension. The
coordinator's `p131-projection-api03/report.json` now records successful checked
API acquisition of source03. Finite, native and runtime gates remain separate.

`cases-v01.json` pins the unchanged Phase130 baseline String.order workload
and `list-workload-v01.bend`, an unrelated retained-root lexicographic U32-list
product. Both compile the same source with parent and candidate; no source
comparison loop changes between variants. The String oracle is inherited,
and `prepare-fixtures.py` independently computes list comparison expectations.
`expected.stdout` is the ordinary six-line oracle for both. The fourth argument
is reserved; timed calls use `repetitions warmups size reserved`, and the final
line is elapsed milliseconds. A long-prefix check should increase `size` while
keeping repetitions small; it is a stack/correctness gate, not a benchmark.

Use existing `phase128/emit-entry.mjs` with `P118_CASE_MANIFEST=cases-v01.json`
and the selected Phase128 runtime report, followed by aligned builds and the
independent ordinary stdout. `inspect.py` compares parent/candidate QBE without
executing it:

```sh
python3 -B selfhost/tools/performance/phase131/projection/inspect.py \
  --parent-ssa PARENT --candidate-ssa CANDIDATE --out FRESH.json \
  --owner String.cmp --consumer String.order
```

For list transfer select `--owner p131l_cmp --consumer p131l_query`. The audit
requires byte-identical original reader, a new consumer reader calling it,
and an owning fallback. Separately inspect actual hot callers: admission and
an emitted reader alone do not prove it executes. Earlier inlining may have
copied the old owning body into those callers, a known independent composition
boundary. Root's shallow-record investigation is studying that boundary too.
