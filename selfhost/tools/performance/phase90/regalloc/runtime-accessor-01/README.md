# Prepared large-table runtime integration

This candidate combines the upstream-compatible `__OPTIMIZE__` attribute guard with a host-only dispatch accessor when `FID_ENTER >= 4096`. It is not applied or qualified. Read `runtime-only.patch` for the small source change; `plan.json` binds the existing canonical runtime/template/driver and the checked compiler used for template generation.

`FID_ENTER` is a generated integer macro (`tables.bend`, nb_fids), inserted in the Tables payload by `ne_program_runtime`. It does not exist at the initial WL_DYN definition. The candidate leaves that initial direct definition intact, then conditionally redefines WL_DYN beside the later host table. That location is inside `#if !DEVICE`, after Tables and before emitted segments and all actual dynamic dispatch uses. `WL_POP` references WL_DYN at expansion time, so it also sees the selected route. The accessor uses `FAR PRESERVE(preserve_most)`, retaining the word-bank-friendly ABI while preventing inlining.

For optimized images below4096 entries, the accessor and redefinition are preprocessed away, retaining direct table dispatch. For unoptimized builds at every size, the separate guard intentionally removes unsupported preservation attributes. GPU dispatch is unchanged. The threshold4096 is a conservative policy boundary, not a measured universal crossover; the synthetic512/2048 controls show scaling but do not establish runtime overhead at4096.

Root integration steps:

1. Run `plan.json`'s `templateCommand` under the normal serial guard. This invokes the checked Bend runtime scanner; the host script does not manufacture template parts.
2. Run the listed `followup` command. It verifies the scanner's receipt, exact5-part round trip, unchanged parts1/3/4, and expected edits only in parts0/2. It produces `canonical.patch` covering runtime.c, runtime-template.json and the typed-driver template hash together.
3. Review/apply that patch only after the prototype gates succeed. Rebuild and qualify the actual B1/B2/release; do not treat an installed image as consuming the new runtime until those gates complete.
4. Check both sides of4096 using actual preprocessed host C, preserve the tiny dispatch/ABI controls, and compare independent native outputs. Measure small representative program execution and the full native compiler. GPU exclusion is a source audit here, not a GPU execution test.

The existing O0-only prepared patch is an alternative, not something to apply first: both plans are based on the same unchanged canonical inputs. Applying either invalidates the other's input check. No historical native image/cache receipt is rewritten by this plan.
