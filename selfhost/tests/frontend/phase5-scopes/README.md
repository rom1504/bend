# Scope and shadowing witnesses

Use `cases-v4.json`: nine successful programs with check, interpreter and JS
lanes, explicit `#|` output oracles, and isolated execution workers. They cover
last-name shadowing in parallel bindings, simultaneous value scope, reusable
marks, an erased outer binding, ordinary constructor destructuring, match rows,
and a duplicate spanning nested constructor fields plus an outer capture.

Upstream opens patterns left-to-right and resolves the most recently opened
name. The compiler's pattern list/value order must stay unchanged; only the
new bindings prepended to the body lookup environment need newest-first order.
The fresh baseline produced1 instead of2 for parallel, local and match-row
examples. This is an execution mismatch, not merely a diagnostic difference.

`cases.json` and its two original `Pair` fixtures retain an invalid first setup:
Base already declares Pair, so both compilers reject those examples before the
intended shadowing path. `cases-v2.json` replaces them with fresh ScopePair names;
`cases-v3.json` adds the nested-field/outer-capture control. Do not treat the
original invalid setup as proof of scope behavior or silently overwrite it.

`cases-v3.json` additionally retains a valid upstream program whose middle bare
value name is followed by a braced annotation. The current raw parser rejects
it before scope analysis; this remains an explicit unrelated conformance gap.
`cases-v4.json` uses a separately named grouped-value fixture to test the same
duplicate/outer-scope rule without that parser obstruction. The original valid
failing fixture and its observations remain unchanged.
