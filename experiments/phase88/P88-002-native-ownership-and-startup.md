# P88-002: remaining ownership cost and Base preparation

Final status: accepted in the separate native pilot. Single Base check,
phase/caller attribution and authenticated Bend Data decoding qualify. Base
startup is58–59ms including cache read/decode/cleanup; full product and refusal
gates pass. Native B2 and general host support remain open.
[Report](../../implementation/phase88/README.md).

## Initial hypothesis (retained)


Status: attribution/prototype preparation. Phase87 removes quadratic text work,
leaving term_drop/span_fade about3.8s over a five-Lexer process and Base~3s per
process. Existing leaf profiles do not identify allocation callers or phase.
Use bounded timed samples and authenticated CFI to recover surviving native
callers without a rebuild. Only measured source mechanisms become candidates.
Prepared-Base persistence must preserve hash/version/checker/trust identity;
resident reuse is amortization, not a faster fresh compiler invocation.

[Design](../../design/phase88/native-correctness-and-speed.md).
