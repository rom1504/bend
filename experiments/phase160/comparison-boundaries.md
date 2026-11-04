# Phase160 — comparable self-compilation boundaries

Source/metadata audit of the qualified Phase152/153 compiler and historical bendc
`9c54842eb5756803af599583ca49870d1e09186a`. No compiler, benchmark, build,
restoration or deletion was performed for this audit. Source and retained JSON
were inspected with Python and text searches. The initial read-only census was
subsequently materialized as an explicitly requested source-only preparation,
described below. Compiler checking/building and the Phase156 cross-built request
experiment are separate, root-controlled activities.

**The existing self-emission clocks measure different compiler programs doing
different work.** Their ratio does not isolate the cost of executing Bend, the
runtime, checking, optimization, or the output format. The decisive next control
is one complete compiler implementation, one input/Base, one selected route and
one complete output oracle, executed under different generated-code backends.

## Observed work and size differences

| Quantity | Our qualified self request | Historical bendc self request |
| --- | --- | --- |
| Compiler input source | 3,085,157 bytes; 66,399 physical lines; one assembled source plus selected Base | Six modules, 1,173,696 bytes and 32,161 physical lines, plus 71,783-byte historical Base |
| Declaration count | 8,265 assembled source rows: 7,213 `def`, 369 `type`, 683 `law`; excludes prepared Base rows | 3,406 loaded declarations including Base, dynamically observed at `Opt.lowers`; 3,044 become `OCore`, 362 `OKeep` |
| Source checking | Present; 33.57 diagnostic CPU seconds in checking/publication | Absent from historical `--no-check`; separate checked route performs checking then reloads/parses for emission |
| Reachable source-owner evidence | 4,291 lowered owner groups, 4,162 mapped to assembled source and 129 unmapped Base/composite owners | 2,023 `Gen.def` calls after whole-list optimization; these are reachable emission requests, not machine functions |
| Backend representation/output | 56,649 generic segment FIDs; 73,926 emitted QBE functions; 118,227,421 output bytes | 2,802,777 C bytes exactly reproducing the seed; source C has 2,023 `W_*` wrapper definitions and 1,974 `F_*` definitions under the lexical counting rule below |
| Independent backend verification | First verifier 7.93 diagnostic CPU seconds; conditional final verifier 9.22 seconds | No corresponding independent structural-IR verification stage was found in the audited historical emission path |
| Complete emission clock | Phase153 one diagnostic capture: 238.762 seconds wall; excludes machine construction | Phase158 clean medians: 4.499 seconds unchecked, 8.810 seconds checked |

These count definitions deliberately remain visible. Our 8,265 excludes Base,
whereas historical 3,406 includes it; 4,291 lexical owners are not exactly the
same concept as 2,023 optimized emission requests. The latter also follows
specialization/fusion: observed counts are 3,406 → 3,407 → 3,461. Neither count
measures dynamic calls or unique C machine functions surviving Clang.

The 73,926 QBE functions comprise 56,649 `p111_*` generic functions, 14,929
`p112w_*` workers, 2,254 `p113d_*` functions, 93 `p114r_*` functions and `main`.
This comes from the authenticated retained owner analyzer, not an ELF symbol
grep. One source owner expands into multiple continuations/workers. The
historical C count is a source-text census of lines matching static function
definitions, excluding declarations ending in `;`; native definitions,
preprocessor branches, closure functions and wrappers require separate
interpretation. In particular, the agreement between 2,023 `W_*` definitions
and the observed `Gen.def` count is useful consistency evidence, not a proof
that the two compilers perform the same 2,023 computations.

The input byte difference is about 2.6× before Base and output text differs by
42.2×. Neither ratio predicts elapsed time. QBE's low-level text and explicit
continuations describe different work from C plus a runtime header. Conversely,
the input-size difference alone is not a demonstrated explanation of the much
larger timing difference. Per-byte throughput would hide both differences.

Retained inputs for this census:

