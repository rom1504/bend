# Phase57 image staging

`setup.mjs` is a narrow successor to the frozen Phase56
`bootstrap/setup-v2.mjs`. Its [derivation](setup-derivation.json) records the
exact parent/output hashes and every text replacement. Phase54–56 remain read
only. This method creates no checked-attempt metadata or bootstrap sidecar.

```js
const state = await setup(imagePinsFile, freshPrivateDirectory, {
  role: 'raw', // or 'source' or 'direct'
  progress,
});
```

The input is the exact Phase56 String01 `image-pins.json`, SHA256
`11c5e4982678ac88e86f7d304ba8c3fc12c22ec756b0b2fa43f615a23ab77619`.
It joins the genuine checked attempt, compiler source, 77 roots, B2 emission,
diagnostic derivations and ordinary-driver qualification before selecting a role.

| Role | Actual selected file | SHA256 |
|---|---|---|
| `raw` | `attempt.checkedApi`: original checked upstream emission | `1498f6758c1ce713225209cc6ad9e0c27a0d5aee2ed674c4ae35990cf945cf52` |
| `source` | `attempt.api`: derived checked B1 | `128619779fb5e29138bd33273bc5de6b81f39bdb54c2cebb93e69f3ca63acaea` |
| `direct` | `emission.module`: qualified direct B2 | `3f652f7d3e26e06fe74da18bf8709195c54e4620906ffb7c1d0643c96ecbd57e` |

The raw API hash must also equal the genuine bootstrap report's `apiSha256`.
The historical eight-driver comparison applies to derived B1 and direct B2.
For raw, `image.driverQualificationApplies` is false; its admission comes from
the checked attempt, not a relabelled historical comparison.

The return shape remains
`{api,D,subject,emission,roots,inputs,copies,image,project,verifyFinal}`.
`api` is the actual loaded object; `image.api`, `image.base`, `image.runtime`,
`image.directRuntime` and `image.driver` are file identities. The staged API is
selected through `BEND_TYPED_API` and ordinary `loadApi()` must return its named
default export. No positional conversion or fallback route is introduced.

Every fresh directory must be under `selfhost/build/phase57/`. Its `project/`
contains byte-identical driver/dependencies, runtime/effects, manifest and chosen
API. It starts without a Base cache. Each role has its own private directory;
cache names and contents bind the actual API hash and exact Base. `verifyFinal()`
rehashes inputs and copies, revalidates the checked attempt, and checks any
created Base cache's API/Base/source/book identity.

**Setup loads the API during preparation.** Clean latency workers must therefore
be separate fresh processes using the staged paths; setup must not execute before
an allegedly cold import timer in the same process. Priming and provenance costs
remain outside the measured request, as specified by the independent worker.

The setup and its exact derivation passed independent static review. Node syntax
checking passed without importing the module or running a compiler. Heavy jobs
remain root-scheduled and serial on CPU3, with a 1 GiB Node heap, 2 GiB tree-RSS
bound and 4 GiB available-memory floor. This helper supplies no supervisor itself.
