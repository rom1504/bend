# Why emitted readers do not yet compose broadly

The four-way v01 experiment exposes an earlier optimization boundary, not a
missing nine-field runtime ABI. The wider producer emits borrowed scalar readers,
but most timed consumers have already inlined their owning implementations.
Only the actual `f_find` loop retains the new key-equality call. These are static
observations; native speed and dynamic admission remain separate measurements.

[code01.json](code01.json) pins all eight complete QBE products, their source
fixtures, both producer sources, and every inventoried function body. Its
[replay tool](../../../selfhost/tools/performance/phase137/audit/code-v01.py)
uses the current integrated emission receipts. No target runs were performed by
this audit. The qualified producer source is
`a00019246b5181b288ab4d3e09e616bd41415fe6381e89a96185c05efa19fb57`;
the width-only producer is
`863e28f8bba8a285332875ce99bf82a20d2ea3052c6f4b6aed3606b0d67485b5`.

## Actual call paths, before any inline-policy change

In `selfhost/build/phase137/query-wide-emit01/queries-fused.ssa`, the decoded
`$direct.p137q_repeat` reaches `$p126scc.49`, whose call at line 5931 targets
`$direct.p137q_key_eq`. The adapter at line 5777 checks
`p118_rt_borrow_scalar_safe`, calls `$p118borrow.read.p137q_key_eq` on success,
then sinks its two owned roots exactly once. On refusal it calls the retained
owning implementation. The reader starts at line 5487: its 289 QBE lines contain
no owning take9 or sink, and five static runtime borrowed-read sites across
branches. This proves an available guarded path, not the fraction of executions
that take it.

The name-equality reader also exists (line 4632, with its adapter at 4922), but
the actual `lookup` body at line 7309 does not call it. Its owning extraction was
already expanded into the caller. `p137q_kind_eq` has no borrowed reader in this
v01 product; its owning body at line 5146 retains one take9 and seventeen static
sink sites. The unrelated record reader exists at line 4395, yet the actual
record fixture's `p137q_repeat` bypasses it too. The latter is important negative
transfer evidence: counting emitted readers would incorrectly suggest a broad
optimization.

| Actual private function | Original source, either producer | Fused v01 source, either producer |
|---|---:|---:|
| `lookup` | 526 lines; 3 take9; 49 sinks | 664 lines; 3 take9; 57 sinks |
| `nc_ctor_owned` | 560 lines; 4 take9; 58 sinks | 698 lines; 4 take9; 66 sinks |
| Unrelated record repetition | 341 lines; 2 take9; 24 sinks | 335 lines; 2 take9; 24 sinks |
| Compiler-query repetition | 608 lines; 4 take9; 48 sinks | 608 lines; 4 take9; 48 sinks |

Counts are static sites across mutually exclusive branches, not dynamic events
or exclusive costs. They also include owned-result projections that the scalar
predicate proposal does not eliminate. The fused query QBE grows from 1,654,955
to 1,705,188 bytes when width16 is enabled; growth alone supplies no speed claim.

## Source-level explanation

In the selected source, `p128raw_session_finish` performs the existing
`open → inline → ranges → close` sequence before late borrowed-reader discovery.
`p114s_inline` (line 48796) runs `p113i_functions`, retaining the unchanged
independent commit verifier. Eligibility uses `p113j_returns` through
`p113i_eligible` (line 46797). The older `p113i_scalar_leaf` walk is **not** the
active eligibility predicate and changing it alone would not test this issue.

The active walk allows scalar statements without inspecting their meaning:
`p113j_plain` at line 47095 and `p113j_returns` at 47105. Consequently, a small
predicate containing an owning nine-field take can be expanded before the
observer pass has a chance to replace its public entry.

The apparently inconsistent `f_find` result has a concrete explanation.
`p126sc_worker` at line 55012 constructs its local SCC body with
`p113i_14_`/`p113i_15_` prefixes. The inliner's existing clean-name policy rejects
such previously expanded locals (`p113i_name`, line 46656; `p113i_function`,
46939), so this caller keeps its key-equality call. Ordinary eligible callers
do not have this protection. No benchmark-name policy is involved.

The late restoration rule is narrower than arbitrary inverse inlining:
`p128bi_rule` (line 56197) only recognizes an exact two-statement call/result
wrapper with checked argument patterns. It cannot recover a record match and
its owning operations after those operations are distributed through a caller.
Late reader generation therefore cannot alone repair all of these call sites.

## Small falsifier: preserve a still-useful boundary

The isolated `queries/retain-wide-v01.bend` experiment changes profitability
only. Its one override, `p113i_eligible`, substitutes the same return-shape walk
with a stricter scalar visit: do not inline a function containing the exact
`p111_rt_take` argument shape with a literal count 9–16 and zero high word.
Nested scalar branches are inspected too. Unknown counts, different imports,
other widths and malformed argument shapes retain their previous policy.

This does not grant borrowing, remove owning fallbacks, skip a verifier, move
the observer pipeline, or re-prepare the whole program. Root lifetime,
noescape, layouts and actual helper availability are still established by the
existing observer admission and final verifier. A deferred owning getter may
still return an owned String or record; its existence does not make that result
borrowed. Only a separately admitted scalar consumer can use the borrowed ABI.

