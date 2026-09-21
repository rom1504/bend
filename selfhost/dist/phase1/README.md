# Phase 1 compiler artifacts

These are experimental builds of the optimized compiler. The supplied
`../typed-api.mjs` remains the default. Native timeouts and unmet performance
thresholds are retained in the [implementation report](../../../implementation/phase1/report.md).

| File | Role |
|---|---|
| `bootstrap-api.mjs` | Bend compiler emitted by pinned upstream TypeScript |
| `selfhost-api.mjs` | Same compiler emitted by its own Bend JavaScript backend |
| `compiler.bend` / `.map.json` | Frozen assembled source and module line mapping |
| `runtime.mjs` | Runtime used for both checked self-emissions |
| `bootstrap-report.json` | Upstream pin, module/source/API hashes and bootstrap provenance |
| `fixedpoint-report.json` | Complete checked stage 2 / stage 3 byte comparison |
| `component-report.json` | Component checks for the same source modules |
| `manifest.json` | Distributed file sizes and SHA-256 hashes |

The self-emitted compiler has SHA-256
`44227e5e9aa714682c3a5f042cbf38fce86cc6bc510265aeda75103ed242579a`.
Both checked self-emissions produced these exact bytes. This proof applies to
the recorded source, host, Base and path layout; it is separate from language
conformance and performance thresholds.

From `selfhost/`:

```sh
BEND_TYPED_API="$PWD/dist/phase1/selfhost-api.mjs" \
  node --stack-size=4096 cli.mjs tests/conformance/typed-smoke/base-u32.bend --run
```

See the [compiler guide](../../../docs/BEND-IN-BEND.md) for the bootstrap API,
resource settings and generating a fresh local fixed point after relocation.
Historical absolute paths in provenance files identify the original run; the
artifacts are selected by the explicit local path above.
