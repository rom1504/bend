# Native self-emission: retained timeout and exploratory prefix

The native B1 still has no successful native B2 self-emission. The unchanged
1,755,310-byte compiler source reached the 600.022 s guard with no C output or
compiler diagnostic. Peak RSS was 1,079,590,912 bytes and the available-memory
floor was 26.74 GB: this particular stop was a deadline, not an observed OOM.
The preceding eight live/cache gates remain successful and separate from the
failed self-emission row in
[`native-b1-nine-gates01/report.json`](../../selfhost/build/phase89/native-b1-nine-gates01/report.json).

## Qualification remains failed

[`partial-self02/report.json`](../../selfhost/build/phase89/partial-self02/report.json)
retains three serial captures of the same native image:

| Capture | Result | Samples | Overruns | Interpretation |
| --- | --- | ---: | ---: | --- |
| Normal Map, five requests | return 0; all five C outputs exact | 2,138 | 0 | Original complete analyzer passes |
| Map stopped after 3 s | intentional return 77 | 752 | 0 | Strict stopped reader passes; incomplete request sequence |
| Self source stopped after 60 s | intentional return 77 | 15,003 | 1 | Strict stopped reader rejects |

The self capture has an intact `END`, zero dropped samples, all three sampler
threads initialized, and no clock, disarm or thread-capacity errors. The one
overrun corresponds to 1/15,004 timer expirations, about 0.0067%. This is enough
to explain the exact rejection; it does **not** change the qualification rule.
Its guard ends after 60.142 s at 235,614,208-byte peak RSS. Five existing IO.now
marks show preparation ended and the first request started around 87 ms process
CPU. There is no completed request boundary or C correctness result.

Do not rerun merely to obtain a green profile. The incomplete data is useful for
choosing a small experiment, with its failure status retained. It cannot measure
full self-compilation time, establish pass totals, or prove behavior after 60 s.

## The actionable observation is shared String comparison

The explicitly unqualified
[`partial-self02-exploratory.json`](partial-self02-exploratory.json) contains
physical leaf PCs and bounded physical ownership return addresses. Of its
15,003 samples, `term_drop` has 6,059 and `span_fade` 4,625: together 71.21% of
this prefix. String append has only **two** leaf samples. The output-composition
work addressed earlier in Phase89 is not the main activity observed here.

| Physical owner of ownership work | Samples | Share of this prefix | Source correspondence |
| --- | ---: | ---: | --- |
| `spin_2` | 4,564 | 30.42% | `p88_string_eq`, including inlined `p88_string_eq_go` |
| `spin_95` | 1,411 | 9.40% | `dn`: extract a KDef's name |
| `WL_FID_HAS_NAME` | 508 | 3.39% | Linear String-list membership |
| `spin_1` | 422 | 2.81% | `tg`: extract a KTerm's tag |
| `spin_31` | 376 | 2.51% | `dk`: extract a KDef's kind |

These are leaf ownership samples attributed through recovered physical return
addresses, not additive call-tree totals or predicted savings. `spin_2` itself
also has 804 leaf samples, and `spin_95` 289. Musttail-erased callers are not
reconstructed: in particular, we cannot assign all String comparisons to one
parser or checker algorithm.

The frozen Bend source starts with the consuming equality from Phase88. It
matches both linked strings, compares characters and consumes their tails.
Frozen C lines 14248–14308 implement that loop; lines 14310–14323 wrap it as
`spin_2`. For shared `SCon` nodes, `ctr_take` takes the `span_fade` path, which
retains the fields and drops the consumed parent reference. Traversing a shared
String therefore performs ownership operations at each visited character.

The exact executable makes this attribution more specific:

| Return-site PC | Actual call immediately before it | Ownership samples |
| --- | --- | ---: |
| `0x889276` | `span_fade`, two fields | 2,177 |
| `0x8892a4` | `span_fade`, two fields | 1,585 |
| `0x8894c9` | `term_drop`, first mismatch remainder | 406 |
| `0x889500` | `term_drop`, second mismatch remainder | 362 |

