# Phase147: measuring complete verifier regions quickly

Candidate03 reduced complete verifier-region time on all three tested input
families. These are selected compiler internals, not new whole-compiler or
upstream-parity measurements. The [compact verifier design](compact-verifier.md)
describes the representation change; [machine inspection](verifier-machine-inspection.md)
describes the emitted workers. [Pinned evidence](verifier-fast-loop.json) records
the completed controls, native construction, clean timings and diagnostic leaves.

| Selected input family | Original median | Candidate03 median | New / old | Less time | Native build |
| --- | ---: | ---: | ---: | ---: | ---: |
| Lexer, 16 repetitions | 291.565 ms | 227.125 ms | 0.779 | 22.1% | 15.1 s |
| Map, 4 repetitions | 154.326 ms | 137.374 ms | 0.890 | 11.0% | 23.7 s |
| Compiler-verifier slice, 16 repetitions | 428.554 ms | 352.327 ms | 0.822 | 17.8% | 17.3 s |

Each repetition checks six complete raw segments and six complete direct
functions. We select two large/branch-heavy bodies and a declaration-order
spread. The entire global function/constructor metadata and ordered predecessor
signatures remain available. Local schemas, representation construction, flows,
branch merges and reclamation are charged. Both modes run inside the same native
executable, with mode and repetition count supplied at runtime. Four alternating
pairs include process startup and final teardown, with no startup subtraction.
The paired ratios were 0.768–0.783, 0.879–0.904 and 0.818–0.828 respectively.

The compiler workload is a 37,696-byte dependency closure of the original
verifier, compiled through the actual current frontend and lowering pipeline.
It is not a sample of every pass in the 3 MB self-hosting compiler. These bounded
regions establish that the candidate survives complete construction and teardown
costs; a full source request remains the integration gate.

The checked baseline API is acquired once. A candidate API takes about two
seconds to acquire; all 60 initial controls, 16 supplemental controls and 36
captured-function comparisons passed for candidate03 and its scalar-query
successor04. The controls compare exact independently specified diagnostics,
schema errors/counts, parameter seeds and final live state/terminal flags.
Representation observers compare semantic rows, not physical trie layouts.
Another 19 numeric-map flow controls and two isolated schema-count boundary
controls passed. They exercise explicit high-bit U32 IDs, structural intersection,
equal/unequal capacities and retained immutable roots. These are helper controls;
they do not claim complete-entry exhaustion coverage or native ownership proof.
The three native builds above total 56.1 seconds; their clean timing campaigns
take only a few additional seconds. This is the useful inner loop before a full
compiler build. Reusing immutable capture inputs avoids paying frontend/lowering
cost again for each verifier edit.

## What the native profile supports

One diagnostic run per mode executed 768 repetitions of the exact same Lexer
binary, independently expecting `9216\n`, empty stderr and exit zero. A reused
general sampler captured 919 original and 667 candidate leaves at a 16 ms
period. Both captures passed the minimum 500 samples, near-complete process CPU,
zero loss/overrun and plausible delivery gates. Symbol resolution was 90.9% and
92.4%; unknown samples remain in the denominators. No compiler-image owner or
unwind mapping was applied to this separate executable.

| Physical leaf/group | Original samples | Candidate03 samples |
| --- | ---: | ---: |
| Reclamation group | 127 | 66 |
| Ownership and products group | 157 | 117 |
| `term_drop` | 89 | 46 |
| `span_fade` | 38 | 20 |
| Generic `p111_rt_ctor` | 57 | 34 |
| `heap_alloc` | 12 | 3 |
| Borrowed string equality loop | 28 | 2 |
| Borrowed string comparison | 33 | 39 |
| Borrowed name hashing | 29 | 23 |

The samples support reduced ownership and reclamation work. They do not count
allocations, identify which callers caused runtime work, or isolate all costs of
the numeric map. The candidate still spends time in its exact-name schema lookup
(24 leaves), string comparison and hashing. Its boxed numeric lookup itself has
only two leaves, so this survey cannot establish the benefit of the successor's
scalar observers. That hypothesis is tested with another checked, paired native
measurement. One fixed period can alias; these diagnostic times are excluded
from clean performance claims.

## Scalar-query successor04

The same three native preparations and controls completed for candidate04.
Its new/original ratios were 0.775 Lexer, 0.881 Map and 0.813 compiler slice.
These are only about 0.6–1.1% better than candidate03's normalized ratios across
separate builds. They do not establish a large second gain or a precise causal
estimate for scalar queries alone.

The actual Lexer02 assembly does establish the intended code shape. The direct
membership worker has 89 assembly instructions and no `p125_rt_ctor2`, whereas
the original numeric lookup has 116 instructions and reconstructs its result
cell. Its local-value caller shrinks from 77 to 58 instructions and calls the
scalar worker. The scalar capacity worker also avoids result-cell reconstruction.
The fused memory path calls the name lookup once and then the scalar memory
observer, replacing the earlier capacity and value queries. These are static
instruction counts, not dynamic operation counts. The generic boxed lookup
remains for legitimate consumers; source and assembly do not claim its global
removal. A whole-request check must decide whether the extra helpers are worth
retaining.

## Reproduction and retained failures

The [campaign instructions](../../experiments/phase147/tools/README.md) describe
the maintained source/build interfaces and exact guarded job plans. Python/JS
perform extraction, transport and comparison; compiler judgments and optimized
algorithms remain Bend definitions. These region experiments preceded explicit
integration. The selected implementation now accelerates three intermediate
direct-admission sites while retaining the original raw and final verifiers;
see the [integration audit](integration-audit.md) for the exact boundary.

Baseline01 exposed a character-literal bug in dependency extraction; the general
lexer mask was fixed and baseline02 checked successfully. Candidate01 exposed
Bend's computed-match restriction; the candidate owner introduced checked helper
definitions before candidate03. Real-screen01 passed a pin object instead of its
file path to an orchestration reader; the fixed fresh real02 compared all 36
functions. Initial native argv metadata omitted the explicit test sentinel;
the timing method records that correction without rebuilding or modifying the
already compiled source. Failed receipts and consumed method bytes are retained.
