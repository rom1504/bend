# P4-021 retained scheduling evidence

`runs.tar.gz` contains the six actual attempts (two focused, loaded-host serial,
four-core, idle-host serial, reverse four-core), complete observations, failed
request artifacts, actual persistent-worker histories, frozen harness/host/cache,
comparison audits, exact tool sources and historical observation reference.
The adjacent manifest records every member's source identity and SHA-256.

Archive SHA-256: `ea635da52a44d4da3f5919000b1b5fa471e5ee7a5a7005c675d2aa671b1670c2`. Size: 6,532,979 bytes.
All 7,991 files were verified unchanged during archive creation.

The archive supports offline inspection. It is not a compiler release or a new
checked bootstrap. Compiler images and pinned upstream sources are identified
by the retained reports and available through the separate final source capsule.
Exact replay still requires the original verified Node, canonical input paths,
compiler/runtime and pinned upstream inputs; extracting evidence elsewhere does
not waive those checks.

Primary observation: one otherwise-idle serial run took 1,036.017 seconds;
four-worker runs immediately before and after took 299.376 and 297.699 seconds.
Their 298.537-second median gives 3.47031× workflow throughput / 71.1841% less
wall time using four CPU cores. Every run contains the same 2,756 raw results and
harness verdicts, including 377 existing failed checks. This does not establish
full conformance or a per-core compiler algorithm improvement.
