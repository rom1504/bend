# Prefix semantics campaign

Initial prefix-only checkpoint: 2026-09-23T05:22:47.424016+00:00. Isolated candidate; no production/default promotion. The [preregistered experiment](../../experiments/phase6/P6-003-prefixed-semantics.md) follows the rejected scope-only marker from the preceding campaign.

## Prefix capsule v2

The candidate consumes the full `+` operand through postfix/application syntax before marking, matching the pinned TypeScript precedence. An empty call preserves the head; calls with arguments cannot become binders. Operand errors propagate unchanged. In atom position only, an adjacent `++` token is split into two prefix marks; infix string concatenation keeps its original token and behavior.

Marked datatype eligibility is checked before lexical shadowing: the datatype must have at least one leading quantity and a bare datatype must have no remaining non-quantity parameters. This repairs the previously accepted `+U32` counterexample. Marked non-datatype names become a private `FUnboundVar` that global freshening consumes into a fresh ordinary Var without introducing a binder mapping. The marker records whether the spelling was lexically bound so namespace qualification can reject a marked global while preserving the deliberately unbound local occurrence. No permanent core tag or U32 sentinel is introduced.

Four modules change, adding24 physical Bend lines. [Candidate patch](prefix-semantics-candidate.patch). Source projects and attempts are frozen under `selfhost/build/phase6/campaign/semantics`; durable evidence is being assembled after the current gates finish.

| Fresh paired frontend selection | Released-source checked baseline | Prefix v2 |
|---|---:|---:|
| Observations |78|78|
| Acceptance/phase/checked agreement |39|78|
| Exact complete observations |17|46|
| New exact / lost exact |—|29 /0|

All78 live TypeScript observations are unchanged between the baseline and candidate runs. The strict selected gate still fails: the two actual pinned `+name` fixtures now fail during checking, but their checker diagnostic text does not yet match. The other30 exact residuals are diagnostic differences in custom negative witnesses. None is silently reclassified as an exact conformance repair. These are selected observations, not the full pinned inventory.

The maintained genuine checked build and equality derivation pass the21 declared acceptance/phase controls. Fourteen direct graph controls pass: ordinary/nested/large raw IDs, refusal to follow an existing binder mapping, marker elimination, seeded/unseeded exact loading, and six accepted graphs structurally identical to baseline. This establishes noncapture for these controls, not arbitrary U32 allocator exhaustion safety.

Six accepted programs execute correctly in interpreter and JavaScript lanes (12 observations per compiler), including adjacent double-mark lambda reuse, datatype shadowing, ordinary marked locals and parameters. The first native attempt is retained as unsupported because Clang was absent from the launcher environment. A second attempt found retained Clang16 but sandbox spawnSync failed with EPERM. The third, already-authorized bounded attempt used normal subprocess permissions: all six native outputs match pinned TS exactly. All four toolchain environment variables and the first two failures are retained; no compiler or oracle changed between native attempts. No performance comparison is claimed: correctness jobs run onCPU1 alongside independent work.

## Retained unsuccessful attempts

The v1 source already matched70 of72 classifications; its remaining two mismatches were a new adjacent `++f` control, whose lexer token was not accepted in prefix position. V2 repairs that parser boundary. No exact or classification observation was lost versus baseline in the v1 gate.

The initial custom selection incorrectly used one `accept:false` oracle for both a successful parse lane and a rejecting check lane. Both compilers failed those mistaken parse oracles. The full original72-row gate remains unchanged; v2 uses separate parse-success and check-rejection IDs and adds six nested-prefix/concatenation observations. This oracle correction is separate from the source change.

The first graph control script imported the baseline module namespace instead of its default API and failed after eight controls with a JavaScript TypeError. A new script version and new output directory use the actual default API; all14 controls pass. Both attempts are retained.

## Remaining work

The original erased-name guard was independently rebuilt and reproduced28/28 classification agreement with20 exact observations. Its mandatory-assignment follow-up is now being tested separately before combination. Root is independently reviewing the prefix capsule. Root owns broad integration, promotion, final frontend metrics and checked self-reproduction. Existing template diagnostic collapse and the printed fresh-positive-ID versus upstream `^-1` distinction are not solved by this parser capsule.

## Frozen combined result

Completed 2026-09-23T05:38:19.377738+00:00. The five-module [combined patch](prefix-erased-semantics-candidate.patch) is ready for root's integration gates; it is not installed into the default compiler. Compared with the release source it adds81 physical lines:24 for prefix handling and57 for erased-header parsing. The checked source is `37bcda6917d639cc0a6391408ac782b2f8b56327bb2bd89b882a5f481ba47f0d`, genuine checked B1 `f1401a62050e56036711db956147d72f59f93c7d4561d0551e98c6315f22afaf`, maintained derivative `4633b1365c659cf88fbb02ca665c63374e2e62a5c1e42c7596c0760a2b7af590`.