The risk is real: this broad syntactic profitability rule also preserves
unprofitable calls, including getters for which borrowing never succeeds. It
may lose inlining wins and enlarge the final call graph. Therefore first check
actual `p113i_eligible` controls, then whether the same small timed consumers
reach their emitted readers and remove take/sink work. Measure query runtime
and compilation cost before considering any whole-compiler acquisition.

This is a bounded policy falsifier, not a recommendation to disable inlining
globally or duplicate the earlier observer analysis. If it pays, preserving an
already established observer fact would be a cleaner future policy than
assuming every wide owning extraction will eventually be profitable to borrow.

## Retention experiment: the actual caller boundary now survives

The root emitted the v02 query and unrelated-record fixtures with the checked
retention candidate. [code03.json](code03.json) records the original inventory;
[code04.json](code04.json) expands that inventory to include the v02 constant-kind
predicates and the ordinary scalar getters `da`/`db`. The latter is produced by
the versioned [code-v02.py](../../../selfhost/tools/performance/phase137/audit/code-v02.py),
with both the width-only v02 and retained v02 products pinned. The earlier v01
negative observations above remain unchanged.

Actual v02 named direct-call paths now reach these guarded borrowed readers:

- The compiler-query loop reaches `p137q_name_eq` through `lookup`, and
  `p137q_is_adt`/`p137q_is_ctr` through `nc_ctor_owned`.
- Its ordinary scalar projections also reach the existing `da` and `db`
  borrowed adapters. This is an additional consequence of keeping boundaries,
  not a new getter transformation.
- The unrelated record loop now calls `p137q_record_query` twice and reaches
  its already emitted reader. Previously both owning bodies were inlined.
- The prior `f_find`/key-equality path remains available.

| Actual private function | Width-only, fused v02 | Retention, same fused v02 |
|---|---:|---:|
| `lookup` | 590 lines; 3 take9; 54 sinks | 203 lines; 0 take9; 15 sinks |
| `nc_ctor_owned` | 560 lines; 4 take9; 58 sinks | 151 lines; 0 take9; 13 sinks |
| Compiler-query repetition | 608 lines; 4 take9; 48 sinks | 272 lines; 0 take9; 4 sinks |
| Unrelated record repetition | 333 lines; 2 take9; 26 sinks | 183 lines; 0 take9; 4 sinks |

These are local static counts; moving an operation into a callee does not
eliminate it. Inspection of the actual callees gives the stronger, limited
conclusion: the name/key/constant-kind/record and `da`/`db` reader fast branches
contain no owning take9 or sinks, with the public adapters doing their required
root release and retaining the original owning fallbacks. **Two important
owning paths remain:** `p137q_is_cache` is still a 106-line implementation with
one take9 and thirteen sink sites, and `dc` is an 89-line owned-result projection
with one take9 and eight sinks. They remain actual callees of `lookup` and/or
`nc_ctor_owned`. Zero local take9 is therefore not zero whole-query RC work.

In the retained query product, the key locations are `lookup` at line 8314,
its `p137q_name_eq` call at 8456, `nc_ctor_owned` at 8900, and the actual repeated
query at 9433. The constant-kind readers start at 4565 (`is_ctr`) and 5194
(`is_adt`); their guarded adapters start at 5070 and 5699. In the separate
retained record product, the repeated caller starts at 9006 and calls the
record adapter at 9071. All are under
`selfhost/build/phase137/retain-query-emit01/` and pinned in code04.

Complete query QBE decreases from 1,735,925 to 1,585,208 bytes; record QBE from
1,646,717 to 1,541,047 bytes. This is a real composition result without another
observer-preparation pass. The seven relevant reader bodies (`da`, `db`, record,
the two constant-kind predicates, and the two name predicates) retain identical
body hashes across these producers: the change makes existing readers reachable
rather than inventing a different reader algorithm. It justifies the small controlled runtime comparison;
it does not yet establish dynamic fast-path frequency, native compiler speed,
or a reason to acquire a complete compiler image before transfer is measured.

## Linked-machine check

The [focused machine receipt](machine01/report.json) pins both existing ELF
products for each fixture, their complete build receipts and QBE identities,
and thirty-one selected function disassemblies. Only `objdump` inspected existing
ELF files; this audit did not execute the programs or rebuild them. The tool
records the exact disassembly commands and call-target addresses.

| Selected linked function | Width-only v02 instructions | Retention v02 instructions |
|---|---:|---:|
| `lookup` | 724 | 257 |
| `nc_ctor_owned` | 753 | 212 |
| Compiler-query repetition | 892 | 294 |
| Unrelated record repetition | 402 | 182 |

Instruction counts include alignment padding and cover whole functions, not
one dynamic loop trip. In the retained query ELF, `lookup` calls the name adapter
at `0x40cb13`; the adapter's call at `0x40aa59` reaches the private reader. Its
guard and owning fallback calls remain at `0x40aa35` and `0x40aa49`, followed by
the two required sinks on the reader branch. `nc_ctor_owned` calls the ADT and
constructor predicates at `0x40d2a1` and `0x40d3ec`. Their adapters likewise retain
both guarded paths and their one-root release.

In the retained record ELF, the timed loop calls its record adapter at
`0x40d3dd` and `0x40d477`; that adapter has the guard at `0x409062`, owning fallback
at `0x409076`, reader call at `0x409086` and two root sinks afterward. This
independently confirms that machine code preserves the QBE composition result.
It does not replace runtime measurement or establish a whole-compiler gain.
