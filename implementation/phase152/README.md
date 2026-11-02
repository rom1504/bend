# Phase152 — preserve prepared values and qualify the integrated compiler

The maintained Bend compiler now preserves authenticated nullary constants
through bounded selector expansion, integrates the faster Phase150 lexer and
uses the compact Phase151 dispatch tables. This is one maintained source tree,
with QBE unchanged as the native backend.

The full cold-build screen improves **259.30 → 249.22 seconds (3.89%)** on the
same frozen compiler source. The new generated compiler removes 13,600 redundant
constructor/sink pairs and is 3.32% smaller. This is a useful integration and a
general optimization capability, not the proposed100-second compiler.

[Design](../../design/phase152/README.md) ·
[Contract](../../docs/self_hosted/prepared-constants.md) ·
[Independent audit](../../research/phase152/prepared-values-contract.md) ·
[Code census](../../research/phase152/compiler-code-census.md).

## What changed and why

Static preparation already knows that an ordinary nullary constructor is a
packed, nonowning word. Bounded selector expansion recovered the original
erased body and lost that fact. The backend consequently emitted runtime
constructor and sink calls. These calls allocated nothing: their cost was
calling, checking, argument transport and ownership bookkeeping.

The new capability first applies the old selector admission rules, then admits
only a bounded correspondence between the original compact body and a freshly
prepared same-name body. Only authenticated nullary constructor leaves may
become packed constants. Their full-width `N_Imm64` binding survives local aliases
and lets existing keep/sink elimination work. Unknown facts retain the original
fallback. No benchmark-name recognizer, new IR, runtime ABI change, or weakened
final verifier was introduced.

This removes the execution penalty that blocked the compact table spellings.
The independently tested scalar lexer retains the existing token representation
and all parser consumers. The integrated source adds 292 lines and 42 declarations
(including two private lexer types), from 66,107 to 66,399 assembled lines. All 112
protected declaration hashes are unchanged. Source checking and finite controls
are not a new BendTT equivalence theorem.

## Native compiler and machine products

Every row compiles identical 3,085,157-byte source, SHA256
`027e15041035522ed7e40ef971eff75f24a09ef6a00e3f8fe335839f94bcb8a8`, with fresh
processes and machine products, fixed prepared Base/runtime/toolchain and CPU3.
OS caches are not flushed; these are one-observation screens, not confidence
intervals. Read-only metadata/census work ran separately during the final build;
no other compiler or benchmark target ran concurrently.

| Executing compiler | Product | Full build | Emission + QBE overlap |
| --- | --- | ---: | ---: |
| Qualified Phase147 N2 | New N1 |259.302s|252.590s|
| New N1 | New N2 |254.613s|248.028s|
| New N2 | New N3 |249.222s|242.103s|

The last two generations produce byte-identical 118,227,421-byte QBE, assembly
and objects. Whole ELF files differ; ELF identity is not claimed. N1 was built
by the old code generator and therefore has a different QBE product. Source
identity, self-reproduction and semantic qualification remain separate gates.
The maintained production assembly is byte-identical to the frozen qualified
source; installed releases remain unchanged.

On the same source, N1→N2 preserves all 73,926 generated function symbols while
eliminating all 13,600 strictly recognized nullary constructor→copies→sink pairs
across 4,466 functions. Total calls fall 249,613→222,581; QBE text falls 1.50%,
assembly3.17%, object4.99%, executable19,596,488→18,945,224 bytes (3.32%).
These are static counts. They do not assign all size or timing changes to one
instruction deletion, and they do not imply heap-allocation savings.

## Isolated mechanism and transfer

The unchanged Phase151 native witness, two alternating observations per variant,
20 million calls per observation:

| Consumed dispatch path | Original compiler | Constant-preserving compiler |
| --- | ---: | ---: |
| Scalar roles |1.3215s|0.6065s (54.11% less)|
| Scalar opcode |2.2155s|1.4585s (34.17% less)|
| Original roles |0.6960s|0.6205s|
| Original opcode |1.5580s|1.4605s|

All exact source/table and observation controls pass. The two consumed selector
workers lose42  ctor and 42 sink calls; their loops also lose redundant calls.
The unrelated search matches its complete independent output. The small safe
usage-summary kernel also passes, but 0.06469→0.06466s is neutral at this scale.
Smaller generated code is not automatically faster execution.

Complete hosted acquisition screens change19.518→19.916s (dispatch),
14.750→14.927s (usage), and 5.979→6.062s (search), each a single observation.
The changed general compiler API costs roughly16 seconds to acquire, avoiding
a full native compiler build for early experiments. This cheaper research path
uses existing maintained tools; no new autonomous search system was built.

## Qualification

The new N1 passes focused19. N2 passes all 64 ordinary qualification cases,
including the independent45-program corpus. All 66 selector/image/ownership
controls pass. The checked hosted image passes8 JS spot checks. Native self-
reproduction passes as described above. These are finite qualification gates;
full-language, parallel, GPU and kernel-proof claims are not implied.

The same checked hosted image also passes6 C spot checks after repairing the
maintained host adapter's C route. The adapter had incorrectly run direct-JS
dependency analysis before native emission; the older compiler image reproduces
the same failure. The corrected route matches the existing public CLI. This
was a workflow defect, not a newly introduced Bend semantic regression.

