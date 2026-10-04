# P43-003: direct BST build versus temporary products

Status: investigate, prequalification. Owner products; root serializes execution.

Falsifiable claim: residual generic build/insertion is material at BST64, and
private zipper Tuple/BF/List allocation remains material after direct calls. These
are independent claims requiring original/direct/products variants. Stronger scalar
island precedence stays unchanged. Only source-owned private values qualify.

Plan and safety boundaries: [design](../../design/phase43/products.md).
Tools, exact commands, rejected selector and source candidate:
[implementation](../../implementation/phase43/products.md).
Starting evidence: [checked16 profiles](../../implementation/phase42/profile-findings.md).

Saved-JS oracle and two-point screen02 pass; exact values/ranges and semantic scope
are recorded in the linked implementation report. Actual compiler qualification
remains pending. Tiny actual-source oracle must pass complete
intermediate values, aliases/fresh shells, exact fuel/duplicate order, host fallback,
ordinary activation/generic-call reduction and deep iterative insertion before timing.
Root preserves failures and actual commands under selfhost/build/phase43. No Phase42
raw output is written. Saved-JS measurement valid for the two recorded points; source promotion not proposed.
