# Offline descendant guard analysis

`tools/analyze-descendant-guards-v2.py` is the policy-aware successor. The
original analyzer and its source11 evidence remain unchanged. Both read existing
root-owned observations; only read-only `objdump` is executed by the analyzers.

Always supply the policy explicitly and a fresh output prefix:

```sh
python3 -B experiments/phase171/tools/analyze-descendant-guards-v2.py \
  --report selfhost/build/phase171/descendant-verifier-guard-plan15/execution/report.json \
  --policy result-or-rfc --out FRESH_OUTPUT_PREFIX
```

Use `--policy legacy` for the older source11/13/14 result guard, even when its
diagnostic counter records RFC bits. Counter version and compiler policy are
independent: `descendant-find-guard-plan14` used source13 machine code with the
newer bit-classifying counter. It still has zero promotions. Its checked offline
result is [guard-coverage-find13-rfc-diagnostic.json](guard-coverage-find13-rfc-diagnostic.json).

The tool validates report completion, exact stdout/empty stderr, input and
object/runtime/ELF identities, zero counter loss, and consistent counter bounds.
It maps call return addresses against **that diagnostic fixed-address x86 ELF**.
It then checks the reviewed frozen Bend wrapper/helper identity and the complete
emitted QBE wrapper, including root arguments, reader branch, exact four RFC
operations, fallback, keep-before-drop and returns. Unsupported variants refuse
rather than guessing a policy. Source-helper hashes normalize whitespace only.

Counts are interpreted as follows:

| Quantity | Derivation |
| --- | --- |
| Root declines | root calls − root passes |
| Reader declines | root passes − result-guard calls |
| Legacy promotions | result-guard passes |
| RFC-policy promotions | result-guard passes + failedFirstRfc |
| Result declines | result-guard calls − promotions |
| Owned fallbacks | root calls − promotions |

The last two RFC sets are disjoint: `failedFirstRfc` counts only old-guard
failures whose first argument has bit63. **Promotions are derived from exact
policy/control flow and counters, not separately instrumented keep calls.**
The table retains old guard passes independently. RFC bit classification does
not read heap counts; count1 follows only under the valid-state argument in
[result-guard-delta-audit.md](result-guard-delta-audit.md).

Offline validation checked source11/source13 legacy and source15 RFC wrappers;
all three reject the opposite policy. Three source15 QBE mutations also refuse:
wrong RFC mask, OR changed to AND, and bypassing the reader-decline branch. These
are analyzer metadata controls, not Bend/native correctness tests. One initial
validation command referenced a nonexistent `descendant-find-emission14` path;
it failed before analysis, and the rerun used the actual source13 predecessor.

The v15 verifier diagnostic shows 165,120 calls, zero root declines, 768 reader
declines and 164,352 derived promotions: **99.5349%** of entry calls. Of those,
65,280 pass the old result guard and 99,072 use the additional RFC permission.
Only 0.4651% use the owned fallback. Root-admission relaxation therefore has no
coverage benefit on this workload. See the exact
[v15 observation](guard-coverage-verifier15.md); this is not a timing or whole
compiler speed prediction.

Frozen analyzer SHA256:
`e413fd17800c1a6508f48601454d3c954c64e650609094d54b306f4e0c07a41a`.
Every generated JSON also pins the analyzer, source, QBE, diagnostic binary,
counter input and retained guard-caller disassembly.
