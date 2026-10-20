# Mat.qty is the mature per-use scalar-field certificate, computed by
# nc_erase_mat before erasure from the instantiated checked constructor type.
# This module consumes that plan; it does not infer types from a constructor
# spelling or from the numerical shape of an arbitrary Term.
@unsafe
def p113df_mask(+mat: KTerm, +count: U32) -> U32:
  nt_choose(U32,String.eq(tg(mat),"Mat") && U32.is_eq(ix(mat),U32.inc(count)) && U32.is_le(count,8),
    u => nt_choose(U32,U32.is_lt(qt(mat),U32.shln(1,U32.to_nat(count))),v => qt(mat),v => 0),
    u => 0)

# Keep the existing local names, IDs and full-Term words. Only ownership kind
# changes. The book argument is reserved for an independently admitted Nat
# extension; the scalar certificate already contains its original type proof.
@unsafe
def p113df_field_env(+book: List<&2,KDef>, +mat: KTerm, +count: U32, +i: U32, +n: U32) -> List<&2,NC_Binding>:
  nc_field_env(nm(mat),"",count,i,n,p113df_mask(mat,count))

@unsafe
def p113df_kind(+mask: U32, +i: U32, +prior: N_WordKind) -> N_WordKind:
  nt_choose(N_WordKind,U32.is_ne(U32.and(mask,U32.shln(1,U32.to_nat(i))),0),
    u => N_W32{},u => prior)

@unsafe
def p113df_refine(bindings: List<&2,NC_Binding>, +mask: U32, +i: U32) -> List<&2,NC_Binding>:
  match bindings:
    case Nil{}: []
    case Con{NC_Binding{id,word,kind},rest}:
      Con{NC_Binding{id,word,p113df_kind(mask,i,kind)},p113df_refine(rest,mask,U32.inc(i))}

@unsafe
def p113df_vars(fields: List<&2,KTerm>) -> Bool:
  match fields:
    case Nil{}: True{}
    case Con{+field,rest}: String.eq(tg(field),"Var") && p113df_vars(rest)

# A virtual product match transfers the same independent fields as a boxed
# take. Refine only the exact matched constructor's variable fields, retaining
# every preexisting kind on an unset bit. No boxing or physical ABI changes.
@unsafe
def p113df_bundle_env(+mat: KTerm, +bundle: KTerm, +env: List<&2,NC_Binding>) -> List<&2,NC_Binding>:
  +fields = ks(bundle)
  +bindings = nq_field_bindings(fields,env)
  nt_choose(List<&2,NC_Binding>,String.eq(tg(bundle),"NQBundle") && String.eq(nm(mat),nm(bundle)) && p113df_vars(fields),
    u => p113df_refine(bindings,p113df_mask(mat,terms_len(fields)),0),
    u => bindings)
