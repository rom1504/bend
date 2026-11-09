# Renderer-only proof at p134e_registered's verified IDs/final-tables pairing.
# No source names are reserved or inserted. Proof occupies otherwise absent
# N111Id.value metadata and is stripped before every new pairing. Raw/manual
# IDs, incomplete tables and unsupported capabilities keep the dynamic guard.

@unsafe
def p185cb_items(tables: List<&2,P111QData>, +name: String) -> List<&2,P111QDatum>:
  match tables:
    case Nil{}: []
    case Con{P111QData{+key,alignment,exported,items},rest}:
      nt_choose(List<&2,P111QDatum>,String.eq(key,name),u => items,u => p185cb_items(rest,name))

@unsafe
def p185cb_unique(tables: List<&2,P111QData>, +name: String, +found: Bool) -> Bool:
  match tables:
    case Nil{}: found
    case Con{P111QData{key,alignment,exported,items},+rest}:
      nt_choose(Bool,String.eq(key,name),u => nt_choose(Bool,found,v => False{},v => p185cb_unique(rest,name,True{})),
        u => p185cb_unique(rest,name,found))

@unsafe
def p185cb_at(items: List<&2,P111QDatum>, +index: U32) -> P111QDatum:
  match items:
    case Nil{}: P111QZeros{0}
    case Con{head,rest}: nt_choose(P111QDatum,U32.is_eq(index,0),u => head,u => p185cb_at(rest,U32.sub(index,1)))

def p185cb_number(item: P111QDatum) -> U32:
  match item:
    case P111QLong{lo,0}: lo
    case _: 4294967295

@unsafe
def p185cb_ref(item: P111QDatum, +name: String) -> Bool:
  match item:
    case P111QReloc{symbol,0}: String.eq(symbol,name)
    case _: False{}

@unsafe
def p185cb_header(+tables: List<&2,P111QData>, +header: List<&2,P111QDatum>) -> Bool:
  +caps = p185cb_number(p185cb_at(header,11))
  U32.is_eq(nt_count(P111QDatum,header),24) &&
    p185cb_unique(tables,"p111_program",False{}) && p185cb_unique(tables,"p111_cid_arity",False{}) &&
    p185cb_unique(tables,"p111_cid_hot",False{}) && U32.is_eq(p185cb_number(p185cb_at(header,0)),11102) &&
    U32.is_eq(p185cb_number(p185cb_at(header,1)),192) && U32.is_ge(caps,9) && U32.is_le(caps,15) &&
    U32.is_eq(U32.and(caps,1),1) && p185cb_ref(p185cb_at(header,16),"p111_cid_arity") &&
    p185cb_ref(p185cb_at(header,17),"p111_cid_hot")

# One linear table pass builds a numeric-CID index. The later constructor
# index walk performs bounded trie lookups, never a table scan per constructor.
@unsafe
def p185cb_scan(arities: List<&2,P111QDatum>, hots: List<&2,P111QDatum>, +next: U32, +index: KDef) -> P111VScan:
  match arities hots:
    case Nil{} Nil{}: P111VScan{index,"",next}
    case Con{P111QByte{+arity},rest} Con{P111QByte{+hot},more}:
      nt_choose(P111VScan,U32.is_lt(next,65536) && U32.is_le(arity,255) && U32.is_le(hot,1),
        u => p185cb_scan(rest,more,U32.inc(next),p111v_put(index,U32.show(next),"P185CtorTable",arity,hot)),
        u => P111VScan{missing(),"descriptor constructor bytes",0})
    case _ _: P111VScan{missing(),"descriptor constructor tables",0}

@unsafe
def p185cb_marker(+term: KTerm) -> Bool:
  String.eq(tg(term),"P185BoundDescriptor") && String.is_empty(nm(term)) &&
    U32.is_eq(ix(term),11102) && U32.is_eq(qt(term),192) && U32.is_eq(terms_len(ks(term)),0)

