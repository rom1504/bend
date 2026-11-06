# Retained full-profile caller coverage

2026-11-06; offline inspection only. No profile/target rerun or profiler rewrite.
The existing `attribute.py` successfully joined the retained candidate full
capture, caller/context sidecars, exact libc unwind table and current owner map.
Receipt pairing, all 46,151 FID bindings and 60,929 function symbols validated.
This binding establishes addresses/metadata; lexical ownership remains
conditional on the recorded emitter contract, not proved logical ancestry.

**The existing caller data cannot assign the large lifetime/product costs to
compiler owners.** Its ten CFI ranges cover only 1,130 bytes of the pinned libc;
there are no runtime-helper unwind rules in this capture.

| Retained observation | Samples | Fraction of all 5,358 |
| --- | ---: | ---: |
| Eligible/recovered/symbolized physical callers | 227 | 4.2367% |
| Unsupported/unknown physical callers | 5,131 | 95.7633% |
| Recovered caller is `p111_set_regs` | 227 | 4.2367% |
| Recovered caller is a generated compiler worker | 0 | 0% |
| Dispatch context without a lexical owner | 2,865 | 53.4714% |

All recovered addresses are `0xd78066` in this diagnostic ELF, immediately
after the call to `memmove@plt` at `0xd78061`. Direct disassembly confirms the
mapping. The source operation is
`memmove(state->regs, values, count * sizeof(uint64_t))`
(`selfhost/src/runtime/qbe/runtime.c:3984–3987`). Thus the formerly unnamed libc
leaves are register-transfer work, not an unidentified compiler algorithm.
Adding the 120 samples whose physical leaf itself is `p111_set_regs` gives
347/5,358 = **6.4763%** for these two disjoint physical locations. This is not a
prediction that all register transfer can be eliminated, or a clean cold-build
time decomposition.

Of the 227 recovered callers, 108 also have no lexical dispatch owner. The
others retain their already-known outer dispatch context; the largest is
`nc_uses_list` with eight samples. Those contexts are not newly recovered
inclusive owners. Private synchronous work can run beneath an outer dispatcher.
There is no recursive-runtime caller distribution to interpret here: the table
never unwinds a runtime leaf in the first place.

The unresolved physical costs include `term_drop`609 samples, `span_fade`362,
`p111_rt_sink`195, `p125_rt_take2`224, `ctr_take`124 and `p125_rt_take4`96.
Their source callers and ownership origins cannot be recovered retrospectively
from these sidecars. More analysis of this existing caller stream will not fill
that gap, and the nearly complete borrowed-selector promotion coverage gives no
reason to spend another iteration merely loosening its guards.

For a future bounded measurement, first prepare supported CFI rules for selected
hot runtime functions in the **current diagnostic ELF**, reusing retained
objects. Check whether one physical frame reaches a generated worker; if it
only reaches another runtime helper, preserve that result rather than calling it
a compiler owner. A bounded second-frame extension would need its own validated
CFI/stack-read contract. Such a focused capture could identify which producer,
traversal or continuation family warrants a structural change. No ≥30% gain or
specific large optimization is justified by the available caller evidence yet.
No new capture is requested as part of this cycle's close.

## Reproduction and identities

The metadata-only join used:

```python
import sys
sys.path.insert(0, "selfhost/tools/profiler")
import attribute
base = "selfhost/build/phase171/candidate-profile-full01/000-sample-full-candidate-n1-staged/"
report, events = attribute.attribute(
    base + "analysis.json", base + "callers.txt",
    "selfhost/build/phase161/profile-prep04/unwind/table.json",
    base + "contexts.txt",
    "selfhost/build/phase171/candidate-profile-prep01/owners.json")
```

| Input | SHA256 |
| --- | --- |
| `candidate-profile-full01/report.json` | `df232e2b9f6316532612b5175e80117678cf57c4ff7eeb7080aba3891c02ac87` |
| Ordered `callers.txt` | `ed0ab11ffe1bab92386039500238b03b6d0e205f416b2d2f659e688844149a97` |
| Phase161 retained unwind table | `c7245df4732c0b4c8212f9e715e0733aec602c42765fb348e5a65b9c57ab49b5` |
| Pinned libc object | `d13f170ab30a0f91d9713e0c2196efa5fe0bc42f0f2737cf0e56380df8051159` |
| Maintained `attribute.py` | `4728b9a8175087ff0159c4bc59a0575ffa37838b00be0fc83bbac356610916da` |

The profile remains usable: 5,358 samples, zero loss and about99.34% process-CPU
coverage. That capture quality does not broaden its limited caller coverage.
