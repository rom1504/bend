# Final-source small compiler comparison

All **54** observations pass exact outcomes and diagnostics, byte equality among
the Bend compilers, and execution of the successful emitted programs. Three
fresh-process rounds alternate variant order on CPU1. The unchanged Phase3
compilers and the final Phase4 compilers compile identical inputs through the
same frozen host and output runtime; TypeScript stays at the pinned revision.

| Compiler | Tree request | List-sort request | Rejected bytes request |
| --- | ---: | ---: | ---: |
| Starting B1 | 1.698 s | 3.100 s | 0.813 s |
| Final checked B1 | 1.568 s | 2.704 s | 1.090 s |
| Starting public H | 3.342 s | 6.028 s | 3.134 s |
| Final public H | 3.144 s | 5.620 s | 2.338 s |
| Final canonical private H control | 2.232 s | 3.834 s | 1.724 s |
| Pinned TypeScript | 0.411 s | 0.446 s | 0.374 s |

Successful B1 requests improve **7.6% and 12.8%**; public H improves **5.9% and
6.8%**. The canonical private H is another **29.0% and 31.8%** below final public
H, but remains slower than checked B1. In this comparison its request times are
**5.43× and 8.60×** TypeScript; final public H is **7.65× and 12.60×**. These are
small-program request ratios, not full-source ratios or user-program throughput.

The rejected bytes example's B1 median regresses 34.1%. Its three new samples
are 0.818, 1.294 and 1.090 seconds versus 0.812, 0.854 and 0.813 seconds for the
starting B1. The first pair is nearly flat; the spread warrants a separate
confirmation. All three original samples are retained and the regression is not
hidden by combining successful and rejected workloads. The public-H negative
case also has substantial spread. A confirmation is recorded separately rather
than replacing this matrix.

## Rejected-input confirmation

A separate five-round three-way check retained all 15 exact outcomes. The B1
request medians are 0.789 seconds before and 0.828 seconds after: **4.9% more**,
with process wall 1.933→1.955 seconds. Individual final-B1 samples are 0.839,
0.908, 0.828, 0.803 and 0.822 seconds. The earlier 34.1% magnitude therefore does
not reproduce in this confirmation, but a small regression remains in the
median. This is reported alongside the successful-compilation gains. Shared
host variability is plausible; the experiment does not establish its cause.
The [confirmation report](small-comparison-evidence/b1-negative-confirm.json.gz)
and exact configuration are archived without replacing the original matrix.

## Measurement scope

| Compiler | Tree process wall | List-sort process wall |
| --- | ---: | ---: |
| Starting B1 | 2.989 s | 4.373 s |
| Final checked B1 | 2.832 s | 3.988 s |
| Starting public H | 4.675 s | 7.426 s |
| Final public H | 4.489 s | 6.941 s |
| Final canonical private H control | 3.574 s | 5.183 s |
| Pinned TypeScript | 1.973 s | 2.034 s |

Process wall includes this comparison worker's startup and identity checks. The
private image is used inside a dedicated data-only worker; these are **not** the
supported private CLI's complete launch/verification costs. Its public input
boundary remains unchanged. Each Bend API has a separately checked serialized
Base cache prepared before timing. TypeScript loads and checks Base per process;
it has no equivalent serialized cache here. OS caches are not flushed. Other
experiments ran on other physical cores, so shared host effects remain possible.

The final B1 is the 63-export checked validation API, and the private control
derives its host exports from that same API. Ordinary development uses the
separately measured 54-export API. Earlier prototype matrices with another export
boundary remain evidence for their own exact artifacts.

The final public H has SHA `b33b38e32a263bf78e1d43cf459b7abf9a41d78d112d71a25f87ddba7bd09bf8`;
the private control has SHA `75ebe9e0b3f1f103250621c77c1e455160f83f1479740f8f440c54a6d4dfa598`.
Boolean matcher and stability-cache prototypes are excluded from this matrix.
The generated program bytes are identical across the Bend variants, so this
experiment supplies no claim of faster emitted user programs. Program execution
is a correctness gate; startup-dominated execution timings are retained in raw
evidence without being presented as a steady-state runtime benchmark.

[The evidence manifest](small-comparison-evidence/manifest.json) preserves the
complete report, exact configuration and consumed comparison tool. Replay from
`selfhost/` with `tools/performance/phase4/compiler-compare.mjs CONFIG NEW_DIRECTORY`
under the recorded Node 24.18.0 and resource flags, after recreating the checked
artifacts identified by that configuration. The report records all hashes,
provenance, cache preparation, individual samples and emitted output identities.
