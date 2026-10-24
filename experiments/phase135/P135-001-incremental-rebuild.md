# P135-001 — Real compiler edit reuse

Status: bounded native experiment complete; no promotion.

[Design](../../design/phase135/README.md) ·
[Report](../../implementation/phase135/README.md) ·
[Metrics](../../implementation/phase135/metrics.json).

1. **Late semantic hits transfer to full compiler speed.** Not demonstrated.
   Actual B reuses1387/1507 entries but takes374.922s, versus364.183s through the
   same executable's ordinary entry. Different clock boundaries and one pair
   prohibit a stable regression estimate. Both outputs exactly match independent
   full B. Do not extend this cache based on hit count alone.
2. **Compiler-announced boundaries permit real object reuse without a whole-QBE
   discovery scan.** Demonstrated on native A→B:56/66 objects reused, both full
   payloads exact; independent cold B has identical loaded sections/ELF headers.
   An A-only cache replay verifies the actual hit/miss mask, avoiding polluted
   all-hit B measurements. Replay15.979s versus cold38.906s includes authentication.
   However monolithic machine construction still takes14.699s guarded, versus
   cached replay16.064s. This is not a net development-loop win.
3. **Late constructor-ownership summaries provide a general cheap preparation
   gain.** Correctness passes29 controls and18 hosted full products, but timing is
   mixed and insertion misses earlier queries. No native acquisition or adoption.

Native stage B: frontend175.080s, raw lowering62.179s, optimize/verify68.360s,
render/backpressure72.677s.62.7% precedes the existing cache.18 compiler-output
checks and6 ordinary executions pass; three-case compiler request ratio0.99305×
monolithic is effectively flat. No new broad45, N1/N2, upstream or program-runtime
score. Qualified Phase134 and installed selection remain unchanged.

Preserve the failed Boolean host bridge and the refused overlapping guard launch.
Next split frontend substages and prove useful early prepared-definition reuse;
remove backend bookkeeping overhead before promoting the machine path.
