# Diagnostic source01 refused; quantity-only source02 prepared

The independent API source check correctly rejected `p136q_find_go` because the
`rows: U32` parameter was stored in two result fields without an explicit shared
quantity. The failure occurred at frozen source01 line58412; the check took
5.155 seconds and returned status1. It produced no checked API and no diagnostic
measurement. The selected compiler and its admission/checking rules are unchanged.

Preserved failed evidence:

- `selfhost/build/phase136/query-source01/compiler.bend`
  (`e2ee41b0…31d3c46`)
- `selfhost/build/phase111/p136-query-api01/{report.json,stderr}`
- `selfhost/build/phase136/query-api-guard01/process.json`

New `query-counts-v02.bend` adds six quantity annotations: `+rows` in both
find-result constructors; `+count` in both bounded list-prefix helpers; and
`+acc` in the two constructor-name collectors whose alternative closures both
capture it. This review covers the remaining repeated scalar uses and analogous
closure captures. No query, counter, control, production declaration or expected
result changes.

`prepare-query-v02.py` freezes source02
`c1e89dfd6b664da0634995f4e305e027ade0ddf1aaa747269227fcc46fb1930a`.
`query-census-v02.mjs` binds that exact source. Both original methods and the
failed source remain unchanged. The coordinator subsequently source-checked
source02 and ran all14 controls plus30 census observations successfully.
[The final query evidence](query-results.md) records the closed receipts. No
target was run by this agent while preparing the correction.
