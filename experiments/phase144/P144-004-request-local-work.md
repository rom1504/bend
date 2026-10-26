# P144-004 — remove repeated work inside one compiler request

The refreshed native profile identifies three separable costs: parser prior-name
search, repeated constructor ownership queries during erasure, and intermediate
String construction while rendering function bodies and footers. All three can
reuse information or storage within one request without an incremental cache.

## Selected experiment

- Preserve an exact first-match parser prior index. The pre-existing generic
  index has different duplicate precedence, so substituting it directly is
  incorrect. Only four prior-lookup consumers use the new view; local declaration
  scans retain their existing behavior. Scope equality includes the optional
  view, and an absent view retains the original lookup fallback.
- Construct immutable constructor-ownership facts once at the checked request
  boundary. Carry them through the actual annotation/erasure path, retaining
  existing admission, malformed-input fallback and first-error behavior.
- Flatten body chunks together with their final footer. Avoid a completed body
  String being copied again merely to append the footer. The old renderer remains
  an independent complete-output oracle.

Integrated source01 also removes an unobserved rollback capture from the native
session adapter. Generic transactional rollback remains unchanged; its independent
session/batch gates are still required before qualification.

## Evidence so far

Source SHA `992893e6cf6a5bf7d6d092812b3a5da20852feca882005f32a91e607cef0483b`
passes upstream checking and72 finite controls (27 parser,35 ownership,10
rendering). Lexer, Map and closure QBE products are byte-identical. The qualified
Phase143 image builds a native N1, which emits the exact115,909,112-byte frozen
Phase142 QBE in266.862s. A fresh parent run takes304.534s:37.672s /12.37% less
compiler execution. One pair, candidate first; not a confidence interval.

The original runtime and frozen input are unchanged. Consequently this result
does not imply a generated-program speed change. It is not yet native N1/N2
qualification, a full source-to-executable time, or a smaller-input self-build.

The separate hosted parser extraction compares3,535,203 complete graph pairs,
including the prepared seed, with no difference. Both independently observed
and Bend-computed checksums agree over16,769,616 words. Hosted parse time is
95.069s versus63.458s; native attribution remains a separate experiment.

## Reproduction and negative evidence

`selfhost/build/phase144/integrated-source01/manifest.json` binds every overlay,
the exact parent and protected proof/verifier declarations. The preparation
scripts and original/candidate controls are under
`selfhost/tools/performance/phase144/{parser,ownership,emission}`. Compact
interim receipts are preserved in `implementation/phase144/checkpoint01/`.

Earlier parser extraction attempts omitted associated laws or misparsed a
quoted character. They failed source checking before native execution and are
retained. The corrected extraction uses declaration-preserving lexical masking.
A renderer slice containing a large captured constant timed out before QBE
emission; do not interpret that as renderer runtime or extend its deadline.

Next: attribute the integrated native savings with the improved stage profiler,
measure native parser cost, and qualify the selected composition once further
bounded experiments settle. No source law is newly proved by these finite tests.