- `selfhost/build/phase153/source01/compiler.map.json`: exact assembled source
  declaration rows, source locations and byte spans; source SHA256
  `027e15041035522ed7e40ef971eff75f24a09ef6a00e3f8fe335839f94bcb8a8`.
- `selfhost/build/phase153/prep01/source-owners.json`: 4,291 lexical owner
  groups, all valid, and exact first/last FID intervals summing to 56,649.
- `selfhost/build/phase153/prep01/owners.json`: 73,926 emitted functions and
  descriptor segment count 56,649, bound to exact QBE SHA256
  `1032c6a6495ca86bb26ad2bcd7ae639ed49dc987765dfe567dce7ac6224bf7bb`.
- [Phase159 metrics](../../implementation/phase159/metrics.json) and
  [report](../../implementation/phase159/README.md): dynamic historical stage
  counters, allocation counter limitations and clean/profile separation.
- Historical source/seed and exact Base identities are in the
  [Phase158 reproduction method](../phase158/published-method.md).

## Frontend work retained after runtime reach filtering

Our assembly contains multiple backend implementations and control definitions.
The source map contains 1,692 rows under `src/back/js/`, with 624,663 declaration
bytes; only 59,334 of those bytes belong to source rows matched to a runtime
owner in this native image. Other rows include QBE: 2,564/918,399 bytes;
native: 1,076/337,678 bytes; and `tests/compiler/native-controls.bend`:
295/109,399 bytes. These byte totals count declaration bodies according to the
source map, not full files with surrounding comments/preamble.

Across the assembly, 4,162 `def` rows and 550 `law` rows map to native runtime
owners. This supports a specific distinction: definitions can be parsed and
checked even when their code does not survive runtime reach selection. It does
**not** prove they can be removed from the source without affecting laws,
constructor ordering, checking, specialization or exported compiler behavior.
A native-only source closure could be an experiment in reducing compiler
acquisition input, but it would be a different source product and would need
full output/behavior gates. It is not a free execution optimization.

Historical bendc also loads unreachable definitions. `Main.build` reads Base
and recursively loads imports; `Gen.program` runs `Pick.decls`, `Lo.program`,
`G.new`, and `Dps.build` before `Gen.all(["main"])` selects emitted names.
`Opt.lowers` visiting all 3,406 declarations was observed, not inferred from
source. The historical compiler therefore is not an example of optimizing only
reachable bodies. Its source includes checker, JS and native backend facilities
too; no claim that only our input contains multiple backends is warranted.

Source references: historical `bendc.bend:15230–15278` and
`19436–19464`; maintained `selfhost/src/host/native-plan.bend:189`,
`selfhost/src/back/common/constructor-facts.bend:179–211`. See the detailed
[historical pipeline audit](../phase159/bendc-pipeline.md).

### Offline root-main closure: 45% fewer source bytes

At root's request, the existing Phase147 declaration extractor was applied in
memory to the exact qualified QBE assembly with the sole root `main`. That first
census created no output file or executable. The extractor follows identifier references
outside comments/strings, maps constructors to their defining type, retains
every declaration sharing a selected name (including law/def pairs), and
preserves selected declaration bytes/order.

| Census | Qualified assembly | Extracted root-main closure |
| --- | ---: | ---: |
| Source bytes, including retained comments/spacing | 3,085,157 | 1,697,879 |
| Physical lines | 66,399 | 44,186 |
| Declaration rows | 8,265 | 5,007 |
| Definitions / types / laws | 7,213 / 369 / 683 | 4,163 / 294 / 550 |
| Mapped existing runtime owners missing | — | 0 |

This removes **44.97% of source bytes**, 33.45% of lines and 39.42% of
declaration rows. All retained blocks hash exactly to their originals; no name
has only some of its original law/definition group retained. All 4,162 mapped
existing runtime-owner declarations and their mapped laws survive. This is a
strong exposure check, not semantic qualification.

