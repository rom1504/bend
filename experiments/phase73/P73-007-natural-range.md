# P73-007: retain native Nat range facts

Checked native Nat values are bounded by NAT_IMM (48 bits). Existing scalar
facts cover U32/F32/Char/Bool, leaving Nat arguments opaque. Preserve the Nat
range at CPU private and scheduler entries with a mask that is an identity on
valid Nat values. Keep overflow operations, error checks, loop polling and raw/
device fallback. No C type extension or library-specific rule. This adds one
word kind to the existing IR. Check native overflow/high-value boundaries and
measure the whole cohort; discard if it does not pay for its complexity.

Candidate09 passes frontend36 and four smoke/rotated runtime cases, but the
tradeoff is poor: tree284ms versus candidate08 307ms, expression495ms versus438,
Array.map479 versus478, lexer292 versus295. Roles have visible timing drift;
these are independent campaigns, not confidence intervals. Reject this version
rather than keep a new IR kind with a possible AST regression. All four production
files restored exactly from candidate08's frozen snapshot before candidate10.
