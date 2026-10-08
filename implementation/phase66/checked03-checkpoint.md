# Checked migration checkpoint

October 8, 2026. Upstream `059266225b77c8ca256ac6b25ee5c21449bab151`
is merged as `af6dfc1`. This checkpoint records a working checked candidate;
the Phase65 package remains installed until the remaining qualification passes.

Attempt `selfhost/build/phase66/checked-b1-03` completed its checked bootstrap,
guarded profile7 derivation and strict paired 36-case validation. All 36 outcomes
pass on both sides, with zero exact differences. The selected derived B1 is
`1ed7deccc250732402fb3aebda4c0852adacdf983a8bcfe12b12658dfda23094`.
The entire bounded build/validation command took 29.283 seconds and peaked at
1.50 GB process-tree RSS. This is a build observation, not a compiler latency
comparison or a B2 result.

The source migration covers internal namespace identities and displayed names,
parser diagnostics, current Base/effect interfaces, iterative composite host
marshalling, printability identity, and bootstrap/tool defaults. The optional
Base annotation permission remains disabled for the new Base until separately
qualified. The maintained compiler still has 115 Bend modules.

Earlier focused evidence is separately scoped:

- The raw attempt02 image overflowed in recursive `String.cmp`/`String.cmp.fin`
  during prefix loading. A preserved API-boundary trace established the location.
  Profile7 changes guarded string equality and literal choices; it preserves the
  new unary runtime and does not apply the old array-argument tail rewrite.
- Profile7 passed 151,084 primitive comparisons, six exact historical-profile
  replays, 19 refusal controls and 42 actual choice cases. Its attempt02 derivative
  passed all 16 host/runtime controls, including the formerly failing deep fixture.
- The legacy effect candidate passed 34 runtime controls, including local TCP
  and UDP exchanges. Four new timed-send operations and the ambiguous suffix on
  asynchronous TCP write failure remain explicit legacy-backend refusals.
- The old compiler and old TypeScript reference have identical normalized
  outcomes on all 3,026 frontend observations. Four expected later-stage fixture
  errors occur identically on both sides at the checking-only boundary.

The new full frontend comparison, generated-program timing, separate B1/B2
latency campaigns, genuine self-reproduction, final size audit and release
installation remain pending. Failed build and harness attempts remain preserved.
See the [phase report](README.md) for the evolving five-metric scoreboard.
