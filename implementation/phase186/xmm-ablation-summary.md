# XMM and U32-to-F32 ablation screen

The four-role, four-round screen is complete and position balanced. All48 timed samples and44 pilots pass exact output/count revalidation; no role exceeds10% max/min spread.

| Case | Full / no-XMM | Runtime reduction | Full / no-U32-conversion | Runtime reduction |
|---|---:|---:|---:|---:|
| Active ray256/2240 | 0.956560 | 4.344% | 0.716101 | 28.390% |
| Numeric recurrence256 | 0.999657 | 0.034% | 0.989669 | 1.033% |
| Local fold | 0.989973 | 1.003% | 0.986553 | 1.345% |

These are conditional contrasts against the full candidate: XMM disabled with conversion retained, and conversion disabled with XMM retained. They are not additive contributions. The three-case geometric-mean runtime reductions are1.811% and11.245%; these are narrow screening metrics, not full45 results.

The emitted ray program supplies a concrete mechanism. Disabling U32-to-F32 conversion replaces244 `cvtsi2ssq` sites with244 additional `p111_rt_op` call sites (41→285). Disabling XMM retention leaves arithmetic/conversion/helper counts unchanged but increases total emitted instructions23812→23994 and `movd` count1353→1605, removing199 `movaps`. Product-nearest and nearest.t each expand by52 instructions; each doubles its `movd` count72→144. Counts are static sites/whole function bodies, not dynamic retirement weights.

Local-fold is a useful negative control: all three assembly sources and linked `.text` bytes are identical. The only ELF section differences are build-ID and symbol/string metadata. Its roughly1% timing differences do not demonstrate an optimization effect. Numeric without XMM retains the same instruction counts with operand-load ordering differences; its0.034% result is effectively unchanged at this screen's precision.

The earlier `xmm-live-x86-runtime01` ray flag was confined to C: max/min1.144 versus before1.016 and candidate1.024. The target median ratio0.652618 (34.74% lower) is independent of the shared C denominator, while C-relative interpretation retains that dispersion caveat. Earlier local-fold separately had candidate max/min1.137; do not interpret its0.58% regression. Both original screens remain unchanged, and the ablation results are separately reported.

Exact report, compiler/source preparation and program pins, per-role samples, section hashes and instruction counts are in [xmm-ablation-mechanism-analysis.json](xmm-ablation-mechanism-analysis.json). No target jobs were run for this analysis.
