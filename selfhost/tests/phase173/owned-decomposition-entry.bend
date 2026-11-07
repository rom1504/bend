# Single experimental preparation hook; retain the original static algorithm.
@unsafe
def p112s_prepare(+book: List<&2,KDef>, +names: List<&2,String>, +constructors: List<&2,N_Constructor>) -> P112SPrepared:
  p173oa_prepared(book,names,
    nt_choose(P112SPrepared,nc_pack_foreign(book),u => P112SPrepared{book,[],""},u =>
      nt_choose(P112SPrepared,String.eq(dk(index_first(book)),"BookCache"),
        u => p112s_attach(book,constructors,p112s_defs(book,p112s_block_effects(ns_ctor_index(constructors,missing()),p111_effects(book,names)),names,[],P112SImage{0,[],missing(),""})),
        u => P112SPrepared{book,[],"static preparation requires a fresh cached request"})))
