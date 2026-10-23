# Native-producer qualification

`qualify.py` is a data-only binder. It executes no compiler, build, generated
program or timing target, and writes one fresh qualification receipt. It keeps
the actual native producer separate from the independent upstream source check.

Root runs the unchanged Phase130 `native-request.py`, using fresh
`selfhost/build/phase130/p131-*` directories because that runner deliberately
retains its original output guard. Aligned machine builds and semantic coverage
use the unchanged Phase123/125 methods. No historical method or report is edited.

For a byte-preserving source change:

```sh
python3 -B selfhost/tools/performance/phase131/native/qualify.py \
  --admission selfhost/build/phase131/native-admission01.json \
  --producer selfhost/build/phase111/p130-native01-n2/program \
  --acquisition selfhost/build/phase130/p131-acquisition01/report.json \
  --n1-build selfhost/build/phase111/p131-n1/report.json \
  --self-emission selfhost/build/phase130/p131-self01/report.json \
  --n2-build selfhost/build/phase111/p131-n2/report.json \
  --first-focused selfhost/build/phase111/p131-n1-focused/report.json \
  --final-focused selfhost/build/phase111/p131-n2-focused/report.json \
  --final-full45 selfhost/build/phase111/p131-n2-full45/report.json \
  --out selfhost/build/phase131/native-qualification01.json
```

Names above are illustrative future paths. The producer must be the exact N1 or
N2 file in the frozen qualified Phase130 selection. The chain is N0(S)→Q1→N1,
then N1(S)→Q2→N2; the binder requires **complete raw Q1=Q2 bytes**. Focused19 runs
on both N1 and N2; ordinary45 runs on N2. No hosted full-source emission is claimed
or needed. The exact source S must already have its independently checked API.

If code generation changes Q1 versus Q2, retain that difference. Run N2(S)→Q3,
build N3, and add `--reproduction N2_REQUEST_REPORT --n3-build N3_BUILD_REPORT`.
In that mode `--first-focused`, `--final-focused`, and `--final-full45` must bind
**N2, N3, and N3**, respectively; complete raw Q2=Q3 is mandatory. The report keeps
all three products/images and records whether Q1=Q2 separately. An unequal Q2/Q3
refuses qualification. Neither route asserts ELF byte equality.

The admission kind is `phase131-native-acquisition-admission`, with
`complete`, `sourceChecked`, `originalVerifiersUnchanged`, and
`runtimeContractsUnchanged` true. Required pins are `source`, `api`, `runtime`,
`sourceBinding`, `checkedApi`, `parentAdmission`, and a nonempty `semanticChecks`
list. It also declares `changedDeclarations`, `addedDeclarations`, and `inputs`.
Each semantic-check report must be complete. Ordinary successful reports declare
`pass` or `passed`; the unchanged Phase128 `finite.mjs` schema instead requires
`finiteGroups[REPORT_ABSOLUTE_PATH]` mapping exact group names to positive counts,
complete groups and every original `:pass` (or `p118z_controls` `PASS `) row. Such
finite evidence must consume this exact admission source/API/source manifest.
No synthetic top-level success field is added to historical reports.
Admission remains root-owned: attaching an unrelated successful check does not
establish a semantic connection; the source/body audit and focused controls must
justify that connection before root issues admission.

The binder independently enforces:

- Frozen qualified parent selection/qualification, source/API/runtime/image
  identities, QBE build toolchain and branch-alignment policy.
- Complete module-snapshot replay of S from Phase130 with the Phase131 composer;
  exact changed/added inventories, protected declarations, and changed-body hashes.
- Exact S consumed by the successful upstream checked-API command, original
  checker/host/tool authority bytes, and required request-bound exports.
- Unchanged inherited runtime-authority bodies against the source-bound Phase128
  contract, including its original body hashes. A change there needs a separately
  reviewed contract successor; a declaration of unchanged runtime is insufficient.
- Actual N0/N1/(N2) native command, exact source/Base/carrier/stamp/runtime context,
  authenticated compact or original carrier receipt, successful exit, empty stderr,
  unchanged inputs, and complete raw QBE. The request's runtime-context field alone
  does not prove its producer's linkage; selected/build lineage supplies that link.
- Each machine build consuming the preceding QBE plus the selected runtime and
  frozen QBE/assembler/linker files/arguments. No per-program C or cproc route.
- Exact focused and ordinary corpus/order/oracles. Each positive row binds its
  native emission, image build, generated binary, exit, full stdout and stderr.
  Each negative row must be the original source/backend refusal, with its original
  stage/prefix, exit1, no output and no timeout; a crash cannot satisfy it.

All referenced pins are rehashed, conflicting identities for one path are refused,
and the output is created exclusively. The binder records `targetsRun:false`,
`hostedAcquisition:false`, `selected:false`, and `installed:false`. This finite
qualification is not a mathematical compiler proof, performance result, upstream
migration, or release promotion. Runtime/codegen semantic claims remain bounded
by the independent controls and frozen19/45 suites.

Read-only validation of the binder consumed the actual Phase130 compact
self-emission and both focused19/full45 receipts successfully, rehashing2,148
unique files. No target ran and no Phase131 qualification was fabricated. The
new-source admission and optional N3 path still require their actual root-produced
receipts. No code-generation-change qualification is inferred from this schema
replay.

`admission-templates.json` retains two unissued branch templates (regions-source03
and projection-source03) with exact checked APIs and finite groups. Their
`complete:false` status is deliberate: root must review/select the integration
and issue its actual admission. Neither claims generated-code preservation.
Readloop is excluded pending its independent controls. The CPU6 check guard
derivative permits3GiB with a16GiB available-memory floor and retains the same
CPU6 correctness lock; its exact edits are in `check-guard.derivation.json`.
The first regions API attempt stopped at the older2GiB cap and remains intact.

`admit-combined.py` is the narrower issued-admission producer for exact
`combined-fast-source02`/`p131-combined-fast-api02`. It joins the four actual
finite/differential campaigns,16 real Base-body comparisons and six complete
QBE/oracle products from three sources. It replays the source/body contract and
binds the actual safe algebra/absent declarations to seven independently checked
helper laws. Unsafe merge, generic traversal, callers and native compilation are
not thereby proved. The separate semantic join has its own successful verdict;
original campaign reports remain unchanged.

The actual acquisition permission is
`selfhost/build/phase131/combined-fast-admission01.json`. It is complete and
source-checked, while `nativeQualified`, `selected`, and `installed` remain false.
Full-source native reproduction and focused19/ordinary45 are still required.
