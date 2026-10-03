# Checkpoint 06: selected compiler frozen for broad qualification

Selected candidate: **checked15**, API
`4a5bdf433610d5760a7296aa64d6c2afac5dfba720ea2ebb00a6706cde906d73`.
It is a checked B1 derivative. Phase41 remains installed pending final admission.

The last source change adds 25 lines to reuse canonical tuple, List and Bool
layouts for precisely proven owned eager constructors. It preserves the original
typed argument emitter, erased slots, field order and alias behavior. All bytes
outside the six admitted BST private worker/helper bodies remain identical to
checked13. Actual private constructor calls fall from Tuple12/Con8/True4/False4
to zero; the corresponding native literal sites replace them.

Actual compiler-output screen, three balanced rounds, milliseconds per call:

| BST size, seed | checked07 | checked13 | checked15 | Pinned TS | Speedup over checked07 | checked15 / TS |
|---|---:|---:|---:|---:|---:|---:|
| 32, 17 | 3.120082 | 0.203091 | 0.153840 | 0.013503 | 20.28× | 11.39× |
| 128, 17 | 42.784560 | 1.493758 | 0.891259 | 0.181910 | 48.00× | 4.90× |

The complete BST and independent sequential controls pass again for checked15.
See [prototype-summary07.json](prototype-summary07.json) for exact identities,
samples, ranges, deep observations and activation. These screens do not replace
the pending fresh 45-point final comparison or establish application-wide parity.

Four independent BST saved-output variants preceded this source change. Native
construction alone won; adding transfer-array changes did not improve it, so
those changes are excluded. The Map.bit dispatch prototype passed full values
and hostile traces but ran 30–44% slower, and is rejected. No Map source change
is included. This final selection closes optimization work for the release;
remaining work is broad qualification, measurement, installation and reporting.
