# P82-003: carry the exact merged source bound

Status: retained in selected compiler04; genuine B2 installed.

Hypothesis from [design section2](../../design/phase82/fixed-work-and-native-products.md):
native preparation can reuse a binder bound computed for the same source world,
without trusting arbitrary cache metadata or including generated temporary IDs.

`nr_prepare_annotated` builds the plain merged definitions, computes their bound,
then constructs the mirror index and runtime closure. Its request carries
`Some{bound}`. That index contains only the same source definitions, so traversing
the index and list again cannot increase their maximum binder ID. Source
ownership/main/layout checks retain their original ordering. Ordinary
`nr_prepare` carries `None{}` and `nc_compile_error` continues scanning raw input.
An injected driver API cannot select the owned preparation path.

Compiler03 fails the unrelated template-prefix affine check and is preserved.
Compiler04 passes checked B1/frontend36, raw31, the focused native gates,
native100, B2/B3 and installed/relocated controls. Both stages reproduce all12 C
benchmark outputs exactly. The owned/raw preparation comparison in compiler05
also preserves source, runtime book, names, foreign scope and paths, with only
the bound certificate differing intentionally.

The final paired compilation gain is measured for **template + bound reuse**:
5.10% B1/6.15% B2. There is no separate balanced bound-only comparison; do not
subtract gains from the earlier template screen to invent one. See the
[report and receipts](../../implementation/phase82/README.md).
