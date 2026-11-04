# P160-001 — execute our complete compiler request under bendc

Use Phase156's already checked1,565,433-byte request closure, original SHA256
6020f680fd96e59b5a629e3ba898aacfc7f85895e9b2b22f3f1426084f656ce3.
The `old` route includes live Base preparation, source parsing/checking,
optimization, independent native verification, output and teardown. Its existing
QBE executable and full-source118,227,421-byte independent QBE oracle are retained.

First gate: whitespace-only lambda compatibility with structural upstream parser
equivalence, followed by checked bendc emission. Machine construction is justified
only after successful admission and a measured generated-code size budget.
Preserve the Phase157 pinned Base and exact nine-site legacy IO adapter, if still
applicable; reject additional foreign assumptions rather than broad ABI patching.

Compare a smaller ordinary Map request first against the complete independent
oracle; then full-source or a complete real frontend stage. Bound disk/RSS and
stop on semantic failure. No full-image qualification or default replacement.
Separate unmodified and Phase159 allocator-policy identities if used. Runtime
policy changes cannot silently become explanations for historical self-emission.
