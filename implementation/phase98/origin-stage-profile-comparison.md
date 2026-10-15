# Matched complete B1 and B2 profiles

Both exact current images successfully compiled the same complete `2a72bbdc…`
source under the unchanged Phase88 sampler. B1 (`099df960…`) produced 6,550
request samples over 104.801 seconds of request CPU; B2 (`c481bd2c…`) produced
8,823 over 141.169 seconds. Both completed normally with zero sample loss,
accepted process CPU coverage above 99.9997%, and the same complete C
(`6ae1675a…`) and clock-stripped diagnostic. The commands use one worker, CPU 3
and 16 ms samples; B1's documented lack of the B2 argv sentinel is accounted for.
The marked request excludes Base/runtime preparation and output writing.

The [comparison receipt](../../selfhost/build/phase98/ownership-origin-stage-comparison01/report.json)
authenticates both accepted windows, their full preparations, source, images,
generated C and raw samples. Its
[offline method](../../selfhost/tools/performance/phase98/comparison/compare-origin-stage-profiles.py)
also records 21 exact C spans and seven exact-symbol disassemblies. These are
one successful capture per image, without randomized repetitions or an isolated
pass toggle. They describe the stage difference and concrete mechanisms;
they do not assign a causal speedup to any proposed removal.

## Ownership share falls while ownership time rises

Estimated seconds below are each stage's marked request CPU time multiplied
by that stage's sample fraction. At this sampling period, they are also close
to `samples × 0.016 seconds`. Different request denominators make percentage
comparison alone misleading.

| Leaf work | B1 samples / share | B1 estimated CPU s | B2 samples / share | B2 estimated CPU s |
| --- | ---: | ---: | ---: | ---: |
| `term_drop` | 2,448 / 37.37% | 39.17 | 2,891 / 32.77% | 46.26 |
| `span_fade` | 1,330 / 20.31% | 21.28 | 1,318 / 14.94% | 21.09 |
| `rfc_wrap` | 100 / 1.53% | 1.60 | 254 / 2.88% | 4.06 |
| All three | 3,878 / 59.21% | **62.05** | 4,463 / 50.58% | **71.41** |
| Other leaves | 2,672 / 40.79% | 42.75 | 4,360 / 49.42% | 69.76 |

The sampled stage difference is about 36.37 CPU seconds: 9.36 more in these
helpers and 27.01 more in other leaves. This partition is descriptive, not a
claim that all helper work can be removed. Every ownership sample has a
recovered physical owner; musttail-eliminated logical ancestors remain absent.

## Concrete physical buckets

| Mapped leaf plus its physically owned cleanup | B1 estimated CPU s | B2 estimated CPU s |
| --- | ---: | ---: |
| `kc` | 11.01 | 11.20 |
| `nt_choose` | 2.06 | 2.43 |
| `String.append` and its exact reconstruction continuation | **4.86** | **13.44** |
| Generic closure-apply leaf | 7.71 | 5.46 |

`kc` cleanup itself is approximately unchanged, 10.06 versus 10.00 seconds.
Known-closure Boolean lowering remains a substantial absolute-cost opportunity,
but these captures do not identify it as the main cause of the stage gap. The
generic closure-apply leaf is smaller in B2. Its CPU cannot be assigned entirely
to `kc` or `nt_choose`.

The append mapping is explicit in both generated C files: B1 schedules
`STRING_APPEND_K21896`, while B2 schedules `native_k_44186`; each continuation
constructs an `SCON`. This bucket has 304 versus 840 samples, an estimated
8.58-second difference. B1's
[continuation](../../selfhost/build/phase98/ownership-origin-stage-comparison01/b1-2.asm)
loads the character as a 32-bit value, stores it without a reference-tag check,
and returns through a direct `wl_tab` lookup. B2's
[continuation](../../selfhost/build/phase98/ownership-origin-stage-comparison01/b2-2.asm)
loads a general 64-bit `Term`, checks both field tags before sealing, and calls
`wl_target` before its indirect return. The sampled B2 `rfc_wrap` call belongs
to the tail field, not the character field. These are real code differences,
but their individual costs have not been isolated. The full-profile `wl_target`
leaf cannot all be assigned to append. This physical bucket is not an inclusive
cost of every logical append caller.

