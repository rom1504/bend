# Pilot measurements

Median microseconds per call, including the batch checksum. Smaller is faster. Each call uses the displayed size and one of 32 runtime seeds.

| Input | Original AGY | Tuned AGY | Original C | Tuned C | Tuned QBE | Tuned Bend-to-C | Tuned AGY / C |
|---|---:|---:|---:|---:|---:|---:|---:|
| coverage-list-pipeline-128 | 0.3301 | 0.0043 | 14.0504 | 0.0027 | 0.0035 | 0.0011 | 1.61× |
| coverage-list-pipeline-512 | 1.2939 | 0.0043 | 57.1289 | 0.0026 | 0.0034 | 0.0011 | 1.60× |
| list-residue-257 | 0.6550 | 0.0069 | 28.3654 | 0.0029 | 0.0058 | 0.0019 | 2.34× |
| coverage-expression-32 | 0.1012 | 0.1227 | 4.8778 | 0.0519 | 0.1973 | 0.0831 | 2.37× |
| coverage-expression-128 | 0.3866 | 0.4534 | 19.9830 | 0.1918 | 0.7733 | 0.3222 | 2.36× |
| coverage-bst-32 | 1.3799 | 1.8541 | 11.8886 | 0.2942 | 1.5993 | 0.3821 | 6.30× |
| coverage-bst-64 | 3.2785 | 2.3810 | 33.0357 | 0.3986 | 2.0647 | 0.4870 | 5.97× |
| editdist | 520.8333 | 578.1250 | 494.7917 | 38.4115 | 588.5417 | 322.9167 | 15.05× |
| variation-editdist-0-17 | 129.8828 | 144.5312 | 124.0234 | 9.6436 | 146.4844 | 80.4036 | 14.99× |
| variation-editdist-3-123 | 1041.6667 | 1156.2500 | 992.1875 | 77.4740 | 1182.2917 | 650.0000 | 14.92× |

## Family and fixed-work summaries

The family ratios use the geometric mean across the historical sizes in each family. The extension point is shown separately above.

- list: 1.61× tuned AGY / tuned handwritten C
- expression: 2.36× tuned AGY / tuned handwritten C
- bst: 6.14× tuned AGY / tuned handwritten C
- editdist: 14.99× tuned AGY / tuned handwritten C

Equal weight per measured family gives **4.32×**. The following normalized batch times multiply median time per call by the corresponding native45 repetition count. The seed schedule is specific to this suite.

| Program | Seconds for measured native45 anchors |
|---|---:|
| original-agy | 0.6073 |
| original-hand-c | 5.9831 |
| tuned-agy | 0.5823 |
| tuned-hand-c | 0.0643 |
| tuned-qbe | 0.5952 |
| tuned-bend-c | 0.2838 |

## Fastest observed source per family

Here each side picks one source form for the whole family by its normalized fixed-work total on the historical sizes. This post hoc comparison includes the original and all attempted forms and is descriptive of these measured inputs.

| Family | AGY source | Handwritten C source | AGY / C (fixed work) |
|---|---|---|---:|
| list | tuned | tuned | 1.61× |
| expression | original | tuned | 1.98× |
| bst | tuned | tuned | 6.14× |
| editdist | original | tuned | 13.49× |

## Effect of changing the Bend source on each backend

Speedup is original runtime divided by tuned runtime. Values below one mean the tuned source ran slower.

| Input | AGY x86 | QBE | Bend-to-C |
|---|---:|---:|---:|
| coverage-list-pipeline-128 | 77.51× | 89.27× | 1314.08× |
| coverage-list-pipeline-512 | 304.33× | 354.85× | 5297.39× |
| list-residue-257 | 95.40× | 105.50× | 1465.47× |
| coverage-expression-32 | 0.82× | 10.31× | 25.95× |
| coverage-expression-128 | 0.85× | 9.69× | 26.58× |
| coverage-bst-32 | 0.74× | 6.13× | 9.11× |
| coverage-bst-64 | 1.38× | 12.76× | 20.06× |
| editdist | 0.90× | 1.79× | 2.59× |
| variation-editdist-0-17 | 0.90× | 1.80× | 2.60× |
| variation-editdist-3-123 | 0.90× | 1.78× | 2.60× |

## List fusion control

| Input | Fused AGY (µs) | Fused handwritten C (µs) | AGY / C |
|---|---:|---:|---:|
| coverage-list-pipeline-128 | 0.3482 | 0.1581 | 2.20× |
| coverage-list-pipeline-512 | 1.3794 | 0.6226 | 2.22× |
| list-residue-257 | 0.6971 | 0.3125 | 2.23× |
