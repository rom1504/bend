# P186-005 — reject wider bounds and alignment as the next main opportunity

Increasing old admission limits from 512 to 2,048 statements and 128 to 1,024
produces exactly the same 172 record and 13 Unicode probe rows. All eleven
boundary controls pass under both configurations. Fourteen queried owners show
no useful additional admission. Map helpers that fit the wider limits still
fail closure/readiness conditions. Counting individual frame sites is not the
same as proving a closed set of distinct continuation cases.

The size-limit hypothesis is therefore rejected for these actual paths. Limits
remain unchanged in the selected compiler. Exact comparison is preserved in
[caps-probe-comparison.json](../../implementation/phase186/caps-probe-comparison.json)
and [candidate profile/probes](../../implementation/phase186/candidate-profile-and-probes.md).

Separate loop-alignment probes pass 150 output checks but change runtime by less
than 0.40%. No alignment policy is selected. More favorable text size or alignment
is not itself evidence of less runtime. The stronger remaining assembly evidence
is the real spilled/copy-heavy loop documented in
[remaining-assembly-work.md](../../implementation/phase186/remaining-assembly-work.md).
