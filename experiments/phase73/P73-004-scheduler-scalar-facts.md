# P73-004: retain scalar types in scheduler entries

Counters show thousands of scalar `term_keep` calls upstream avoids, including
expression4161 versus0 per16-input cycle. Private workers retain U32/F32/Char/
Bool telescope facts, but scheduler entries for recursive definitions still
extract all registers into opaque64-bit Terms. Extend the same checked telescope
query to direct-entry parameter declarations. Keep continuation/capture slots
opaque, and raw/unsupported checked permission paths unchanged. No replacement
of the scheduler or C recursion. Test whole outputs and runtime speed; remove
if extra compilation or code size does not pay for itself.