The first two sites alone account for 3,762 samples, **25.07%** of the prefix.
Samples inside `term_drop` below `span_fade` belong to the same sites and are
already included; do not add them again. This is concrete evidence of ownership
traffic while reading shared Strings. It does not establish how many calls occur,
which strings alias, their lengths, or how much a different lowering will save.

`dn` has a related mechanism. C lines 17292–17337 take a nine-field KDef, keep
its name and sink kind/type/body/constructors. For a shared definition this
retains then releases unused fields. `f_find` (frozen Bend line 12886) scans a
definition list, retaining a candidate while projecting its name and comparing
it. `f_decl_local` retains a list scan on index hits to preserve chronological
selection; other contextual/sugar resolution sites also call `f_find`. It is
unsafe to replace those scans with the existing final-definition index without
proving the ordering contract. No source change is proposed on that basis alone.

## The profile changes over time

Windows below start at the first sample, not at an inferred compiler phase.

| Window | Samples | drop + fade | `f_find` leaves | `has_name` leaves |
| --- | ---: | ---: | ---: | ---: |
| 0–10 s | 2,500 | 62.32% | 55 | 0 |
| 10–20 s | 2,500 | 71.44% | 74 | 0 |
| 20–30 s | 2,500 | 69.72% | 4 | 0 |
| 30–40 s | 2,500 | 69.36% | 0 | 0 |
| 40–50 s | 2,500 | 77.68% | 0 | 81 |
| 50–60 s | 2,500 | 76.72% | 0 | 156 |

Three final samples lie just beyond these windows. Name projection and parser
functions occur early; later samples include checking, normalization and name
membership. `dn`'s shared-take ownership site falls from 249 samples in 10–20 s
to four in 50–60 s, while the two String shared-take sites grow from 391 to
1,060. Thus the prefix is progressing through different work, not stuck in one
constant parser operation. It does not identify the later timeout's stage.

The completed Map control differs: across its five request intervals, ownership
drop/fade is about 50.60%, String append is 13.17%, and eager `nt_choose` disposal
is a visible physical caller. The self source's first minute cannot be replaced
by the Map profile or extrapolated from its speed. Conversely, both expose shared
String observations, so a general comparison improvement has a broader rationale.

## Smallest next falsifier

Test **borrowed traversal with owned roots retained until return**, first on a
tiny checked program, not another complete compiler acquisition. Compare the
existing exact `p88_string_eq` with a diagnostic native kernel that reads each
node using `term_peek`, performs no per-character retain/drop, then consumes the
two original root references exactly once after computing the result. Read-only
traversal must preserve both roots until every read finishes. Do not weaken any
runtime sharing guard or treat this hand-written diagnostic as production Bend.

Use the same small source through upstream C and our native backend, inspect
whether our existing observer lowering already produces this shape, and only
then consider implementation. A useful control matrix includes empty/equal,
first/last-character mismatch, unequal lengths, Unicode, two aliases of one
String, two distinct equal Strings, and shared tails. Retain and read the original
strings after each comparison so the workload actually observes shared input.
Scale lengths 8/64/512 and equal-prefix length independently; consume results.
Require exact results, unchanged surviving roots and balanced final ownership
counts. The intended diagnostic difference is per-character `span_fade` versus
two root releases, not a change in comparison semantics.

This bounded kernel experiment distinguishes an ownership-lowering opportunity
from raw comparison cost without compiling the 17 MB compiler C again. If it
does not materially reduce cost on shared input, stop. If it does, the next
question is how to express or prove this observation in the compiler's general
lowering. The present native B1 is built by upstream C; improving only our emitted
C does not automatically accelerate that existing B1. Native B2 remains blocked,
so a result there is not permission to advertise a self-hosting speedup.

