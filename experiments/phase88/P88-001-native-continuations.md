# P88-001: replace observer host closures with Data frames

Final status: accepted into current source. Seventeen complete old/new JS/native
observer products and45 broad C/execution points pass. Runtime closure-sharing
rejection is unchanged. [Report](../../implementation/phase88/README.md).

## Initial hypothesis (retained)


Status: implementation, before checked controls. The Phase87 eight-case matrix
proves unsafe eager/double reuse is the native fail-stop mechanism; inline types
are not a repair. Eight reusable frame variants preserve continuation behavior.
Compare complete NO_Analysis values against the original implementation, then
whole Map C against installed B2. Track every failure and retain old source.

[Design](../../design/phase88/native-correctness-and-speed.md).
