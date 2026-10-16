# P102-003: construction and reusable build work

Status: construction mechanism retained; reusable-build hypothesis not supported.
Registered 2026-10-16. [Campaign](../../design/phase102/ambitious-native-campaign.md).

Hypothesis: eliminate intermediate construction or separate reusable native
runtime compilation to reduce complete runtime/build work. Existing Phase100
C is about 3–3.5× upstream size and Clang work is 2–3.5× slower on these apps.

Inspect actual emitted structure and existing research. Choose one concrete
experiment. Measure clean total cost and warm reuse separately, including object
preparation and link costs. General transformations must preserve runtime ABI,
full output and parallel controls. A smaller C file alone is not a speed result.

Result: the shared runtime prefix is only~84KB of555–748KB application C.
Identifier compaction cuts C size18.6% but only hints at~3% Clang savings; emitted
executable/data sections are identical. PCH warm time is neutral and clean setup
adds cost. Neither is integrated as a performance win.

The productive structural alternative is generic tail recursion modulo a final
constructor field. It turns recursive builders into private hole-filling loops
while preserving ordinary boxed results, strict argument order and fallback.
The same rule activates in String append and unrelated graph constructors;
aliased, three-field, late-failure and refusal controls pass. Original Phase99
bounded branch specialization is also retained, with its own frozen controls.
See [mechanism and evidence](../../implementation/phase102/trmc.md). The combined
candidate is not an isolated attribution of each change; the separate cell-reuse
pair explicitly measures only that additional allocator intervention.
