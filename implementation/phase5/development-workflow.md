# Maintained development entry

`selfhost/tools/development/workflow.mjs` composes the existing checked bootstrap
and paired conformance harness. It freezes one project-shaped attempt, records
the actual source/runtime/host/API identities, primes that API's validated Base
cache and preserves finite child deadlines, failure reports and worker histories.
`validate` reuses only a verified completed compiler with fresh fixture graphs
and output paths. Incomplete builds require a new attempt. There is no new
compiler algorithm, oracle, worker protocol or fake bootstrap report.

The checked profile is the default. The explicit equality profile verifies a
separate derivation and binds its selected output and original checked input to
the attempt manifest. The unchanged checked API and its genuine bootstrap report
remain alongside the derivative. Mutable working sources can change afterward;
reused validation still tests the frozen build, not those edits.

## Correctness evidence

- Eleven focused workflow tests pass: resource/configuration validation,
  canonical-path/source/API/helper/runtime/proof drift, checked and derived API
  association, stale cache/book identity, output refusal, strict-failure
  preservation, spawn failures, output overflow, timeout and cleanup of a
  separately grouped compiler child.
- `checked-01` completes an actual checked bootstrap and all 21 paired frontend
  acceptance/phase witnesses. Both compilers pass the declared oracles. Twelve
  exact diagnostic differences remain explicitly reported.
- `reuse-01` reuses the verified API for four selected witnesses; all declared
  oracles pass, with two exact diagnostic differences retained.
- `execution-01` compiles and executes `base/list_sort.bend` through isolated
  TypeScript and Bend workers. Both pass, with exact output agreement.
- `equality-01` completes a fresh genuine bootstrap, the independently verified
  equality derivation, and the 21 paired witnesses. All declared oracles pass;
  the same twelve diagnostic differences remain. The CLI explicitly labels the
  artifact `derived-b1`; its transformed API has no bootstrap sidecar.

The default witnesses are acceptance/phase checks, not an exact-diagnostic or
full-language conformance claim. `strictExact` is available for selections that
must agree byte-for-byte. Optional full candidate frontend orchestration is
implemented but was not run as part of this focused workflow gate. Root owns
the separately scheduled integrated broad sweep.

Independent review by lexer_analysis found an API/derivation association gap;
the final guard and focused counterexample close it. Reciprocal equality review
requested conservative protected-parameter binding refusals, which its owner
added before the final workflow gate. Source, runtime and public ABI are unchanged
by the workflow. Concurrent correctness work used other cores, so these runs
establish no timing or speedup claim.

## Preservation and use

Commands and resources are recorded in the raw reports. The
[archive](development-evidence/README.md) retains the attempts, actual frozen
compiler/tool snapshots, caches, selected reports, histories, logs and focused
test source. Earlier intermediate runs remain labeled by their consumed tool
identities; they are not silently upgraded to the final wrapper revision.

Use the [maintained guide](../../docs/PHASE5_DEVELOPMENT.md). Historical
performance wrappers remain available for their original experiment recipes;
the normal entry does not depend on those wrappers.