Other like-named owners are less directly comparable. For example, `has_name`
falls from 7.86 to 3.76 estimated seconds, but B1 inlines equality into that
owner while B2 exposes separate equality workers. Calling this a 4.10-second
logical membership improvement would be unsound. The report retains such
physical buckets with their actual symbols and this limitation. Its helper
table overlaps cleanup assigned to these owners; the tables must not be added.

## Broader borrowed and scalar code in B1

The upstream-generated C provides an explicit structural correspondence for
the otherwise anonymous spin helpers. In
[`spin_3`](../../selfhost/build/phase98/origin-checked01/program.c:14215),
the String constructors, `same` argument, character comparison and tail recursion
match the source walker. It uses `term_peek`, a raw `u32 same`, and no retain,
consume, allocation or disposal operation. `spin_5` calls this walker followed
by `spin_6`, which disposes the two roots; `spin_5` itself performs no retain.
The `has_name` C caller explicitly invokes `spin_5`.

B2's public `p88_string_eq` instead retains both roots before invoking its
walker. Its shared-root observer adapter disposes those saved references after
the borrowed traversal, and the public finish path disposes the remaining root
references. The successful B2 profile already confirms the borrowed loop is
active: 577 leaf samples lie in its mapped pointer-walk region. The remaining
boundary work does not imply that the observer failed to run.

Likewise, B1's
[`spin_2`](../../selfhost/build/phase98/origin-checked01/program.c:14299)
reads a generic `KTerm` tag through `term_peek` and calls `spin_3`; the enclosing
`spin_1`/`spin_7` path preserves the term until final disposal. B2's
[`p98_tag_eq_read`](../../selfhost/build/phase98/origin-b1-self01/execution/output.1.c:76806)
still consumes the term fields and disposes unused fields. Thus B1 already has
borrowed projection and scalar simplifications beyond the current B2 route.
Most small spin helpers are inlined and have no independent ELF symbol, so the
profile cannot construct an equivalent whole-request B1 equality bucket merely
by matching names to B2's 21.44% equality bucket.

The runtimes also differ. B1's
[`term_peek`](../../selfhost/build/phase98/origin-checked01/program.c:13821)
uses `w64_load` for the reference cell; on the CPU this is a relaxed atomic
64-bit load. B2's
[`rfc_view`](../../selfhost/build/phase98/origin-b1-self01/execution/output.1.c:40368)
assembles two atomic 32-bit loads and performs an acquire when the count is one.
The [exact runtime spans](../../selfhost/build/phase98/ownership-origin-stage-comparison01/runtime-spans.json),
[atomic macros](../../selfhost/build/phase98/ownership-origin-stage-comparison01/runtime-macro-spans.json)
and append disassemblies preserve that distinction. The load and ordering rules
are part of the runtime contract; this observation does not justify dropping
an acquire or substituting an unproved load protocol.

## Next experiments

1. **Recover scalar and dispatch information in the append construction path.**
   The mapped 8.58-second difference gives a concrete starting point: preserve
   known character field types and review direct continuation dispatch before
   changing the String representation. Test these independently, then consider
   builders or chunked emission at identified callers. The samples do not prove
   quadratic prefix growth.
2. **Bring B2 borrowing closer to the demonstrated upstream contract.**
   Focus on the retained tag projection and equality boundary protocol, with
   explicit escaping-child ownership and lifetime checks. The active String
   observer alone does not provide that projection rule. Match the behavior
   before inferring any saved reference operations.
3. **Continue Boolean closure elimination as an absolute-cost experiment.**
   Both images spend roughly 12 seconds disposing branches under `kc` and
   `nt_choose`. A lowering that avoids constructing unselected captures could
   help both stages, while preserving argument demand, effects and ownership.
4. **Treat runtime reference-cell access as a separate experiment.**
   Compare the complete atomic protocols and their concurrency assumptions;
   preserve correctness controls. The profile alone cannot separate its cost
   from scalar lowering, inlining, layout and other backend differences.

These captures replace the earlier missing-current-B1 comparison. No partial
or divergent watchdog profile enters the analysis. The separate TS context and
[ideal helper-removal ceiling](origin-b2-profile.md) remain illustrative bounds:
neither the matched profiles nor their physical buckets establish removable
time or a controlled pass-level causal effect.
