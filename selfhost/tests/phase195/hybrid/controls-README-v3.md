# Hybrid v3 syntax correction and controls

V1 and v2 remain frozen. V3 preserves the overlay algorithm and all18 expected
control rows while moving three matches to helpers whose arguments are already
computed:

- `x195_h_stmt_marked` performs the statement match after its caller computes
  the before/after/write mask.
- `p195h_point_marks` destructures generated point marks.
- `p195h_count_pair` compares the scanner and mark-traversal final positions.

These repair the source grammar's refusal of a match after local bindings.
The reviewed `x190_j_checked` override itself is byte-identical to v2; the
contract pins the new complete overlay and control files separately.

Use `checked-controls-argv-v3.json` with root's checked API03/source03 receipts.
The v3 driver authenticates `controls-contract-v3.json` and still requires
exactly18 ordered successful labels:5 installed-home and13 analysis assertions.
`machine-controls-plan-v3.json` supplies the separate expanded checked API and
existing joint/loop/register, call and float gate commands described in
`controls-README-v2.md`, using the v3 source modules. No existing fixture or
observer pin was changed.

Metadata extraction inspected all37 v3 blocks and found no remaining
top-level match after a local binding. V8 parsed the driver's executable body
after substituting imports/import.meta solely for parser checking; the driver
and checked API were not executed. Root retains source-checking and target
execution authority. The syntax correction is not yet a checked-source pass.
