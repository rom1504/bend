# A concrete backend-independent semantic query still coupled to C text

Bounded source and retained-QBE inspection; no target execution or implementation.
Inputs are the Phase131 source/QBE identities already pinned in
[the Bend audit](bend-opportunities-inputs.json) and
[Phase132 census](../../implementation/phase132/census.md).

The largest attributed owner, `ni_template`, occupies2,130,828 QBE bytes across
145 generated functions. Its source at31188 returns C expression templates such
as `U32_BIN($0, +, $1)` and `f32_rewrap(...)`. This alone does not show why a QBE
compiler needs it. The actual retained N2 QBE supplies that missing evidence:

| QBE line | Qualified-image caller | Consumer's source purpose |
|---:|---|---|
|175091|`$direct.nd_scalar_known` → `$direct.ni_template`|Template nonemptiness, excluding `f32_show`/`f32_read`; source32818.|
|275927|`$direct.nc_native_primitive` → `$direct.ni_template`|Template nonemptiness, plus array-known and `nat_divmod`; source32671.|
|2135862|Public `$direct.ni_template` adapter → private implementation|ABI wrapper, not a dynamic-hotness claim.|

The first two are concrete selected native calls, not merely source retained in
an unrelated backend. Their machine-independent answers are Booleans, yet the
implementation first selects a C-template String and compares it with empty.
The emitted callers retain generic String-equality and ownership operations.
`nc_native_def` feeds native reference identity, entry lowering and private-worker
admission; `nd_scalar_known` feeds native direct-call classification.

There is another source coupling: `nc_primitive_arity` at32681 obtains the C
template and detects `$1` with replacement/equality to infer unary versus binary
arity, after explicit array/atomic/`nat_divmod` cases. This inspection did not
trace every indirect/scheduler invocation of that helper. It is a source-level
dependency, distinct from the two directly witnessed emitted calls above.

QBE operation lowering already has a finite semantic/runtime catalogue:
`p111_op_id` at39580 and `p112_intrinsic` at41216 lower operations without reading
C templates. The opportunity is to consolidate **primitive semantic facts**
(recognized name, arity, scalar/result/effect category) independently from target
text, then let C template generation and QBE lowering consume those facts.
This is a small example of the fact-sensitive interfaces proposed in Phase133.

Do not overstate the mechanism. The3,082-line private `ni_template` body returns
many static tagged constants, so fresh C-template allocation per invocation is
not established. Its140 static constructor call sites are not dynamic allocation
counts or evidence all belong to result construction. What is demonstrated is
unnecessary text-valued selection/consumption and a semantic dependency on C
spelling. Dynamic frequency, removed allocations, request-time gain and how much
of the2.13MB owner would actually disappear remain unmeasured. Other C consumers
or conservatively registered fallback entries may retain some or all of it.

The cheapest next experiment is an exact scalar catalogue ceiling on these
helpers, preserving all old answers. Check every recognized template key,
array/atomic/`nat_divmod` case, `f32_show/read`, empty/unknown keys and malformed
names, including the old arity result for unknown keys. Verify catalogue/runtime
ID agreement independently; avoid assuming the C and QBE accepted-name sets are
already identical. Compare complete ordinary QBE products and current backend
behavior before timing the actual classification query trace. No new IR, parser
or backend is necessary to test this architectural cleanup.
