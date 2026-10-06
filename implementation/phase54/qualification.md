# Phase54 qualification

The selected `checked-graph02` image passes the frozen semantic scopes and retains installed Phase53 user-program output exactly. The [qualification summary](../../selfhost/tools/performance/phase54/evidence/qualification.json) pins the checked attempt, successful reports, execution records and preserved failures. Its API SHA is `d7d0396cda189918299ddeb0105e9d682f6a22bffa70004ab6d0ebeac20f4857`; the prior Phase53 comparison API is `3e3fb8c3bc4c445567696ce62bd95979e36746ddde5bb9e0aad3038fc362c9b9`.

| Independent scope | Result | Receipt |
| --- | --- | --- |
| Original source semantics | Candidate 96/96; pinned TS 95/96; differential agreement 95/96 | [Source report](../../selfhost/build/phase54/semantic-final02/source-controls/report.json) |
| Cold/repeated numeric, bits and effects | Candidate 34/34; pinned TS 28/34 | [Numeric report](../../selfhost/build/phase54/semantic-final02/numeric-controls/report.json) |
| Composition order, captures and partial calls | Both roles 18/18 | [Composition report](../../selfhost/build/phase54/semantic-final02/composition-controls/report.json) |
| Genuine overapplication | Both roles 2/2 | [Overapplication report](../../selfhost/build/phase54/semantic-final02/overapplication-controls/report.json) |
| Direct census | 26/26 exact and semantic agreement; 22 pass verdicts and 4 not applicable | [Census report](../../selfhost/build/phase54/semantic-final02/direct-census/report.json) |
| Maintained legacy compatibility | 8/8 | [Maintained report](../../selfhost/build/phase54/semantic-final02/maintained-legacy/report.json) |
| Production JS output retention | All 45 point modules equal installed Phase53 bytes; 23 checked source emissions | [Production byte comparison](../../selfhost/build/phase54/semantic-final02-completion01/production-js45-byte-comparison.json) |
| Native representative retention | 3/3 exact complete C outputs; both roles pass all 3 CPU source goldens | [Native report](../../selfhost/build/phase54/semantic-native-retry01/native-representatives/report.json) |

These scopes overlap and are not summed. The original NaN source golden stays 40. Candidate fresh/repeated original and renamed table calls return 40; the one original TS source failure and six cold numeric TS failures remain visible. Every other value, order, error, getter, alias, closure-demand and recursive observation remains mandatory. The maintained suites use explicit legacy selectors, preserving the prior default-routing repair rather than changing the direct contract.

All four semantic module comparisons also pass exact full output equality against retained Phase53 acquisitions: [source 29](../../selfhost/build/phase54/semantic-final02/source-byte-comparison.json), [numeric 2](../../selfhost/build/phase54/semantic-final02/numeric-byte-comparison.json), [composition 1](../../selfhost/build/phase54/semantic-final02/composition-byte-comparison.json) and [overapplication 1](../../selfhost/build/phase54/semantic-final02/overapplication-byte-comparison.json). The archive-aware comparator joins checked source and compiler receipts to raw emissions and replays the complete-row observer exactly. It performs no output normalization or archive extraction. Helper-only core8 earlier matched all 8 points in a data-only comparison: 6 source receipts and 7 used modules, including that observer.

Native retention covers U32 arithmetic (`word_arithmetic.bend`, stdout `63`), F32 arithmetic (`float_arithmetic.bend`, `8`) and array/closure map/fold (`array_map_loop.bend`, `690` then `1`). The same controller emits both checked roles, compares complete C bytes and builds/runs each fresh CPU binary. The [toolchain binding](../../selfhost/build/phase54/semantic-native-retry01/toolchain-binding.json) records the maintained Clang 16 environment and unchanged executable hash before/after. This is three-source retention evidence, not broad native conformance.

Targets ran serially on CPU3 with a 1 GiB Node heap, 2 GiB tree RSS cap and 4 GiB available-memory floor. Acquisition, census and maintained methods own their sole guard; standalone Node controllers use the bounded supervisor. The original [18-step execution](../../selfhost/build/phase54/semantic-final02/execution.json) retains its first 15 successful stages and a precompiler CLI failure caused by an omitted required `--node`. The [three-stage continuation](../../selfhost/build/phase54/semantic-final02-completion01/execution.json) passes production acquisition/comparison, then retains a native failure caused by Clang being absent from default PATH. A fresh same-controller retry with the maintained toolchain passes native3. Neither failed execution record is relabeled as a pass.

For reproduction, the [launcher successor](../../selfhost/tools/performance/phase54/semantic-launch-plan-v3.py) adds only the required Node argument to the frozen 18-stage plan and records its parent. The unchanged production acquisition requires:

```sh
python3 selfhost/tools/performance/phase53/acquire.py \
  --attempt ATTEMPT --set full --role candidate --backend direct \
  --node /home/ai/.nvm/versions/node/v24.18.0/bin/node \
  --cpu 3 --heap-mib 1024 --rss-mib 2048 --available-mib 4096 \
  --out selfhost/build/phase54/NEW_JS45
```

Native reproduction additionally uses the recorded `CC`, `CPATH`, `LIBRARY_PATH` and `LD_LIBRARY_PATH` from the toolchain binding. Historical methods, fixtures and oracles remain unchanged. These checks add no benchmark samples or runtime improvement claim. Installation also passes all 42 legacy and 24 default controls plus integrity/relocation/tamper checks; see the [release receipt](../../selfhost/tools/performance/phase54/evidence/release.json). The timed-out full77 compiler profile remains a follow-on and is not covered by these gates. Detailed build paths above are members of the raw archive linked from the [publication index](../../selfhost/tools/performance/phase54/publication.json).
