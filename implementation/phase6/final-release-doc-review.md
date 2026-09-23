# Final release documentation review — 2026-09-23 03:12 UTC

Lightweight independent review of `README.md`, `selfhost/README.md`,
`docs/BEND-IN-BEND.md` and `implementation/phase5/consolidated-release.md`.
Crosschecked the relevant `package.json`, CLI, release verifier/installer,
bootstrap implementation and relocated-CLI evidence description by reading
files only. No compiler, test, oracle, hashing, archive or Git command ran.
This is a scoped documentation review, not another release verification.

**One actionable discrepancy:** the older “Rebuild and validate” block in
`selfhost/README.md` still recommends
`BEND_UPSTREAM=... node tools/typed-driver.mjs --bootstrap` without an explicit
`BEND_TYPED_API`. The actual driver defaults that output to
`dist/typed-api.mjs`, replacing the consolidated derivative with ordinary B1 and
creating `dist/typed-bootstrap-report.json`. The unchanged release manifest then
fails verification (the verifier explicitly refuses that stale default sidecar).
This contradicts the new default-release workflow at the top of the same file.
Use `npm run build` for a default rebuild, or set a fresh absolute experimental
API path in this advanced bootstrap example, as the newer compiler guide already
does. No compiler implementation change is needed.

The reviewed current-selection and lineage statements otherwise agree with the
implementation: ordinary CLI loads the default derivative; `npm run build`
performs genuine checked bootstrap, separate guarded equality derivation,
focused paired validation and installation. A failed selected gate prevents
installation. The original checked parent and authentic reports are retained;
the derived default has no fabricated bootstrap sidecar. Node24 and the exact
pinned upstream checkout are rebuild prerequisites, while ordinary packaged
execution needs neither upstream TypeScript nor that checkout. Native execution
has separate Clang/platform requirements. The 6.03× full-source comparison is
attributed to the derivative, not the independently self-emitted H compiler.

The native error chronology is now coherent: the original sandbox EPERM with
CLI exit0 remains a failed historical observation; the dated02:53 correction
records exit1, regression controls and a fresh release build with unchanged
compiler bytes. Broad backend evidence used its frozen pre-fix host and is
explicitly qualified. Relocation claims also distinguish local relative-byte
verification and transformation replay from historical absolute bootstrap
provenance. The later isolated package smoke adds actual interpretation, JS and
IO execution without upstream/cache history; it does not claim relocated native
execution or a new fixed-point proof. Historical seed instructions retain their
2026-09-21 date/hash and canonical-path limitation.

## Resolution and final evidence review — 2026-09-23 03:20 UTC

**The README discrepancy is resolved.** The replacement “Rebuild and validate”
section uses `npm run build` followed by `npm run verify:release`, documents
fresh experimental output paths and links the current genuine-parent proof
instructions. The obsolete command passing the derived default into the old
bootstrap-based self-host runner is also removed. Historical distributions now
have clearly labeled archive pointers. The earlier finding above is retained as
review history, not an outstanding issue. No execution was needed for this check.

Read `phase5/broad-backends.md`, its closed audit and the candidate raw report;
read `phase6/boolean-branches.md`, the actual four pilot result files and wrapper
report, the direct-control source/report; and reread `marked-name-analysis.md`
and its independent audit. No compiler/test/oracle or archive verification ran,
and no artifact hashes were recomputed. Simple arithmetic and JSON row counts
were computed from these existing reports.

Broad backend claims match the recorded scope:3,962 compiler observations are
1,981 paired fixture/lane rows, including999 JS and982 native per compiler.
The lane totals and runtime-success counts agree with the audit. All527 Bend
negative observations have error results;212 meet their strict oracle and315
fail it. Coverage completion is correctly separated from strict conformance and
infrastructure health. The354 exact differences,299 diagnostic-only field
differences and55 other comparison differences are not presented as55 newly
introduced semantic failures. The single positive Bend timeout, TS crash and
compile failure, Bun limitations, correctness-work overlap and pre-fix frozen
native helper are all explicit. Public-H backend coverage is correctly left
unexecuted, not inferred from its frontend or self-host proof.

