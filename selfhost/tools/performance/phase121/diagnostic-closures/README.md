# Closure construction/application ceiling

These are diagnostic source substitutions, not compiler improvements. The exact
frozen closure64/256 `bench` bodies now invoke a descending Nat loop, applying
`U32.add(value, U32.add(1, U32.from_nat(pred)))` for each predecessor from n-1 to 0.
This preserves the source composition's n-to-1 application order and every U32
wrapping point. It avoids materializing the closure chain. The entire Phase93
measurement/validation suffix remains byte-identical; source and oracle hashes
are in `manifest.json`. The helper precedes `bench`.

`prepare.py` checks the parent SHA256 and verifies the frozen complete expected
values with an independent imperative model. No compiler/native run is performed.
The existing JS `j_callback_compose`/`j_callback_factory` predicates provide the
candidate general admission mechanism; this source ceiling does not prove that
native adaptation is implemented or correct.