| Source area | Rows before → after | Declaration bytes before → after |
| --- | ---: | ---: |
| `src/back/js` | 1,692 → 189 | 624,663 → 59,334 |
| `src/back/native` | 1,076 → 534 | 337,678 → 155,029 |
| `src/back/qbe` | 2,564 → 2,005 | 918,399 → 687,464 |
| `src/back/common` | 247 → 206 | 88,525 → 62,749 |
| `src/front` | 732 → 712 | 195,471 → 188,961 |
| `src/check` | 557 → 467 | 133,387 → 113,170 |
| `tests/compiler` | 295 → 15 | 109,399 → 6,246 |
| `tests/phase149` | 10 → 0 | 5,382 → 0 |

The closure is 1.698MB rather than smaller than Phase156's 1.565MB experiment:
the maintained `main` brings its full supported native CLI/source-preparation
paths, whereas Phase156 uses a restricted request driver despite its candidate
and original-ancestor clones. Their source sizes alone do not define equivalent
compiler products.

Reproduction is an offline import/call of
`experiments/phase147/tools/prepare.py:extract`:

```python
canonical = E.assembly.maintained_assemble(
    ROOT / "selfhost/src/compiler.json", ROOT / "selfhost", "qbe")
assert hashlib.sha256(canonical).hexdigest() == (
    "027e15041035522ed7e40ef971eff75f24a09ef6a00e3f8fe335839f94bcb8a8")
body, inventory = E.extract([("qualified-qbe-canonical", canonical)], ["main"])
assert hashlib.sha256(body).hexdigest() == (
    "15d41d9bf2cec2b11f4dab6dbce8c2cfea5eb59b5ce0b879d5281a5084012bc2")
```

Extractor source SHA256:
`f218c0b934c105592b33b48938c7de5e0353660bb0efd0033963817f1d3c6cc6`.
The check joins inventory `(name, kind)` against `compiler.map.json` and
`source-owners.json`; source ownership is lexical, not a fresh type/reach proof.

An independent source check and full output/behavior gate remain necessary.
Dropped type declarations can change constructor IDs or emitted tables even
when all existing runtime owners survive. String-based name conventions and
compile-time dependencies also need semantic validation. Therefore this is
an acquisition/source simplification candidate, not evidence that generated
compiler execution improves 45%. The measured parse/load plus checking envelope
is 63.21 diagnostic CPU seconds; proportional savings within it are a hypothesis,
and this frontend envelope alone cannot explain a roughly fiftyfold raw clock
difference. Preserve the identical-input cross-build as the causal execution
test, with source simplification as a separate axis.

### Reproducible source preparation

The subsequent source-only preparation is
`selfhost/build/phase160/closure-prepare01/manifest.json`. Reproduce into a fresh
directory, from the repository root:

```sh
python3 -B experiments/phase160/tools/prepare-closure.py \
  --out selfhost/build/phase160/closure-prepare02
```

The script pins the original qualification/source, maintained recipe and module
inputs, extractor, source map and runtime-owner map. It writes the exact
1,697,879-byte `compiler.bend`, adjusted `compiler.map.json`, all8,265 identities
in `declarations.json`, separate5,007-row `kept.json` and3,258-row `dropped.json`,
and the complete owner-retention audit in `runtime-owners.json`. All original and
new order/byte positions are recorded. It checks selected emitted spans against
the original blocks, paired-name completeness and retention of every mapped
runtime-owner declaration before marking preparation complete. No Bend compiler
is imported or executed; all semantic gates remain pending in this preparation.

The intended next control is the smaller compiler processing the **original full
qualified source** and matching its existing complete output oracle. Processing
only its own smaller source would change the workload and would not establish
the same compiler-request behavior or execution-speed comparison.

## Verification and representation are distinct work

The qualified request's first and conditional final structural verifier check
names, widths, assignment, terminal paths, signatures and bounded accesses.
They do not prove the compiler or runtime's ownership semantics. The final
9.22-second interval is nested in the 19.42-second observer/composition stage:
never add both as disjoint costs. Checking/publication plus the two verifier
intervals is about 50.72 diagnostic CPU seconds, roughly 21% of this capture.
Even impossible removal of all that work would leave most of the gap. Removing
the gates is not an acceptable comparable optimization.

