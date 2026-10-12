# P75-014: binder sets rather than definition dictionaries

Profiles attribute66ms inclusive numeric B2 time to occurrence sets, including
many generic index allocations. A variable set needs neither String keys nor
KDef payloads/collision buckets. Use a three-constructor persistent U32 Patricia
set, sharing an existing path for repeated insertions. Retain exact32-bit keys,
Var-as-leaf raw semantics, and all liveness/drop ordering. No memoization by term
identity. Validate against JS Set and retained nc_occurs on randomized boundary
IDs and malformed Var children; require exact complete C. Test the three-source
fast loop before any broad gate. Generated user runtimes and JS backend unchanged.

The first editing command expected a manifest path without src/ and failed
before editing the manifest/bridge. Its following shell command nevertheless
ran compiler12, a duplicate of compiler11; preserve it as an orchestration
mistake, not an occurrence-set candidate or speed result. Compiler13 is the
first actual candidate with this representation.
