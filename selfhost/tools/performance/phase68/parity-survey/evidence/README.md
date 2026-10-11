# Preserved first capsule attempt

This packaging attempt failed verification with `ZIP members differ from
manifest`. The ZIP and manifest both contain the same974 members: the producer
sorted archive names as strings but compared them with paths ordered by
`pathlib` components. The first differing order is the `lexer/` directory
versus `lexer-0-bangs-zero/`; membership itself is identical.

`capsule.partial.zip` is12,457,423bytes. It remains an unpromoted failed attempt:
the original producer stopped before its full per-member verification loop.
`manifest.json` and `verification.json` retain their original bytes. No raw
input was changed or removed.

The corrected producer is [capsule-v2.py](../capsule-v2.py), using separate
`evidence02/` output and comparing both name lists after string sorting.
Consult [the successor verification](../evidence02/verification.json) for
its delivery status. The successor binds this attempt's file hashes without
embedding a redundant copy of its ZIP. Keep this directory tracked alongside
the successor, including the partial ZIP and original [producer](../capsule.py).
