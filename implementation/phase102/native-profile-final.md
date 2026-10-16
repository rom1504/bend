# Closing unchanged-native-compiler profile

`selfhost/build/phase102/native-map-profile03/report.json` profiles qualified
candidate03 B2 compiling the frozen cached `map_closed` source. It does not
rebuild or instrument the compiler source. A retained generic signal sampler
records physical instruction locations in the unchanged authenticated ELF.

Four isolated requests at each of8ms and13ms produce1,041 pooled samples.
All eight requests reproduce every C byte and every clock-stripped diagnostic
from the same-image qualification request. Requests include startup, preparation,
emission and teardown. They are profiling observations, not clean latency samples.

| Physical leaf | Pooled samples | Share |
|---|---:|---:|
| `term_drop` |305|29.30%|
| `span_fade` |208|19.98%|
| `p88_string_eq` |57|5.48%|
| `rfc_wrap` |44|4.23%|
| `p98_tag_eq_read` |44|4.23%|
| `p98_tag_eq` |43|4.13%|
| Direct String append |23|2.21%|
| `nq_uses` |20|1.92%|
| `nc_uses_term` |15|1.44%|

Ownership/storage release remains the largest visible cost after direct-worker
composition. This supports investigating retained aggregate observations and
short-lived ownership transfers before another round of arithmetic tuning.
It does not establish which callers caused these leaves, whether every operation
can be removed, or that all programs share this distribution. Compare an exact
generated-C intervention plus negative ownership controls before predicting a
broad speedup. Allocation/release must not be skipped merely because it is hot.

The reproducible command uses fresh output paths:

```sh
python3 -B selfhost/tools/performance/phase102/profile-native.py \
  --build selfhost/build/phase102/native-chain03/b2.json \
  --request-row selfhost/build/phase102/native-chain03/controls/05-cached-map_closed/b2/report.json \
  --sampler-report selfhost/build/phase102/observer-profile01/report.json \
  --rounds 4 --out selfhost/build/phase102/native-map-profile-new
```
