# Independent final admission of the actual demand-lowered program.
# Adapter bodies are checked exactly; all other bodies use the original verifier.
# No synthetic original body, producer validity bit or registry is trusted.

@unsafe
def p167v_allowed(+book: List<&2,KDef>, +source: String, +bangs: List<&2,String>, +ready: KDef) -> Bool:
  +definition = lookup(book,source)
  +arity = nd_arity(book,source)
  +signature = p111v_get(ready,p113d_public(book,source))
  String.eq(dk(definition),"Def") && Bool.not(nc_native_def(definition) || nc_foreign(definition) || nb_contains(bangs,source)) &&
    U32.is_le(arity,32) && String.eq(dk(signature),"P113Direct") &&
    U32.is_eq(da(signature),arity) && U32.is_eq(dx(signature),1) && U32.is_eq(ix(dv(signature)),0)

# Independent mixed original boundary. Generic bodies still use the unchanged
# verifier. Exact adapters are checked against source, headers AND final workers.
@unsafe
def p167v_obligation(+entry: KDef, +book: List<&2,KDef>, +bangs: List<&2,String>, +headers: KDef, +ready: KDef) -> Bool:
  +owner = dn(entry)
  +source = nm(dt(entry))
  +header = p111v_get(headers,owner)
  String.eq(dk(entry),"P164Adapter") && String.eq(tg(dt(entry)),"Ref") &&
    String.eq(owner,p113d_public(book,source)) && U32.is_eq(da(entry),nd_arity(book,source)) &&
    p167v_allowed(book,source,bangs,ready) && String.eq(dk(header),"function") &&
    U32.is_eq(da(header),da(entry)) && U32.is_eq(dx(header),0)

@unsafe
def p167v_bucket(entries: List<&2,KDef>, +book: List<&2,KDef>, +bangs: List<&2,String>, +headers: KDef, +ready: KDef) -> String:
  match entries:
    case Nil{}: ""
    case Con{+head,rest}:
      nt_choose(String,p167v_obligation(head,book,bangs,headers,ready),
        u => p167v_bucket(rest,book,bangs,headers,ready),
        u => "demand adapter source/header/final-worker obligation: " ++ dn(head))

@unsafe
def p167v_obligations(tree: KDef, +book: List<&2,KDef>, +bangs: List<&2,String>, +headers: KDef, +ready: KDef) -> String:
  match tree:
    case KIndexLeaf{hash,bucket}: p167v_bucket(bucket,book,bangs,headers,ready)
    case KIndexNode{hash,mask,left,right}:
      p111_first(p167v_obligations(left,book,bangs,headers,ready),p167v_obligations(right,book,bangs,headers,ready))
    case KDef{name,kind,arity,templates,typ,value,ctors,native,unsafe}:
      nt_choose(String,String.eq(kind,"Absent"),u => "",u => "demand invalid adapter map")

@unsafe
def p167v_one(+segment: N111Segment, +ids: N111Ids, adapters: KDef) -> String:
  match segment:
    case N111Segment{+name,+arity,result,incoming,flags,body}:
      +entry = p111v_get(adapters,name)
      nt_choose(String,String.eq(dk(entry),"Absent"),u => p111v_segment(segment,ids),u =>
        nt_choose(String,String.eq(dk(entry),"P164Adapter") && U32.is_eq(da(entry),arity) && p164a_shape(segment),
          v => "",v => "demand adapter body/header mismatch: " ++ name))

@unsafe
def p167v_segments(segments: List<&2,N111Segment>, +ids: N111Ids, +adapters: KDef) -> String:
  match segments:
    case Nil{}: ""
    case Con{head,rest}:
      p167v_segment_done(rest,ids,adapters,p167v_one(head,ids,adapters))

@unsafe
def p167v_segment_done(+rest: List<&2,N111Segment>, +ids: N111Ids, +adapters: KDef, +error: String) -> String:
  nt_choose(String,String.is_empty(error),u => p167v_segments(rest,ids,adapters),u => error)

@unsafe
def p167v_scans(+book: List<&2,KDef>, +bangs: List<&2,String>, +program: P113DProgram, +adapters: KDef,
    functions: P111VScan, constructors: P111VScan) -> String:
  match program functions constructors:
    case P113DProgram{+original,+direct} P111VScan{+fs,+fe,fc} P111VScan{+cs,+ce,cc}:
      +main = p111v_get(fs,"main")
      nt_choose(String,Bool.not(String.is_empty(fe)),u => fe,u =>
      nt_choose(String,Bool.not(String.is_empty(ce)),u => ce,u =>
      nt_choose(String,String.eq(dk(main),"Absent") || Bool.not(U32.is_eq(da(main),0)) || Bool.not(U32.is_eq(dx(main),0)),
        u => "program requires a direct, zero-argument main segment",u =>
        p167v_catalogued(original,N111Ids{fs,cs},adapters,
          p167v_obligations(adapters,book,bangs,fs,p113e_signatures(direct,missing()))))))

@unsafe
def p167v_catalogued(+original: P112StaticProgram, +ids: N111Ids, +adapters: KDef, +error: String) -> String:
  match original:
    case P112StaticProgram{P111Program{segments,ctors,show,names,effects,pure},nodes}:
      nt_choose(String,String.is_empty(error),u =>
        p111_first(p167v_segments(segments,ids,adapters),p112s_image_error(original)),u => error)

@unsafe
def p167v_original(+book: List<&2,KDef>, +bangs: List<&2,String>, +program: P113DProgram, +adapters: KDef) -> String:
  match program:
    case P113DProgram{P112StaticProgram{P111Program{segments,ctors,show,names,effects,pure},nodes},functions}:
      p167v_scans(book,bangs,program,adapters,p111v_functions(segments,P111VScan{missing(),"",0}),
        p111v_constructors(ctors,P111VScan{missing(),"",0}))

# All final workers are private. Public entry behavior is the independently
# authenticated actual adapter, not an emitter's choice to replace a generic body.
@unsafe
def p167v_private(functions: List<&2,P113DFunction>) -> Bool:
  match functions:
    case Nil{}: True{}
    case Con{P113DFunction{name,params,result,public,body},rest}:
      Bool.not(public) && p167v_private(rest)

# p113e_functions checks the actual final list in dependency order. Ordinary
# self/mutual calls are refused; the existing tail-again operation remains legal.
@unsafe
def p167v_direct(+program: P113DProgram, +error: String) -> String:
  match program:
    case P113DProgram{P112StaticProgram{P111Program{segments,constructors,show,names,effects,pure},nodes},+functions}:
      nt_choose(String,String.is_empty(error),u =>
        nt_choose(String,p167v_private(functions),v =>
          p113e_functions(functions,N111Ids{p113e_originals(segments,missing()),ns_ctor_index(constructors,missing())},missing()),
          v => "demand final worker must be private"),u => error)

@unsafe
def p167v_final(+book: List<&2,KDef>, +bangs: List<&2,String>, +adapters: KDef, +program: P113DProgram) -> String:
  p167v_direct(program,p167v_original(book,bangs,program,adapters))
