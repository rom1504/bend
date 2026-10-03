# Phase42 direct call discriminator

Status: investigate; saved-JS controls and timing belong to root. No compiler
source change or promotion is claimed by this document.

The Phase41 tree capture retains 12.89% sampled self time in invokeExact,
6.57% in apply, and two warp_leaf frames totaling 17.68%. These shares do not
predict saved time. The cheapest discriminator removes the single saturated
warp_leaf edge inside the admitted structural worker. This bypasses the generic
call dispatcher, native Bool.xor dispatch, and the nested finite-selector proof
lookup while preserving primitive comparison, xor and three fresh constructors.

A second independent edge replaces the private bsort leaf's key call with exact
U32 increment/multiply and prng shift/xor arithmetic. A third ablation erases
only the redundant proof-covered conditionals inside five private workers.
The complete variant combines both edges and worker guard erasure. It does not
remove recursive continuation stacks or change their child evaluation order.

The complete transitive root guard remains intact, including Bool.xor, leaf,
key, prng and every structural/stat helper. Public entries and generic bodies
retain their source bytes; hostile bindings/getters must refuse private entry.
The synchronous pure graph admits no callback capable of changing dependencies
between guarded root entry and private work. Mutation, reentry or host-owned
input at a refused boundary cannot revive proof. Generic fallback remains the
owner of host demand/error order. Reconstructed nodes/leaves stay fresh and
existing zero-case child aliases stay shared.

The derive tool consumes explicit Phase41 saved tree + TypeScript paths and a
new output directory, checks checked receipt/API/pin and all recorded consumed
file identities, and produces exact original/noise controls plus leaf, leaf-key,
guards and complete variants. It derives diagnostic adapters from the retained
Phase41 tool without modifying that tool. The controls retain the Phase41
independent nested-array oracle, mutation/getter cases and depth30000 summary,
then add leaf U32 extremes/equal-order cases and independent BigInt key arithmetic.

Before compiler implementation, root must measure the distinct ablations. A
source survivor must use typed saturated first-order graph analysis and existing
backedge/ownership proofs, never benchmark names. The source patch must preserve
runtime bytes and a complete dependency guard. Full graph lowering is justified
only after the measured edge/guard discriminators establish which work matters.

Source survivor details: helpers-v2 uses the original JPure closure and typed
signature, then a depth16 active-definition walk refuses all recursive helper
paths. Each body is bounded256 and each matcher retains the existing finite
Bool/List/userADT layouts; native Nat matcher prefixes remain on their original
worker path. Native inline permission is limited to the existing typed Bool.xor
proof. Original arguments are captured once in order before introducing callee
binders. Original annotations preserve result inference across parallel lets.

The separate expansion.patch adds shared2048 fuel before that graph walk. Each
source-node visit consumes fuel, and every saturated helper call visits its
callee body again with the remaining fuel, including repeated calls to a shared
helper. Exhaustion or a repeated active name refuses the direct plan before
emission. This bounds copied plans rather than merely counting unique graph
definitions. Compilation/source costs still require a fresh checked measurement.

## Residual post-calls discriminator

Actual checked01 remains3.7–4.7x TS on the three tree points. Its private workers
have14 actual acyclic helper IIFE sites and no remaining worker proof lookups;
the generated continuations still re-read original typed prefixes after each
child and preserve full parent argument vectors. The full handwritten graph
changes representation, scopes and recursion together, so it cannot attribute
the remaining gap.

Post-calls tools isolate those mechanisms on exact checked01 bytes:
post-calls-frames.mjs derives live continuation fields and a separate native
recursive ceiling, retaining identical helpers; post-calls-scopes.mjs hoists
exact closed helper IIFEs into deduplicated named functions, retaining identical
workers/stacks. Scope-aware reference analysis distinguishes helper-local binder
IDs from live caller references, and remaps only lexically free references.

The recursive ceiling is a diagnostic for bounded scalar tree points up to
12 levels. It must still fail the depth30000 probe with RangeError and restore
the proof. It cannot be promoted as an unrestricted source worker. The live and
hoisted roles retain stack-safe owners and must pass the complete inherited
191 oracle/75 hostile-boundary controls. The controls reuse actual compiler
adapters and check each derived clean parent's identity.

A helper-hoist survivor can use one private encoded `$direct` declaration per
admitted original definition, with exact complete closure guard/context and
source arguments once in order. A continuation survivor can derive lexical
live fields and continuation arms from the same checked source, retaining
source child order and deep-stack iteration. Broader graph-native recursion
requires its own stack-bound and host-boundary evidence.
