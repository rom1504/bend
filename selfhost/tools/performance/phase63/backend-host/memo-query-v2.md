# Memo query v2: preexisting cache qualification

Use the same CLI as `memo-query.mjs`, replacing the script name with
`memo-query-v2.mjs`. Prepare the preferred Base frame in a separate worker first.
Every measured role then requires the exact frame3 cache keyed by the original
B2 image bytes, Base bytes and canonical Base path in the checked generator
snapshot. Missing preferred frames fail before the request clock.

The receipt pins this cache before and after, records its actual read count,
and blocks any cache-directory writes or replacements during the request. A
rejected frame that causes regeneration therefore fails qualification instead
of becoming a cold-cache timing. Cache content validation remains in the
unmodified driver; this controller does not duplicate the decoder. All roles
use the same hooks, supplied-API lane and filesystem guards. These guards add
a small common cost, so use only v2 roles together for a timing comparison.

The original Numeric baseline in query-memo01 created the cache and is not a
valid timing comparison. Its 35,273 WNF calls include that preparation. The warm
Numeric variants made only 1,265–1,325 WNF calls. Map used the preexisting cache
and showed 523/756 identity arity hits, eliminating 8,075 WNF entries. One round
is a useful opportunity screen, not a stable speed estimate.

All identity-key, immutability, bounded-capacity and diagnostic-only limits in
`memo-query.md` still apply. The original consumed controller remains unchanged.
