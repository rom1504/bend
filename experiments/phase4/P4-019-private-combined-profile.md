# P4-019: Combine private Boolean specialization and stability memoization

Recorded: 2026-09-22, after the corrected four-way comparison; this is not a
claim of preregistration.

- Owner: direct-calls agent; independent review: compact-index agent.
- Correctness: 48 selected comparison observations, 300 Boolean controls,
  3,786 stability controls, 14 reused-source/import observations and the actual
  escaped-string fixture pass. Broad frontend and candidate whole-source gates
  are running; ordinary public APIs are unchanged.
- Measurement: three alternating fresh-process rounds on CPU 0, separately
  validated and primed Base caches, exact input/tool identities retained.
- Decision: **Investigate; named opt-in promotion pending final gates.**
- Related: [P4-009](P4-009-stability-memo.md),
  [P4-012](P4-012-boolean-matchers.md),
  [P4-016](P4-016-private-lexical-scope.md).

## Claim and invariant

Combining exact reviewed Boolean matchers with completed pure stability-fact
memoization should reduce residual dispatch and repeated fact scans more than
either alone. It applies only inside the immutable, JSON-only private compiler
boundary. Completed Boolean facts are keyed by term identity; first-argument
demand, original failure paths and public emitted-library semantics remain.

The composite transform must reconstruct the independently reviewed stability
delta byte for byte before applying it to the Boolean image. Exact H, runtime
and worker-body guards refuse unsupported revisions. The default transform
remains independently selectable and byte-identical.

## Evidence and retained failures

The [earlier matrix](../../implementation/phase4/private-combined.md) passed its
48 selected observations but used the private base later disproved by the
full-source lexical-capture failure. It remains historical evidence, not a
whole-compiler correctness claim.

The [corrected matrix and package report](../../implementation/phase4/private-combined-fixed.md)
records the complete setup, all rows and reproduction commands. Corrected
private control `61e7d94c…` versus combined `4318bbcd…` yields core request median
26.902→23.855 seconds (11.3% lower), process median 28.034→24.986 seconds and peak
RSS median 592,764→588,012 KiB. All three core pairs improve. Boolean-only and
stable-only medians are 25.452 and 25.513 seconds, respectively; their gains are
not multiplied. Tree, list and the retained checker rejection also improve in
this sample. Another physical core was running the full-source control.

Seven package controls verify default/candidate byte identities, proof status,
profile guards and captured modules. Follow-up negative metadata fixtures reject
false recorded source and selected-image hashes. Earlier preparer-only review
found no blocker; final independent promotion review is separate.

## Next discriminating gate

The corrected default has now completed whole-source compilation with exact H
output. The root-owned combined full-source run and exact frontend comparison
are pending. Any changed verdict, diagnostic, output, publication invariant or
material memory regression blocks promotion. Only after these gates may the
staged canonical builder expose `--profile=phase4-boolean-stable` for the exact
reviewed H. Normal checked B1 iteration and default private specialization stay
available independently.

The [preserved evidence manifest](../../implementation/phase4/private-combined-fixed-evidence/manifest.json)
contains configurations, all observations and consumed tool/profile snapshots.
Large checked source/API artifacts are prerequisite inputs identified there;
the compact archive does not silently claim to contain them. Final gate results
and the promotion decision must be appended rather than replacing the failed
base attempt.
