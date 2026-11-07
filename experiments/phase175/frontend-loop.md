# Phase175: native frontend fast loop

Use the installed Phase171 source/image qualified in Phase174. The canonical
source is 3,161,409 bytes, SHA256
`74cd7de3e5076490e20ba0218d4c9254853be72562946b9ef66fed6c10c7a53a`.
This experimental driver stops **before backend admission, optimization, QBE
rendering and machine construction**. It changes no maintained compiler code.

The immediate purpose is cheaper falsification of frontend optimizations. A
frontend win is not yet a complete self-build win. Preserve the fixed full-source
workload and charge diagnostic image acquisition separately.

## Source and measurement boundaries

[`frontend-plan.bend`](../../selfhost/tests/phase175/frontend-plan.bend) copies
only the current `p86_plan` orchestration under `p175fp_*` names. Its ordinary
computations, their order and errors remain unchanged. The current Phase143
compact-checker choice and threshold are retained; stale Phase136 checker
orchestration is not revived. All original canonical definitions remain available. Request mode delegates once
to the original `p86_plan_annotated`, so an explicit candidate replacement of that
boundary is exercised without duplicate validation. [Declaration identities](frontend-origin.json).
Four explicit success branches can return early:

| Mode | Last completed original work | Observation |
| --- | --- | --- |
| `parse` | Header/import checks, prefix completion and graph loading | Complete parsed original book |
| `check` | Current selected checker and successful checking result | Complete checked book |
| `context` | Proof report, ownership check, compilation eligibility and context | Complete context book and verdict |
| `annotation` | Reachability, annotation and unchanged annotation validation | Complete annotation book and verdict |
| `request` | Original annotated erasure/request preparation | Complete `NR_Request` and verdict |

These are **cumulative stop modes**. They are not isolated additive stage timers.
A mode's result no longer retains values needed only by later stages, so
reclamation placement can differ. Request mode retains the ordinary final
frontend result boundary. Use repeated balanced measurements and profiler
attribution before inferring a small stage cost from two cumulative clocks.

[`frontend-native.bend`](../../selfhost/tests/phase175/frontend-native.bend) reads
input/Base/carrier through the existing Bend `p86_read_file`, prepares Base once,
and then executes one selected stop mode. It has no ordinary compiler dispatcher
and no backend continuation. Match-based forcing precedes the ending `IO.now`,
as in the historical Phase136 diagnostic; no deep walk is inserted at that clock.

Stdout is one line:

```text
phase175 frontend request hash=DECIMAL_U32
```

Stderr separately reports `base_ms`, cumulative `frontend_ms`, and
`observation_ms`. The latter includes the full structural digest and its small
output. Input reads precede these clocks. Outer process time additionally
includes startup, file reads and final reclamation. Use all clocks honestly;
subtracting observation time is not a complete research-throughput result.

The [digest](../../selfhost/tests/phase175/frontend-digest.bend) traverses every
term/definition variant and field, including binder quantities/presence, spans,
removed names, cached index structure, request source/book/scope, names, paths and
bound. It is one 32-bit structural observation, **not collision-free equality or
a correctness proof**. Its cost can be substantial on full source and is measured
after the frontend boundary. Full-value controls must not be replaced by a digest.

## Fast validation before full-source measurement

1. Source-check the assembled experimental API. Explicitly export
   `p88_cache_prepare`, `p175fp_plan`, `p175fp_reference`, `p175fd_value`,
   `p175fv_actual` and `p175fv_expected`. The reference entry wraps the unchanged
   `p86_plan` result. On small frozen inputs, compare the **entire returned value**
   of request mode against that reference, including request metadata/verdict.
2. Compare `p175fv_actual()` and the independently written `p175fv_expected()` as
   complete values. The actual fixture executes real parser-span placement and
   pattern substitution, preserving an outside alias. Its literal oracle includes
   every child, span, quantity, note and lambda-presence flag. Include a deliberate
   comparator mutation refusal. The tiny fixture is a semantic gate, not a broad
   performance proxy.
3. Check ordinary successful input plus parser/type errors: request mode's entire
   error value must equal the unmodified reference. Earlier stop modes intentionally
   have not performed later checks, so do not label parse-mode acceptance a
   successful check. Compare complete parsed/checked/annotation values with the
   corresponding original stage helpers for any candidate changing those stages.
4. Acquire one frontend-only native executable through the existing checked build
   workflow. Run a small request and compare its stdout digest with the checked
   API's full-value result. Native execution still requires the usual authenticated
   Base/carrier/runtime and bounded execution guard.
5. Only then run the fixed full source. Start with request mode and one relevant
   earlier stop. Collect the existing profiler on the frontend executable when
   attribution is needed. Avoid five full-source repetitions merely to populate
   every row of this table.
6. Keep the baseline API/image frozen: comparison with the reference entry in the
   *same candidate* validates diagnostic wiring only, not the candidate algorithm.
   Compare candidate results against independently retained baseline results.
   A candidate changes only explicit named canonical definitions, preserving this
   driver and input. Retain complete small-value/reference/error gates. If it wins
   meaningfully, measure one unchanged full compiler request before paying for
   complete compiler acquisition and broad qualification.

For an extracted real compiler source to feed the frontend, use
`frontend-values.bend` plus `frontend-workload-main.bend`. The conservative closure
contains the real unchanged span/pattern routines and dependencies. This is a
small transfer case; the full canonical compiler remains the main workload.

## Existing workflow, minimal transport

