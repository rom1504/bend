# Phase175 — frontend optimization, provisional results

**The combined frontend improves 62.854→56.219s, 10.56% less, across two balanced
pairs on the full fixed compiler input.** Parser lookahead reuse alone improves
parse/load 26.452→23.062s, 12.82% less, in one ordered pair. The installed
Phase171 compiler and maintained source remain unchanged pending full-build gates.

[Design](../../design/phase175/README.md) · [Exact provisional metrics](metrics.json) ·
[Receipt index](evidence-index.json) · [Reproduction](reproduce.md).

This is an in-progress checkpoint. Full cold source-to-executable comparison
and generated-code gates remain pending. The same-source C comparison hit its
Clang construction budget, so has no execution result. There is no new upstream-parity score,
100-second build, generated-program runtime result, or native qualification.

## What we learned

The parser repeatedly requested the same token spelling and constructed the same
lookahead tail while deciding how an expression grows. Two small replacements
share those observations within the decision and leave parsing transitions,
source positions and errors unchanged. Unlike earlier allocation-count
improvements, this removed enough work to appear in a complete native parse/load
measurement on the unchanged 3,150,535-byte compiler input.

The other hypotheses illustrate why complete-component measurement matters:
finite precedence dispatch was neutral; reusing already-established constructor
field quantities during erasure was neutral or slightly worse; delaying further
publication canonicalization was neutral. Replacing quadratic report-name
membership with the existing collision-safe index has a small positive screen,
but no isolated paired confirmation yet. The selected combination now improves
the complete frontend component; this does not isolate each change's contribution
or establish a complete self-build improvement.

## Results and measurement boundaries

All source timings use the frozen Phase170 compiler input
`434edd1d56128f9480800573abf8a0ae21d910a547837af089f25cd1d0e89b71`,
prepared Base and the same QBE runtime/toolchain. The executing reference is the
installed Phase171 version published in Phase174, canonical source
`74cd7de3e5076490e20ba0218d4c9254853be72562946b9ef66fed6c10c7a53a`.
Targets run through the root-owned CPU3 execution lane.

| Experiment | Component baseline | Candidate | Interpretation |
|---|---:|---:|---|
| Lookahead plus indexed report names, complete frontend |62.854s|56.219s|10.56% less; baseline/candidate/candidate/baseline, matching full-input observation.|
| Reuse parser lookahead |26.452s|23.062s|12.82% less; one baseline→candidate pair.|
| Finite operator precedence dispatch |26.661s|26.381s|1.05% less; treat as neutral.|
| Checked field-quantity reuse |60.509s|61.085s|Separate full-frontend screen; do not select.|
| Deferred publication flush |60.509s|60.297s|Separate full-frontend screen; neutral.|
| Indexed report-name membership |60.509s|59.358s|Separate full-frontend screen; 1.90% less, needs confirmation.|

The last three rows compare separate candidate runs with an earlier baseline;
they are **not** fresh paired measurements. Each parser pair has one observation
per image, not a counterbalanced repeated sample. For lookahead, complete process
time including input reads, Base, digest and teardown was 27.247→23.850s
(12.47% less). No filesystem cache flush or statistical confidence claim.

The combined whole-process medians are 71.320→64.684s, 9.30% less; digest cost
remains approximately 8.15s. Frontend observations were 62.624/63.084s versus
56.437/56.001s. Use this fresh paired baseline for the combined result, rather
than the earlier 60.509s screen baseline. Its full candidate source adds 2,175 bytes (0.069%),
three replacements and 19 helper declarations, with every original declaration,
all 112 protected declarations and the original native main preserved. This is
still a component result, not a new complete cold self-build measurement.

The frontend driver stops before backend optimization, QBE rendering and machine
construction. Its `parse`, `check`, `context`, `annotation` and `request` modes
are cumulative stopping points, not additive stage timers. The complete request
baseline clocks **60.509s frontend**, 0.213s Base and **8.081s structural
observation**, inside 68.874s complete process time. The parser-only baseline's
observation is about 0.486s. The 32-bit digest is a timing observation, supported
by separate complete-value comparisons; it is not a collision-free oracle.

## The faster experiment loop

Acquiring the first complete frontend diagnostic executable cost 53.474s,
including 37,118,525 QBE bytes. A separately checked parser-only closure excludes
the checker and eraser and costs **25.746s**, with 18,967,097 QBE bytes: 51.85%
less acquisition time. Both sides of the parser comparison use that smaller
service. This is a narrower diagnostic tool, not a faster production compiler.

The diagnostic services, digest and optimization logic are written in Bend.
Host adapters perform authenticated source transport, process control and full
value comparison; they do not implement the compiler transformations.
See [the precise boundaries](../../experiments/phase175/frontend-loop.md).

## Correctness evidence

Every successful candidate API was independently source-checked. Completed
receipts establish the following finite coverage; repeated executions of the
same controls are not additional distinct tests:

| Candidate | Complete observations |
|---|---|
| Lookahead |66 precedence values, 38 parser values, 3 boundary controls, 41,380 finite operator-alphabet strings; 14 sources at parse/request boundaries, 28 stage comparisons.|
| Precedence |Same parser controls;14 sources across five boundaries, 70 stage comparisons.|
| Parser-only service |14 complete parse values agree with the full frontend service; candidate service also passes 14.|
| Field quantities |18 controls, complete emitted term observations, 16 complete request/error comparisons, including real dependent-field and rewrite programs.|
| Report names |15 literal ordered-list cases checked in both APIs, complete cross-API records, 14 request/error comparisons.|
| Publication |45 update observations in each API, literal stale-ADT answers, 7 small and 8 large complete DChecking comparisons, and 6 sources at check/request boundaries.|
| Selected combination |14 sources at parse/request boundaries, 28 complete stage comparisons, with the unchanged request oracle checked for all 14. An earlier three-source transfer run also passed. Isolated finite controls are not counted as rerun combination coverage.|

The ordinary unchanged request entry is also compared where the receipt records
it. Values include constructor variants, all fields, spans, quantities,
ownership metadata, order, indexes and diagnostics. These are finite checks, not
BendTT theorems or whole-compiler equivalence proofs. Matching native digests on
the large timing input supplements these gates; no full-source complete-value
or generated-QBE equality claim is added at this checkpoint.

Publication exposed an important fixture mistake: duplicate constructor names
are rejected by the parser, before compact checking. The first comparison
correctly failed its claimed compact-admission gate. An independent probe
established the actual boundary, and the corrected manifest explicitly keeps
that source as a parser-error control. Five other large sources reach compact
checking; direct large DChecking controls retain checker-collision coverage.
The original failure is preserved. The older general fixture named
`erased-param` also remains a parser-negative control, not positive erasure
coverage; the two new well-formed dependent/rewrite fixtures provide that.

Independent [field provenance](../../experiments/phase175/field-provenance-audit.md)
and [report-name](../../experiments/phase175/semantic-report-names.md) audits
remain explicit about scope. Ann marker shape alone is not authority for
erasure. The suspected report-name lone-surrogate exception was falsified by
source and generated-code inspection: both membership equality and hashing use
nonvalidating code-point reads; no extra Unicode guard was added.

## Negative evidence and cost discipline

Eight failed API acquisitions are retained: affine-use mistakes, an attempted IO
`main` export, typed definitions after forward laws, a KLambda pattern arity
mistake, and a reserved `law` local. Subsequent checked acquisitions repair these
without changing the independent semantic gates. One native lookahead acquisition
was stopped by the disk-budget guard during external filesystem consumption;
the later acquisition used fresh output and succeeded.

The first full-candidate CLI check exited with `SOME PROOFS FAIL`: 7,195
definitions depend on unsafe or foreign code. This is the CLI's proof-safety
policy refusal, not a source type failure. It neither qualifies nor refutes the
candidate's source typing. The separate source-only check and native qualification
are distinct gates: `full-source-check02` subsequently passed unmodified upstream
loading, `book_valid` and zero unresolved holes in 7.306s (8.064s guarded wall
time). This establishes source type acceptance, not proof safety, BendTT
verification, backend correctness or native self-hosting. Native qualification
remains pending at this checkpoint.

Method files evolved during the investigation. Historical receipts retain their
original method hashes; in particular the precedence and field comparison runs
used older `compare-frontends.mjs` versions. Those exact historical bytes are not
claimed to remain at the live path. The report pins the current comparator
`9eff7115e15dd1bfa5db5af56de3083a8a76c2cddcef62c90fd5ea4f627b7ea9`;
new reruns must record that method version and fresh results. Original receipts
are preserved rather than rewritten to appear authenticated by the newer tool.

The same-source upstream C diagnostic emitted 11,871,272 C bytes in 30.256s, then
Clang exceeded its 80-second construction window. It produced no execution-speed
comparison. This is an incomplete diagnostic, not evidence that C runs faster
or slower. The receipt and timeout remain in the index.

[Verified storage recovery](../../experiments/phase175/storage-recovery.md)
recovered 3,012.09 MiB net in the emergency tranche, or 3,273.20 MiB including the
earlier already-archived selection. Exact originals were archived and independently
verified before pruning. Installed images, rollback and current evidence stayed
hot; the normal 5 GiB compiler reserve remained unchanged. Recovery time, target
time and agent effort must not be conflated. This draft does not claim a final
phase-wide cost total while jobs are still pending.

## Next decision

The combined frontend gate passed. The full candidate is prepared separately as
`a0e953a84de73aa22403dde7ec2144540197633857a0f7b5b9784f9e66f5ad04`,
with exact inverse reconstruction of the parent and no pruned declarations.
Independent source checking is complete. Require representative generated-QBE
gates and native qualification before considering it an installed compiler.
Keep field reuse, extra publication deferral and precedence dispatch out of the
selected combination unless new evidence overturns their neutral screens. A
fixed-source cold pair is necessary to determine whether the parser saving
survives compiler acquisition and later stages. Installation remains a separate
qualification decision.

Compact raw reports, resource-guard receipts, selected diagnostics and finite
value artifacts are retained losslessly under [evidence/](evidence/index.json).
The main evidence index links those copies and pins the complete local receipts.
Large source manifests, compiler images and generated products are not duplicated;
the retained evidence is not a standalone executable reproduction capsule.