The erased branch now requires assignment, preserves whitespace before `=` or a single-name annotation, only extends a parallel header with same-line name-headed terms, and applies erasure to every parallel binder. It delegates values, body parsing and core construction to the existing let/parallel workers. A bare `-x` can no longer become an accepted reply, and using the second erased parallel binder is correctly rejected. Empty-call second binders follow upstream's head-preserving behavior; a `+`-marked second erased binder is rejected at the mandatory-assignment boundary.

| Combined focused comparison | Released-source baseline | Combined candidate |
|---|---:|---:|
| Frontend observations |140|140|
| Classification agreement |78|140|
| Exact observations |33|98|
| New exact / lost exact |—|65 /0|

All live-reference observations are stable. The combined candidate's140 observations exactly reproduce the independently tested prefix78 and erased62 observations, so combining the capsules does not change their selected results. The actual pinned `parse/prefix_operator_dead.bend` now matches exactly in both lanes. The two pinned `+name` check diagnostics remain strict failures; this is not a claim that all current318 full-inventory failures are repaired. The candidate has not run a new broad frontend sweep or checked fixed point.

All12 accepted execution fixtures pass through interpreter, JavaScript and native backends:36 observations per compiler, all outputs exactly equal. This includes executing the repaired erased parallel/newline/annotation paths, not only checking unused definitions. Twenty direct graph controls pass, including nine accepted graphs equal to the baseline, seeded/unseeded equality, marked-name noncapture and explicit zero quantities on every erased parallel binder. The file-only [audit](prefix-semantics-audit.json) verifies the five changed modules, unchanged production source at the checkpoint, input stability and40 closed persistent worker histories.

The erased sequence retains three source attempts. V1 reproduces the earlier standalone name guard. V2 adds a result-only mandatory-let guard but rejects a valid newline before `=`; its52-row gate is retained with50 classification agreements. V3 replaces that inadequate result boundary with the dedicated erased-header parser and passes62/62 classifications,52 exact. The first file-only audit also incorrectly required a pinned negative parse observation to have verdict `pass`; the harness correctly labels it `observed`. Its failing script/log are retained, and the corrected audit accepts either legitimate verdict while still requiring exact observation equality. No compiler output or fixture oracle was changed for that audit correction.

## Reproduction and preservation

The [archive manifest](prefix-semantics-evidence/manifest.json) maps historical absolute paths to SHA-addressed objects in `prefix-semantics-evidence/raw.tar.gz`. The archive contains8,930 historical file identities in2,745 deduplicated objects (15,925,254 compressed bytes; SHA256 `435a27764e6d5f79169e4998eb8be732a96ecd051dbc8815249beacafd277faf`). It retains all local projects, genuine checked APIs, derivatives, Base caches, fixtures, paired reports, worker histories, launch output, failed attempts, audit tools and small frozen baseline host inputs. Normal successful execution workdirs are deleted by the maintained `retain=failed` harness; regenerate their C/binaries from the retained compiler and fixtures. Node24.18, the pinned upstream checkout and the linked Clang/system toolchain are external prerequisites. Native environment and compiler identity/version are explicit archived files.

From `selfhost/`, after restoring files at their recorded paths or creating fresh isolated copies/configs, the maintained commands are:

```sh
node --stack-size=4096 --max-old-space-size=4096 tools/development/workflow.mjs run \
  build/phase6/campaign/semantics/config-combined-v1.json NEW_ATTEMPT
node --stack-size=4096 --max-old-space-size=4096 tools/development/workflow.mjs validate \
  NEW_ATTEMPT build/phase6/campaign/semantics/selection-combined-v1.json NEW_FRONTEND_GATE
node --stack-size=4096 --max-old-space-size=4096 tools/development/workflow.mjs validate \
  NEW_ATTEMPT build/phase6/campaign/semantics/fixtures-runtime-combined-v1/cases.json NEW_RUNTIME_GATE
```

Actual launchers use `taskset -c1` and external300-second bounds; direct graph controls use120 seconds. The native gate additionally sets all four variables from `native-environment-v2.json` and needs ordinary Clang subprocess execution permissions. Historical paths and proof identities are retained rather than silently rewritten. Timings overlapped independent correctness work and are not speed measurements. Root's independent prefix review and broad integration decision remain separate from these isolated results.
