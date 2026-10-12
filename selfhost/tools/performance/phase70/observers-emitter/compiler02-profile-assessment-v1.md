# Compiler02 observer compilation cost

The four completed `compiler02-profiles01` requests justify testing P70-008,
but do not show that all observer overhead is removable. No compiler or native
target was executed by this analysis lane. The two reducers ran serially on
CPU0, pin their input summary and exact V8 profiles, and save all attribution
in `compiler02-observers-v1.json` and
`compiler02-observer-contexts-v1.json`.

| Instrumented request | Request clock ms | Named observer union ms | Plan union ms | Typed analysis union ms | Adapter union ms |
| --- | ---: | ---: | ---: | ---: | ---: |
| Numeric B1 | 2707.789 | 251.667 | 17.193 | 108.903 | 69.254 |
| Numeric B2 | 1760.567 | 69.130 | 43.622 | 21.216 | 20.457 |
| Array B2 | 1765.292 | 68.237 | 34.594 | 10.965 | 21.425 |
| Lexer B2 | 2168.929 | 54.922 | 26.806 | 11.069 | 19.203 |

These columns overlap. Each sample contributes once within a family; the
columns must not be added. B1 trampolines hide some caller names, so its plan
union is especially incomplete: analysis legitimately has more named samples
than the named plan entry. Its `no_route_names` inclusive union still captures
248.441 ms. Zero named samples also do not establish zero work. These are
instrumented profiles, not clean measurements or confidence intervals.

The adapter has a clear B2 source cost: `no_wrapper_nodes` calls
`nc_field_count`, which calls recursive `nc_find_ctor` across the book to
validate the wrapper constructors. The latter two functions each account for
16.212/17.706/15.852 ms under wrapper validation in Numeric/Array/Lexer B2.
Ordinary lowering of the accepted adapter is retained too. B1 has 33.564 ms
under `no_adapter_lower`; nested `nc_prepare_env` contributes 23.243 ms and
`nc_uses_list` 19.560 ms. These figures overlap and include implementation
effects of B1's different generated JavaScript, not extra semantic work.

The plan front end repeats arity work even though the entry index already
knows arity. `no_plan_checked` checks `nd_arity`, and `no_schema` checks it and
passes it again to `nol_params`. Under the route, B2 `nd_arity` contributes
12.698/13.274 ms for Numeric/Array; source inspection identifies this as a
possible later cleanup, not a measured removable estimate. A larger indexed
constructor/layout refactor is not justified by this small sample alone.

## What P70-008 can and cannot remove

The pinned `compiler02-ready-eligibility-v1.json` reads all three emitted C
files. Each contains exactly one borrowed observer, `String.cmp`; the ordinary
NF worker for that owner is absent. P70-008 therefore preserves the only
emitted observer in these three compiler benchmarks. It can avoid analysis of
ordinary-ready candidates which currently fail observer admission. It cannot
remove the successful String comparison plan, its constructor validation, its
ordinary wrapper lowering or its generated code.

This makes the first causal check particularly clean: every arm must emit the
exact qualified Numeric C. The root's prospective saved-API factorial compares
compiler02, occurrence rollback, the ordinary-ready skip and both, in real B1
and B2 images, using four balanced rotations (32 requests) after eight fresh
Base preparations. Saved image substitutions have exact original bytes,
reverse recovery and commutation proofs. These are diagnostic artifacts; a
new source build and broad checks remain necessary before shipping a policy.

The skip adds an existing linear `nb_contains` traversal for each eligible
owner. It may cost more than the cheap schema failures it avoids. Moreover,
ordinary-ready owners can still have scheduler callers, so the policy can
forgo runtime improvements outside this Numeric case. The earlier Map/String/
Tape retained-path audit reduces that concern for the measured motivating
families, but does not prove general dynamic coverage. Select only after a
useful measured main effect; preserve the exact old routes otherwise.

There is no basis here to call the full 251.7/54.9–69.1 ms redundant or to
promise a corresponding whole-compiler gain. If P70-008 is negligible, the
next clean investigation is a narrow validated arity/constructor lookup reuse,
with exact output and unchanged malformed-plan refusal, rather than removing
proof checks or extending the observer backend.

## Why Numeric, Array and Lexer retain String comparison

This is a real source dependency, not evidence of accidental whole-Base
emission. All three `phase46/*-batch.bend` wrappers read command-line counts
with `IO.args` and `Nat.read`. The Numeric chain is:

```text
main → p46.arguments → p46.number → Nat.read → Nat.read.fits
     → String.is_le → String.order → String.cmp
```

Pinned Base source `base.bend` SHA256
`99ac43f2b2bb3e3f39acdcedcecbbd3cb44749ce13969c827d6973fa66f7facf`
defines `Nat.read.fits` at line2209. It compares against
`"281474976710655"` through ordinary eager `Bool.or`/`Bool.and` arguments.
Thus even a short count does not statically remove the string-comparison
dependency. `String.is_le` calls `String.order`, whose body projects the scalar
from the root-preserving comparison. Array and Lexer use the same
`p46.number(Nat.read(...))` wrapper pattern.

The native host driver uses `reach_book` to select runtime annotations, then
`nc_annotated_context` restores the original type-level context needed by
layout checks. Native `nc_live_names` independently follows erased references
from `main` for emission and observer candidate names. There is no demonstrated
unused-Base-emission defect here. A hypothetical inter-request cache of verified
Base plans is a different design requiring explicit context and permission
validity; these profiles do not justify introducing it during this phase.

## Completed factorial: keep the existing observer policy

The root completed all 32 clean Numeric requests, after eight fresh Base
preparations, with exact qualified C in every arm. Full retained data are in
`selfhost/build/phase70/compiler02-factorial01-summary.json`; the execution
plan SHA256 is
`747edf83b39f5a56ede3d717bcb62a587de06024a2866a3ee818aca1ca069070`.

P70-008 is **not selected**. B2 skip/base median ratios are 0.99787 with
occurrence insertion and 1.00069 without it. The corresponding geometric
means of paired round ratios are 1.00501 and 1.00732, and the skip wins only
one and two of four rounds respectively. These differences do not establish
a useful gain. B1's apparent 5.4% median improvement in one contrast is
dominated by inconsistent slow requests and does not reproduce across the
factorial or in B2. Preserve all timings instead of selecting a favorable
aggregation.

The sampled observer cost remains real; the causal result shows that this
particular ready-list guard does not profitably remove it. Root is separately
removing occurrence insertion in checked03 after its 2.22% B2 median penalty
and four of four slower rounds. The observer skip stays unapplied, and all
proposal/source-image artifacts are frozen. Reusing verified wrapper layout
facts remains a future idea only; no more observer optimization is planned
for this phase.
