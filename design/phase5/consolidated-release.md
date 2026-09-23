# Consolidate the Phase 5 compiler

User-directed scope change, 2026-09-23 02:36 UTC. Finish this phase as one usable
compiler version, then focus on remaining semantic gaps and the measured 6×
performance deficit. This supersedes earlier plans to leave the default artifact
at its historical baseline. It does not alter frozen experiment plans or evidence.

## One default

Publish the validated maintained equality derivative of final checked B1 as
`selfhost/dist/typed-api.mjs`. The ordinary `node cli.mjs FILE` command selects it
without environment overrides. Its compiler algorithms come from the same 59
Bend modules; its guarded string-equality specialization is a compiler-host
optimization. The genuine checked parent and actual self-emitted H remain
lineage and validation evidence, rather than competing onboarding choices.

The selected API is SHA-256
`e2b5463678a26558e8fea1d585782e0863f1046067949a374f0469080281b15a`.
Its checked parent is
`5969c53d34a088bc9630eb2c065c2eea7fd260294cf3fefb14dffb305b7e4667`.
The assembled source is
`e3b927d13dc2645e19171b72de60c49dd5bc5e5059863937153b957e2ce0ec1d`.
These are actual artifacts, not a new bootstrap or a claim that H has the same
speed. The release must remove stale bootstrap sidecars next to a replaced API.
Preserve original reports unchanged as historical records; release verification
uses relative paths and hashes and must work without the original build tree.

## Build, install and verify

Add a thin maintained release entry composing existing checked build, equality
derivation and selected validation. It also installs an already validated attempt
and verifies installed source, runtime, Base, host, API and transformation lineage.
Do not modify the frozen workflow/equality helpers consumed by ongoing gates.
Keep fresh attempts immutable. A later source change requires a new build;
verifying or running an artifact never silently rebuilds it.

The shipped release manifest records artifact kind, pin, original checked parent,
exact replayable equality transformation, source/module identities and supporting
validation. Historical absolute paths do not become relocated proof paths. A
local integrity verifier is not a new run of every referenced conformance test.

Check actual default CLI behavior without BEND overrides, then relocation into
an independent staging directory without access to old build paths. Include
checking, interpretation, JS compilation/execution, and native CPU execution
where Clang is available. Retain failure reports and exact commands.

## Gates and acceptance

Already complete: 387 focused observations per compiler, all 2,756 final B1
frontend observations, fresh checked B1→H→H byte identity, controlled full-source
TS/B1/derivative comparisons, and 2,756 exact frontend observations each for H
and the derivative. Known strict failures remain 318. These are scoped gates,
not full conformance or proof soundness.

Run the paired broad backend gate on the selected derivative: 999 JavaScript
and 982 native eligible probes per compiler, retaining ineligible cases, strict
failures, actual outputs, infrastructure failures and incomplete histories
separately. Earlier broad preparations 01–03 never ran; preparation 04 changes
the candidate prospectively. Preserve all preparations. Broad timings overlap
other correctness work and are not performance measurements.

## After consolidation

Preserve this release while investigating the three remaining parser acceptance
gaps and missing-import phase differences in isolated candidates. Re-profile the
optimized compiler before choosing a performance rewrite: earlier unoptimized
B1 string-comparison samples cannot describe the residual cost after equality
specialization. Use component workloads, counters and seconds-scale focused
gates before another full compilation. Maintain separate compiler throughput,
validation-loop latency and emitted-program runtime metrics.

## Observed native failure propagation — 2026-09-23 02:50 UTC

Default-CLI testing found a real host edge case: spawnSync can supply an error
and status0 when pipe capture is denied. The native build wrapper then reports
status:error with exitCode0, so automation sees success. Correct the fallback to
a nonzero code whenever an error is returned, preserving real nonzero child
status. Add a regression using the observed tuple, signal/null status, ordinary
compiler rejection and success. Rebuild/install the release to bind this host
change; compiler source/API bytes must remain the proved/benchmarked bytes.
The ongoing broad gate uses its immutable pre-fix host snapshot and retains its
original results. Record the host-only difference, not a rerun of those gates.
