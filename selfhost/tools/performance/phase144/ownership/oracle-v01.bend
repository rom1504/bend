# Exact selected-source reference declarations; names only are changed.

@unsafe
def p144o_original_ctor_identity(
  +book: List<&2, KDef>,
  +name: String,
) -> String:
  kc(String, p144o_original(book, name), u => name, u => nc_ctor_encode(name))

@unsafe
def p144o_original_ctor_specs(+book: List<&2, KDef>, cs: List<&2, KDef>, +params: U32) -> List<&2, N_Constructor>:
  match cs:
    case Nil{}: Nil{}
    case Con{+c, rest}: Con{N_Constructor{p144o_original_ctor_identity(book, dn(c)), nc_live_count(book, nc_skip_tel(book, dt(c), params), da(c)), True{}}, p144o_original_ctor_specs(book, rest, params)}

@unsafe
def p144o_original_constructors(book, ds):
  match ds:
    case Nil{}: Nil{}
    case Con{+d, +rest}:
      nt_choose(List<&2, N_Constructor>, p88_string_eq(dk(d), "ADT"),
        u => List.append(&2, N_Constructor, p144o_original_ctor_specs(book, dc(d), da(d)), p144o_original_constructors(book, rest)),
        u => nt_choose(List<&2, N_Constructor>, p88_string_eq(dk(d), "Def") && nc_foreign(d),
          u => Con{N_Constructor{dn(d), nc_all_args(book, dt(d)), True{}}, p144o_original_constructors(book, rest)},
          u => p144o_original_constructors(book, rest)))
