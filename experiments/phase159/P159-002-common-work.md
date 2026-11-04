# P159-002 — same computation, different execution machinery

Use Phase157's exact common compiler-owner workload. Reuse its independent full
output oracle and existing products. Separate fresh input preparation from one,
four and sixteen batches. The hypothesis of universally faster GC/direct calls
already failed in Phase157; profiles should identify which work changes with
repetition and whether one meaningful boundary is cheaper elsewhere.
No ratio against full compiler speed or generated-program corpus is inferred.
