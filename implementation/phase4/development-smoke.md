# Normal bootstrap and selected development loop

The documented normal commands work with the file-backed supervision fixes. A genuine `tools/typed-driver.mjs --bootstrap` created a fresh checked API in **22.416 s**, then the genuine `tools/conformance/target.mjs` ran all **21** Phase 2 rule cases in **18.754 s** process wall time (**18.444 s** inside the paired runner). Their observed combined process cost was **41.170 s**. This is a single practical workflow observation, not a repeated benchmark; cache state was not reset or claimed cold.

The bootstrap used the canonical clean pinned upstream, Node 24.18.0, CPU 3, a 4 MiB Node stack and 4 GiB heap. Output went to `selfhost/build/phase4/development-smoke/api.mjs`; the default distributed API and report stayed unchanged. The actual normal API exports exactly **54** functions and is 1,008,078 bytes, SHA-256 `cae448302162a3f7bc108343d72728be3d056338e31c36ae5b7d915daac7cc42`. Checked source SHA-256 is `aa61191865a6bd657b2998aacfa22d178ef0bdb526d4fceabc8369b8e1955cc2`: guarded book canonicalization, before telescope integration.

The selected run consumed the **real** `api.mjs.bootstrap.json`, with verified post-build provenance. It used persistent workers, jobs=1, recycling at 64 requests, 30-second request limits and a 4 GiB RSS bound. All 21 explicit acceptance/phase oracles and semantic comparisons passed. Twelve retained exact diagnostic differences remain; selected success is not full language conformance. The normal bootstrap CLI exposes no internal phase clock, so its recorded number is complete process wall time, not an invented checking/emission breakdown.

## Preserved failures and repairs

The first relevant test run used `--test-isolation=none` and passed **27/32** tests. Four failures came from test-side synchronous pipe capture returning empty output: retained replay checks and resource-argument propagation. A shared test-only file-backed capture helper fixed these while retaining each test's expected exit status and checking spawn errors/signals explicitly. The second attempt passed **31/32**.

The remaining overflow failure was a real isolated harness gap in this supervised environment. `run-probe.mjs` captured child streams through pipes, so missing captured bytes let an oversized writer be accepted. The fix uses file-backed capture, checks combined stdout/stderr bytes both during execution and after exit, keeps capped logs, and kills the process group on deadline or overflow. Spawn errors and signals invalidate a response; ordinary nonzero compiler rejection responses retain their semantics. A stale response is removed before launching a new worker.

The same **32/32** tests then passed without weakening any oracle. Four additional focused cases passed: a fast combined stdout/stderr overflow, a valid response followed by SIGTERM, an ordinary nonzero compiler rejection and an old response followed by a worker that produces none. Both failing attempts remain in the evidence. The genuine 21-case paired command was also rerun after the harness fix and passed again, retaining the same 12 diagnostic differences. Its inner wall time was 11.488 s with caches left in place; this is a correctness rerun, not a comparable cold-loop timing.

A final exit-contract review added numeric exit-code validation: only worker codes 0/1 are expected, a success response cannot accompany exit 1, and a compiler rejection with exit 1 remains valid. Synchronous spawn exceptions close the inherited descriptors and clean temporary capture files. The complete rerun passed **40/40**: the same 32 existing tests plus eight focused guards, including actual ENOENT and synchronous spawn-failure cleanup. Earlier 32/32 and four-guard results remain preserved.

## Provenance

The original broad snapshot also noticed three concurrently edited private-compiler tools that this workflow never loaded. Its overall `complete:false` record is retained. A separate scoped companion identifies the actually consumed bootstrap and paired-harness tools, all unchanged during the successful command run, and separates test failures from command success. Later harness fixes have their own source snapshots and rerun evidence; they do not rewrite the original timing record.

See the [summary](development-smoke-evidence/summary.json) and [archive manifest](development-smoke-evidence/archive-manifest.json) for original hashes, exact commands, test output, real bootstrap metadata, both paired reports and consumed tool snapshots.
