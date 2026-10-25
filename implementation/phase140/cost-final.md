# Phase140 final cost inventory

Snapshot **2026-10-25T18:12:15+00:00–2026-10-25T20:59:25.053885+00:00**; elapsed **167.17min**.
Numerical inputs and exact pins: [cost-final.json](cost-final.json). Earlier20:34 cost-review files remain unchanged.

Only terminal guards are charged, including failures (`complete:false` with a terminal exit). Pending work is listed separately.

| Completed workflow | Runs | Success / failure | Guard seconds |
|---|---:|---:|---:|
|Checked API acquisition|44|22 /22|419.56|
|Complete native compiler-edit loops|4|4 /0|2272.36|
|Generated-product machine build|1|1 /0|14.75|
|Hosted finite/semantic/product checks|35|28 /7|459.17|
|Independent full-product oracle|1|1 /0|334.54|
|Native compiler acquisition|4|4 /0|1475.59|
|Native compiler machine build|4|4 /0|65.62|
|Native smoke/request checks|7|7 /0|27.62|
|Profiling campaign|1|1 /0|480.19|

Completed guards: **101**. Summed workflow wall: **92.49min**; interval union: **91.40min**.
Failed guards: **29**, **132.41s** target time. Outside completed intervals: **75.77min**, not an idle-time measurement.

## Candidate acquisition and size

| Source | SHA prefix | Lines | Code-line approximation | Source bytes | Emission guard | Machine build |
|---|---|---:|---:|---:|---:|---:|
|03|c0a45049c8a4|62,012|45,009|2,859,986|358.81s|15.12s|
|15|9d6ac8d5ae35|63,587|46,202|2,939,395|367.62s|15.32s|
|17|fcef9aa66f8f|63,993|46,506|2,961,899|373.15s|15.52s|
|18|c9ded5523c4d|64,408|46,808|2,978,442|376.01s|15.37s|

Machine-build and stage timers below are nested explanations; do not add them again to guard totals. Acquisition is not compiler throughput or qualification.

## Completed native loop stage observations

| Receipt / revision | Frontend | Raw | Backend | Registry | Render/close | Total |
|---|---:|---:|---:|---:|---:|---:|
|full-product01 /A|137.091s|56.493s|74.256s|15.423s|51.023s|334.286s|
|full-product01 /B|51.394s|44.820s|35.266s|12.805s|9.266s|153.551s|
|full-batch01 /seed|134.031s|70.679s|93.104s|15.390s|49.689s|362.893s|
|full-batch01 /inline-policy|53.058s|15.497s|45.100s|11.948s|8.044s|133.647s|
|full-batch01 /continuation-policy|58.181s|15.828s|42.966s|11.622s|7.814s|136.411s|
|full-batch01 /product-policy|59.385s|15.751s|44.409s|11.967s|7.853s|139.365s|
|batch-smoke01 /seed|0.276s|0.211s|0.754s|0.077s|0.232s|1.550s|
|batch-smoke01 /edit|0.403s|0.129s|0.297s|0.035s|0.051s|0.915s|
|batch-smoke01 /revert|0.401s|0.131s|0.304s|0.036s|0.052s|0.924s|
|batch-smoke01 /edit-again|0.401s|0.129s|0.300s|0.036s|0.052s|0.918s|
|batch-smoke02 /seed|0.277s|0.214s|0.752s|0.078s|0.232s|1.553s|
|batch-smoke02 /edit|0.408s|0.129s|0.297s|0.035s|0.052s|0.921s|
|batch-smoke02 /revert|0.405s|0.129s|0.295s|0.035s|0.052s|0.916s|
|batch-smoke02 /edit-again|0.407s|0.129s|0.315s|0.037s|0.052s|0.940s|
|full-product02 /seed|129.648s|74.884s|93.643s|15.339s|50.615s|364.129s|
|full-product02 /product-policy|31.319s|14.161s|40.652s|11.389s|7.707s|105.228s|
|batch-smoke03 /seed|0.272s|0.210s|0.748s|0.076s|0.229s|1.535s|
|batch-smoke03 /edit|0.401s|0.127s|0.285s|0.032s|0.047s|0.892s|
|batch-smoke03 /revert|0.403s|0.128s|0.287s|0.032s|0.048s|0.898s|
|batch-smoke03 /edit-again|0.402s|0.127s|0.290s|0.032s|0.049s|0.900s|
|full-product03 /seed|135.016s|73.657s|89.905s|15.209s|49.590s|363.377s|
|full-product03 /product-policy|30.966s|13.306s|40.079s|9.902s|6.777s|101.030s|

full-product01: independentProductsExact=False; native=490.786s, enclosing runner=505.593s.
full-batch01: independentProductsExact=False; native=776.487s, enclosing runner=797.556s.
batch-smoke01: independentProductsExact=True; native=4.581s, enclosing runner=5.747s.
batch-smoke02: independentProductsExact=True; native=4.631s, enclosing runner=5.870s.
full-product02: independentProductsExact=True; native=473.125s, enclosing runner=483.949s.
batch-smoke03: independentProductsExact=True; native=4.522s, enclosing runner=5.704s.
full-product03: independentProductsExact=True; native=468.140s, enclosing runner=479.423s.

## Scope and pending work

- Guard wall is workflow time, not aggregate CPU time, agent effort, token use or quota consumption.
- Interval union accounts for overlapping guards. Nested native, build, stage and transport timers are never added again.
- Intervals outside completed guards include implementation, coordination, unguarded work and pending runs; they are not measured idle time.
- Historical acquisition and qualification outside the campaign are excluded. Prior Phase140 attempts and failures remain charged.
- Scope is the two bounded guard globs; unguarded metadata/finite work is not comprehensively metered.
- Source/module bytes are rehashed. ELF bytes are reported from the completed build receipt; executable contents are not rescanned.
- Completed loop status does not establish independent semantic qualification; each exact-oracle flag is retained.
- Stage observations are single exploratory runs; matching inputs/checkpoints and repeated timing are needed for causal performance claims.

For interpretation and efficiency lessons, see [the earlier cost review](cost-review.md). Source03/15/17/18 and differently sequenced edit batches are not interchangeable controlled ablations. Confirm exact oracle status and matching source/checkpoint inputs before attributing a gain.
