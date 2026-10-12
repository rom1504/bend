# P75-002: reuse unchanged candidate and reporting work

After P75-001's three native smoke programs and27 runtime intervals pass,
restrict retry to candidates whose erased references intersect withdrawn product
signatures. Unchanged signature inputs cannot require re-lowering. Preserve
constructor facts and original admission order. Require identical C versus the
first planned candidate. Also return trust names and their verdict from one Bend
query, preserving old public APIs and eliminating the duplicate report traversal.
The new query does not need a maximum-binder scan: its dependency walk only
reads names/types/bodies and never synthesizes binders. Check ordinary reports
and generated C, then retime before broader qualification.
