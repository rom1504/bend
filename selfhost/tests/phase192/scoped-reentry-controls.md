# Actual continuation-frame reentry observation

This fixture closes the coverage gap in the original stacked-frame sentinel:
its **first continuation** pushes a second frame from a renamed case scratch
buffer, then reenters the owner. It is an ordinary original N111 segment family
that must pass the existing segment verifier and unchanged H admission.

Append `scoped-reentry-controls.bend` to the scoped candidate API source and
export:

```text
p192hcf_controls
p192hcf_emit
p192hcf_validate
```

The fixture requires the existing H body/setup factories and scoped setup
module. It has no dependency on the Phase185/186 test fixtures. Keep the four
scoped late-pass hooks and the ordinary typed output exports as in the current
scoped API acquisition.

Use the new standalone transport in the root-owned resource/disk guard:

```text
<bound engine> selfhost/tests/phase192/scoped-reentry-controls.mjs
  --api <checked authority>
  --assets <pinned assets>
  --source-manifest <exact API preparation manifest>
  --out <fresh selfhost/build/phase192 output>
```

Default group is `reentry`. The driver retains checked authority, preparation
fixture identity, bound engine, pinned toolchain/runtime and CPU3 gates from
the existing worker transport. Both direct ELF and rendered GNU-as routes must
print exactly:

```text
phase192 scoped reentry controls: observations=84 failures=0
```

Five exact compiler-data rows require source verification, two-case H
admission, independently fixed FIDs1/2, a runtime frame call in the ordinary
worker, and **no runtime frame call** in the scoped worker. Both workers are
emitted from the same H plan, differing only in the scope supplied to setup.
These checks prevent a nominally scoped fixture from passing without actually
eliminating a continuation-buffer frame call.

The original control flow is:

1. `owner(n,seed)` returns `seed` at zero. Otherwise it pushes `first(seed)`
   and descends to `owner(n-1,seed+3)`.
2. `first(captured,result)` calculates `marker = captured XOR mask`, pushes
   `second(result)` from its renamed case buffer, and reenters `owner(0,marker)`.
3. `second(carried,resumed)` returns `carried*33 XOR resumed`.

The independent C oracle starts at `seed+3*n` and applies that recurrence in
reverse depth order with unsigned64 wraparound. It also constructs the exact
final contents of **every stack word**, including the result captures and FID2
left by the popped second frames. It compares the complete initialized
`P111State` object representation, including SP, counters, environment fields,
all registers and reserved bytes, plus unchanged stack guards. Counts are
0,1,2,3,17,128,100001 and six low/high/wrapping seeds, for42 observations per
worker role per machine route.

Depth zero must leave the complete caller stack untouched. Large depth uses
the explicit runtime continuation stack and local Again transfers; no native
self-recursive call is introduced. This fixture covers scalar capture/FID/SP
semantics. Owned/shared source cases remain separate required coverage.

Only source/static checks were performed when adding these files. Root owns
all compilation and machine execution; no pass is claimed here.