## Broad execution and request speed

Both compilers freshly acquired all 45 timed-wrapper programs and satisfied
their independent complete outputs. Two balanced timing rounds use unchanged
input points. Forty timed points meet the 100ms resolution gate at scale1;
four very fast closure/list points are repeated at scale64 for both roles.
The zero-work point remains correctness-only. No input point or output oracle
was changed, and the initial insufficient-resolution results remain preserved.

The closing artifact comparison establishes a stronger preservation result:
**all 45 QBE files, assemblies and objects are byte-identical** between compiler
roles. Whole ELF files differ and are not claimed identical. These ordinary
programs did not exercise a changed lowering result; the runtime observations
are consequently a neutral regression screen, not evidence of user-program
speed gains. The compiler itself and the selector witnesses do emit different
machine code.

Combining those explicitly identified44 point ratios gives **0.99896× Phase147**,
or effectively unchanged generated-program speed. Equal-source weighting is
0.99963×; mean positive log-slowdown is 0.002514; no point exceeds 1.05×,1.1× or2×.
The worst observed point is RLE at 1.0152×. Two rounds are a regression screen,
not confidence intervals. This is not a newly measured upstream ratio.
The original scale1 fixed-batch intervals sum 20.3135→20.2800s, including the
short intervals; that sum does not make every individual short ratio reliable.

Four balanced cold-request rounds per input measure compiler execution separately:

| Native compiler request | New / Phase147 |
| --- | ---: |
| Lexer |0.98054×|
| Map churn128 |0.97334×|
| Expression128 |0.96937×|
| Three-point geometric mean |**0.97441×**|

Each request checks its complete retained QBE product. Their acquisition outputs
were independently executed; each role can legitimately have different QBE.
The 2.56% request improvement and 3.89% full-build screen are consistent with a
small broad compiler gain. The 54% dispatch microbenchmark is not a54% compiler
speedup.

The runtime campaign exposed an independent harness bug: eligibility from the
last catalog row was reused for every row, incorrectly including the zero-work
control. A one-line per-case metadata fix and a mocked full-run regression test
cover both case orders and the 99/100ms boundary. All 10 offline benchmark tests
pass. Fresh manifests bind the corrected method; original reports were not
rewritten. The full scale1 report's aggregate correctly remains incomplete due
to the four short points. [Metrics](metrics.json) explicitly combines it with
the separate resolution run, rather than claiming one uniform-scale aggregate.

## Costs, negative evidence and retained artifacts

The 51 guarded jobs account for 1,746.14s (29.10min), including 766.35s for the
three full native builds and 224.12s for 90 benchmark product acquisitions.
Four failed guards total77.68s: one missing source-transport refresh output,
an offline-test stdlib import shadow, and the candidate/older-image C-route
failures. Two incorrect finite-control assertions were corrected by independent
review before their assertions ran. No failed evidence was discarded.

Peak aggregate RSS is 3,077,107,712 bytes during checked hosted API acquisition;
native full builds fit the ordinary2GiB cap. There was no guard OOM, timeout,
disk-reserve breach or pruning. All 51 jobs were closed through maintained
retention in 38.84s; the qualified N2 remains hot. See [cost](cost.json),
[qualification](qualification.json), [retention](retention.json) and
[replay/evidence](evidence/README.md). Guard time excludes agent work, static
source/machine inspections, Git and documentation. Three bounded agents assisted;
token/quota billing was unavailable and is not estimated.

The compiler transformations are Bend. Two existing host adapters received
metadata/routing repairs; no new host-language compiler or optimizer was built.
Promoted standalone component copies are retired after exact evidence archival;
the maintained modules own the implementation. Historical comparisons recover
their exact old source from Git or frozen assemblies, not today's reference
functions.

There is an avoidable cost in this campaign: the complete product acquisition
and timing ran before the exact 45-output identity comparison. Future iterations
should first emit against retained complete QBE references, preserve those
identity receipts, and build/time only changed products under the same runtime
and toolchain. Unchanged products are identity evidence, not invented timing
samples. This would have avoided most of the 90 machine builds and repeated
program execution here. The repeated broad run was additionally needed because
the first run exposed the harness eligibility bug.

## What we learned and what to do next

Preserving semantic facts across an existing optimization boundary removed a
whole category of work in thousands of real compiler functions. It generalizes
beyond the original two selectors and improves the compiler itself. The ordinary
user corpus is neutral: these source patterns are much more prominent inside
the compiler. The measured whole-build improvement also fits the prior profile's
rough 6% direct ctor/sink envelope; the removed nullary calls did not account for
heap-reclamation time.

Authenticated packed static values and raw static boxes offer a narrow follow-up,
but static boxes can acquire owning wrappers when stored into owning objects.
The [audit](../../research/phase152/prepared-values-contract.md) records that
boundary and remaining inline-constant keep sites. Their hotness is unmeasured;
the site census does not justify another large speed prediction.

For a large next gain, use the cheaper checked-API witness loop to investigate
complete allocation/representation work in lowering, rendering and frontend
publication, then refresh attribution on this qualified image. Preserve one
controlled full-build checkpoint after decisive component evidence. This phase
demonstrates self-optimization of the compiler executable; it does not establish
recursive acceleration in the rate of discovering further improvements.
