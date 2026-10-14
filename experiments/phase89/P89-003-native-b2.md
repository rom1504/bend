# P89-003: minimal native self-emission boundary

Status: feasibility audit. Test the assembled compiler before general module
loading. Identify required native foreign providers and trust checks, then tiny
IO controls before full self-emission. Cache identity, host effects and native
B2/B3 are separate gates. Do not mark an upstream-built native B1 self-produced.
[Design](../../design/phase89/bun-and-native-output.md).
