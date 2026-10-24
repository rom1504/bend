# P131-006 — remove unused borrowed scratch fields

Status: rejected as a performance change; retain the diagnostic evidence.

Hypothesis: a verified shallow reader copies more fields than its scalar consumer
needs. A whole-CFG demand mask can retain ownership guards, calls and fallbacks
while removing dead scratch stores and their source loads.

The runtime/alias audit classifies every scratch escape. The no-retain borrowed
field helper and count-zero special constructors permit the tested transformation.
The main reader shrinks745→635 machine instructions; the packet reader133→123.
All four independent ordinary outputs and30 timed outputs pass. Five paired
rounds show only0.21% less time for the use query and0.21% more for the record
query. A null-pointer-only alternative also gives no useful gain.

No production pass, source change or full compiler rebuild is justified. This
is a useful counterexample to equating static instruction elimination with speed.

[Research](../../research/phase131/field-mask.md) ·
[Runtime audit](../../selfhost/tools/performance/phase131/regions/nullary-buffer-audit.md).
