# P142-005: price the known ELF-auditor membership opportunity

Executed the already prepared Phase140 retained-object observer, with unchanged
qualified Phase135 receipts. It reconstructs the attested prior local-binding
view; it does not claim that deleted raw objects are still available.

Both auditors accept the two valid retained objects and agree on all eight
negative controls (allocated bytes, relocation change, symbol binding, remaining
local promotion). The reviewed sole change is list membership→set membership.

The large data object comparison takes0.5220→0.2486s; the smaller code object
0.02125→0.01484s. These single ordered component observations save about0.280s
combined, despite eliminating millions of membership comparisons. Metadata
extraction is separate (0.677/0.224s), and the full guard including copying,
hashing and negative controls takes13.064s.

This does not explain the historical11.133s non-child machine residual or
establish a complete build improvement. Keep the simple correction available,
but do not pay cache reseeding/migration costs or build a broader machine cache
solely for this saving. Direct retained-unit transport remains a different,
larger opportunity. Receipt: `selfhost/build/phase142/machine-audit01/report.json`.
