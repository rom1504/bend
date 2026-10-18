# Preserved version-1 array fixture failure

`arrays-io-v1.bend` and `manifest-v1.json` are the exact pre-correction files.
Root's `selfhost/build/phase108/coverage-qbe01/report.json` records four successful
QBE controls followed by this fixture's source-emission failure. This is a
fixture parse failure, not a target runtime discrepancy.

Version 2 routes each computed `Array.get` result through a helper parameter,
then destructures that parameter using the existing Base style. Its expected
stdout remains exactly `arrays=seed/changed/seed\n`. All other expected values
remain unchanged. The current manifest binds this archive, the failed receipt,
and the before/after source hashes. No target was run while making the correction.
