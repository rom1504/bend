# P86-003: attribute the native Map fail-stop without a compiler rebuild

Status: failure localized; root cause and repair remain open.

After correcting the prototype's exact Base `./effs/` spelling, Map compiles
correctly in the guarded JS sibling and ordinary B2 but native exits1 with
`runtime fail-stop`, at about60MiB RSS. Stop the positive timing campaign.

Discriminator: upstream's identical error text covers work-ring, block-shape and
reference-counting guards. Interpose the unstripped native executable's dynamic
`_exit` import in a tiny diagnostic-only shared library, preserve exit status,
capture the stack, and symbolize return PCs offline. This avoids changing the
compiler source/binary or another194s C build. Do not use diagnostic clocks as
clean timings. Preserve raw stack, source, binary bindings and assembly.

Observed chain: `WL_FID_NOA_EVAL_K8169` → `rfc_wrap` → `err_fail` → `_exit(1)`.
The call site attempts `term_keep` while retaining observer-evaluation values;
the failing runtime guard rejects a closure or task entering ordinary reference
counting. This is neither the OOM nor stack-depth diagnostic. Generated source
retains `_k_2` as a generic Term, while the Bend path includes untyped unsafe
higher-order forwarding and a typed continuation consumer.

This identifies the failure boundary, not whether the original cause belongs
to our unsafe representation use, upstream lowering, or both. Next: minimize
the typed/erased continuation case before altering a runtime safety guard.
No guard bypass, upstream edit, production fix or native-B2 claim is made.

[Report](../../implementation/phase86/README.md) ·
[Diagnostic methods](../../selfhost/tools/performance/phase86/README.md).
