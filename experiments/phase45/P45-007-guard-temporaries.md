# P45-007 — Guard descriptor-test temporaries

**Decision: stop before derivation or execution. No production change.**
Root rejected narrowing the requested mutation contract to a standard imported
Array.every assumption. No timing or semantic qualification occurred.

The proposed rule would replace scalarGuard's
[a,c,e,b].every(d=>Object.hasOwn(d, 'value')) with four ordered short-circuit
Object.hasOwn calls. It would test the current every descriptor against the
existing private regionProtocolDescriptors[3] snapshot for every dependency,
using captured reflection functions and the captured Array prototype. Changed
or accessor every descriptors would retain the original expression. Every
G/code/env/bound and prototype validation would still occur on every entry.
There was no cross-entry caching or removal of source/proof guards.

The frozen Phase44 API is 0d3325425139c59ac81c4f1bca19fa09e9f977062aa3b202c0ef1c8c7b56b0ea,
runtime e62cf92d8b600fdc2eb44029b1945f288c81bf878931f883a1b6f4fb5774aaeb,
core 2276c6cf4be648421839a11e887913a1ac7fce7801e0ba9af86dc1b44fabd384.
The [unexecuted sketch](../../selfhost/tools/performance/phase45/guard-temporaries-v1.py)
retains exact runtime/core/API hashes and unique anchors, untouched program
suffixes and module identities. Its main entry explicitly refuses execution;
it is preserved negative evidence, not a ready experiment command.

## Why stop

The existing snapshot establishes identity with the imported method, not that
its implementation is native every. If a custom every is installed before
module initialization, it can be captured by that snapshot. Replacing its
invocation loses observable method behavior, callbacks and mutation. A reused
or frozen receiver array also changes identities and state visible to custom
every; it is not an automatic safe alternative.

Independent static review found the transformation equivalent **within** the
runtime's explicit standard-host-at-import premise (core.mjs comment above
stringHostOwnKeys). In that restricted domain, the added reflection gate is
inert, overridden post-import every falls back, and four live Object.hasOwn
lookups preserve mutations between callback invocations. This conditional
argument does not establish hostile-import equivalence. Root required the
broader preservation and chose to stop rather than add new host machinery.
This is a scope/provenance rejection, not measured evidence of regression.

## Remaining cheap attribution direction

The [P45-006 diagnosis](P45-006-remaining-frontier.md) counts 77 descriptor reads
and 18 prototype reads in the successful six-dependency scalar guard. Keep the
entire guard unchanged and use diagnostic entry/guard counters or a CPU profile
to attribute fixed cost on zero/small/large ordinary inputs. Distinguish time
spent in invokeExact, localGuard/scalarGuard and actual private workers. Such
instrumented observations estimate the cost center; they do not establish a
causal optimization gain.

A future elimination experiment should target redundant checks inside one
already-established full root capability, after exact guard facts are explicit
in the IR. It should preserve the original public entry checks and mutation
fallback rather than identify native hooks through an imported snapshot. No
such transformation or execution is authorized by this stopped hypothesis.
