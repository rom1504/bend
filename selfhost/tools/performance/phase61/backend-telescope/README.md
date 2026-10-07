# Private backend specialization prototype

Source-only proposal; no live compiler source edits or targets by this owner.
[Architecture and evidence](../../../../../implementation/phase61/backend-types-next.md).

`draft01/specialize.patch` adds a 34-line direct-only helper and redirects four
constructor/matcher/calls specialization sites. It reuses the existing checked
beta-stability grammar and fused environment materializer, bounded to 64 pending
bindings. Empty/single arguments keep the old helper. Unknown/unsafe/exhausted
steps realize pending bindings and run the complete original `j_specialize` on
remaining arguments, including its `Absent` propagation and later traversal.
No eager `env_tele_fill`/`Error` substitution is made. Manifest records live
parent hashes and existing admitted-materializer hashes. `git apply --check`
passed; independent review and root application/build are separate gates.

After a genuine candidate checked B1 exists, root can run under its existing
bounded CPU3 job guard (no nested guard in this controller):

```
NODE --max-old-space-size=1024 --stack-size=4096 \
  selfhost/tools/performance/phase61/backend-telescope/controls-v1.mjs \
  selfhost/build/phase61/checked-state06 NEW_CHECKED_ATTEMPT FRESH_PHASE61_OUTPUT
```

The controller pins actual attempts/APIs, strict flag and completed36-check zero
agreement, raw source helpers and its own dependencies. It appends probe exports
and inert counters with an Acorn-checked exact inverse; it does not replace any
compiler operation. Twenty-four cases compare old/new/retained-legacy complete
KTerm values and independent expected values, including malformed-head `Absent`,
erasure, dependent replacements, duplicate binder IDs, aliases, beta/unsafe
fallback, spans, KLambda metadata, and 63/64/65/129 bindings. Empty-list original
identity and caller-input retention remain. A parametric `jd_ctor_checked` bridge
must execute the new helper/cursor and produce the same complete constructor.
This is bounded explicit first-order IR coverage, not a malformed getter/cycle
host ABI or fresh source frontend qualification.

Only after those gates should root produce genuine B2 and compare ordinary
Numeric/Map/lexer requests with the existing qualified exact-output packets.
The proof scans can cost more than saved reconstruction, especially on tiny or
one-argument telescopes. Reject if clean requests regress or eligible work is
small; no speedup or allocation savings follow from the static proposal.
