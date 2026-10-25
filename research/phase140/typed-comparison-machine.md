# Typed comparison: actual emitted QBE evidence

The candidate removes higher-order comparator dispatch at the rewritten list
boundaries. It does **not** turn recursive scalar/statement equality into a
simple machine loop. This is offline inspection of emitted QBE, not x86
assembly inspection or a runtime result. No target was built or timed here.

## Exact artifacts

| Role | Source SHA256 | QBE SHA256 | QBE bytes |
| --- | --- | --- | ---: |
| Candidate 17, `phase130/p140-acquire03` | `fcef9aa66f8f468f9a07641e8e67a4b74ecbbdb62a04a3d295f4cced676282de` | `1ac630165de38f7ee70e4a0d57adbd894c786a2e8a18d1388c171efb228c2348` | 117444006 |
| Candidate 18, `phase130/p140-acquire04` | `c9ded5523c4d4c3ca9b700c4aff12cd77e02043684f0472ed2f8ec8c412b6313` | `fba8d217cdb76b541af039ee51aeccc8040d9c9cc15ede5d977c6a3ac01294fd` | 117801984 |

Paths are under `selfhost/build/`; both QBE files were independently rehashed
for this inspection and agree with their acquisition receipts. Candidate 18
composition is `session/modules-native-v18.json`; private source is
[compare/typed-v01.bend](../../selfhost/tools/performance/phase140/compare/typed-v01.bend).
Existing generic comparators remain in the image for unreplaced consumers and
independent differential controls.

## Source boundary

The new scalar list helper, source lines 126–130, is exactly:

```bend
def p140e_scalars(a: List<&2,N111Stmt>, b: List<&2,N111Stmt>) -> Bool:
  match a b:
    case Nil{} Nil{}: True{}
    case Con{x,xs} Con{y,ys}: p140e_scalar(x,y) && p140e_scalars(xs,ys)
    case _ _: False{}
```

The statement helper at line 133 substitutes `P113DStmt` and `p140e_stmt`.
Neither introduces a physical-identity shortcut or changes `&&` semantics.

## Before: curried callback and two continuation frames

Candidate 17's `$direct.p134v_list` begins at QBE line 2602703 (127 lines).
The retained candidate 18 version begins at line 2082880, also 127 lines. In its
matching nonempty-list branch it keeps the comparator closure, writes a 32-byte
continuation frame followed by a 16-byte frame, then applies the comparator to
its first argument. The next continuation applies the second argument.

These exact, noncontiguous candidate 18 lines show that path:

```qbe
# L2082933
%v_v_4292171159 =l call $p111_rt_keep(l %state, l %v_v_4292171159)
# L2082953
%v_p114t_19_next_sp =l add %v_p114t_19_sp, 32
# L2082964
%v_p114t_27_next_sp =l add %v_p114t_27_sp, 16
# L2082970
%v_reply =l call $p111_rt_apply(l %state, l %v_v_4292171136, l %v_v_4292171135)
```

The frame sizes describe explicit runtime-stack traffic on this branch, not
native-stack consumption or total per-element allocations.

## After: known two-argument transfer, but still a trampoline

| Candidate 18 body | First QBE line | Body lines | Comparator transfer |
| --- | ---: | ---: | --- |
| `$direct.p140e_scalars` | 2608563 | 107 | `p111_rt_jump`, two arguments |
| `$direct.p140e_stmts` | 2612227 | 107 | `p111_rt_jump`, two arguments |
| `$direct.p140e_scalar` | 2609487 | 780 | Scheduler transfers remain |
| `$direct.p140e_stmt` | 2611618 | 275 | Scheduler transfers remain |

Both typed-list bodies contain zero `p111_rt_apply` and zero `p111_rt_keep`
calls. Their matching nonempty branch pushes one 24-byte continuation and jumps
to its known comparator with both arguments. The scalar-list witness is:

```qbe
# L2608626
%v_p114t_17_next_sp =l add %v_p114t_17_sp, 24
# L2608635
%v_reply =l call $p111_rt_jump(l %state, w 46622, l %v_scratch, w 2)
```

The statement-list transfer is at line 2612299:

```qbe
%v_reply =l call $p111_rt_jump(l %state, w 46666, l %v_scratch, w 2)
```

Therefore one callback capture, one partial-application stage and one of the
initial continuation frames disappear. The explicit initial frame footprint
is 48→24 bytes on the compared branch. A scheduler transition and the recursive
comparison's continuation work remain. The 107/127-line ratio is a static shape
observation, not a runtime estimate.

## Some typed helpers do compose with local continuations

`p140e_args` has an exported adapter at 2608977 and an actual 187-line `p114r`
worker at 2608987. The worker directly calls the native `p140e_arg` helper and
uses `p114r_descend`/`p114r_unwind` rather than applying a comparator closure:

```qbe
# L2608993
jmp @p114r_descend
# L2609062
%v_p114h_call_result =l call $p113d_FID_36_100_105_114_101_99_116_46_112_49_52_48_101_95_97_114_103_(l %state, l %v_p114h_arg_0, l %v_p114h_arg_1)
# L2609151
jmp @p114r_descend
# L2609170
%v_p114h_case_1_local_p114h_call_result =l call $p113d_FID_36_100_105_114_101_99_116_46_66_111_111_108_46_97_110_100_(l %state, l %v_p114h_case_1_local_p114h_arg_0, l %v_p114h_case_1_local_p114h_arg_1)
```

The encoded direct call at 2609062 names `$direct.p140e_arg`; the final encoded
call at 2609170 names `$direct.Bool.and`. The worker still saves continuation
state, calls `p111_rt_frame` at 2609138 and combines results during unwind.
It should not be described as allocation-free, a single tight tail loop or a
new short-circuit transformation.

## Interpretation and next gate

The intended code-generation change is present; its generality is narrower
than removing all scheduler traffic from structural equality. Actual compiler
request timing must decide whether this saved dispatch outweighs code growth
or layout changes. Original final verification remains independent.

If the speed result is small, inspect dynamic time in the remaining mutual
scalar/list and statement/list scheduler regions before adding more specialized
helpers. A bounded first-order comparison worklist could remove that control
boundary, but would need its own evaluation-order, ownership and stack-safety
argument. It is not implemented or justified by this static evidence alone.

For reproduction, match complete QBE function headers, decode numeric `FID_`
components as character codes, then inspect the specific bodies above. Public
trampoline exports and local `p113d`/`p114r` workers are different functions;
counting only public headers would miss the direct `p140e_args` worker.
