# Final native profile refresh

The latest N2 profiles identify **verifier name/index work, Base decoder state
reconstruction, and emitted-string construction** as the strongest next targets.
The earlier bang-query-cache idea is poorly supported by these requests.

| Final N2 request | Physical / context samples | Verifier owner share | Carrier-decoder owner share | String.append requested words |
|---|---:|---:|---:|---:|
| Lexer | 628 / 670 | 23.81% | 14.17% | 8,015,180 |
| Closures | 659 / 731 | 5.40% | 48.68% | 907,149 |
| Map | 807 / 835 | 14.98% | 10.59% | 11,751,661 |

All pools pass the 500-sample threshold, zero-loss and output gates. Active owner
shares are diagnostic execution contexts, not inclusive stacks. They must not be
added to physical leaf shares. Context-only overhead is 6.1–8.3%; counter-enabled
overhead is 66.8–86.5%, so neither supplies the clean speed headline.

Compared with the earlier same-runtime Phase130 counters, final dispatch counts
fall 31.4% / 12.0% / 40.6%, allocation words 22.7% / 10.4% / 23.4%, and register-copy
words 36.1% / 13.4% / 40.2%. This is actual reduced instrumented work. Frame pushes
increase slightly; not every operation improves. All authenticated sampled libc
copy PCs recover `p111_set_regs`, accounting for 4.82% / 8.25% / 6.65% of physical
samples. Register clearing stays zero.

The measured image is final **N2**, not the later qualified N3. The controlled
compiler-speed results and their stage distinctions are in
[native-results.md](native-results.md). [Exact profile identities and counters](profile-results.json)
and [the source-grounded opportunity analysis](../../research/phase131/final-profiles.md)
retain measurement limitations, source evidence and bounded next experiments.
