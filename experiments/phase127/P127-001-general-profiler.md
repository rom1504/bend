# P127-001: can reusable attribution explain native compiler cost?

Status: active. Parent `6fe4f29`; start2026-10-23 09:44 UTC.

Hypothesis: unchanged-binary samples plus a small generic context/counter layer
can distinguish repeated compiler work from runtime representation costs, making
the next optimization decision more precise without another broad rebuild.

Design: [general native profiler](../../design/phase127/general-native-profiler.md).
Qualified Phase125/126 N1 images and each image's own complete emitted-QBE oracle
are the initial fixed inputs. Independently specified ordinary programs test
generality. Clean timings and diagnostic captures are separate artifacts.

Falsifier: attribution stays in undifferentiated runtime helpers, changes program
output, materially distorts the computation without a useful clean counterpart,
or requires more machinery than its first measurable insight justifies.

Evidence and decisions will be appended as experiments complete. No target has
yet executed in this phase. Disk has147MiB free; initial preparation is read-only
analysis and small source files while immutable duplicate recovery is assessed.
