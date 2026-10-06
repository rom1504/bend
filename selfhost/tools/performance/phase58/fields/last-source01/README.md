# Last live constructor-field source proposal

The isolated `last-field.patch` changes three direct-backend modules and adds one shared printer helper (five physical lines, 220 bytes net). `identity.json` pins every before/after file. Root applies and builds it; these copies do not themselves modify the maintained compiler.

`jd_ctor_field_join(name, value, rest)` prints the current field followed by the already rendered suffix. An empty suffix identifies the final **live** field. The ordinary constructor path first skips erased fields; therefore trailing erased telescope entries do not prevent the preceding live field from being final. The ordered constructor path supplies its existing `named` suffix to the same helper, leaving prefix, value and temporary threading unchanged.

`jd_literal_field_key(name, last)` emits a computed key when `last` is true or the name is `__proto__`. Earlier ordinary keys remain quoted literals. `jd_host_marshal_field` passes false, retaining its previous literal spelling and computed `__proto__` exception. Empty and all-erased constructors retain only their tag. Values and subsequent fields remain in their original printed order.

The patch does not change scalar reconstruction, owner lookup, choice admission, dependency scanning, shared SCC dispatch or resource bounds. No field-count or constructor-name performance rule is introduced. The prior full-reversal and width diagnostics remain unselected.

Source static review passed at patch SHA `64e3e13fe8a7e51dcf7c8d5756c24c2bd8e1e2d46464f3bdfb461e967ca8ff82`. Actual checked build and source controls are separate root-owned gates. The callbacks owner supplies the existing 17-observation controller successor and focused last-live-field source/controller, including erasure and callback-order cases.
