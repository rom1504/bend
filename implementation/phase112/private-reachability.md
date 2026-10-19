# Private-worker reachability opportunity

The facts full compiler contains **6,935 conservatively unreachable private
workers, occupying 3,179,317 QBE bytes**. Removing only those definitions could
avoid 6.83% of this emitted file. This is an offline opportunity measurement;
no QBE, production source, object or executable was changed.

| Facts full emission | Count / bytes |
| --- | ---: |
| Complete QBE file | 46,541,018 bytes |
| All functions | 35,753 |
| Nonprivate functions, all treated as roots | 28,421 |
| Private worker definitions | 7,332 |
| All private definition bytes | 4,178,858 |
| Reachable private workers | 397 |
| Unreachable private workers | 6,935 |
| Unreachable private definition bytes | 3,179,317 |
| Unreachable share of private bytes | 76.08% |
| Private exports / address escapes | 0 / 0 |

The input is
`selfhost/build/phase111/p112-facts-full-emit01/program.ssa`, SHA256
`15e95d0792ce4eb864cb2e3f6f4f2da36ca4b8f89c336433fb366f97ecd2345f`.
The small count/proof receipt is `evidence/private-reachability01.json`, SHA256
`1036b862a469f22844809d5a69c1b01746e00f21759e78f5c83fbadbbb3aae99`.
It pins `workers/inspect-private-reachability.py` and contains hashes of the
function ranges/bodies, direct-call graph, roots and computed reachable set.
It retains no transformed QBE or copied input.

The method roots **every nonprivate function**, regardless of observed execution
or descriptor reachability, and follows direct calls transitively. It also roots
any exported private function and every private-symbol occurrence that is not a
definition or direct call, including occurrences in data. All 22,669 private
symbol occurrences in this input classify as 7,332 definitions and 15,337 direct
calls; there are 12,967 distinct direct-call edges to private workers. All private
references resolve to definitions. Thus the estimate does not depend on dynamic
hotness, a restricted entry point or assuming that unobserved public functions
are dead. Byte counts cover each function header through its closing brace and
newline.

The source explains the excess. `region-multi/emit.bend` deliberately renders
every frozen registry entry through `p112c_private_chunks`. An admitted private
version is an available optimization target, not an automatic callee of its
public counterpart. `p112f_public` renders the original or fused public body
through `p112w_public_segment`; that path can emit its own self-tail loop or body,
and calls a private worker only at an actual selected call site. Descriptor
function addresses retain the public `$p111_...` entries. Consequently, retaining
all public functions does not itself retain all corresponding `$p112w_...`
definitions.

A narrow future source change would retain the complete immutable admission
registry, select public transformations as today, collect their actual private
dependencies, then close that set over **stored first-admitted private plans**.
The dependency walker must include both terminal `P112WorkerCall` nodes and
private `N111Call` nodes introduced by continuation fusion, plus any private
address value. It should filter only final private rendering, preserve every
public definition and metadata table, and never replan with a smaller ready set.
Independent controls should include a private chain, unreachable chain/cycle,
private address escape and a public fallback that makes no private call.

The upper bound here is roughly 3.18 MB of avoided rendering/backend input,
leaving about 43.36 MB. It does not explain the full growth from the earlier
28.46 MB profile, prove proportional allocator savings, or predict execution
speed. Planning work may remain unchanged even if these unused definitions are
not rendered. A separately admitted implementation and matched measurements
would be needed for those claims.
