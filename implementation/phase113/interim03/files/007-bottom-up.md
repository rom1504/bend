# Optional bottom-up simplification experiment

The wide18 audit showed why a larger inlining limit alone was insufficient.
Inlining eliminated `cell.f3` inside its callers, but expanded the product
`cell` to 391 nodes, just above the 384-node policy. Its loop caller retained a
call to the entire cell. Across all 45 functions, direct IR nodes grew from 1,799
to 4,961; retained direct-call sites fell 35→20. These are structural counts from
`selfhost/build/phase113/wide-audit18`, not runtime measurements.

Instead of raising another limit, `bottom-up.bend` overrides only the completed
candidate hook. It keeps the existing 16 KiB stack rejection, then applies the
same operation-derived scalar simplification before eligibility/table insertion.
A smaller callee can then be reused and inlined by later callers. This composes
constant propagation with bounded inlining in the natural bottom-up order.

The initial policy remains 192 callee nodes, 512 caller growth and 16 sites.
Freshness, result-vector snapshots, scratch boundaries, topological calls,
input verification and final verification/rollback are unchanged. This is not
another traversal that might re-inline already reserved names. The final range
pass is retained because a caller's actual arguments may expose additional facts.

Append `bottom-up.bend` after `entry.bend` for the optional profile.
`audit-policy.bend` separately replaces the diagnostic reason helper so that it
asks the selected `p113i_eligible` policy instead of reporting a stale 192-node
cutoff. The generic `policy-limit` reason means a size/stack admission boundary;
actual node and stack counts remain in each audit row.

Root must check the composed source, rerun independent inliner and range
controls, inspect exact before/after audits, and execute the frozen semantic and
performance screen before drawing a benefit claim. No target runs by this agent.
