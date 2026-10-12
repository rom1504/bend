# P75-016: selected release decision

Post-validation decision, not a prospective hypothesis. Promote compiler14:
B1 7f05ac96…, B2/B3 0444d283…. Forty-five interleaved requests give 18.09%/17.78%
less B1/B2 time; ratios 2.91581×/1.92053× TS. All twelve C files and binaries
match Phase73 exactly. Native100/raw31/new14, thread 28/shape 6, JS 2992 exact,
report 166, constructor 1066, set 199400, B2/B3 and installed 42/24/5 pass.

Reject the faster omission candidate’s runtime tradeoff and unhelpful bitmap
sets. Preserve known seven reference failures and thirteen native API gaps.
Compilation parity remains a goal, not an achieved claim. Exact receipts,
metrics and remaining architectural opportunities are in the Phase75 report.
