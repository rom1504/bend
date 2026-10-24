# Deferred direct local-name compression

The Phase131 `p111q_local` already emits `%v_` plus its local String nearly
verbatim. Preserving legal ASCII and escaping other characters cannot recover
Phase132's 46% dense-ID text reduction. Long names mostly accumulate generated
prefixes, for example repeated `p113i_0_local_` plus a decimal local ID.

`census.py` replays a metadata-only scan of the exact Phase131 QBE. It refuses
quotes/comments and a changed source hash, so the narrow identifier expression
cannot silently start matching strings. It estimates replacing ten common
generated atoms with two-character escapes. `census.json` records an optimistic
11,589,620-byte reduction, **10.83% of whole text**, before escaping reserved
markers and protecting hardcoded names. No Bend encoder was implemented.

This is materially less than dense per-function IDs and introduces a new cost:
the current emitter can share an existing String suffix, whereas direct
compression must inspect and reconstruct names. A dictionary/prefix matcher
could consume more compiler time than it saves in output. A future candidate
needs an emitter-only timing discriminator before integration.

Source audit also found literal references outside the central hook:
`%v_scratch`, `%v_p114r_resume_local_scratch`, and
`%v_p113a_version_guard`. A reversible encoder must preserve these anchors or
change every corresponding literal producer/consumer consistently. Some finite
controls inspect exact local spellings and would need equivalent expectations;
they must not simply be dropped. Global symbols, public ABI, verifier identities
and semantic local names should remain unchanged.

The coordinator deferred this route in favor of streaming output and reusing
validated lowering. This preserves a negative prioritization result, not a
failed correctness or performance experiment. There were no target runs,
compiler changes, or installed-selection changes.

Reproduce from repository root:

```sh
python3 -B selfhost/tools/performance/phase134/compact/census.py
```
