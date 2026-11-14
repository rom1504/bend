# Phase194 current edit-distance predicate witness

Offline inspection, with no target execution. The authored experiment is
`selfhost/tests/phase194/predicate-{select,hook,controls}.bend`, its independent
C observer/driver, and an unapplied integration patch. It is not yet validated.

The current version uses the `predicate-select-v2` and `predicate-controls-v2`
files with the original hook. The root-owned diagnostic subsequently confirmed
that each targeted comparison is followed by an empty If on that predicate.
V2 admits precisely this no-effect row and accounts for its extra condition
read; unrelated conditions refuse. Offline metadata inspection finds all three
row corridors in both actual preselection bodies satisfy the structural/use
conditions. Checked matcher execution and machine coverage remain root-owned.

The current qualified products are Phase193 `budget-native45-02`, matching the
budget selection rather than the earlier uncapped candidate. The actual fast
worker is `p113d_FID_36_112_114_111_100_117_99_116_46_114_111_119_` (`$product.row`).
Do not confuse it with the substantially larger `p117v_` fallback of the same
decoded name. Local-pair's fast worker starts at 0x40c961 and editdist's at
0x40c966. Each has 314 total instructions; these totals include setup, exit and
fallback. The local-pair binary SHA256 is
`01eea34af5950c9e9c9defb3d59e6e4de9924cbf81430378dd2952718b5b654d`;
editdist is `db7a102244d704cfbe8f94774fbdbd8c64c4854ce2a34d3da4b62b0b2aa7db64`.

Local-pair's continuing cell loop has three materialized predicate/select chains:

* 0x40ce09 compares two symbols, creates `setne`, zero-extends, copies, xor1,
  loads 0/1, retests and cmovs, then stores the cost at -0xa88(RBP).
* 0x40ce9e compares the first two min candidates; `setb`, zero-extension,
  copies, TEST and CMOV follow through 0x40cebe.
* 0x40ceeb compares that minimum with the diagonal+cost; again `setb`,
  zero-extension, spill/reload, TEST and CMOV through 0x40cf1a.

The fixture source's general `umin`/`umin.go` and `b2u` definitions explain these
chains. They execute in the cell recurrence over the 256×256 grid. Historical
Phase191 profiling attributed 98.94% to this row worker, making it a strong
dynamic candidate, but that percentage was not measured on the current product.
Editdist/local-pair are the same algorithm and are not independent families.

The retained QBE reference from
`phase186/release-native45-acquire01/local-pair/phase186-qbe-n2/machine/program`
has the corresponding 176-instruction worker. Its two minima are immediate
`cmp; cmovae` pairs at 0x408f7d/0x408f80 and 0x408f92/0x408f95. It still has a
less direct cost predicate. The C reference's measured hot region is inline in
`NF_FID_pair`, not its standalone row helper; the Phase191 exact profile binds
that 26-instruction inner loop. Current QBE/C references are older backend
products pinned by the Phase193 runtime manifest. They are comparison witnesses,
not same-source compiler implementation measurements.

The source gap is specific. `x191_select_plan` already proves effect-free copy
arms, but `x191_select_emit` receives only a materialized Boolean and snapshots it
into RAX before TEST/CMOV. `x190_branch_step` consumes only immediately adjacent
compare/If pairs. Width/copy/complement rows separate comparisons from uses.
`x192_predicate_body` folds known 0/1 result diamonds but cannot carry arbitrary
comparison operands into the final select. A general SSA project is unnecessary
to consume this local pure corridor.

The experimental consumer keeps the original allocation as the low-risk first
step; existing global branch read/protection facts plus a bounded corridor count
establish that eliminated predicate locals have no other consumers. It preserves
original compare operand values by refusing all operand writes and keeping CMP
at the producer point. It preserves selected-value aliases by snapshotting both
inputs before output publication. It changes no effect ordering or runtime ABI.

The first falsifier is exact machine coverage on the current row body, followed
by ordinary unrelated select-heavy scalar/control workloads. If retained
allocation still spills obsolete intermediates, the existing
`x191_placement`/`x191_ordinary_facts` separation supplies the next shared metadata
boundary: allocation and emission must use the same checked selection plan.
Do not suppress liveness reads using a separately implemented approximation.
The current experiment intentionally does not claim those placement benefits.

Reuse Phase191 conditional-select shape/machine controls and Phase190
comparison/reuse controls in addition to the new finite observer. Full SSA,
cross-branch equality, heap alias analysis, loop hoisting and String-specific
rules are outside the slice. Static instruction differences cannot price its
runtime gain; the root-owned lane must inspect and time actual output.
