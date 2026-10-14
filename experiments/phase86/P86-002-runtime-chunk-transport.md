# P86-002: reuse the existing canonical runtime chunks natively

Status: supported for template setup; no general host-performance claim.

P86-001's first native request produces exact ordinary-B2 C in84ms versus239ms
for the same-entry guarded JS. However, native runtime-template preparation takes
16,646ms versus43ms in JS; Base preparation is3,032/3,812ms. These are single
observations, not broad speed claims.

`ne_template_step` repeatedly builds `acc ++ one_character`. The C runtime's
cons-list strings make this quadratic, unlike V8's string concatenation. The
production host already avoids scanning by transporting five exact Bend-produced
chunks from `runtime-template.json`; the native prototype should do likewise.

Change only the experimental IO entry to read five authenticated chunks and
construct `NE_Parts`. Preserve the raw-scanning native image and its results.
The host tool copies existing generated data; it must neither parse markers nor
reimplement a compiler algorithm. Require the known template digest, matching
runtime digest, five exact pieces, and complete reconstruction of runtime bytes.

Discriminator: template transport should take milliseconds instead of seconds,
with identical complete C against JS sibling and ordinary B2. Keep its IO inside
the runtime-preparation clock. Base preparation still happens once per process
and must remain visible; this is not cold CLI parity or native B2. Retain the
first/fifth request distinction. A fresh checked image and C build are required
because the native entry changed, but no production compiler source changes.

Result: native template setup falls from16,646ms to1–2ms while complete emitted
C stays exact on successful controls. Base preparation, Lexer regression and
Map's separate native fail-stop remain. See [Phase86 report](../../implementation/phase86/README.md).
