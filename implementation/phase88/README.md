# Phase88: a correct, much faster native compiler pilot

The native compiler now compiles and executes all **45 benchmark points from
23 original sources** successfully, emitting exactly the C produced by the
independently installed Phase82 B2. Map's closure-sharing crash is repaired.
Prepared Base startup falls from roughly **3.1 seconds to 58–59 milliseconds**.
A separate consuming string comparison reduces live prepared-request time by
**22.4–32.3%** in a controlled six-source comparison.

This is a usable **upstream-built native B1**: TypeScript compiles our Bend
compiler to C once, Clang builds it, then its requests run native Bend code.
No JavaScript executes in the request path. The cached Base was prepared offline
by an explicitly identified JS-hosted B2 and is decoded in Bend. This is not
native B2 self-reproduction, general module/effect support, or a replacement for
the installed Phase82 JS B2.

[Design](../../design/phase88/native-correctness-and-speed.md) ·
[Native usage](../../docs/self_hosted/NATIVE_HOST.md) ·
[Methods](../../selfhost/tools/performance/phase88/README.md) ·
[Machine-readable results](summary.json) · [Evidence receipt](evidence.json) · [Restore supplement](restore-evidence.json).

## What changed and why

1. **Represent reusable observer continuations as Data.** The observer evaluates
   multiple symbolic branches with the same continuation. Its unsafe source
   duplicated a function closure, which the native runtime correctly rejected.
   Eight explicit Data frame constructors and one dispatcher replace thirteen
   continuation lambdas. Fuel, fresh names, first errors and tail eligibility
   retain their previous behavior. The runtime guard remains intact.
2. **Integrate the three linear output builders qualified in Phase87.** Native
   Strings are linked characters. Appending to a growing prefix repeatedly
   traverses and reconstructs it. Reverse characters/chunks eliminate that
   quadratic construction in indentation, joining and segment emission.
   Phase87's isolated first Lexer request improved 8.2–8.9×; this phase brings
   that fix into current source and qualifies it broadly.
3. **Check Base once in the native entry.** Reuse the actual checked world for
   diagnostic production and prefix preparation, preserving the ordinary
   admission checks. Live Base startup drops from about3.1s to about2.1s.
4. **Consume compiler string comparisons without reconstructing both operands.**
   Physical caller profiles identify String.order result destruction as
   22–24% of live Base samples and21.8% of Lexer request samples. A safe Bend
   equality helper consumes the inputs directly. The native build derivative
   replaces exact compiler-owned String.eq references; imported Base, input
   programs and ordinary JS source remain unchanged. Two-round live Base
   preparation falls further to about1.56s; request savings are below.
5. **Decode an authenticated, shared prepared Base graph in Bend.** A small
   owned-array decoder reconstructs named Data and backward references from
   a1.10MB carrier. It preserves graph sharing and located-source metadata.
   Complete product comparison and external producer/Base/path/ABI/consumer
   bindings precede admission. Cache reading, decoding and temporary cleanup
   are included in the58–59ms Base timer. Missing/wrong cache identities refuse;
   `--live` explicitly selects full preparation.

The production delta is **+51 physical lines across three existing modules**:
32,540→32,591 lines, still132modules. The native-only decoder, entry and helpers
add separate experimental code; this is not an overall line-count reduction.
No allocator, runtime ownership guard or pinned upstream source was changed.
The candidate emits9.0% less compiler C and its binary is8.9% smaller than the
same-phase live baseline, despite adding the decoder. These are image-size
observations, not a universal optimizer improvement.

## Controlled fresh-process comparison

`paired01` rotates five roles over six sources and reverses order in the second
round:60 serial, output-qualified jobs. Linux x86_64; CPU3; native single thread,
GPU off; pinned upstream0592662, Node24.18.0. Values are medians of two rounds.

| Source | Native cached process | TypeScript process | Installed B2 process | Native / TS |
| --- | ---: | ---: | ---: | ---: |
| Small |146ms|718ms|513ms|0.20×|
| Numeric |186ms|758ms|646ms|0.25×|
| Lexer |562ms|840ms|1,187ms|0.67×|
| Map |2,200ms|1,249ms|1,758ms|1.76×|
| Functions65 |308ms|799ms|840ms|0.39×|
| Unicode |146ms|707ms|493ms|0.21×|

These process clocks include executable/Node startup, the relevant Base workflow,
request, complete C writing and shutdown. They exclude Python authentication and
supervisor startup, Clang and user-program execution. The native row uses its
new prepared cache; TypeScript uses its ordinary reference load/check/emit route.
Thus this is a comparison of these supported workflows, not identical internal
work or proof of general language parity. The public guarded Python command has
additional startup/hashing cost. No aggregate silently drops Map.

The same-source live-native comparison isolates the request improvement:

| Source | Native01 request | Native02 live request | Reduction | Native02 cached request | TS request |
| --- | ---: | ---: | ---: | ---: | ---: |
| Small |78ms|54ms|30.8%|56.5ms|335.4ms|
| Numeric |139ms|96ms|30.9%|99ms|371.4ms|
| Lexer |605ms|449ms|25.8%|462ms|470.8ms|
| Map |2,642ms|2,050.5ms|22.4%|2,082ms|818.0ms|
| Functions65 |328ms|222ms|32.3%|225ms|408.1ms|
| Unicode |75ms|53ms|29.3%|56ms|332.0ms|

