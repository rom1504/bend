# Late field-template acquisition admission

`admit-field.py` extends the existing checked acquisition receipt without
changing any older admission, qualification or timing method:

```sh
python3 selfhost/tools/performance/phase128/native/admit-field.py \
  --base-admission selfhost/build/phase128/native-admission02-base.json \
  --field-finite selfhost/build/phase128/native-finite02/report.json \
  --oracle-report selfhost/build/phase128/field-oracle02/report.json \
  --jobs-plan selfhost/build/phase128/field-oracle02/jobs.json \
  --jobs-report selfhost/build/phase113/p128-field-oracle02/report.json \
  --out selfhost/build/phase128/native-admission02.json
```

It binds the exact wired source and checked API to all 100 finite predicates and
545 successful independent C/QBE ABI checks. Relative to the preceding wired
source, only `p111q_constructor_ids` and `p111q_stmt` change. Every other existing
declaration, including verifiers and ID readers, remains identical after the
established declaration normalization. New declarations must exactly match the
three frozen field modules. The original renderer survives as the fallback.

The production runtime object/source stay unchanged. Its header is the exact
oracle ABI header plus the fixed, inherited array-pair function declaration;
the initial overstrict whole-header check is preserved as a failed metadata
attempt. The oracle links the real renderer's QBE with the independent helper
spy only, and validates guards, payloads, state/heap preservation and fallback
dispatch. It does not establish production malformed-term failure semantics.

This is acquisition permission for the sequential CPU ABI, with
`nativeQualified=false`. Native reproduction, ordinary conformance and runtime
performance still need their own receipts. Downstream tools should consume the
extended `native-admission02.json`, rather than the 79-predicate base receipt.
