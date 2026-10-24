# Full compiler-source profile

Profiling the compiler compiling its complete source changes the next-work ranking:
**reclamation and general string/tag comparison dominate more than verifier lookup
or Base startup**.

This is one final **N2** sample-only execution with a 32ms timer and the pre-existing
107,059,385-byte Q2 output oracle. All output checks pass. The 11,254 retained
samples have zero loss/overrun and adequate CPU coverage. There is no paired clean
profiler run, no new speed ratio, and no absolute clean CPU estimate. The sampled
child took 360.357s; comparing that directly with the earlier 379.228s emission would
not establish a speedup.

| Physical leaf | Share of all samples |
|---|---:|
| `term_drop` | 16.55% |
| `span_fade` | 12.83% |
| Borrowed `p88_string_eq_go` | 10.02% |
| `p125_rt_take2` | 3.90% |
| `p111_rt_sink` | 3.46% |
| Unresolved libc leaf | 3.41% |
| `p111_rt_take` | 3.39% |
| `p111_rt_keep` | 2.95% |
| `p111_rt_special_ctor` | 2.27% |
| Cold `p125_rt_take2` path | 2.11% |
| Borrowed `index_hash` | 1.73% |

All 383 samples eligible for the authenticated libc unwind recover `p111_set_regs`
as caller: 3.40% of all samples. Seven additional unresolved physical samples lie
outside that recovered set; do not assign them the same cause. `term_drop`/`span_fade` include reference-management work; these samples do not
show what proportion actually frees nodes. Generic runtime
leaves cannot be assigned to source callers because this run has no dispatch
contexts or event counters.

The existing timeline tool preserves sample order. Its coordinates are approximate
sampled-thread CPU time, **not wall timestamps or proven compiler phases**:

- At roughly 90–120s, borrowed string equality reaches 33.0% of that window and
  borrowed `has_name` 6.3%.
- At 240–270s, borrowed `index_hash` reaches 7.8%.
- In the final 60s, two-field takes, extension/destination construction and output
  conversion become more prominent. In the last window `io_cbuf` is 5.3% and the
  private `String.append` worker 4.5%.

`p88_string_eq_go` is not solely a decoder function: selected source shows
`has_name` calling `p88_string_eq`, and `p98_tag_eq_read` calling the same worker on
`KTerm` tags. The profile cannot yet distinguish these call populations. The joint
membership/equality window makes repeated name scans a useful hypothesis, but it
is not proof that `has_name` causes all equality cost.

For short cold requests, verifier entries and decoder wrapper fusion remain good
bounded targets. For the full self-hosting loop, first investigate an actual
comparison/membership computation and a representative ownership-heavy compiler
computation. Avoid a global tag representation rewrite before identifying the
hot callers. Faster equality alone can remove at most its measured share;
eliminating unnecessary traversals or temporary graphs could also remove related
construction and reclamation work, but that larger benefit remains unmeasured.

[Compact evidence and timeline windows](full-profile-results.json) preserve the
actual executable/source identities. Full local evidence is in
`selfhost/build/phase131/final-full-profile-analysis01/`. See also the
[short-request survey](profile-results.md) and
[source-grounded next opportunities](../../research/phase131/final-profiles.md).

A subsequent, separate [context-only full-source capture](full-context-results.md)
now identifies the active owners of comparison and reference-management work.
Its strongest bounded target is the repeated `nc_ctor_owned` book scan, followed
by existing linear lookup/membership operations. The two captures remain separate;
neither creates a new clean speed ratio.