@unsafe
def p185cb_entry(+entry: KDef, +ready: Bool, +metadata: KDef) -> KDef:
  match entry:
    case KDef{name,+kind,+cid,+arity,+typ,+value,children,native,unsafe}:
      +clean = nt_choose(KTerm,p185cb_marker(value),u => atom("Absent"),u => value)
      +actual = p111v_get(metadata,U32.show(cid))
      +ok = ready && String.eq(kind,"N111Id") && String.eq(tg(clean),"Absent") &&
        String.eq(tg(typ),"P185Constructor") && U32.is_eq(ix(typ),0) && U32.is_eq(qt(typ),11102) &&
        String.eq(dk(actual),"P185CtorTable") && U32.is_eq(da(actual),arity) && U32.is_eq(dx(actual),0)
      KDef{name,kind,cid,arity,typ,nt_choose(KTerm,ok,u => kt("P185BoundDescriptor","",11102,192,[]),u => clean),children,native,unsafe}
    case _: entry

@unsafe
def p185cb_bucket(bucket: List<&2,KDef>, +ready: Bool, +metadata: KDef) -> List<&2,KDef>:
  match bucket:
    case Nil{}: []
    case Con{head,rest}: Con{p185cb_tree(head,ready,metadata),p185cb_bucket(rest,ready,metadata)}

@unsafe
def p185cb_tree(+tree: KDef, +ready: Bool, +metadata: KDef) -> KDef:
  match tree:
    case KIndexLeaf{hash,bucket}: KIndexLeaf{hash,p185cb_bucket(bucket,ready,metadata)}
    case KIndexNode{hash,mask,left,right}: KIndexNode{hash,mask,p185cb_tree(left,ready,metadata),p185cb_tree(right,ready,metadata)}
    case KDef{name,+kind,cid,arity,typ,value,children,native,unsafe}:
      nt_choose(KDef,String.eq(kind,"N111Id"),u => p185cb_entry(tree,ready,metadata),
        u => KDef{name,kind,cid,arity,typ,value,p185cb_bucket(children,ready,metadata),native,unsafe})

@unsafe
def p185cb_scanned(ids: N111Ids, +expected: U32, scan: P111VScan) -> N111Ids:
  match ids scan:
    case N111Ids{functions,constructors} P111VScan{metadata,error,+count}:
      N111Ids{functions,p185cb_tree(constructors,String.is_empty(error) && U32.is_gt(count,0) && U32.is_eq(count,expected),metadata)}

@unsafe
def p185cb_bind(+ids: N111Ids, +tables: List<&2,P111QData>) -> N111Ids:
  +header = p185cb_items(tables,"p111_program")
  p185cb_scanned(ids,p185cb_number(p185cb_at(header,3)),
    nt_choose(P111VScan,p185cb_header(tables,header),
      u => p185cb_scan(p185cb_items(tables,"p111_cid_arity"),p185cb_items(tables,"p111_cid_hot"),0,missing()),
      u => P111VScan{missing(),"unpaired descriptor",0}))

@unsafe
def p185cb_known(+ctor: String, ids: N111Ids) -> Bool:
  match ids:
    case N111Ids{functions,constructors}:
      p185cb_marker(dv(index_find(constructors,ctor,index_hash(ctor,2166136261),32)))

@unsafe
def p185cb_construct(+stmt: N111Stmt, +dest: String, +ctor: String, +buffer: String, +count: U32, +ids: N111Ids, +site: U32) -> List<&2,N111Stmt>:
  nt_choose(List<&2,N111Stmt>,p185cb_known(ctor,ids),
    u => p185cc_cached(stmt,dest,ctor,buffer,count,site),
    u => nt_append(N111Stmt,p185cc_guard(site),
      [N111If{p114t_local(site,"cold_guard"),p185cc_cached(stmt,dest,ctor,buffer,count,site),[stmt]}]))
