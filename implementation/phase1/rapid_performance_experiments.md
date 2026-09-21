# Rapid performance experiments

Status: experiments starting. No new speedup claimed.

The [design](../../design/phase1/rapid_performance_experiments.md) separates cheap
causal experiments from full compiler validation. The frozen phase 1 API is
`dist/phase1/selfhost-api.mjs`, SHA-256
`44227e5e9aa714682c3a5f042cbf38fce86cc6bc510265aeda75103ed242579a`.
The earlier fixed-point and corpus run remain evidence for that artifact only.

First experiments: direct known calls, compact persistent lookup, then their
combination. Results and reproducible commands will be added as they complete.
