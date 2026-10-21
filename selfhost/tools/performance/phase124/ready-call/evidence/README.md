# Ready-resume emission evidence

This is static extraction of root-produced, retained QBE. `inspect.py` reads text,
decodes FID names, resolves continuation IDs against `p111_segments`, and records
exact input SHA-256 identities. It does not run any compiler or target. Reproduce
with `python3 selfhost/tools/performance/phase124/ready-call/evidence/inspect.py`.
The two `.ssa` excerpts preserve original symbols and identify source lines.
`report.json` also records the complete reachable private-call closure.

| Ordinary case | Candidate private owner | Closed continuation cases | Parent static runtime jump sites | Candidate private jump/return/apply sites |
| --- | --- | ---: | ---: | ---: |
| list | `p114r_$direct.parcel.collect` | 2 | 3 | 0 |
| tree | `p114r_$direct.archive.collect` | 4 | 5 | 0 |

Parent counts include its generic owner and precisely the continuations absorbed
by the candidate table, not whole-program counts. They are **static call-site
counts**, not execution counts or timing. Old continuation exports remain in the
candidate file for original graph identity/fallback; their textual continued
presence does not imply this private owner dispatches through them.

The parent controls already invoked ready `p112w_$direct.parcel.turn` and
`p112w_$direct.archive.stamp` helpers in a fused segment. They nevertheless
returned through generic continuation jumps. Thus this experiment tests the value
of local resume, not merely direct-call syntax.

The new list worker calls `p113d_$direct.parcel.turn` and
`p113d_$direct.parcel.join`. The tree worker calls
`p113d_$direct.archive.stamp` (two static sites) and
`p113d_$direct.archive.join` (two). Every argument is loaded from preserved scratch
stores into U64 locals before the native call. Ready results go to
`%p114r_value` then `@p114r_unwind`. Own recursion rebinds snapshotted arguments and
jumps to `@p114r_descend`; there are no native owner reentry calls. The full private
closure consists of the owner, the two helpers, and the join helper's TRMC worker;
none calls back into the owner or uses scheduler jump/return/apply.

Public ABI wrappers retain their register read and one `p111_rt_return`. Ownership
work remains: `take`, constructor creation, TRMC extend/finish, and failure paths
are not removed. Frame/capture stack traffic also remains. The list private worker
contains one `p111_rt_frame` call in a renamed continuation case; tree contains
three. Entry frames inline, but these case buffers do not match the current
`p114t_buffer` factory-name recognizer: it accepts `scratch`/inliner buffers and
`p112f_0..7_local_scratch`, whereas `p114h_buffers` emits exact
`p114h_case_0..7_local_scratch`. A separately measured, narrowly authenticated
extension of that recognizer could reuse existing frame templates; this record
contains no such optimization.

Root reported checked source acceptance, all seventeen pure predicate controls,
and both independent ordinary complete-output controls passing. Those are root's
execution results; this subtask's independently retained contribution is static
mechanism and identity evidence, not additional execution or a speed claim.
