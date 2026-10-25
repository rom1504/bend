# Phase140: the grouped-machine warm-build floor

This is a bounded source/retained-artifact audit. No compiler, assembler, linker
or generated program ran. Timing numbers are the actual Phase135 receipts, not
new Phase140 measurements.

## What the unexplained eleven seconds contain

The matched A-only replay is
`selfhost/build/phase135/machine-edit-replay01/report.json` (SHA-256
`a4dd36026cfbd0ed3342f44cd5654ef3f4f83324e37c68a31fdff3d42908bd91`).
Its nested machine report is
`machine-edit-replay01/machine/report.json` (SHA-256
`43475d0a76e3952fb44041c3e204269c1966b6ad9cee4ff0bb143ef00faf9c09`).
The independent cold counterpart is `machine-cold01/report.json` with its nested
machine report. All are preserved in the Phase135 evidence capsule.

| Recorded interval | A-only warm | Empty-cache cold |
|---|---:|---:|
| Complete replay | 15.979s | 38.906s |
| Explicit supervisor preflight | 1.604s | 2.240s |
| Other time outside nested machine interval | 1.935s | 2.108s |
| Nested machine interval | 12.440s | 34.558s |
| QBE/assembler/objcopy/link children | 4.846s | 17.918s |
| Nested machine interval minus children | 7.594s | 16.640s |

Warm child times are QBE 2.809s, assembly 1.556s, globalization 0.115s, and link
0.366s. Warm rebuilt ten groups and reused 56. The total non-child residual is
11.133s. Existing clocks do **not** identify all of it as hashing: it also
includes Python ELF processing, repeated sorting, report writes, FIFO transport,
supervision and waiting. A measured causal split would require a host-only
profile or instrumented replay. The larger cold residual is evidence against
attributing the whole warm residual to fixed authentication alone.

The conventional monolithic machine build took 14.699s at its guard boundary;
the cached replay's guard was 16.064s. These are comparable historical complete
machine observations. Neither the 4.846s child sum nor the cached-versus-cold
grouped gain is a demonstrated win over monolithic compilation.

## Concrete unnecessary work found

The most precise new finding is in
`selfhost/tools/performance/phase135/machine/elf-v01.py`, `compare`:

```python
expected = [dict(x, binding=1) if x['name'] in before['promoted'] else x
            for x in before['symbols']]
```

`promoted` is a **list**. Every symbol, including the many undefined symbols in
the dispatch/static-data object, performs a linear membership search. Counting
symbol names from retained ELF symbol tables and the authenticated promotion
receipts gives:

| Work in rebuilt objects | Warm ten groups | Cold 66 groups |
|---|---:|---:|
| Symbol records | 58,460 | 118,721 |
| Promoted names | 2,584 | 14,901 |
| List membership comparisons | 29,472,333 | 36,706,106 |
| Set membership probes for the same decision | 58,460 | 118,721 |

The data group alone has 49,491 symbols and 574 promoted definitions. It accounts
for **28,243,383** of the warm comparisons. The count is independent of symbol
iteration order; successful searches use the promoted-name position and misses
scan the entire list. This is an operation count, not a seconds measurement.

The new experimental `phase140/machine/elf-v02.py` changes only this membership
container to a set. It retains every allocated-byte, logical-relocation and
symbol-attribute equality check. The companion `elf-audit-observer.py` is ready
to authenticate retained objects/receipts, compare old/new acceptance and four
negative cases, and observe the audit cost without any machine tool invocation.
Because raw objects were deleted, it explicitly reconstructs the old local
binding view from the earlier qualified promotion receipt; it does not pretend
to have retained raw.o. At the time of this note, neither observer nor a modified
machine replay has run.

Other exact source costs remain:

- `cold-replay-v01.py:21–22,44` verifies 86 input rows totaling 348,877,087 bytes
  twice. The unique pins total 241,803,469 bytes. The same 107MB QBE oracle and
  three methods appear twice; deduplicating identical pins preserves the check.
- `objects-v01.py:30–34,89` acquires and then repeatedly verifies fixed producer,
  runtime, toolchain and method identities, plus the current source/oracle.
- `replay-v01.py` hashes each retained unit and the whole stream; the consumer
  hashes each unit and the whole stream again, writes every unit even on a hit,
  then reopens/re-hashes that unit at `objects-v01.py:75`.
