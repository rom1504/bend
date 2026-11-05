# P167-001 — compile only demanded executable representations

Hypothesis: creating ordinary direct workers once, generating only genuinely
demanded scheduler representations, and omitting the second global region/late
candidate pipeline removes enough backend work to improve complete compilation
substantially without unacceptable generated-program regressions.

This is not Phase164's omitted-worker-body treatment. Demand covers factories and
actual representation references; the final program is independently verified
and emitted directly. Real fallback remains; no fabricated reference bodies.

Screen with nonempty compiler verifier code and an ordinary mixed IO program.
Keep the unchanged optimized baseline, exact same input/runtime/toolchain and
complete source-to-executable clocks. A2× result earns transfer; a small gain or
large runtime regression falsifies the current combination. Source/measurement
identities, rejected cases and follow-up choices belong in the implementation
report. No10× or five-second prediction is established by the current cost model.
