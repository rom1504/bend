# Independent mixed original boundary. Generic bodies still use the unchanged
# verifier. Exact adapters are checked against source, headers AND final workers.
@unsafe
def p164v_obligation(+entry: KDef, +book: List<&2,KDef>, +bangs: List<&2,String>, +headers: KDef, +ready: KDef) -> Bool:
  +owner = dn(entry)
  +source = nm(dt(entry))
  +header = p111v_get(headers,owner)
  String.eq(dk(entry),"P164Adapter") && String.eq(tg(dt(entry)),"Ref") &&
    String.eq(owner,p113d_public(book,source)) && U32.is_eq(da(entry),nd_arity(book,source)) &&
    p164a_allowed(book,source,bangs,ready) && String.eq(dk(header),"function") &&
    U32.is_eq(da(header),da(entry)) && U32.is_eq(dx(header),0)

@unsafe
def p164v_bucket(entries: List<&2,KDef>, +book: List<&2,KDef>, +bangs: List<&2,String>, +headers: KDef, +ready: KDef) -> String:
  match entries:
    case Nil{}: ""
    case Con{+head,rest}:
      nt_choose(String,p164v_obligation(head,book,bangs,headers,ready),
        u => p164v_bucket(rest,book,bangs,headers,ready),
        u => "hybrid adapter source/header/final-worker obligation: " ++ dn(head))

@unsafe
def p164v_obligations(tree: KDef, +book: List<&2,KDef>, +bangs: List<&2,String>, +headers: KDef, +ready: KDef) -> String:
  match tree:
    case KIndexLeaf{hash,bucket}: p164v_bucket(bucket,book,bangs,headers,ready)
    case KIndexNode{hash,mask,left,right}:
      p111_first(p164v_obligations(left,book,bangs,headers,ready),p164v_obligations(right,book,bangs,headers,ready))
    case KDef{name,kind,arity,templates,typ,value,ctors,native,unsafe}:
      nt_choose(String,String.eq(kind,"Absent"),u => "",u => "hybrid invalid adapter map")

@unsafe
def p164v_one(+segment: N111Segment, +ids: N111Ids, adapters: KDef) -> String:
  match segment:
    case N111Segment{+name,+arity,result,incoming,flags,body}:
      +entry = p111v_get(adapters,name)
      nt_choose(String,String.eq(dk(entry),"Absent"),u => p111v_segment(segment,ids),u =>
        nt_choose(String,String.eq(dk(entry),"P164Adapter") && U32.is_eq(da(entry),arity) && p164a_shape(segment),
          v => "",v => "hybrid adapter body/header mismatch: " ++ name))

@unsafe
def p164v_segments(segments: List<&2,N111Segment>, +ids: N111Ids, +adapters: KDef) -> String:
  match segments:
    case Nil{}: ""
    case Con{head,rest}:
      p164v_segment_done(rest,ids,adapters,p164v_one(head,ids,adapters))

@unsafe
def p164v_segment_done(+rest: List<&2,N111Segment>, +ids: N111Ids, +adapters: KDef, +error: String) -> String:
  nt_choose(String,String.is_empty(error),u => p164v_segments(rest,ids,adapters),u => error)

@unsafe
def p164v_scans(+book: List<&2,KDef>, +bangs: List<&2,String>, +program: P113DProgram, +adapters: KDef,
    functions: P111VScan, constructors: P111VScan) -> String:
  match program functions constructors:
    case P113DProgram{+original,+direct} P111VScan{+fs,+fe,fc} P111VScan{+cs,+ce,cc}:
      +main = p111v_get(fs,"main")
      nt_choose(String,Bool.not(String.is_empty(fe)),u => fe,u =>
      nt_choose(String,Bool.not(String.is_empty(ce)),u => ce,u =>
      nt_choose(String,String.eq(dk(main),"Absent") || Bool.not(U32.is_eq(da(main),0)) || Bool.not(U32.is_eq(dx(main),0)),
        u => "program requires a direct, zero-argument main segment",u =>
        p164v_catalogued(original,N111Ids{fs,cs},adapters,
          p164v_obligations(adapters,book,bangs,fs,p113e_signatures(direct,missing()))))))

@unsafe
def p164v_catalogued(+original: P112StaticProgram, +ids: N111Ids, +adapters: KDef, +error: String) -> String:
  match original:
    case P112StaticProgram{P111Program{segments,ctors,show,names,effects,pure},nodes}:
      nt_choose(String,String.is_empty(error),u =>
        p111_first(p164v_segments(segments,ids,adapters),p112s_image_error(original)),u => error)

@unsafe
def p164v_original(+book: List<&2,KDef>, +bangs: List<&2,String>, +program: P113DProgram, +adapters: KDef) -> String:
  match program:
    case P113DProgram{P112StaticProgram{P111Program{segments,ctors,show,names,effects,pure},nodes},functions}:
      p164v_scans(book,bangs,program,adapters,p111v_functions(segments,P111VScan{missing(),"",0}),
        p111v_constructors(ctors,P111VScan{missing(),"",0}))

# Final borrowed imports retain their original independent projection checker;
# array and transport namespace checks are also unchanged.
@unsafe
def p164v_final(+book: List<&2,KDef>, +bangs: List<&2,String>, +adapters: KDef, +program: P113AProgram) -> String:
  match program:
    case P113AProgram{+direct,+certificate}:
      p164v_final_original(program,direct,certificate,p164v_original(book,bangs,direct,adapters))

@unsafe
def p164v_final_original(+program: P113AProgram, +direct: P113DProgram, +certificate: P113ACertificate, +error: String) -> String:
  match direct:
    case P113DProgram{P112StaticProgram{original,nodes},functions}:
      nt_choose(String,String.is_empty(error),u =>
        p114t_verify_done(program,p113a_verify_after(direct,certificate,p118b_verify_functions(functions,original))),u => error)
