# Phase171 follow-up evidence snapshot

Snapshot: **2026-11-06T17:19:49.542373+00:00**. Base checkpoint: `c5d17c0597e147c4010e14f40e4cbb45c2983539` (2026-11-06T16:37:55+00:00). This read-only inventory executed no compiler, generated target or profile. Root-owned native work continues; later runs are outside this snapshot.

The inventory contains **44 terminal jobs**, **35 successful guards** and **9 nonzero guards**, totaling **371.746s (6.20min)** of guarded target-lane elapsed time. 4 jobs started before the commit but were absent from its ledger; they remain explicitly marked. Strictly post-commit starts total 336.137s across 40 jobs. In-flight jobs observed: 0.

Agent token/quota use, agent reasoning time and complete session elapsed cost are unknown. Guard elapsed time is not exclusive CPU and does not count thinking/preparation between jobs. Exact receipt hashes, artifact identities and failed diagnostic pins are in [followup-evidence.json](followup-evidence.json). Existing reports and stage files are unchanged.

| Family | Terminal jobs | Nonzero guards | Guard wall seconds |
| --- | ---: | ---: | ---: |
|descendant|33|7|209.532|
|liveness|4|0|60.869|
|render|7|2|101.345|

## Results at the snapshot

| Experiment | Completed evidence | Interpretation |
| --- | --- | --- |
|liveness|44 controls; exact full verifier QBE; hosted 29.032→29.514s (1.01659×)|No demonstrated complete-request speed gain. Earlier baseline, one candidate observation.|
|render|44 controls; exact full verifier QBE; hosted 29.013→29.176s (1.00563×)|No demonstrated complete-request speed gain. One fresh observation per role.|
|Descendant source11|15 finite controls; static admission for index_bucket and index_find; 18 complete records match the separately generated literal expectation|Implementation/finite lifetime evidence only; no general qualification.|
|Bucket treatment|Four rounds/eight exact outputs; 0.557837→0.562667s (1.00866×)|Approximately neutral on this complete tiny-book fixture; not a whole-compiler gain.|
|Index-find treatment|Four rounds/eight exact outputs; 0.558366→0.555876s (0.99554×)|Approximately neutral on this complete tiny-book fixture; not a whole-compiler gain.|

The timed descendant fixture includes setup, complete result consumption and teardown. Its repeated tiny books and Phase166 consumer limit generalization. Static proposal admission and matching output do **not** establish dynamic use of the borrowed fast path: the timing receipts contain no root/result-guard acceptance counts. The 18-record, 2,394-byte output gate is separate from the timing digest; its millisecond timings are unresolved and are not a speed result.

## Negatives remain evidence

Source11 `descendant-list-emission11` failed with `descendant: no actual direct owner`; no generated machine target ran for that refused emission. It remains a failed guarded attempt. Source09 bucket inspection also explicitly refused the source parameter/result shape; source11 admission does not retroactively change that result. Earlier descendant/render parser/type acquisition failures remain separately pinned below.

Neither the liveness nor render treatment has earned a native full-build claim from these observations. The original 4.21% checkpoint result is unchanged; no new promotion, broad program-runtime result, upstream parity claim or independent BendTT proof follows.

## Guard inventory

Paths below are under `selfhost/build/phase171/`; each maps to the exact full SHA256 in JSON. `success` means the guarded tool exited zero, not that every optimization was admitted.

| Run | Status | Seconds | Guard SHA256 prefix |
| --- | --- | ---: | --- |
|descendant-api01 (pre-commit unaccounted)|failed 1|2.880|`cd266202b4a070b7`|
|descendant-api02 (pre-commit unaccounted)|failed 1|3.150|`04cdbdc19599e238`|
|descendant-api04|failed 1|2.894|`0862123d1351b01a`|
|descendant-api05|failed 1|5.491|`34ab1f5f3750656a`|
|descendant-api06|failed 1|6.189|`ef329ae4de38790e`|
|descendant-api07|failed 1|5.092|`5b847dc162c564ad`|
|descendant-api08|success|14.822|`3989cbc05c776e42`|
|descendant-api09|success|15.380|`97a879dcf6994405`|
|descendant-api10|success|14.978|`631818373a2ff0d2`|
|descendant-api11|success|15.271|`bc710aa4c7902844`|
|descendant-bucket09|success|10.290|`28b87fa692732df9`|
|descendant-bucket11|success|10.396|`3dc9f75329ac97ad`|
|descendant-constants11|success|1.595|`4f7b68edd0aebfcf`|
|descendant-controls09|success|1.615|`6c87b852bc508e95`|
|descendant-controls11|success|1.615|`297c56a826e41938`|
|descendant-find-emission11|success|11.401|`33de6d372dbd7f02`|
|descendant-find-machine11|success|0.966|`867d6e6eec674a93`|
|descendant-find-pair11|success|4.682|`d978a64f17f8ba58`|
|descendant-find-values-machine11|success|0.208|`d074df4ef1209fd0`|
|descendant-find-values11|success|10.340|`a729ea026ef5c436`|
|descendant-index-find11|success|10.385|`94271b5048711f6f`|
|descendant-list-emission11|failed 1|5.130|`cd919bfbed74359d`|
|descendant-lookup-baseline11|success|10.668|`b27064ab9d4f7b3f`|
|descendant-lookup-descendant11|success|11.431|`da3189cd7e22fcb8`|
|descendant-lookup-machine-baseline11|success|0.986|`a09f38af23abfcc2`|
|descendant-lookup-machine-descendant11|success|0.823|`12648c7605e70e2e`|
|descendant-lookup-pair11|success|4.742|`20a730ed4eb3522c`|
|descendant-shape10|success|7.931|`7c37eddfe3a5e596`|
|descendant-values-actual11|success|10.031|`c16b4c8570472dbd`|
|descendant-values-expected11|success|7.593|`62d08266797b4ac2`|
|descendant-values-machine-actual11|success|0.208|`d0e6aca905059977`|
|descendant-values-machine-expected11|success|0.268|`5096b6b0e67b1378`|
|descendant-values-native11|success|0.085|`6dd4c9941c085df7`|
|live-baseline-api01 (pre-commit unaccounted)|success|15.106|`362d8d547e5d038f`|
|live-candidate-api01 (pre-commit unaccounted)|success|14.473|`0f37d9e84d557c23`|
|live-controls01|success|1.413|`6b963cdb48fe3159`|
|live-verifier01|success|29.877|`78116ef1f691756a`|
|render-baseline-api01|failed 1|2.963|`aca61d0014673f6e`|
|render-baseline-api02|success|15.132|`31497b45207f40eb`|
|render-candidate-api02|failed 1|2.695|`170f7c1ee5dfe549`|
|render-candidate-api03|success|15.733|`1e2dd3b9c1261e5f`|
|render-controls01|success|5.912|`b2ebfe3707a81dd0`|
|render-verifier-baseline01|success|29.375|`edb0f166a1b33024`|
|render-verifier-candidate01|success|29.536|`a2ab59c6cdb413a3`|
