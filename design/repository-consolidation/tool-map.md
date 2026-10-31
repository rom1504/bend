# Tool, catalog and oracle migration map

Planning audit at `a5f7a6a`, 2026-10-31. Paths below are relative to `selfhost/`
unless explicitly rooted otherwise. This is a source/contract inventory, not
fresh execution or a claim that every historical tool is current. Use the
[main plan](README.md) for migration gates and retirement conditions.

## Keep one maintained implementation of these capabilities

| Capability | Existing mechanisms to extract/reuse | Required continuity |
| --- | --- | --- |
| Checked JS-hosted development | `tools/development/workflow.mjs`, `typed-driver.mjs`, `assemble.mjs`, `development/equality.mjs` | Independent checking, genuine derived-image provenance, exact Base/API pairing, source maps, errors and supported public exports. |
| Release/package verification | `tools/development/release.mjs`, `self-release.mjs`, `dist/release.json`; native selection/admission | Installed and relocated behavior, source/runtime identities and actual generation. One source release may have several host artifacts. |
| Native compiler request | `tools/performance/phase130/native-request.py`, its Phase125 native-emitter dependency | Complete stdout including final newline, prepared/live Base permission, independent output refusal, runtime/image role distinction. |
| Streaming native construction | `tools/performance/phase134/pipe/build-v02.py` | Compiler → QBE → assembler → linker; bounded materialization, reviewed warnings, complete-QBE oracle, toolchain/runtime pins. |
| Native self-reproduction | Phase146 candidate/qualification and actual N1/N2/Q3 methods | Actual producer lineage, complete products and fallback when ELF identity fails; no invented normalization to skip a generation. |
| Compiler latency | `tools/performance/phase105/compare.py`; Phase145 same-source execution and Phase146 native comparisons | Upstream and selfhost roles, host/stage/target, prepared/live requests, imports/process/request clocks and fresh source-to-executable time. |
| JS program timing | `tools/performance/programs/prepare-direct.py`, `run.py`, `execute.mjs` | Acquisition separate from timed execution, immutable catalogs/observers, pairing, warmup/calibration, budgets and incomplete results. |
| C program timing | `tools/performance/phase93/run.py`, `batch-template.bend` | Native B1/B2 product acquisition, frozen complete-result wrappers, C/Clang policy, calibrated execution and zero-work handling. |
| QBE program timing | Phase125 screens; `tools/performance/phase144/programs/runtime-v04.py` and final product gates | Actual loaded products, QBE/runtime/assembler identities, matched upstream-C reference and complete fixed-batch work. V05 is not automatically the measured authority. |
| Native profiling | `tools/profiler/` | Freeze/run/analyze/compare/render, owners, attribution, unwind, timeline, sampled quality, exact ELF and source-map identities. Preserve the stable path. |
| Stage/event profiling | `tools/profiler/STAGES.md`, `stages_v1.py`, `stages-build-v1.py`, Phase144 concat extension | Stage order/multiplicity and physical versus semantic attribution; reversible runtime hooks and ABI controls; no diagnostic timings reported as clean speed. |
| JS diagnostics | `tools/performance/programs/DIAGNOSTICS.md`, `diagnose.py`, profile/inspection workers | V8 CPU/allocation information, generated syntax/structure and side-by-side comparisons, diagnostics budget separate from execution timing. |
| Frontend/backend conformance | `tools/conformance/` inventory, adapters, judge and reports | Explicit current upstream pin and checked adapter. Do not inherit obsolete README hashes or unchecked defaults. |
| Native focused/broad correctness | `tools/performance/phase125/native/coverage.py`, `full45.py` | Focused19 and ordinary45 independent outputs/refusals; neither is a timed runtime benchmark. |
| Laws/proof workflows | `tools/laws/phase96/run.py`, Phase97 supplements, `proofs/phase98/prepare-current.py`, `tools/laws/phase98/check.py` | Production-source bindings, independent proof checks where established, source checking and finite controls as distinct claims. |
| End-to-end application checks | `apps/` and `tools/performance/phase100/` | Source index/render/planner complete outputs; build, execution, memory and supported worker scaling. |
| Disk/process/evidence lifecycle | `tools/build-retention/guard.py`, `close.py`, `archive-v02.py` | One unchanged lock, one supervisor per job, fresh outputs, declared budget/reserve and recoverable evidence. `campaign.py` remains a historical one-shot, not a general GC. |