Native request time excludes Base/runtime preparation and output file writing,
but consumes all output characters. Reference request time includes its own
load/check/emit work. Native01 already contains the observer repair, linear
builders and single Base check. Native02 adds consuming equality and optional
cache support; live rows select no cache. Two samples are a bounded screen,
not confidence intervals or an architecture-wide benchmark.

## Repeated requests remain a gap

`repeat01` checks all90 outputs from six sources, three roles, five calls each.
Small/numeric/Unicode are stable, but native Lexer rises456→518ms and Map
2,276→2,789ms. TypeScript's fifth requests are279.5ms and431.9ms respectively:
**1.85× and6.46×** native deficits. Do not use the cold-process wins as a claim
of warm throughput parity.

A new native02 Map profile has3,015 request samples,99.998% CPU coverage and no
drops/overruns. Physical return addresses, checked C and disassembly identify:

- **30.7%** in string append and its directly associated ownership operations.
- **11.6%** destroying child NC_Code body strings after composing parent output.
- **7.7%** destroying unchosen `nt_choose` closures.

These are measured costs, not promised removable gains. The first two mechanisms
are related; optimization estimates must not blindly add them. Append-related
samples account for about61% of the increase across the profiled requests, but
there are no allocation/cache-miss counts establishing why that work grows.
No leak or allocator defect has been demonstrated.

Next: destructure child NC_Code products once in the measured general match
composer; compare complete products and exact C in the fast loop. If copying
remains, carry ordered output chunks through nested compositions and flatten
once. Count append characters/allocations per request to distinguish extra work
from poorer locality before touching the allocator. The detailed source sites
and falsifying checks are in [ownership.md](ownership.md).

## Correctness evidence and limits

- 17 complete observer products match old JS, new JS and native, with independent
  success/refusal/fuel/tail assertions.
- 21 linear-builder edge controls were qualified in the unchanged Phase87 capsule;
  this phase integrates their exact changes.
- 1,444 string pairs over38strings pass full JS/native output comparison, Base
  comparison and an independent codepoint oracle, including sharing/reuse.
- 16 small native/raw-JS decoder controls pass. Full cache/fresh/prepared products
  compare88,575/120,669/125,089 object pairs. Wrong stamp, truncation and trailing
  payload refuse. The payload carries Data, not runtime layouts or closures.
- Eight old/new complete Base-preparation cases preserve results and diagnostics;
  ten transport/authentication controls qualify the admitted identity boundary.
- All45 broad points emit exact independent B2 C, build with ClangO2, and execute
  to the complete independently expected stdout. Sources cover23originals with
  size/seed/shape variations. This preserves generated-program behavior and
  exact generated code on this corpus; no new execution-speed ratio is claimed.
- Cached/live launcher positives agree; five negative cases refuse without C;
  existing output is preserved. Publishing stages a complete verified copy and
  refuses to overwrite. Inputs are reauthenticated after execution.
- The maintained checked JS B1/frontend36 development gate passes with zero exact
  differences. Installed JS B2 bytes and historical release lineage are unchanged.

The earlier16 broad failures were fixture-adapter errors: renamed mains without
renaming their laws, then an incomplete/wrong-quantity generic-row serializer.
Both compilers rejected those inputs. Failed string/decoder checks and four
Base-product harness/oracle failures are preserved too. Two launcher import
fixtures initially used invalid import syntax and are also retained. None is
silently overwritten or represented as a passing compiler run.

General imports, arbitrary foreign effects, native self-emitted B2, complete
language conformance, parallel compiler scaling and a compiler proof remain
unqualified. The native pilot supports one source importing exact canonical Base
and only the audited args/print/now effects. Its prepared cache binds the original
canonical path and exact native image. Historical broader native API gaps remain.

## Cost and reproducibility

The complete resource ledger contains373 guarded processes and about18.2minutes
summed guarded wall time, including expected failures and controls. The largest
RSS was4.14GiB during a full native-image Clang build. Native request profiles
stay much smaller (the five-request Map profile peaks around79MiB). Targets ran
serially; bounded agents handled observer representation, Base transport and
profile/source audits. No quota-consumption estimate is inferred from wall time.

Native02 checked acquisition took76.25s; its optimized build took175.07s and
peaked at3.995GiB. Its9,964,168-byte binary SHA256 is
`5babec07f3ff4c3a8c8e7be00566a681a4068b098349f9ee5207e53aa3231c9c`.
The source SHA is`08ea6591…d05e4f`; checked C is`8a636bf1…9c659`.
These identities, full build commands, all attempts and exact external runtime/
Base/cache assets are sealed in the [capsule receipt](evidence.json).

Only previously sealed generated C copies were pruned under disk pressure,
after comparing each byte hash to its unchanged historical archive. Prune
receipts are retained. No historical capsule, source, release or upstream
checkout was replaced. Restore the native assets with the documented helper;
full evidence restoration needs substantially more free disk.

A post-seal packaging audit caught one omitted external runtime receipt. The
original capsule remains unchanged; a small supplemental archive supplies that
receipt. Restoring it from an actually absent path passes authentication. The
[restore evidence](restore-evidence.json) retains the original and corrected
methods, and [restore controls](restore-controls.json) record the check.
After sealing,105.4MB of generated raw evidence copies were pruned only after
exact archived-byte verification; [receipt](cache-prune-after-seal.json).
The native request assets and native01 comparison C remain locally available.
