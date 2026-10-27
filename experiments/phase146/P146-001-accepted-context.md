# P146-001 — retain accepted raw context through final checking

Status: designed, implementation and measurements pending.

Hypothesis: the ordinary pipeline can avoid the Phase145-proven duplicate
raw/static judgment and original metadata reconstruction by retaining its
existing immutable `P114SBoundary`. Recheck actual transformed direct bodies
and namespaces independently, preserving full public verifiers and all rejected
boundary/error fallbacks. No new persistent cache or IR representation.

[Design](../../design/phase146/README.md) ·
[Evidence motivating the experiment](../../research/phase145/architecture-decision.md).

First falsifiers: exact error/order controls; complete frozen QBE equality;
whole-request native cost after a useful cheap checked-source screen. Public
acceptance and independent verifier obligations must not weaken for speed.
