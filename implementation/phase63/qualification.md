# Phase63 qualification evidence

The selected candidate is State09. Compilation measurements use its genuine
self-emitted B2; release installation uses its checked, equality-derived B1.
Those image identities stay separate. The
[final data-only join](evidence/state09-qualification.json) **passes**, after
rechecking 3,061 inputs. Its SHA256 is
`2c481ce79c8c1916b0fe7a27d2adb32f418c2b566e2e795dccf3f25465839bb3`.
The raw `final-state09/qualification.json` is an identical copy with its own
copy receipt. All gates below are complete, including release42/default24 and
the five helper integrity controls.

The join requires these completed, identity-linked gates:

- Strict36 and the exact 94 checked export roots.
- The full 14-step checked-B1 matrix: source96, numeric34, composition18,
  overapplication2, direct26, maintained8, three native byte comparisons and
  independent execution checks at all 45 selected program points.
- Genuine B2 bootstrap, tiny split/plan/compatibility equality and eight driver
  observations; fresh own-source type acceptance, the expected unsafe proof
  trust refusal, and byte-identical B2/B3 compiler images.
- The B2 semantic resume with source96, numeric34, composition18 and
  overapplication2, followed by 23 fresh raw-module comparisons and their
  complete 45-point mapping.
- The balanced 207-worker compilation benchmark, with every emitted module
  rehashed against its exact reference. This is not a fresh program-speed run.
- Five release jobs, ordinary/relocated legacy42 and default24 CLI checks,
  five graph-helper integrity controls, selected installed identities,
  preservation of the previous seven release files and 110 inherited files.

Counts overlap and do not imply full-language conformance. Type acceptance
does not imply mathematical proof: the compiler's explicit unsafe definitions
must still produce the documented proof trust refusal. Raw-module equality
transfers only evidence applicable to those exact program artifacts.

The original B2 semantic parent remains failed. It stopped before observations
because an identity row included `canonicalPath`, while its old validator
expected exactly `file` and `sha256`. The new method separately validates
canonical path and optional byte count before checking the normalized identity.
All four semantic controller bodies and their oracles are unchanged. The join
requires both the preserved failure and successful seven-command continuation;
it never rewrites the failed parent as passing.

Release packaging has a separately reviewed change: the driver now statically
imports `base-cache-graph.mjs`, so installed and relocated inventories must bind
that helper to checked bootstrap provenance. The successor release planner
admits only the exact retained packager delta while requiring selected source,
API, driver, runtime and graph-helper identities. Old consumed methods and
checked snapshots remain untouched. The negative integrity controls exercise
missing, tampered and unbound helpers in a private copy.

The join was run on CPU0 after root closed release and helper writers:

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase63/latency/join-final.py --out implementation/phase63/evidence/state09-qualification.json
```

The join launches no compiler, test, installer or archive. It rechecks completed
receipts and current artifacts, then emits a compact summary. Historical raw
tree/archive closure remains a separate root-owned operation after this join.
Repeating it requires a fresh output path; existing evidence is never replaced.

The own-source check accepted all types and correctly refused mathematical
proof trust for the 3,235 explicit unsafe definitions. B2 and B3 are byte-identical
at SHA256 `e838cbab6e6543d1785da0474c50c1c33ab91e6806d2e6796cfcbeabf5b98003`.
The installed equality-derived B1 is
`4a208bffcf47b5d19f8ff18be1fc01b2faf988b37d38e7f5db9e6bd42d79905f`.
All 110 inherited files remain unchanged, and the previous seven release files
were rehashed in `dist/release-history/97f412af…` against their preinstall pins.
The raw `final-state09/preservation-final.json` records this preclosure check;
it does not claim historical raw/archive closure.
