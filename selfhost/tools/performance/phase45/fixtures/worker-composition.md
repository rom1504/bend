# Independent worker continuation controls

The adjacent `worker-composition.bend` is a correctness fixture, not a benchmark
or an optimizer admission pattern. The recursive helpers are explicitly unsafe
so these tests do not claim an independent mutual-termination proof. No fixture
has been compiled or executed at authorship time.

Every scalar root includes the generic `conduit` call to exercise erased-prefix
instance reconstruction. Its type argument is erased, while its value remains
demanded. All source/helper names differ from the maintained timed corpus.

## Small exact values

All numeric inputs and outputs are U32. Compare complete results against both
unchanged checked04 and pinned TypeScript where they execute successfully.

| Export | `(size, seed)` | Expected |
| --- | --- | ---: |
| `bench` | `(0, 7)` | 7 |
| `bench` | `(1, 7)` | 62 |
| `bench` | `(2, 7)` | 248 |
| `bench` | `(3, 7)` | 437 |
| `tail_check` | `(0, 7)` | 7 |
| `tail_check` | `(1, 7)` | 23 |
| `tail_check` | `(2, 7)` | 15 |
| `tail_check` | `(3, 7)` | 31 |
| `tree_check` | `(0, 7)` | 7 |
| `tree_check` | `(1, 7)` | 29 |
| `tree_check` | `(2, 7)` | 118 |
| `tree_check` | `(3, 7)` | 148 |
| `scope_check` | `(0, 7)` | 4294967290 |
| `scope_check` | `(1, 7)` | 51 |
| `sibling_check` | `(0, 7)` | 4294967282 |
| `sibling_check` | `(1, 7)` | 4294967289 |
| `tail_check` | `(50000, 7)` | 200007 |

`tree_value(2, 7)` must be the entire ordered value
`RibbonMark{8, RibbonMark{95, RibbonEnd{15}}}`. Check constructor names and
every field. Two separate calls must return distinct root objects and preserve
the earlier value unchanged. This public ADT result can remain on generic entry;
`tree_check` is the scalar root intended to expose the internal producer cycle.

## Iterative independent oracles

Use the following JavaScript mathematics in a root-owned controller. It executes
no Bend helper and requires no recursive host stack. `which=0` selects azimuth;
`which=1` selects meridian. Arithmetic is reduced modulo 2^32 at each operation.

```js
function arithmetic(size, seed, which=0) {
  const saved=[];
  let s=seed>>>0, side=which;
  for(let i=0;i<size;i++) {
    saved.push([side,s]);
    s=(s+(side===0?3:5))>>>0;
    side^=1;
  }
  let result=side===0?s:(s+13)>>>0;
  for(let i=saved.length-1;i>=0;i--) {
    const [side,s]=saved[i];
    result=side===0?(Math.imul(result,3)-s)>>>0:(result+Math.imul(s,7))>>>0;
  }
  return result;
}
function ribbon(size, seed) {
  const marks=[];
  let s=seed>>>0;
  for(let i=0;i<size;i++) {
    marks.push(i%2===0?(s+1)>>>0:(s^85)>>>0);
    s=(s+(i%2===0?3:5))>>>0;
  }
  const end=size%2===0?s:(s+11)>>>0;
  return {marks,end,sum:marks.reduce((a,x)=>(a+x)>>>0,end)};
}
```

For `scope_check(n,s)`, expected is `(arithmetic(n,(s+2)>>>0)-15)>>>0`.
For `sibling_check(n,s)`, expected is
`(arithmetic(n,s)-arithmetic(n,(s+1)>>>0,1))>>>0`.
For the tail cycle, expected is `(s+4*n+(n%2===0?0:12))>>>0`.

Cover sizes `0,1,2,3,8,31,32,33,64` with seeds `0,7,4294967295`, then
candidate-only depth controls at 4096 and 50000. Do not require native-recursive
TypeScript or the generic predecessor to survive deep non-tail recursion;
record their actual outcome separately when attempted. The independent oracle
remains the deep value check. Run large cases individually under the resource
supervisor, never concurrently.

## Continuation and boundary obligations

- `bench` must restore the caller seed and execute its arithmetic after the
  callee returns; interchanging target or unwind order changes small values.
- `tree_check` must retain pending constructor work, field order and all nodes.
  For shallow public values, walk the structure iteratively and compare every
  mark/end against `ribbon`, rather than checking only the sum.
- `scope_check` keeps an outer value live across a recursive call and a later
  shadowed binding. Existing synthetic KTerm tests remain necessary for parallel
  Let RHS scope, because source desugaring may produce nested Let nodes.
- `sibling_check` restores the parent frame between two calls and preserves
  their distinct seeds and noncommutative final result.
- Tail cycles must transfer without accumulating native JavaScript frames.
- Repeat shallow calls after deep calls and after exceptions to detect leaked
  machine state. Mutated G/helper code, host methods and raw entry must retain
  the ordinary fallback; apply the existing boundary suite independently.

Value agreement does not prove worker activation. Record dispatcher entries and
call/return/tail transfers in a separate diagnostic, keeping counters out of any
clean timing. Preserve failed compilation or execution attempts rather than
silently removing an unsupported case from the fixture.
