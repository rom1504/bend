# Phase146 — preserve accepted backend context

Start from `c85a25f`, using qualified Phase144 final04. Apply Phase145's actual
same-input verifier witness to a small optimization before broader IR changes.
Goal: reduce cold compiler execution while retaining generated products,
independent final checking, source conformance and a simple implementation.

## First experiment

The existing `P114SBoundary` already binds the immutable raw/static program,
its original-function/constructor ID tables, current direct functions and the
success of opening/checking that boundary. `p128raw_session_finish` discards
it before final verification, repeating raw/static checking and rebuilding IDs.

Retain this boundary through the private session continuation. Only after an
error-free successful open and invariant-preserving inline/range stages, reuse
the accepted unchanged original and its exact tables. Independently recheck all
actual final direct bodies using `p113e_functions`, then run the original array
namespace and transport namespace checks in the original order. Keep the exact
old `p128raw_lowered` fallback for a lowering error or rejected boundary.

Do not alter public raw/direct/array verifier declarations, runtime contracts,
ownership rules, optimization decisions or rendering. The carrier is existing
request-local immutable data, not a new general cache or caller-supplied valid
flag. Audit every entry/caller, including the incremental cold-fallback caller.
The private continuation is not a new arbitrary-input verification API.

Compare raw-check-only reuse with raw-plus-ID reuse on real prepared boundary
data if economical. This isolates work removed without repeatedly acquiring a
full native compiler. Never use a JS-only monkey patch as an accepted compiler
implementation; production changes remain checked Bend.

## Intermediate gates

1. Independently source-check the composed Bend candidate. Preserve all parent
   protected verifier/proof declarations and explicitly inventory overrides.
2. Use actual boundary factories in positive and negative controls: malformed
   raw/static input, invalid direct body, result/argument widths, unavailable or
   reordered callees, reserved namespaces, rejected open, prior lowering errors
   and context/ABI dependencies. Compare exact first errors with the original.
   Audit that no untrusted raw/context pair enters the private successful path.
3. Compare complete ordinary QBE on frozen Lexer, Map and closures, then actual
   compiler-index code. Reuse the parent checked API and native oracles. Keep
   historical batch/ordinary policy differences explicit. Measure whole request
   and verifier-boundary cost separately; diagnostic time is not clean speed.
4. If beneficial, acquire one native candidate using the qualified native parent.
   Require complete output equality on unchanged program inputs, a focused native
   correctness gate and native request timing. Compare the same frozen full
   compiler input for cold cost only after the cheap gates justify it.
5. Perform N1/N2 reproduction and broad ordinary qualification when promoting a
   new qualified checkpoint. Byte-identical complete loaded products can reuse
   prior runtime evidence; changed objects require fresh runtime controls. Keep
   the qualified parent and installed selection intact until justified.

If context reuse is negligible, preserve the result and investigate one complete
numeric-ID verifier environment or parser producer/cursor boundary. Do not add
an unrelated expensive refactor to manufacture a large gain. Conversely, extend
shared original facts only when the same provenance argument and measured costs
support it. Every step must remove actual request work, not merely add cache hits.

## Cost discipline

Root owns one CPU3 compiler/measurement lane. Bounded agents inspect source,
implement an isolated module and independently audit semantics; they do not
execute compiler or benchmark targets. Start with 3 GiB RSS, 16 GiB available
memory, 64 MiB small output limits and bounded jobs. Full emissions need explicit
larger file limits and disk headroom; the filesystem starts with about 458 MiB
free. Preserve pinned evidence/qualified images, investigate recoverable storage
before large builds, and avoid redundant full acquisitions or validations.

Commit design, successful code and reproducible report. Record negative attempts,
complete target/acquisition/validation cost, source growth and any unqualified
scope honestly. No new compiler theorem, upstream parity or 5–10× speedup is
assumed in advance.
