# Native Halt/Exit review

Static review found two port defects, repaired in both native and QBE runtime
dispatch. No target executions or failure-runtime probes were run by this audit.

1. Upstream `bend2/comp.ts` rejects U32 exit codes above 255 before converting
   to a host exit status. The initial port returned a cast int directly.
   Consequently 256 could become OS status zero, while 4294967295 became the
   runtime's negative "continue" sentinel and left an activation live. Both
   Halt and Exit now use the exact upstream error text and reject before the
   cast. Halt still prints its message before checking the code.
2. Exit has one scalar field and may be a packed constructor. The initial port
   read its payload as a heap address. Exit now reads `term_loc(req)` for TAG_PAK
   and the heap field otherwise, matching upstream's packed-field extraction.
   Existing two-field Halt remains heap-backed.

The retained runtime returns a valid status through `io_loop` to main, whose
existing `io_sync` flushes stdout before returning to the operating system.
The range check prevents collision with the internal negative sentinel.

Ordinary valid fixtures are `exit.bend` (status 23), `exit-upper-valid.bend`
(status 255), and `halt-valid.bend` (message plus status 7). Invalid-code behavior
is assessed by source inspection here; this audit does not launch the upstream
`exit_status.js` helper, which creates failure-runtime probes. Source checking,
native product execution and ABI qualification remain separate root-owned gates.
