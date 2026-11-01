# Phase147 final classifier integration: profile addendum

The final compiler retains the renderer and compact-admission improvements and adds the exact runtime-name Boolean classifier. Against the intermediate image, the registry interval falls **16.834s → 15.944s (5.28%)**. The clean full build changes **246.745s → 246.173s (0.23%)**: one observation per image does **not** establish a reliable additional whole-build gain. The classifier is a small simplification with local evidence, not an 11× compiler speedup.

The initial two-optimization comparison remains unchanged in [profile-comparison.md](profile-comparison.md). This addendum records three separate images and their exact inputs in [final-profile.json](final-profile.json). It launches no targets.

## Images and scope

| Version | Compiler image | Compiler source | Changes |
|---|---|---|---|
| Baseline | Qualified N2 `367b6399…d251` | Prior qualified source; fixed-request compatibility independently established | Before Phase147 |
| Intermediate | Candidate N1 `4a925b35…3042` | `15e24090…ec80` | Fragment rendering and compact direct admission |
| Final | Candidate N1 `a3759313…2796` | `0f3bd8a0…7eaf` | Previous changes plus the exact 25-name classifier |

All three process the same frozen **3,010,912-byte request source** (`00940ed5…fb5e`), prepared Base and serial runtime configuration. Both clean and diagnostic runs emit exactly **117,232,528 QBE bytes**, SHA-256 `dceae94a7659ad1ff58395ed34914971422ff9e5841668e910cd95e6b0914010`. Final-image source/object/QBE mappings were derived anew; no older program address or FID map was reused. Qualification of the final N1/N2/Q3 chain is a separate gate, not a consequence of this profile.

## Clocks and profile quality

| Metric | Baseline | Intermediate | Final |
|---|---:|---:|---:|
| Clean full-build wall | 262.496s | 246.745s | 246.173s |
| Emission + QBE pipeline | 256.054s | 239.702s | 239.146s |
| Diagnostic compiler wall | 251.358s | 238.697s | 235.520s |
| Diagnostic staged thread CPU | 249.365s | 236.915s | 233.624s |
| Total samples | 7,794 | 7,405 | 7,302 |
| Exclusive-stage samples | 7,750 | 7,362 | 7,259 |
| Boundary/outside samples | 44 | 43 | 43 |

The final clean result is **6.22% below the baseline**. The additional classifier contribution is not reliably separable in the clean clock. Diagnostic wall is 235.520s in the final run, but this instrumented compiler process excludes the machine-build pipeline and cannot replace the clean headline.

All captures used CPU3, a 32ms main-thread sampling period, unchanged strict stage semantics, successful complete-output oracles, empty stderr and unchanged pinned inputs. All loss, delivery, handler, shutdown and coverage gates pass. The sampled thread covers 99.46%, 99.43% and 99.43% of process CPU respectively. Final peak RSS is 1,037,568KiB, close to the intermediate 1,037,020KiB.

The final registry interval contains **496 samples**, below the existing 500-sample quantitative-attribution threshold. Its milestone CPU duration is measured; its leaf/owner distributions are **descriptive only**. The threshold was not weakened to make the result look stronger. All-stage totals are well above threshold.

## Exclusive stage changes

Values are disjoint thread-CPU durations. Delta compares final against intermediate. The complete 23-stage table is in JSON.

| Stage | Baseline | Intermediate | Final | Final−intermediate |
|---|---:|---:|---:|---:|
| render/output and teardown until milestone exit | 47.469 | 39.244 | 38.864 | -0.380 |
| raw generic/private lowering | 36.937 | 36.395 | 37.634 | +1.239 |
| parse/load | 32.292 | 33.062 | 32.025 | -1.037 |
| checking/publication | 31.546 | 31.561 | 31.304 | -0.257 |
| initial optimizer | 28.861 | 25.327 | 24.293 | -1.034 |
| observer composition and selected final admission | 20.064 | 19.841 | 19.205 | -0.636 |
| registry preparation | 16.879 | 16.834 | 15.944 | -0.889 |
| first independent verifier | 8.323 | 8.234 | 7.914 | -0.320 |
| annotation/reach | 6.200 | 5.956 | 5.910 | -0.045 |
| erasure/finalization | 5.430 | 5.429 | 5.616 | +0.187 |
| static preparation | 4.615 | 4.487 | 4.646 | +0.159 |
| layout check | 2.516 | 2.381 | 2.392 | +0.011 |
| proof report | 2.307 | 2.312 | 2.318 | +0.006 |
| observer discovery | 2.298 | 2.253 | 2.049 | -0.205 |
| observer permission | 1.370 | 1.353 | 1.259 | -0.094 |
| initial private admission | 0.966 | 0.959 | 0.953 | -0.006 |

The nested conditional final verifier is **9.324 → 9.220 → 9.117s**, inside observer composition; it must not be added to these exclusive totals. First independent verification is **8.323 → 8.234 → 7.914s**. Their code and semantic checks remain unchanged. Neither timing decrease licenses claiming that the classifier optimized or bypassed verification.

The mixed movement of unaffected stages—raw lowering increases 1.239s while parsing decreases 1.037s—shows why the 0.572s clean-build difference cannot support a precise incremental whole-request speedup claim. There is one capture/build per image and no confidence interval.

## Mechanism and integration limit

The old membership question constructed runtime-signature lists, tested emptiness and evaluated additional string equalities. The final 41-line literal-pattern implementation answers that same Boolean question for exactly 25 accepted names. It changes no runtime signature table, argument check, ABI or public verifier. The compact verifier still applies only to selected initial/changed-function admission; original raw, final and session verification remain.

[The integration audit](../../implementation/phase147/registry-classification.md#integration-audit-after-the-nearly-neutral-cold-result) disproved loss of the classifier worker itself: the two suffix workers have identical QBE to the prototype, and the entry matches after renaming its own symbol. Assembly also matches after exact symbol/local-label normalization. The production caller context differs: the direct classifier is reached through forwarding/scheduler wrappers, while the isolated prototype loop calls it directly. That is a plausible explanation for diluted transfer, **not a measured attribution of scheduler loss**. No extra performance percentage is assigned to it.

The 10.85× prototype measures classifier throughput. The complete registry interval was only 6.8% of the intermediate diagnostic request, and classifier work is a subset of that interval. Its observed 5.28% stage reduction is a useful local result. It does not establish 10.85× registry speed or 11× whole-build speed.

## What this says to do next

Keep the compact predicate as a small, semantically audited removal of unnecessary lists, subject to the separate qualification gates. Do not expand it into an elaborate dispatch optimization campaign on the strength of its microbenchmark. The larger remaining costs are **rendering 38.864s, raw lowering 37.634s, parsing 32.025s and checking 31.304s**. Initial optimizer still costs 24.293s and observer composition 19.205s.

The next high-value experiment should remove work across a complete remaining region: preserve reusable semantic identities/facts through lowering, reduce name/ownership transport across frontend publication, or extend fragment accumulation through whole rendering bodies. Test conversion, traversal, emission and destruction together; retain the independent final verifier and exact output oracle. The present evidence supports these structural investigations, not a guaranteed forecast of reaching 100s.
