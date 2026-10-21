# Final-source02 emitted reachability census

Read-only census of the existing 74,220,801-byte QBE product, SHA256
`f1abc6d75d176e30d4528f796bd9c866b20964cc74248c929e6b51deb7c4024b`.
The companion [JSON](reachability-census.json) pins that product, its completed
emission report and source02. No compiler, assembler or program was run.

The 2,885 reachable source names expand into **35,767 registered segments**:
2,885 named factories/other entries, 2,870 direct entries, and 30,012 generated
continuation/lambda segments. All remain address-taken by `p111_segments`.
The module contains 45,931 function definitions in total.

| Private implementation family | Definitions | Definition-only symbols | QBE text bytes in definition-only functions |
| --- | ---: | ---: | ---: |
| Complete direct/product (`p113d`) | 827 | 198 | 1,676,030 |
| Legacy workers (`p112w`) | 9,299 | 8,842 | 4,041,081 |
| Recursive workers (`p114r`, H selected here) | 37 | 0 | 0 |

**9,040 private definitions, occupying 5,717,111 QBE text bytes, have no other
symbolic reference in this module.** These functions are not exported. The
count includes neither their possible transitive callees nor any proposed
scheduler-table pruning. This is a narrow textual unused-definition census,
not a new semantic removal certificate or an estimate of object size/time.

For registered public implementations, 619 wrappers call a complete direct
worker and 37 call an H worker. The other 35,111 retain generic/legacy routes.
No R or G worker was selected in this product: all 37 emitted `p114r` bodies
contain the H dispatch structure. The selected source's dispatch is direct
first, then H, then the retained R/G fallback chain
(`recursive-table/first-entry.bend`, `integration.bend`).

Those H bodies contain **42 distinct continuation-FID comparisons**. All 42
identities still have callable original bodies and table entries, totaling
36,072 bytes of QBE function text. In H, `p114h_dispatch` compares the popped
FID to choose a local case; the comparison is an **identity test**, not a call
to the original continuation. This confirms retained representation of the
same continuation cases, but does not establish that other scheduler paths
cannot invoke the originals.

Only two of those 42 FIDs appear in literal `p111_rt_frame` calls across the
whole emitted module; none appear as literal jump/closure targets. That is
deliberately **not** a dead-code test: the transport expansion writes FIDs into
frames through ordinary stores, and closures dispatch indirectly. Arbitrary
numeric constants were not guessed to be FIDs. Across the module, exact
literal helper arguments expose 17,039 jump sites and 16,733 closure sites;
these include retained code and do not measure dynamic use.

The smallest next gate is therefore the private-symbol inventory, before a
new scheduler reachability analysis. The existing renderer emits every direct
function and every legacy registry entry (`p113e_registered` and
`p113e_old_private_chunks`), even when selected output has no symbolic user.
A future typed emission plan could track used private symbols while retaining
the complete original scheduler table and unchanged final verifier. It would
still require ordinary output and self-host qualification. No removal or
performance claim is made here, and no selected source was changed.