[`frontend-prepare.py`](../../selfhost/tests/phase175/frontend-prepare.py) is a
metadata-only adaptation of Phase171's source composer. It pins the canonical
parent, preserves protected definitions, accepts explicit `--module`, `--replace`,
`--prelude`, and `--export`, and invokes the existing conservative declaration
closure extractor. It has **no default exports**. `--native-main` roots the
provided experimental `main`. The hosted API manifest retains the workflow's
required `targets: [qbe]` transport tag; this does not claim backend qualification.

Example source preparation, followed by the existing checked API/native tools:

```sh
python3 -B selfhost/tests/phase175/frontend-prepare.py \
  --module selfhost/tests/phase175/frontend-plan.bend \
  --module selfhost/tests/phase175/frontend-digest.bend \
  --module selfhost/tests/phase175/frontend-native.bend \
  --native-main --out selfhost/build/phase175/frontend-native-source01
```

Native invocation after independent acquisition:

```text
program --threads 1 --gpu off -- phase175-frontend request ABS_INPUT ABS_BASE ABS_CARRIER STAMP
```

The preparation receipt records exact modules, replacements, helpers, canonical
source map and Base binding. It is source transport, not a source-check pass.
The original Phase136 timing/diagnostic methods are historical evidence; this
loop reuses the current maintained build/API/profile machinery.

## Current status

Source and metadata tools are prepared. No compiler or target was run by the
implementing agent. Source checking, complete-value comparisons, timing overhead
and native execution remain root-owned gates. There is no new speedup claim.


## Optional parser-only service

The first complete frontend service costs 53.47 seconds to acquire and emits
37.1 MB of QBE (root's observation). Parser hypotheses should not repay the
checker/erasure image cost. Use these **alternative** modules, leaving the shared
complete-service source unchanged:

- `selfhost/tests/phase175/frontend-parse-plan.bend`
- `selfhost/tests/phase175/frontend-digest.bend` (the same digest)
- `selfhost/tests/phase175/frontend-parse-native.bend`

Root the native extraction at `main`, `p175fp_plan`, `p175fd_value`, and
`p88_cache_prepare`; do not export the full reference entry. The parser API is
only specified for mode `parse`, and the native CLI rejects other modes. The
loader orchestration remains exact through `p175fp_loaded`, which now returns
the parsed book/error directly and has no checking/postcheck branch.

[Metadata-only closure inspection](frontend-parse-closure.json) finds
356,626 bytes / 1,166 declarations, versus 656,302 bytes / 2,190 declarations
for the complete frontend service. The checker, annotation, erasure and backend
entry definitions are absent. Authenticated cached Base decoding does not pull
in fresh Base checking. Source size alone is not an acquisition-time estimate.

The complete result datatype and structural digest stay the same as the full
service. Before timing, independently source-check the parser-only API and
compare its **entire returned parse value** against the frozen checked full
service for successful and parse-error controls. Then check native digest/output
agreement. No source or target execution was performed by the implementing agent;
`parse-closure-inspection01` is metadata preparation only. Candidate parser
changes must use this same smaller driver on both sides of each comparison.

## Selected-mode complete-value comparisons

`compare-frontends.mjs` now accepts `--modes parse`, `--modes request`, or an
explicit comma-separated subset such as `--modes parse,request`. Omitting it
preserves the five-mode comparison. Duplicate, empty and unknown modes refuse.
`--kind stages` skips the separate parser-alphabet and semantic-control campaigns;
it still authenticates both checked APIs/Base, compares every field of all 14
finite stage results/errors, records input identities and rechecks them afterward.

Use `--kind stages --modes parse` to compare the parser-only service with the
frozen complete frontend service, and `--kind stages --modes request` for a
candidate whose separate semantic controls have already passed. This avoids
repeating unrelated stages; it does not change the per-value comparator.

The report lists `requestedModes`, `checkedModes`, `stageCases`, and
`ordinaryReference` scope/status. `checkedModes` is populated only after the
whole selected campaign succeeds. If the baseline exports `p175fp_reference`,
request mode also compares its value with that ordinary entry. If not exported,
the report explicitly says `not-exported`; it still compares the candidate with
the authenticated baseline staged value and makes no ordinary-reference claim.
No reference call is made when request mode is not selected.

## Publication and report-name controls

`--kind publication` validates six publication sequences (45 observations) on
**each** checked API. Every observation must have equal complete baseline and
candidate books, family lists and constructor lists; agreement between APIs alone
is insufficient. It also compares all complete real-checker results (seven small,
eight large), and independently requires the stale-ADT constructor result
`[False,True]` and families `["","A"]` on both sides.

The six pinned files in `parser-publication-cases.json` are then added to the
finite source campaign. Publication mode requires `check` or `request` among its
selected modes. Each selected check/request stage must match the manifest's
expected success; expected failures must be **checker** errors, not unexpected
parser refusal. The complete values still compare across APIs.

Both publication APIs must include `parser-publication-admission.bend` and export
`p175pa_plan`. This diagnostic repeats the same checked loader prefix and returns
its actual suffix count, ordinary-childless-definition count and the original
`p143cg_enough(suffix,256)` decision. The host requires the declared minimum of
257 ordinary definitions and true admission. It neither parses source nor infers
admission from textual line counts. This helper is diagnostic, not a production
checker replacement; source checking remains mandatory.

`--kind report` compares all 15 `p175rn_cases` expected/original/candidate values
on each API, requires the exact corresponding 15 `:pass` labels, and compares the
complete case graphs across APIs. Literal expected order, empty names, collisions,
native filtering and Unicode cases therefore remain independently observable.
These campaigns also retain the chosen stage comparisons and artifact pin checks.