- The above explicit loops alone process **at least 1,491,348,117 bytes through
  SHA-256** for a 107,059,557-byte payload. That counts repeated hash work, not
  physical disk reads, and excludes initial pin creation and object hashes.
- Every reused object is hashed on admission, again when its row is recorded,
  and again at final verification. Receipt hashes repeat too.
- Misses call `E.metadata` before and after globalization; metadata and comparison
  repeatedly sort long symbol/relocation dictionaries through
  `repr(sorted(record.items()))`. The current receipt is also rewritten after
  every unit and before/after every child. Neither cost has a separate clock.

Do not remove authentication wholesale. First deduplicate identical pins within
one verification epoch and retain authenticated fixed context within the
already supervised A→B session. Keep current-source checks, exact cache keys,
single-writer ownership, immutable object receipts and the final producer-status
join. An inode/mtime shortcut alone is not equivalent to content authentication.

## A fair set-only experiment has an identity trap

Phase135 cache keys include the **objects.py and ELF-auditor method hashes**.
Pointing the builder at elf-v02 changes that context and invalidates every hit.
Conversely, secretly running new code while claiming the old method identity
would invalidate the experiment's evidence.

Either rebuild the A cache under the new context, charging acquisition cost, or
make an explicit metadata-equivalence transition: authenticate old receipts and
objects, prove the sole auditor change, create fresh new-context receipts/keys
that retain the exact object identities, and record the transition separately.
Do not modify historical receipts or their frozen methods. The same current B
payload, A-only membership mask, flags and toolchain must be used in the replay.

Even an impossible removal of all 7.594s inside-machine residual would leave
**8.385s**, with historical tool work and outer overhead held fixed. Therefore a
set-only experiment cannot reasonably be expected to reach a five-second whole
machine replay. Its value is a cheap general host-audit correction and sharper
attribution, not a claim that it alone solves the warm-loop floor.

## Smallest later integration with compiler-owned render reuse

P140 already knows the typed cursor boundary, and authenticates reused payload
ordinals. A future version can attach the same small boundary view used in
Phase135, without parsing QBE:

- Private, legacy and public cursor pieces are complete function **bundles**;
  one public piece can contain several function declarations.
- Data header/body slices are incomplete until the empty-data closing piece.
- Main is a separate complete unit. The legacy-newline flag is independent.

Derive this metadata in Bend from the normalized cursor before calling the next
renderer step. Carry family and completion on both fresh and reused records;
validate them against the authenticated prior row on reuse. Do not infer them
from QBE text, emitted newline flags or the next cursor alone.

The host can mechanically group a bounded number of complete bundles, as before.
If a whole current group has the exact same ordered payload identities/lengths
and boundary metadata as an authenticated old group, reuse its object and its
existing full-group digest without copying/re-hashing the old text. Otherwise
assemble only that current group, hash it while writing and compile it. SHA-256
of concatenated bytes cannot be computed from child SHA values; reusing a known
group digest requires that exact ordered-vector match. Current global-data and
dispatch content must remain covered even if some pieces reuse.

The historical edit changed static placement and rebuilt the large data object.
A true same-shape numeric policy edit may leave that object unchanged, but this
must be measured with current emitted bindings. With the old ten-miss pattern,
4.846s of tools is already near a five-second target before host work. With only
one small changed group and unchanged data, the 0.366s historical link time
suggests considerably more headroom; no exact projected time is justified yet.

For a 35s total warm-loop goal, keeping a 14.7s monolithic machine stage leaves
about 20.3s for the compiler and transport. Reaching a verified 5s machine stage
would free almost ten more seconds. Prioritize the actual end-to-end compiler
measurement, then choose whether this extra integration is necessary.

## Qualification boundary

Maintain exact loaded ELF sections **and addresses**, ELF/program headers, BSS
sizes and entry point against a separately cold build of the *same current
partition*. This proves cache reuse did not alter that partitioned image. It
does not prove equality with a monolithic image: object ordering, visibility,
section alignment and final layout can differ.

Keep separate monolithic-versus-partitioned semantic checks and timed compiler
requests; the generated compiler's runtime is a metric too. Preserve branch
alignment, runtime/toolchain/flags, static dispatch tables, indirect references,
closed-image symbol-globalization policy and independent final semantic gates.
Only after a bounded real edit improves complete machine time without adverse
compiler-runtime changes should a broader native qualification be purchased.
