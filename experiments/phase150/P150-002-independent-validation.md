# P150-002 — separate-process validation wall time

Status: finite two-process pilot passed; general scheduler not qualified.

Outcome: two pairs reduce whole guarded elapsed3.269→1.936s (40.78%). All8
independent qualification reports and required exact product comparisons pass.
The Bend coordinator uses the existing async legacy-JS provider under pinnedNode;
same-artifact Bun pipe failures remain negative evidence. No parallel native
heap, compiler-request speedup or CPU-efficiency claim. See
[results](../../research/phase150/parallel-validation.md).

Hypothesis: running identical independent correctness cases in separate heaps
reduces validation wall time without changing generated code. A small Bend
coordinator can reuse existing process supervision and qualification methods.

Falsifiers: Process.run serializes in the chosen host; coordinator overhead
exceeds savings; CPU/RSS/disk costs become unacceptable; child failures or wrong
outputs are obscured; overlap interferes with controlled performance evidence.

Use one aggregate guard, two explicit CPU cores, distinct child output roots,
one-worker/GPU-off native children, independently audited reports and exact
output oracles. Compare complete serial/parallel wall and summed child CPU.
This is not multi-threaded compiler qualification or a fresh generated-runtime
benchmark. See [design](../../design/phase150/README.md).
