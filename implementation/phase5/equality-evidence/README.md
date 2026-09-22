# P5-003 first correctness evidence

`manifest.json` maps consumed file identities to content-addressed gzip objects.
Decompress an object's bytes and verify their SHA256 before use. Identical files
share one object; original absolute filenames document historical locations.
`summary.json` contains the compact outcome, including retained failed attempts.

This archive includes genuine bootstrap APIs/reports and their consumed source
and tool inputs, both derived APIs, old and final helper/tests, selected compiler
observations, actual emitted programs and failure logs. Node is external and
hash-identified. API-specific Base caches are regenerable and omitted. No timing
claim or checked-bootstrap claim is made for the transformed artifacts.
