# Optimized compiler profile evidence

`manifest.json` maps historical file paths to content-addressed objects in
`raw.tar.gz`. Extract into a scratch directory and restore needed files by their
SHA-256 object names. All objects were decompressed and checked; source files
were rehashed after archiving. The Node executable is an identified external
prerequisite. This preserves diagnostic sampling, not a timing comparison.

The original prelaunch plan contains a manually entered future timestamp. Its
bytes are retained, with a separate timestamp correction and actual launcher
start/finish. Reports have not been edited to hide this clerical error.

Regenerate this archive from the retained local run using
`python3 implementation/phase6/profile-evidence/archive.py` from the repo root.
