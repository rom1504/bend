# P68-024 — Closed immutable constructor data should use the static image

- Owner: root; source preparation and independent mechanism audit: upstream lane.
- Registered during P68-022, before execution; diagnostic only, compiler unchanged.
- Decision: investigate; no correctness or speed result at registration.

The lexer template is a closed39-character String. Compiler23 emits an ordinary
worker that allocates39 SCon nodes on every call and has STAT_LEN0. Upstream
uses its static constructor image. Fresh operation counts show239,616 extra
String allocations from this worker per additional16 workloads (6,144 lines).
The RFC excess233,472 equals38 times6,144, consistent with sealed tails;
the wrapper call stack was not instrumented, so that attribution is an inference.

**Hypothesis:** materializing this closed immutable graph in the existing native
static image removes meaningful repeated work and composes with corrected
runtime scheduling. This tests a general literal-constructor mechanism, not a
benchmark-specific compiler rule.

## Diagnostic and controls

Source-only derivation changes STAT_LEN, STAT_IMG and the template worker body,
using the candidate's constructor identifiers and static-region ABI. Preserve
the original C, exact diff and source binding. Prepare static-only and
static-plus-BANGS0 variants; compare with unchanged23, BANGS0-only and upstream.
Build with identical Clang flags. Check independent digests at1/17 repetitions,
including a threads4 pure-result control. Five balanced role rotations use448
measured repetitions and48 warmups, GPU off, single guarded CPU3 target,
>=100ms intervals. No instrumented sample contributes clean timing.

A successful saved-C result does not qualify a general emitter. Integration
must prove recursively closed immutable fields, representation width, layout
identity and deterministic interning; exclude mutable arrays/foreign-owned
objects/effectful expressions and preserve ordinary allocation fallback.
Check static/shared/heap mixtures, repeated consuming matches, source changes,
CPU/device image initialization and other unrelated literals before promotion.

Report: [native parity survey](../../implementation/phase68/c23-parity-survey.md).
