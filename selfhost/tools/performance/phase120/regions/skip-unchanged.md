# Avoid work when the numeric-region pass changes nothing

This overlay follows checked `profit02.bend`. It replaces only
`p120nr_function` and `p120nr_boundary`:

- A caller scan with `next == 0` returns the exact incoming function before the
  extra stack walk and `p113k_function` cleanup.
- An empty candidate table returns the exact incoming verified boundary before
  scanning all functions or performing the extra full-library commit.

For every copied body, the existing stack limit, cleanup and full-library
`p114s_commit` remain. A nonempty table still triggers full commit even if no
caller copies a site; there is no new dirty-flag or changed-only verifier.
The original entry verification and later selected range pass remain unchanged.

`scan.next` starts at zero and increments only in `p120nr_cost` after the exact
copy budget admits an expansion. No-copy scans therefore leave the instruction
semantics unchanged. Returning the original also avoids reconstruction of the
function value. Empty-table detection is exact: this table starts empty and only
inserts eligible/profitable workers; it has no deletion operation.

QBE byte identity with the earlier profit profile is not assumed. That profile
ran extra range cleanup even on untouched functions, and idempotence of that
cleanup has not been established. These shortcuts remove redundant pass work;
ordinary complete-output qualification still applies to the resulting compiler.

`shortcut-controls.mjs` retains the 23 profitability checks and adds four local
checks for untouched function identity, copied-body activation, and empty-table
boundary identity. Raw boundary values in these finite controls test local data
behavior only; they do not authenticate the private verified-boundary premise.
Root owns all executions.
