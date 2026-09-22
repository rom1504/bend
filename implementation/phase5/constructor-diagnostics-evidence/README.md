# P5-007 diagnostic evidence

`raw.tar.gz` retains the isolated checked candidate, integrated baseline source
and API/proof, their frozen tools/runtime/caches, the exact three-file patch,
focused and upstream paired observations, authoritative checker strings,
audit tool/report, and both versions of the fixture-author attempt. The unused
pre-integration staging project was never compiled and is omitted.

Archive: 5,449,972 bytes; SHA-256
`e16fc3370966effbffdde06b8ecde4e8f17113cf06b0cdf6783d54f490c0eb79`.
`manifest.json` records every member's repository-relative path, size and
SHA-256; all actual compressed members were reopened and verified. `archive.py`
records the creation/read-back recipe and refuses existing evidence.

Extract into a fresh directory. Report contents preserve original absolute
identities. Exact replay also requires the recorded Node binary/platform tools
and pinned upstream checkout at their recorded canonical paths; these are
identified external prerequisites, not bundled artifacts. Relocating old files
does not create a fresh checked build or permit rewriting its provenance.

The final audit is `selfhost/build/phase5/constructors/audit.json`. Six local and
two upstream exact differences resolve. Four selected upstream discrepancies
remain visible. The first baseline used invalid empty-angle fixtures; its
`baseline-01` report and `fixtures-v1` source remain separate from corrected
`baseline-02`/`fixtures-v2`. No timing claim accompanies these correctness runs.