The Boolean pilot has four successful checked compilation observations, each
recording the same138,371-byte emitted module hash `016a5ced…`. Recomputed
forward/reverse request reductions are6.7204958%/6.1807980%; corresponding
process reductions are6.3047535%/5.7912904%, agreeing with the report. It correctly
limits the result to two samples per variant on one60,909-byte source workload.
The report explicitly leaves production/default unchanged and does not claim
public-H or whole-source improvement. The existing6.03× full-source ratio is
therefore unchanged.

One minor terminology correction was requested: the Boolean report describes
its400 generated controls as “well-typed graphs.” The generator constructs
finite KTerm data graphs including Unknown tags/noncanonical Apps and invokes
the predicate directly; it does not establish object-language type correctness
for those400 graphs. “Finite KTerm data graphs” accurately describes the gate.
The separate real core-library compilation does perform checking. This wording
issue does not invalidate the predicate differential or pilot measurements.

The marked-name report consistently rejects promotion for the new `+f(1)`
phase regression. Its19-row8→18 classification result and7→9 exact result,
three-row1→2 call comparison and ten allocation/noncapture controls agree with
the retained audit. It retains the mistaken global-call oracle, separates the
pre-existing `+U32` defect and template diagnostic collapse, and names the
uncompleted baseline core-graph/broad/proof obligations. Neither this candidate
nor the independently tested erased-name candidate is represented as shipped.
No new release-blocking discrepancy was found within this documentation scope.

## Campaign-report cross-scope review — 2026-09-23 03:24 UTC

Read the updated Phase5 report, new Phase6 report and `experiments/STEERING.md`,
plus the latest native footprint/scaling note and the user-facing README sections.
No compiler, test, archive or hash work ran. The major scope boundaries are
consistent: the released6.03× comparison is unchanged; H proof durations are
separate descriptive observations; the Boolean pilot and both parser candidates
are unpromoted; backend strict/infrastructure failures remain failures. The
outside-inventory `+U32` counterexample properly qualifies the inventory-only
agreement statement. The fixed-point claim is not used as user-program backend
coverage, and the native C-size issue is not blamed for the separate JS compiler
throughput deficit.

Two concrete follow-ups were sent to root. First, the newly completed native
32/64/128-field scaling gate (native-arity-wall.md,03:21:14) now corroborates
quadratic emitted continuation expansion, while the Phase6 summary and strategy
still name that same scaling falsifier as future work. Update their state to
completed checked emission, retaining the explicit absence of Clang/runtime
execution or an implemented optimization. Second, the selfhost README's older
all-positive backend paragraph explicitly says “supplied baseline,” so it is
historically scoped rather than a false current claim. A nearby pointer to the
current broad report and its native timeout would make the distinction clear
without requiring readers to follow campaign-report links. The main repository
README limits its current numerical pass claim to frontend fixtures.

## Confirmed closeout resolutions — 2026-09-23 03:32 UTC

All three remaining documentation follow-ups are resolved in the current text:
Phase6/STEERING mark the32/64/128-field checked-emission scaling as completed,
with measured sizes and no runtime/optimization claim; the selfhost README links
the current broad timeout directly after its historical baseline paragraph; and
the Boolean report now calls the400 generated controls finite KTerm data graphs.
The original findings above remain historical. This confirmation read only the
changed documentation, without rerunning tools or checking archive hashes.

The new actual-H follow-up and Phase6 aggregate preserve the important failure
boundary. They report the original positional malformed-data graph gate as
failed after430 controls, disclose that later deep/list cases did not execute,
and do not infer partial-closure equivalence from matching arity/type metadata
or baseline self-comparison failure. The separately authorized checked core
emission is explicitly a separate passed subgate using the changed disposable H
capsule. It does not override the failed graph gate. Workflow durations are not
H speed measurements, B1's pilot gain is not transferred to H, and no source
promotion or new whole-source fixed point is claimed. No additional scope
correction was identified.
