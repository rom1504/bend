# Phase193 public fusion / ready tail pilot

Status: experimental implementation and source data controls; root owns source
checking, compilation, actual-runtime observations and performance. No production
module or installed image was edited by the implementation agent.

Append `public-fusion-experimental.bend` to the canonical x86 module inventory,
apply `public-fusion-integration.patch`, then assemble the ordinary selected
source closure. Do not splice the new module into the old Phase192 selected
closure: that closure omitted the now-needed original shared planner definitions
`p112c_plan_index` and `p112w_public`. The canonical compiler.json module universe
already contains their owners; reachable dependency selection should include them.
The hook changes only x181_program_public's existing H consumer call. Its
mode=0 and complete-direct exclusions stay unchanged.

The adapter consumes exact existing planner output, without changing semantic
admission, metadata, source recognition or runtime code. Four ablations are
independent literal Bool variants of x193f_fusion_enabled/x193f_tail_enabled:
(0,0), (1,0), (0,1), (1,1). H remains first, using its original ready set and
original planner, including its existing emission failure behavior. Generic
mode and complete-direct public workers retain their old route.

`p112c_plan_index` retains its original eight-copy bound and hygiene/closure
rules. Its N111 result is used without reconstructing the capture/gap/argument
ordering. Only p112w forwarders already present in x181_cursor_index are callable;
missing symbol, generated-name collision or emission refusal rolls back the
whole original segment. This pilot deliberately leaves unavailable legacy
workers unavailable. x193f_tail mirrors the original p112w_public_segment
result=1/flags=0 gate and p112t direct-loop precedence. It translates only
Scalar/If/Call nodes and explicitly refuses private Again/Result.

Ready public tail transfer snapshots all scratch arguments, calls the existing
ready helper, stores its result, calls p111_rt_return and returns that status.
It cannot use a plain native return because the caller may have a pending Bend
continuation. Newly generated p193f_ names are checked against definitions and
all local uses, including branch conditions, addresses and call arguments.
The original N111 final verifier remains a prerequisite, not replaced by these
checks. These factories are not arbitrary unverified-IR admission APIs.

## Exact retained compiler witnesses

Same-source Phase192 N1 is `native-image01/program`; N2 is
`native-self01/program`. Their source identity is compiler.bend SHA256
301435947ae813b64eebaf30610d2be4aa3be5b7ddd772bd0e68f1b6aac48c20.
Read-only ELF inspection establishes:

| Public owner | N1 ready calls in public body | N2 public body |
|---|---|---|
| $direct.index_leaf | $direct.dn | keep then scheduler jump |
| $direct.index_remove | $direct.dn | original ownership then scheduler jump |
| $direct.p111v_put | $direct.atom twice; $direct.index_hash once | keep then scheduler jump |
| $direct.p131i_insert | $direct.index_split_bit twice | corresponding scheduler paths |

All four distinct target names have actual p112w forwarder symbols in N2. No
benchmark/source-name recognition appears in the implementation. The difference
is a missing general lowering route: QBE p134e_public→p124r_public fallback calls
p112c_plan_index followed by p112w_public_segment; x86's H refusal emits the
original segment. The N2 code is not missing its private helper implementations.

The related same-request physical profile estimates work_loop 0.0863→0.1770 s,
rt_return 0.0181→0.0544 s and set_regs 0.0225→0.0506 s. The dispatcher has36/75
samples; return/set_regs leaves have only8–21 samples, so low precision remains.
No leaf-time difference proves a changed invocation count or predicted gain.
The p114r ELF set difference is only three unsampled owners; broad R/G/extended-H
integration is not selected by this evidence.

## Initial finite fixtures

Append public-fusion-controls.bend and export x193fc_controls/x193fc_emit for a
checked hosted API. Controls21 use the original p111v_segment and planners:
original acceptance; fusion count; disabled retention; one ready call; removed
frame/jump; retained public return; missing-target refusal; reserved definition
and read refusal; self-tail, flags and multi-result fallback; private-node refusal.
These are finite structural controls, not independent runtime observations.

x193fc_emit(fusion,tail) emits original public fixture entries plus one exact
private helper. Source segment FIDs are owner0, continuation1, helper2, tail3.
The owner captures 0x100000007, then passes 0x20000000b to helper(x)=x+1;
the continuation adds the captured word. Expected owner result0x300000013,
plain-tail result0x20000000c. The direct helper uses the normal state-leading
one-result ABI; the generated public return must preserve pending caller state.
The independent audit agent owns stronger mutation-gap and real-runtime controls
under separate ready-fusion-controls names. No test result is implied here.

First structural falsifier: selected transformed real owners must contain the
expected ready calls and fewer complete scheduler transfers, while H/direct
owners stay on their prior route. Then require actual compiler-request transfer
and unrelated user-workload benefit before paying full qualification cost.
