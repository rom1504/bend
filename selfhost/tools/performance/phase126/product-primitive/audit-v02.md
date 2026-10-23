# V2 correction before qualification

Use `manifest02.json`, `flat-observer-v02.bend` and `controls-v02.bend`.
The original `audit.md` records the first proposal; its allowance for word
literals is superseded here. All other mechanisms and proof obligations remain.

Static review found that `p111_values` is specifically a mapper of already
evaluated **Var** terms to local words. It is not the `p111_value` evaluator and
does not interpret `NWord` literals. Passing a word literal to it could create
an undefined local or, worse, accidentally refer to a different existing local
with the same numeric identifier. The first prototype therefore had an
overbroad local field predicate. The current observer residual checker normally
already rejects word-literal fields, but that was not a sufficient interface
contract for the new helper.

V2 admits only Var fields and the corresponding pure control now requires
constant refusal. This is enough for the actual root/observation constructor
residual and avoids adding any second evaluator. The original files are kept
as a rejected audit version; no target result is attributed to them.
