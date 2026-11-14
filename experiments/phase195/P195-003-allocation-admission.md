# P195-003 — global allocation budget ceiling

Joint allocation rejects bodies above256rows and selects32names. Test1024rows
with unchanged32-bit facts, graph verifier and legacy fallback. Version1 source
transport changed both limits but was never acquired; active version2 changes
only the joint gate. Actual diagnostics show only three ray owners affected;
nearest/editdist/tree/lexer alreadyjoint and Map's four large bodies exceed1024.

Static trace stack references increase690→853; old fallback supplied146regional
transient homes while joint selects32globalnames. First balanced ray ratio is
1.00147×baseline, effectively unchanged. Reject limit-widening as a standalone
speed improvement. Investigate composition of global and regional allocation,
not blind increase of a bitset width or admission limit.
