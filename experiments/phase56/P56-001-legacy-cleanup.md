# P56-001: delete unused legacy helpers without changing emitted behavior

Hypothesis: seven manifest-local helpers have no live consumers, including
maintained legacy tests and bootstrap clients. Removing their definitions reduces
source context without changing the checked API.

Design: [qualification and simplification](../../design/phase56/qualification-and-simplification.md).
Result: accepted. The source loses 42 physical lines, 34 code lines and seven
definitions; both checked and derived API bytes equal Phase55. All 36 strict
focused gates pass. The public legacy interface and helpers referenced by
maintained controls remain. [Report and exact evidence](../../implementation/phase56/cleanup.md).

The combined selected release also contains P56-002; its final legacy and package
qualification is recorded by the [phase report](../../implementation/phase56/README.md).
