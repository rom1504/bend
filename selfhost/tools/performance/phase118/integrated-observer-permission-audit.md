# Optional independent observer permission

`integrated-observer-permission.bend` is a separate, unqualified overlay after
the frozen conservative `integrated-entry.bend`. It overrides only
`p118e_prepare`; prepare-v4 therefore needs `--module-overrides p118e_prepare`
in addition to the ordinary parent overrides. No existing module is modified.

The reason is compiler-as-workload transfer: a program using trusted File
providers fails the packed-scalar `ns_definitions` predicate, so the conservative
integrated entry cannot give its pure observers the new borrowed lowering.
Mature C already splits these permissions in `nr_compile_prepared` and
`nc_compile_checked`. This overlay reuses that existing distinction.

The exact additional predicate is `no_effect_definitions(book,names)`, without
any whitelist or definition changes. It requires ordinary checked definitions
to contain no `Rwt`, and foreign definitions to have both the trusted marker
and a filled `Foreign` body. Its permitted foreign names are exactly:

- `IO.args`, `IO.print`, `IO.now`, `IO.print_err`;
- `File.open`, `File.read`, `File.size`, `File.write`, `File.close`.

It does **not** admit `File.read_bytes`, `File.write_bytes`, `File.read_at`, or
`NativeHost.*`. Those being present in the QBE runtime capability catalogue is
not evidence of observer safety. Query `p118i_permission(request)` on the exact
checked compiler request before considering native acquisition. That exported
Boolean is a diagnostic observation, not a caller-supplied production authority.

The integrated entry still checks source and original IR, and ordinary planning
still performs `p111_runtime_admission`. Selected Base/runtime/provider identity
must remain authenticated by the existing host/native capsule process. The
observer classifier's trusted bit is meaningful only under that existing
boundary; matching provider names alone is insufficient.

For scalar-enabled requests the previous integrated path is unchanged. For
scalar-disabled requests the optional path derives only observer workers, and
only if the unchanged mature observer predicate succeeds. The original
constructor metadata, `scalar` and `unshared` flags stay unchanged. This path
never calls `nh_definitions`, `p118c_candidates`, `p118c_apply_verified`, or the
cold preparation continuation. Array and cold permissions are not broadened.

Every selected observer still passes the NO schema/residual and wrapper/root
checks, and every nonempty added worker set still passes `p118b_compose`'s
structural checker. NO excludes owning Array roots, allocating Word views and
foreign calls within the observer body. Functions that cannot be derived remain
on their original implementation. The optional route uses the same failure
semantics and candidate order as the conservative integrated entry.

Minimum qualification: predicate inspection on the exact compiler request;
pure controls showing identical QBE; authenticated File/IO controls exercising
root-preserving observers and complete outputs; ordinary shared-root and alias
controls; then a measured native compiler workload. Preserve the false result
if another unsupported provider or source form prevents permission. Do not
expand the whitelist to obtain a desired benchmark result.

This is source-reviewed code only. No compiler, target, benchmark or native
qualification was run by the audit agent. Any transfer to compiler speed is
unmeasured until the root completes those gates.
