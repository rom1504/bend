# Independent declared-import phase review

Reviewer: conformance_options, 2026-09-23. Read-only review of the isolated P6-011
driver diff, host controls, retained paired observations and actual missing-root
and missing-Base preflight results. No compiler or test was independently rerun.

The change confines its catch to the existing `realpathSync` call. Only a recursive
declared import with ENOENT and `error.phase === undefined` gains `phase: 'parse'`.
The same Error is rethrown. Input/root errors, explicit phases, other filesystem
codes, read failures after realpath, collision checks and discovery order retain
their existing paths. There is no added filesystem probe or traversal.

The eight retained host-test groups meaningfully separate root/relative/absolute/
nested import failures; preserve original Error identity and diagnostic text;
cover ENOENT versus EACCES/EIO/ELOOP/ENOTDIR, read races, directories and symlinks;
and exercise module collisions and later-request source edits. The parser stub
isolates filesystem taxonomy; it is not presented as real Bend conformance.

The ten retained pinned observations show only the intended load-to-parse phase
change after excluding expected host-identity metadata. All diagnostic bytes,
status, checked flag and exit code remain unchanged. Five strict fixture failures
and ten exact diagnostic differences remain. The audit correctly retains the
underlying `selectedComplete: false` and workflow `complete: true, pass: false`;
the original mistaken audit assertions are recorded separately.

One scope question was raised during review: recursive `Base` also receives the
new import flag. The current released API performs Base preflight before
discovery. Root subsequently exercised that actual path: both a missing main
source and a missing bundled Base return error/load/unchecked/exit1. The separate
25-observation neighbor gate passes its declared controls, retaining nine known
exact differences, including the competing body/import first-error residual.
The measured current release behavior therefore meets the intended boundary.
Legacy direct `discoverSources` callers without the Base preflight are outside
that observation; documentation should not broaden the resource-error claim to
every possible historical API.

Verdict: suitable for the stated host-only integration. It removes ten phase
differences, does not repair five diagnostics, and does not establish import-first
error ordering or successful cycle/diamond execution. No performance gain is
claimed. Evidence is retained under
`selfhost/build/phase6/campaign/import-phase`, especially `comparison-audit.json`,
`host-controls.tap`, `preflight-run.json`, `missing-root.json`, `missing-base.json`
and the neighbor gate.
