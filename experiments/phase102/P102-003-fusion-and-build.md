# P102-003: construction and reusable build work

Status: registered 2026-10-16. [Campaign](../../design/phase102/ambitious-native-campaign.md).

Hypothesis: eliminate intermediate construction or separate reusable native
runtime compilation to reduce complete runtime/build work. Existing Phase100
C is about 3–3.5× upstream size and Clang work is 2–3.5× slower on these apps.

Inspect actual emitted structure and existing research. Choose one concrete
experiment. Measure clean total cost and warm reuse separately, including object
preparation and link costs. General transformations must preserve runtime ABI,
full output and parallel controls. A smaller C file alone is not a speed result.