Protocol versions such as `stages_v1` are valid compatibility boundaries; do not
flatten distinct schemas just to remove a version suffix. Conversely, multiple
campaign-specific scripts that implement the same profiler/runner logic should
become one maintained method plus configuration.

## Preserve existing incremental tooling without a new optimization campaign

The Phase140 session modules and batch interface, Phase142 indexed-session
candidate/methods, and Phase135 machine-group/object-reuse methods are additional
build capabilities to migrate. The latest measured session candidate is still
experimental; Phase146 ordinary qualification does not qualify it. Its qualified
producer checkpoint and independent fresh-output references are separate assets.

Provide a maintained experimental session/object-reuse mode from the canonical
tree, preserving its original status. Check a no-op, one substantive edit,
revert/error recovery and source/runtime/policy invalidation against independent
mode-matched fresh output. Unknown dependencies must still rebuild. If this
integration is unresolved, retain exact historical recovery and report the
capability migration incomplete; do not silently drop it or turn it into a second
maintained compiler source. This is preservation work, not a warm-speed campaign.

## Preserve these distinct catalogs

| Catalog/contract | Authority | Migration warning |
| --- | --- | --- |
| Historical JS15 | `tools/performance/programs/catalog.json` and reference bundles | Remains historical; cannot silently stand for original45. |
| Expanded JS/original45 | `tools/performance/phase37/catalog.json`, fixture directories, algorithm/reference oracles | Preserve case IDs, arguments, complete observations and weights. |
| C original45 | Phase88 closed source manifest plus Phase93 `batch-template.bend` derivation | Preserve observer work, calibration and independent expected values. |
| QBE timed45 | Frozen Phase112/131 timed wrappers and repetition profile consumed by Phase144 | Distinct from small ordinary-native45 correctness sources. |
| Native semantic suites | `tools/performance/phase111/coverage/manifest.json`, fixtures/expected; `coverage/full45/manifest.json` and expected | Independent semantic oracles must survive historical tool retirement. |
| Formal/finite rules | `proofs/phase96/production/catalog.json`, `proofs/phase98/catalog05.json` | Preserve deduplication and theorem/control classification, not a misleading combined proof count. |

The timed native original45 has 44 measurable points and a zero-work control.
Budget, case selection and measurement depth are independent. Expose consistent
20/60/300/600-second interface choices across targets while retaining each
protocol's honest coverage and startup/warmup behavior. Never shrink inputs,
silently omit slow cases or report unfinished runs as a full score.

## Common manifest fields

- Implementation role and exact source/image: upstream reference or selfhost.
- Compiler execution host and version: JS under Node/Bun, or native ELF.
- Bootstrap producer/source lineage: checked B1, genuine B2, native N1/N2, etc.
- Output target and optimization policy: JS, C, direct QBE; ordinary or session.
- Preparation: live Base versus exact prepared Base/carrier, no-op/warm/cold state.
- Program environment: JS engine, Clang/QBE/assembler/link flags, runtime/provider
  identities, atomic or single-mutator policy and supported parallel mode.
- Workload/case/oracle identities, clock boundaries, pairing/order, budget/depth,
  source maps, measurement/diagnostic role, raw observations and completion status.
- Tool commit/path/blob and bounded operational assets; historical provenance
  separately, so a new request does not authenticate the entire experiment history.

"Native B2" alone identifies neither emitted target nor a complete ancestry.
QBE-generated programs can legitimately be compared with upstream-generated C,
provided the report says so. Ordinary/session policies may have different QBE
products and require mode-matched references.

## Cheap validation sequence

1. Resolve imports, root discovery, asset dependencies and exact method pins;
   compare old/new planned argv and input/output contracts without targets.
2. Replay retained success/failure reports through new analyzers; preserve
   pairing, units, zero-work handling, geometric/family/log-deficit calculations.
3. Run relevant existing harness/profiler/conformance-judge/storage controls and
   focused missing-asset, wrong-oracle, changed-pin, timeout and fresh-path checks.
4. Execute one small real request/product per changed adapter contract, then a
   bounded paired timing screen if code or runtime identities differ.
5. Perform final bootstrap and broad capability qualification once at integration.

Existing generic native profiler qualification concerns sequential main-thread
sampling. Historical all-thread samplers are research evidence, not automatic
generic-profiler support. Preserve currently working capabilities and explicitly
name experimental ones rather than silently promoting them during file movement.
