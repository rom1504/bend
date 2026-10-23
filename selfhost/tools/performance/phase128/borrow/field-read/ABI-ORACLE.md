# Independent late-emission ABI oracle

Append `oracle-wrappers-v2.bend` to the checked field-template producer and export
`p128bf_oracle_module()`. Write its returned string verbatim to a fresh receipt
directory as `borrow-field-oracle.ssa`. This produces ten small functions through
the actual candidate `p111q_stmt`, covering widths0–8 and a descriptor/count
mismatch. It does not independently reimplement the template in a host language.

Compile that QBE file through the pinned QBE and assemble/link it with
`abi-oracle.c` using the repository's existing native command wrappers. Do not
link the production runtime: the fixture deliberately supplies a helper spy.
The coordinator owns execution and records source, QBE, object, tool identities,
commands, exit status and JSON result. A successful run has545 checks and zero
failures (35 valid cases and74 fallback cases, five checks each).

The C fixture supplies independently constructed raw/static-like fields and RFC
headers. It compares exact 64-bit payloads, output canaries, result count, complete
heap/header bytes and state bytes. Widths2–8 each cover raw low/high locations and
RFC counts1,2,16777215; payload location512 ensures a nonzero header high32.
No valid case may call the spy.

Malformed tags and constructor IDs use a null heap with otherwise valid state
and scratch. They must reach the spy once without a header/payload dereference,
preserve all arguments and return its distinctive status word unchanged. The
spy does no heap reads or scratch writes. Nullary, packed, boxed-width1 and
descriptor/count mismatch also exercise unchanged rendering. An erroneous
fast-path read can terminate the fixture instead of producing a pass receipt;
that is a failed test, not an expected production behavior.

This isolates **late-emission ABI equivalence and fallback dispatch**. The spy is
not an oracle for production runtime failure semantics: real malformed terms
reach the independently audited fail-stop helper path. Nor does the fixture
replace ordinary Bend ownership, source-admission, independent verifier or
native self-hosting qualification. Its custom function arguments are only test
plumbing and are not added to production segment IR or verifier permissions.