Historical source checking itself is real work: its checked clean median is
8.810 seconds versus 4.499 unchecked, and check-only median is 5.044 seconds.
Do not add medians or treat their difference as an exclusive parser/checker
timer. Checked IO compilation reloads the source. Its expected unsafe/foreign
check-only report is separately matched to upstream, not silently considered a
safe proof. Our cached Base admission differs from its live historical Base
parsing; the proposed Phase156 route uses live Base for every compared role.

Both implementations materialize multiple forms. Historical bendc has tokens,
layout, expression declarations, core IR and raised declarations before C;
`Lo.program` runs inlining/simplification, specialization and fusion. Four
bounded specialization/fusion rounds do not mean four full useful changes.
Our IR adds generic continuations, private workers, independent certificates,
composition and emitted registries. `p113d_passes(...,32)` is a bounded solver
with progress/eligibility behavior, not proof of 32 complete executed passes.
Measure actual processed rows or stage cost before calling these loops redundant.

The historical uncounted stage observer attributes 2.789 inclusive CPU seconds
to `Lo.program`, of which fusion is 1.632; `Gen.program` inclusive is 3.469.
Its `Lex.all` sum is 0.738 and final Doc flatten 0.050. These are overlapping
diagnostic intervals, not clean comparable versions of our complete parse/load
or output/cleanup stages. Allocation instrumentation observes 327.8 million
allocation requests and 8.07GB requested bytes before rounding; historical
speed is not explained by an absence of allocation. Those event counts must not
be compared to our small 8,202-byte input as though both were self-compilation.

Hypotheses still open: fewer dynamic representation transitions; better
ordinary-call execution of the same recursive compiler; less name/metadata
traffic; a smaller emitted representation; different memory-management costs.
Static call/segment counts alone establish none of these causal explanations.
The Phase159 cap experiment applies to newer bendc56 on the five-owner workload,
not the historical9c self-emission or our complete self request.

## Identical-input feasibility and cheapest next controls

Compiling the exact historical bendc CLI through our qualified QBE backend is
not currently a valid drop-in experiment. Its source declares `Hub.ensure` and
`Cc.begin/end/elf/link` as custom C/JS providers (historical lines8222 and9301).
They are reachable through the ordinary CLI. Our fixed native provider catalogue
in `selfhost/src/back/qbe/lower.bend:699–715` does not include them; it explicitly
rejects unavailable providers before lowering. Historical Base2.0.32 also differs
from our qualified Base and prepared carrier. Parser/check compatibility could
be separately screened with the exact old Base, but successful parsing would
not demonstrate a buildable or qualified historical compiler. Removing CLI
branches or substituting effects would be an explicit extracted variant.

The selected Phase156 complete-request closure is the stronger first control:

1. Keep original route selection, source text, live Base, original independent
   verifier, write protocol and complete 118,227,421-byte QBE oracle identical.
   Whitespace compatibility must pass an independent parse-equivalence gate;
   never silently port semantics to make another compiler accept it.
2. Compile that same Bend implementation under available backends. Establish
   exact full output before timing; hold CPU, environment, runtime arguments,
   stack/resource policy and file sink fixed. Include source/Base preparation,
   writing and cleanup in each role. Exclude image acquisition from request
   timing but report its cost separately.
3. Compare execution within that common experiment, not against Phase153's
   historical absolute clock. Phase156 contains candidate routes and ancestor
   clones and has its own image layout; selecting `old` does not turn its binary
   into the qualified production image.
4. If one backend makes this entire compiler request much faster, profile that
   exact input under both. It demonstrates execution headroom for our actual
   algorithm, while holding its verification and large output obligations fixed.
   If results stay close, focus on algorithm/work representation, then use
   complete frontend/backend stage oracles to test one reduction at a time.

The cheapest no-target checks have now been done: source/owner cardinality,
existing stage interpretation, source effect admission and oracle-route audit.
No unbounded compatibility port, full self-rebuild, changed verification policy
or new broad program benchmark is necessary to answer the next causal question.
