# Native verifier: work retained after the compact-flow change

Read-only inspection used the actual measured Lexer executable's retained
`selfhost/build/phase147/verifier-native-lexer01/native/program.s`.
`program.ssa` was not retained. This is generated machine-code evidence, not a
new profile or an attribution of the observed runtime gain.

The native compiler admits direct `p113d` workers for `p147n_get`,
`p147v_live_get_fact`, `p147v_local_fact` and `p147v_memory`.
`p147n_put` uses a stack-safe `p114r` recursive region. Numeric intersection
and assignment still use scheduler segments. Thus the earlier Phase144 failure
to obtain useful direct workers does not explain this candidate's behavior.

Two concrete unnecessary boundaries remain:

1. Successful `p147n_get` takes a two-field cell with `p125_rt_take2`, then
   reconstructs that cell using `p125_rt_ctor2` (constructor ID201). Its ordinary
   local-value and capacity consumers immediately project only presence or
   capacity. Returning a scalar observation can remove this intermediate
   reconstruction without changing the representation of the live tree.
2. Assignment really materializes its two-field `P147VEnv` carrier. The success
   continuation FID2419, `$p111.k.228590`, calls `p125_rt_ctor2` with constructor
   ID203 before returning. It was not eliminated by native product lowering.

The first boundary is the cheaper next ablation. Candidate04 adds distinct
scalar membership and capacity observers and fuses a memory check's repeated
base lookup into one schema lookup and one numeric-tree observation. An assigned
zero-capacity pointer remains distinct from absence. Nonlocal values cannot
have positive bounded capacity, so their memory checks still fail. The original
generic lookup stays available for intersection and test projections.

Candidate03 module SHA256 is
`a176649d151a0d729d760958b2890b2e0b1aaf3e20724162f34c725ea4057555`;
its exact snapshot, unchanged observer snapshot and the successor patch are in
`selfhost/build/phase147/verifier-scalar-observer01/`. Candidate04 module SHA256
is `7352cfde6f0a0a538993e33b0e46981db74f539c60ea4a9c2fcc7fd7e1e9de60`.
Both use the same complete segment/function entry interfaces. Candidate04's
checked acquisition, 60 expected-error/full-state controls, 16 additional state
controls and 36 captured actual functions pass. Its native candidate/reference
ratios are approximately 0.77466 for Lexer, 0.88100 for Map and 0.81295 for the
compiler slice, versus 0.77898/0.89016/0.82213 for candidate03. The scalar change
therefore adds only about 0.6–1.1% after normalizing each executable against its
own original-verifier path. These separate acquisitions are not a same-executable
03/04 comparison or evidence for a whole-compiler speedup. Full timings and
profile limitations belong to the companion fast-loop report.

The successor assembly confirms the intended disappearance: `p147n_has` uses
89 instructions without `ctor2`, versus 116 for the original generic numeric
lookup; `p147v_local_fact` drops from 77 to 58 instructions; scalar capacity uses
110 instructions without `ctor2`. Memory now follows one schema lookup through
`memory_fact` to `memory_at`, replacing the capacity/value double query. These
static counts establish code changes, not their dynamic execution cost. The
original candidate's profile gives numeric `get` only two samples; it supports
reduced ownership/reclamation overall, not a large boxing-only explanation.

An environment-free rewrite remains deferred. It could remove the second
allocation boundary, but would add an immutable-schema argument to many helper
calls and change register transport. That tradeoff deserves a separate complete
native measurement, rather than being combined with scalar observation.
