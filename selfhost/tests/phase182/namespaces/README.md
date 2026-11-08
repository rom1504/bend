These fixtures are exact copies from upstream commit
`9a4223d577ba56a0cb53d1fd952d2b481c38930f`, preserving each file's complete `#|`
observation and relative imports. Files ending `_lib.bend` are dependencies and
also retain their upstream standalone observations. No compiler or fixture was
executed while preparing this change.

The maintained frontend now selects a namespace by syntax: references, laws and
datatype applications use declarations; constructors, matcher arms and the
bare-constructor pattern check use constructors. Alias ambiguity uses the same
selected namespace. This ports
[1a0e615](https://github.com/bendlang/bend/commit/1a0e6153f6f9c032c354cf8f2f17f13f4039820e).
The old constructor-dependent fallback when locating a declaration is removed.
The datatype-braces diagnostic tries the written name and then its unqualified
name, preserving the useful `Maybe{...}` note in imported files.

Generated sugar names select the current file's own declaration or constructor,
falling back to Base when only Base declares that spelling. They do not use
import aliases. This applies to `Exists` (including `where` and `exs` laws),
`Empty`, list/tuple constructors, fixed operators, and array construction,
indexing and assignment. Operator namespace propagation and assignment-statement
recognition compare against those same resolved names. Binder lookup and literal
encodings are unchanged.

Let values still infer in their common outer scope. The inferred type receives a
second kind check only when `kindq(e, q) == 2`: a safe reusable binding requires
Data. Affine/erased bindings and unsafe reusable bindings retain the inferred
world without repeating that check. Value checking, parallel binding scope,
quantity-use checks and unsafe policy remain in place. This ports
[fa1066b](https://github.com/bendlang/bend/commit/fa1066befe4b1c98fb293709f2770d1a0e8e27c5).

| Entry fixture | Independent obligation |
| --- | --- |
| `ctr_named_def.bend` | `Done{...}` and matcher arms name the constructor while `Done(...)` names the module's definition; prints `True{}`. |
| `law_def_named_ctr.bend` | An imported law's forward `Done` reference cannot bind to the entry's unrelated definition; the false equality is rejected. |
| `ctr_of_datatype.bend` | Imported braced `Maybe` keeps the datatype repair note. |
| `sugar_alias.bend` | Aliases named String/Array/Nat do not capture sugar. |
| `sugar_ctr_tld.bend` | Sugar chooses constructor identity independently of a same-spelled declaration. |
| `sugar_list_own.bend` | A Base-free imported module's list, tuple and cons syntax use its own constructors. |
| `ops_own.bend` | Fixed operator sugar uses the module's own definitions. |
| `neq_own_empty.bend` | Inequality sugar uses the module's own Empty. |
| `where_own_exists.bend` | The module's own Exists remains attached to a where-law; invalid evidence is rejected. |
| `or_own_bool.bend` | Boolean fixed sugar and nested operator propagation retain the module's namespace. |
| `let_dependent_type.bend` | Thirty dependent lets, shadowing and erased bindings check once at their source; prints `&1`. |
| `let_unsafe_dependent_type.bend` | Thirty unsafe reusable dependent lets preserve the existing unsafe kind policy; prints `&1`. |
| `let_dependent_domain.bend` | An ordinary dependent return domain remains accepted. |
| `let_dependent_domain_bad.bend` | An invalid type argument is still rejected at the originating signature. |
| `let_plus_dependent_type.bend` | A reusable binding of Type rather than Data remains rejected. |
| `let_forward_refused.bend` | Avoiding redundant kind checks cannot admit an unavailable definition. |

The six new maintained definitions are `f_context_known`,
`f_context_resolve_table`, `f_context_own`, `f_matcher_named`,
`dg_unqualified_name`, and `dg_datatype_braces`. `f_decl_local_ctor` is removed.
Internal signatures additionally carry the existing input scope or selected name
for `f_binary_plain`, `f_list_nodes`, `f_law_bind`, `f_namespace_operator`, and
`f_context_write`; their callers and forward laws are updated together. None of
the changed definitions occurs in `compiler.json`'s protected declaration table.
The manifest is root-owned and was not edited here. Equality sharing is a
separate Phase182 change.
