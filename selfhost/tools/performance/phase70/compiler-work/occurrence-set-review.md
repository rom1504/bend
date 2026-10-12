# P70-006 independent source review

Reviewer: `/root/phase69_review`. No imports or targets executed.

Source review passes under the actual `nc_uses` empty-seed, uniform-marker
invariant. The collector's mutually recursive functions have no independent
production callers importing arbitrary indexes. Full U32 keys are exact; zero
split mask means the same ID. Existing buckets contain the same singleton marker,
so avoiding replacement retains the complete tree value. Missing and novel IDs
use the existing algorithm. Malformed Var children remain leaves. This does not
establish equivalence for forged internal helper arguments with varying payloads.
Uses08/Reuse11 did not implement this insertion optimization.

Method review passes: complete index/partition/share comparisons and independent
Var-as-leaf membership/ordered strings; full-bit and zero/MAX boundaries;
duplicate-heavy and unique-key cases; metadata and empty-environment poison.
Counters are sampled immediately around `nc_uses` before extra live/share calls.
Appended wrappers call original closures and the original checked image prefix
remains byte-exact. Root must bind images to checked acquisition receipts.

- Patch SHA256: `c18804873f5a2b7456bfb8ad567b2f863c347266895b206587b69d57dbf771c8`.
- Controls SHA256: `c192aa2c24f14e9ebd40fd2d93eb9deccf96f35f629fe90319a8ea2d6b768ea3`.
- Controller SHA256: `1deb90d9ff682ccba076396cc5040debeb959e68b2852dffb97bee74b6cb20ba`.

No source or method blocker found; this is not a correctness or speed result.