A second, separate tiny source can scale repeated exact-name lookup over
64/256/1,024 definitions and compare full returned KDef products. It can test
projection/list-scan amplification, but cannot justify replacing chronological
parser lookup with final-definition lookup. Neither experiment needs a symbol
representation rewrite or a fresh 600 s self attempt.

**Bounded follow-up rejected:** true read-only borrowing cannot be obtained by
merely rearranging ordinary Bend arguments under the current upstream C lowering;
retained roots still leave recursively matched aliases subject to `ctr_take`.
Do not revive the old reconstructing String comparator as a substitute. A much
narrower candidate was prepared in
[`phase89/equality/`](../../selfhost/tools/performance/phase89/equality/README.md):
match the carried False Bool before destructuring either remaining String, while
keeping strings first in the recursive decreasing tuple. It can avoid one extra
SCon pair at mismatches, not ownership on the entire compared prefix. Root ran
its first standalone acquisition and the parser rejected `match a b` at line 9:
"'a' can't be matched in this position", because the earlier match uses the
later binder `same`. Preserving strings first in the recursive argument tuple
does not satisfy this separate match-order requirement. The job returned 1 in
0.921 s with 176,095,232-byte peak RSS; no JS or C was emitted. This candidate
is stopped, with no code-shape or performance result and no subsequent rewrite.
The exact V5 derivative and original recipe remain preserved.

Failure evidence:
[`equality01/report.json`](../../selfhost/build/phase89/equality01/report.json)
SHA256 `5c5f4ac271c6baecadd13cae9c50d7371834ef321920746def64f632b3b9bb24`;
[`guard process.json`](../../selfhost/build/phase89/equality01-acquire-guard/process.json)
SHA256 `ba7c76aa82df3f3cf51bf3ae18f6ef4f463f073abcd4697a78b34ab7b2ab5a13`.
The source audit lane performed no target execution; root owns this retained
failed first gate. It supports consolidating the native-B2 blocker and ownership
investigation rather than spending another full compiler build on this helper.

## Provenance and reproduction

| Artifact | SHA256 |
| --- | --- |
| `phase89/compiler-native-self01` | `8bacae268296d6fe16d02ce50a7a2189bd587506c074532c6e5d74e622716e45` |
| `phase89/native-self01/compiler.bend` | `4584cf083d9eddad6f1290c9472c3aac2708099caa716a27f5b53fbcbaee1618` |
| `phase89/native-self01/compiler.c` | `b156023421863836c4a0a752b61f9d538282aa376359716a36909f131e9555ff` |
| `partial-self02/stopped-self.samples` | `21ae1710b7e7a7b603eb119e39329431b5516f2ed6b6d23884c4a97c22d8dcca` |

Upstream pin: `059266225b77c8ca256ac6b25ee5c21449bab151`. The new
[`explore-physical.py`](../../selfhost/tools/performance/phase89/partial-capture/explore-physical.py)
always marks its output unqualified and hashes its method, symbolizer, executable,
raw samples and guard receipt. It uses offline ELF/readelf/addr2line inspection;
it does not execute the compiler or modify the original strict analyzer.

```sh
python3 -B selfhost/tools/performance/phase89/partial-capture/explore-physical.py \
  --samples selfhost/build/phase89/partial-self02/stopped-self.samples \
  --binary selfhost/build/phase89/compiler-native-self01 \
  --process selfhost/build/phase89/partial-self02/stopped-self-guard/process.json \
  --out /tmp/phase89-self-exploratory-fresh.json
objdump -d --no-show-raw-insn --start-address=0x88925d --stop-address=0x889508 \
  selfhost/build/phase89/compiler-native-self01
```

The earlier ad hoc `partial-self02-unqualified.json` is retained separately;
the reproducible report above supersedes its methodless summary. No new target
run, compiler build, production algorithm change or qualification relaxation was
performed for this audit.
