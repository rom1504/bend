# Isolated maintained integration

The selected source is `selfhost/build/phase195/selected-source02/compiler.bend`,
SHA256 `ee95d489522b4fdbdf253137319417f3eb09abe12f192db493d840c542adb8c5`.
Its editable modules and manifest are isolated under `selected-source02/maintained`.
`selected-source02/changed-files.json` lists the eight changed/new files. Live
source and the installed selector were not modified by this integration step.
`selected-source02/maintained-source.patch` provides their complete reviewable diff.

The final selection includes table-v3, branch-v2, call-v1 and sqrt-v2. It excludes
cycle scheduling, alternate register pools, physical selection and recurrence
forwarding. The earlier plan's branch-only hook is superseded by the checked
call-v1 hook and its four helpers, exactly as in `combined-api-source01`.

`maintained-integration-audit.py` constructs the isolated maintained tree and
produces `maintained-integration-audit.json`. Seven API roots retain 5,359
declarations. All 4,475 executable definitions have byte-identical declarations
after removing external framing and adapting only the two signatures described
below; internal body whitespace and comments are retained by this stronger check.
Type sets and normalized declarations also match. Seven reused canonical QBE
table helpers exactly match their original definitions. All five non-x86
assembled source profiles remain byte-identical.

Two explicit forward interfaces are required by maintained module ordering:
`x181_label` and `x181_program_data`. The Bend parser requires definitions filling
laws to use untyped binders. Therefore their definition headers become
`def x181_label(n,frame):` and `def x181_program_data(data,available):`, with
their original typed interfaces moved to laws and their executable bodies
unchanged. Source-check01 preserved the initial parser rejection caused by
retaining typed definition headers after the new laws. Source-check02 accepts
the corrected source through upstream loading, checking and zero unresolved
holes in 6.962 seconds. This is source acceptance, not kernel verification.

Three earlier metadata staging attempts remain under
`selected-source-staging-failed01/02/03`: the first two exposed manifest
dependencies outside `src`, and the third exposed a one-line-definition case
in the audit's initial body extraction. These did not run candidate targets.
The corrected staging copies the full manifest dependency list; its byte audit
compares raw declarations rather than assuming multiline bodies.

Native image acquisition and the subsequent finite/reproduction/runtime gates
are separate evidence. The eight executable argv files in the Phase195 build
directory use the selected-source02 pin, the explicit Phase186 QBE N2 producer
and the frozen Phase194 asset manifest. No installed-image change is implied.

These native gates subsequently completed. `native-qualification-summary.json`
pins source acceptance, N1 acquisition, N2 self-build, exact N2/N3 compiler
object reproduction, all 45 independent program oracles at each generation,
45 equal program objects/135 equal linked sections, all 64 finite catalog
controls and ten runtime controls. Native build durations were 172.697 seconds
for N1, 284.331 for N2 and 335.161 for N3; these are observed qualification
costs, not paired compiler-performance claims. The N2 image is
`selfhost/build/phase195/native-self01/program` with its `report.json`.

The default promotion method also passed its read-only check, producing
`maintained-promotion-plan01.json`; `applied` remains false. Root owns the
separate runtime/held-out result, hosted/native transfer, paired compiler-cost
decision and any later maintained-source copy.

After the broad runtime and compiler-cost screens completed, the eight selected
source changes were applied. Live x86 assembly of the compiler source matched
the checked source02 byte for byte. The installed image selector remains at
Phase189. [Final promotion receipt](../../implementation/phase195/maintained-promotion01.json).
