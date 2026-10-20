# Compose only after direct-fields/model.bend. Exact original match hooks stay
# unchanged; validated mature mask facts remain the fallback for all slots.
@unsafe
def p113df_field_env(+book: List<&2,KDef>, +mat: KTerm, +count: U32, +i: U32, +n: U32) -> List<&2,NC_Binding>:
  nt_choose(List<&2,NC_Binding>,U32.is_eq(i,count),u => [],
    u => Con{p113n_field_binding(book,mat,count,i,n),p113df_field_env(book,mat,count,U32.inc(i),n)})
