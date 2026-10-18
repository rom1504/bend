# Consume exactly the source declaration's parameter count. A function-valued
# result must not be mistaken for another argument by erased/direct arity.
@unsafe
def nxe_signature(+term: KTerm, +left: U32, +params: List<&2,NxeRole>) -> NxeSignature:
  nx_choose(NxeSignature,U32.is_eq(left,0),u =>
    nx_choose(NxeSignature,nxe_role_known(nxe_role(term)),v => NxeSignature{params,nxe_role(term),""},v => NxeSignature{[],NxeUnknown{},"unsupported result representation"}),u =>
    nx_choose(NxeSignature,(nxe_all(term,1) || nxe_all(term,2)) && nxe_role_known(nxe_role(kid(term,0))),v =>
      nxe_signature(kid(term,1),U32.sub(left,1),nxo_join(NxeRole,params,[nxe_role(kid(term,0))])),v =>
      NxeSignature{[],NxeUnknown{},"unsupported, erased or dependent parameter"}))

def nxe_refused(error: String) -> NxeResult:
  NxeResult{None{},error}

@unsafe
def nxe_finish(+source: KDef, +erased: KDef, signature: NxeSignature) -> NxeResult:
  match signature:
    case NxeSignature{params,result,+error}:
      nx_choose(NxeResult,Bool.not(String.eq(error,"")),u => nxe_refused(error),u =>
        nx_choose(NxeResult,String.eq(dk(erased),"NativeErasedBody") && String.eq(dn(source),dn(erased)) && U32.is_eq(da(erased),nxo_size(NxeRole,params)),v =>
          NxeResult{Some{NxeCertificate{source,erased,params,result,nxe_constructors(),"phase110-Base-ListString-owned-Term-v1"}},""},v =>
          nxe_refused("missing or mismatched erased fact")))

@unsafe
def nxe_source(+source: KDef, +erased: KDef) -> NxeResult:
  nx_choose(NxeResult,String.eq(dk(source),"Def") && Bool.not(String.eq(dn(source),"")) && U32.is_gt(da(source),0) && U32.is_le(da(source),8),u =>
    nxe_finish(source,erased,nxe_signature(nxe_type(source),da(source),[])),u => nxe_refused("unsupported source definition or declared arity"))

@unsafe
def nxe_entry(+source_book: List<&2,KDef>, +erased_facts: List<&2,KDef>, +name: String) -> NxeResult:
  nx_choose(NxeResult,nxe_layout_ok(source_book),u => nxe_source(nxe_lookup(source_book,name),nxe_lookup(erased_facts,name)),u =>
    nxe_refused("canonical checked Base descriptors required"))
