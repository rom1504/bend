# Static emitted-module identities for checked06

[Exact identity report](../../selfhost/build/phase40/module-identities06.json)
binds the Phase39 portable manifest and both complete45point checked candidate
preparations. Source and fixed-point metadata agree across compared roles;
these are hash observations, not execution measurements.

| Comparison | Identical points | Changed points | Changed source files |
|---|---:|---:|---:|
| checked05 → checked06 | 42/45 | 3/45 | 2 |
| phase39 → checked06 | 30/45 | 15/45 | 8 |

Checked05→06 changes only raytrace and its two active-ray points, across two
source files. The typed Nat/data-result restriction restores those checked06
modules to Phase39 bytes. The other42points preserve checked05 modules exactly.
Against starting Phase39,30points have identical modules and15points change.
Timing shifts on the30same-byte points cannot be attributed to changed compiler
emission. Shared inputs/source files and generic-row adapters are different
counting units; module byte deltas must not be summed per input as new code.
No runtime gain follows from this static comparison alone.
