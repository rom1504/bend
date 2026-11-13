# Experimental integer/F32 region coexistence

This prototype permits unrelated XMM values to remain resident across ordinary
scalar integer statements. It does not rename values, reorder instructions,
change floating arithmetic, or extend lifetimes through calls/control flow.
The implementation is 93 Bend lines, plus 74 lines of data-only controls.
No production module was edited and no compiler/target job was run here.

## Integration and controls

Include `float-regions-experimental.bend` in a candidate checked source and apply
`float-regions-integration.patch` only to that experimental source. The one hook
replaces the allocator's `x186_x_homes` implementation with `x192fr_homes`; frame
placement and all machine emission remain untouched. The original `x186_x_scan`
is deliberately retained as a separately callable baseline.

Include `float-regions-controls.bend` and export `p192fr_controls`. It returns 24
ordered `=1` rows. The first five require a float value to span an integer
operation while the independent original scanner excludes it. The rest cover
every ordinary operand/result role, canonical-copy retention, stale canonical
metadata after mutation, calls, allocation, backedges, returns, branches and
unsupported integer operators. These are allocator/data controls only; actual
emission/runtime checks remain a separate gate.

## Clobber and canonical-value audit

The whitelist is Set/Load/Store over U32/U64/Ptr, Offset, and supported U32/U64
Bin arithmetic/comparisons. `x181_alu` and `x181_condition` reject unsupported
operators (including div), so their future implementations do not silently
inherit permission. Existing scalar paths in `scalar.bend`, `physical-moves.bend`
and `register-binary.bend` use only GPRs, memory and flags. They do not call a
helper or write XMM registers. Shift selection can write RCX; this is harmless
to XMM homes and remains governed by unchanged GPR allocation. Loads/stores keep
their exact order and addresses, and no frame slot or memory operation is moved.

All local operands and destinations of admitted ordinary statements are marked
`X185TBlocked` globally, including reads. This prevents the existing GPR-only
emitter from reading a stale GPR home of a value promoted into XMM. Every write
also clears that name's `X186Canonical` marker, so a later U64 copy cannot treat
an arbitrary full-width integer as a low32 canonical word. Proven canonical U64
copies retain their existing XMM-aware emission and inclusive interference
endpoints. Ordinary noncanonical U64 copies instead block both input/output.
Unrelated canonical facts survive; calls, allocations and all control/terminal
boundaries retain original cuts and metadata resets. Parameters/setup exclusions,
14-home pressure behavior and inclusive range reuse are unchanged.

## Actual numeric recurrence ceiling

The supplied file is actually
`selfhost/build/phase192/diagnostic01/coverage-numeric-recurrence-256/preselection.json`.
Its `$direct.p37.numeric` worker reuses the virtual name `value` for F32 operation
results, a U32 multiply and the final U64 xor. That name remains globally barred
under this prototype. `p113p_move_31_0` carries recurrence state through Again,
so it remains excluded as well. `p113p_move_23_0` is an early floating temporary
whose useful interval already fits the original closed floating region.
Consequently the integer coexistence prototype is not expected to improve this
numeric worker by itself. A measured change needs an exact emitted diff; no
runtime gain is claimed. Separating differently typed definitions of `value`
would require an independently justified renaming/lifetime project.

The prototype may help other general functions with distinct float temporaries
separated by unrelated integer work. Its source cost and lack of a demonstrated
hot numeric benefit are reasons to keep it experimental until such a witness is
identified. Do not promote it just because the synthetic allocator controls pass.
