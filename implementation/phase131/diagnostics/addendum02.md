# Closed diagnostic addendum 02

[addendum02.tar.gz](addendum02.tar.gz) adds **262 files / 55,340,903 raw bytes**
in **12,114,804 compressed bytes**. Its SHA-256 is
`723a2362ef78168be55382ecd9704620d8f765d17de73c17ec13c910b16d35a8`.
Every new member was reopened and matched its size and hash. Eleven unchanged
members are reused from the [first capsule](README.md). Selected reused source
files were rehashed, while the first archive’s individual members were not
reopened or overwritten. The parent archive and inventory identities were
checked and joined to the original receipt.

Both compressed archives total **16,983,175 bytes**, below the combined 20 MiB
limit. [The addendum receipt](addendum02-receipt.json) pins all outputs;
[its inventory](addendum02-inventory.json) records the exact frozen plan, new
members, reused members, exclusions and declared dependencies.

| Later evidence | Readable exact copy | Scope |
| --- | --- | --- |
| Full-source context-only profile | [addendum02-full-context.json](addendum02-full-context.json) | 11,852 samples from the diagnostic final-N2 relink; counters off, no clean baseline or new speed ratio |
| Scalar selector query ceiling | [addendum02-selector.json](addendum02-selector.json) | Four pilot observations and twelve calibrated observations, distinct from compiler-wide timing |
| Two bucket-fusion laws | [addendum02-bucket-laws.json](addendum02-bucket-laws.json) | Exact source-value equivalence; does not establish full-tree lookup, native ownership or code-generation correctness |
| Same fused source, wider producer | [addendum02-wide-selector.json](addendum02-wide-selector.json) | Twelve matched query timings plus two ordinary 34-line output gates; no whole-compiler gain or native qualification claim |

The full-source profile includes raw samples, active contexts, resolved
attribution and timeline. It reuses the original exact owner map. There is no
new CFI caller capture and no event-counter run. Active dispatch ownership is
neither a source-call stack nor an allocation-origin trace; sample fractions
must not be added to the separate physical-profile fractions.

The selector evidence includes calibration plans, pilot and calibrated outputs,
static inspection, ordinary qualification receipts, fixtures, oracles and
methods. The later composition compares **the same fused source** under two
producer policies. It is not an extra source-algorithm optimization. The source
proofs and these proxy results are separate from the frozen qualified compiler's
admission; they do not retroactively enlarge its proof scope or modify the
installed compiler.

Nineteen newly selected large generated outputs or executable/object artifacts
are omitted with authenticated identities. The one-level evidence receipts also
retain 7,370 external/historical dependency pins as declarations. Those are not
a recursive rehash or a claim that all historical raw inputs are present. Exact
proof payloads and the directly referenced proof/tool receipts are retained;
this archive executes none of them.

## Read or unpack

Verify the compressed hash, then unpack into a fresh directory. The two archives
have no conflicting member paths, so they may share an empty destination:

```sh
mkdir /tmp/phase131-diagnostics-complete01
tar -xzf implementation/phase131/diagnostics/diagnostics.tar.gz -C /tmp/phase131-diagnostics-complete01
tar -xzf implementation/phase131/diagnostics/addendum02.tar.gz -C /tmp/phase131-diagnostics-complete01
```

Paths are relative to the original repository root. Preserved JSON contains its
original absolute paths; raw logs and resolved analyses are available for offline
inspection, while fresh target execution or symbolization needs the separately
pinned native images/system dependencies. This is an evidence bundle, not a
standalone compiler distribution.

The reviewed data-only sealer is
[archive-diagnostics-addendum.py](../../../selfhost/tools/performance/phase131/native/archive-diagnostics-addendum.py).
It authenticates the parent inventory through the original receipt, verifies
selected closed reports and input pins, reuses unchanged parent members, checks
the combined compressed-size bound, and reopens every new member. The original
archive and its immutable receipt remain unchanged.
