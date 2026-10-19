# Rejected immediate-helper experiment

The optional immediate `keep`/`sink` expansion is not qualified. Root's
`selfhost/build/phase112/final-probes-runtime01/report.json` records a complete-output
or success-count failure on the fast Unicode control, despite process exit zero.
The corresponding gap-if profile passes that control. The failing profile must
remain excluded from the facts compiler acquisition.

The offline witness `evidence/immediate-isolation01.json` pins both emitted QBE
inputs and the inspection method. The fast Unicode input has 637 functions and
107 immediate expansion sites. There are no duplicate emitted `%t_N` definitions
or labels within a function. Replacing each exact conditional expansion with its
original helper call, then consistently renaming numeric temporaries and labels,
makes every function body match the passing gap-if input. The report stores each
edit, its offsets and original bytes; reconstructing the entire fast input from
the collapsed text was checked exactly. This is source/data inspection only.

The source-level predicate remains justified: unsigned Term `< 2^57` has no RFC
bit and has tag 0 or 1. On these words runtime04's `term_keep` returns its argument
and `term_sink` has no effect. The wrappers perform no additional state operation.
Consequently, source-level heap aliasing does not supply a missing side effect
for this subset; all other words still call the original helper in the same
order. Destination/input aliasing is also preserved because the comparison reads
the input before either branch assigns the destination.

This does **not** establish correctness of the compiled conditional block.
Possible explanations still include an introduced control-flow/SSA/liveness
interaction or machine lowering of the 64-bit comparison; neither has been
demonstrated. `cultl` expresses the intended unsigned long comparison in the
emitted QBE, but the failing machine path has not been isolated. A changed call
boundary can expose a backend or prior undefined-value issue without implying
that the runtime helper had a source-level alias effect. No further native
debugging or speculative fix is included in this experiment.
