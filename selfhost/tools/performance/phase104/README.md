# Recursive-improvement baseline

This is independent measurement infrastructure, not compiler implementation.
Node reads provenance and collects results; the optional screen reuses the
existing Python resource-guarded experimental launcher. The public native CLI
remains Bend and does not acquire these development dependencies.

From the repository root, with the existing Phase102 candidate04 artifacts restored:

```sh
mkdir -p selfhost/build/phase104
node selfhost/tools/performance/phase104/baseline.mjs selfhost/build/phase104/audit-new
node selfhost/tools/performance/phase104/baseline.mjs selfhost/build/phase104/screen-new --screen
node --test selfhost/tools/performance/phase104/baseline.test.mjs
```

Use fresh output directories; overwrite is refused. No network access, source
edit, compiler image build, selected-release change or PR interaction occurs.
The data-only audit streams file hashes, verifies source/build/emission links,
compares actual self-C and diagnostics, and extracts historical clocks. It is
an internal provenance check anchored to the pinned candidate04 source, not a
new independent whole-compiler qualification or a tamper-proof evaluator.

The screen performs 16 serial requests: Small/Lexer × B1/B2 × four alternating
rounds, fresh processes and cached Base. Each request uses the existing one-worker,
GPU-off, pinned-CPU, 30-second and 2 GiB RSS guard. It requires 512 MiB free disk
before each request and preserves raw evidence after failures. Complete C bytes
and clock-stripped diagnostics must match the frozen development oracle.

`requestMs` comes from the compiler clock; `processMs` is the guarded process
wall time. `launcherWallMs` includes Python startup, authentication, supervision,
publication and capture-log writes. These are separate boundaries. Four samples
on two familiar cases establish a small baseline, not a general performance
ranking, a held-out result or evidence of accelerating research.

Generation rows are explicit: B1/B2 built and executed historically; B3 C emitted
historically but executable unbuilt; B4/B5 unexecuted. No missing generation gets
a zero time or an inherited speed measurement. The cost model uses single old
self-request/build observations and excludes agent/tests.

The tool fails closed when historical assets are unavailable or changed; it
does not silently restore/rebuild them or fall back to another compiler.
Evidence-bundle restoration must be into an isolated checkout or fresh directory,
never over current artifacts. For the first retained run see the
[report](../../../../implementation/phase104/README.md); for the proposed
protected autonomous service see the [design](../../../../design/phase104/recursive-improvement.md).
