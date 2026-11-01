# Experimental policy selection over the existing verified emission routes.
# 0: current direct/H/R/G/extended-H/generic precedence.
# 1: complete direct, then the original H query, then generic/fused.
# 2: complete direct, then generic/fused.
# This does not make an unchecked program, worker or ownership claim admissible.
# Plans must come from the unchanged checked lowering/final-verification path.
# The caller validates the policy domain before compiling a request.

@unsafe
def p149r_limited(+regions: U32) -> Bool:
  U32.is_eq(regions,1) || U32.is_eq(regions,2)


@unsafe
def p149r_fallback(+segment: N111Segment, +index: P112FusionIndex, +ids: N111Ids, +ready: KDef) -> String:
  p112f_public(segment,ids,ready,p112c_plan_index(segment,index,ready))


@unsafe
def p149r_selected(+regions: U32, +segment: N111Segment, context: P134Context) -> String:
  match segment context:
    case N111Segment{+name,+arity,result,incoming,flags,body} P134Context{+ids,+index,direct,+ready,view,lookups,heap,mode}:
      nt_choose(String,U32.is_eq(mode,0),
        u => p149r_fallback(segment,index,ids,ready),
        u => p149r_direct(regions,segment,index,ids,ready,name,arity,p111v_get(direct,name)))


@unsafe
def p149r_direct(+regions: U32, +segment: N111Segment, +index: P112FusionIndex, +ids: N111Ids,
    +ready: KDef, +name: String, +arity: U32, +function: KDef) -> String:
  nt_choose(String,String.eq(dk(function),"P113Direct") && U32.is_eq(ix(dv(function)),1),
    u => p113e_public(name,arity),
    u => nt_choose(String,U32.is_eq(regions,1),
      v => p124r_public_extended(segment,index,ids,ready,p114h_plan(segment,index,ready)),
      v => p149r_fallback(segment,index,ids,ready)))


@unsafe
def p149r_public(+regions: U32, +segment: N111Segment, +context: P134Context) -> String:
  nt_choose(String,p149r_limited(regions),
    u => p149r_selected(regions,segment,context),u => p134e_public(segment,context))

# Policy stays outside the existing cursor. Empty private/legacy transitions
# must stay here: the original next function can recurse directly to Public.
# Every other piece, table slice, boundary and renderer remains unchanged.

@unsafe
def p149r_next_selected(+regions: U32, cursor: P134Cursor) -> P134Step:
  match cursor:
    case P134Private{Nil{},context,next}: p149r_next_selected(regions,next)
    case P134Legacy{Nil{},context,next}: p149r_next_selected(regions,next)
    case P134Public{Nil{},context,next}: p149r_next_selected(regions,next)
    case P134Public{Con{head,rest},+context,next}:
      P134Piece{p149r_selected(regions,head,context),True{},P134Public{rest,context,next}}
    case _: p134e_next(cursor)


@unsafe
def p149r_next(+regions: U32, +cursor: P134Cursor) -> P134Step:
  nt_choose(P134Step,p149r_limited(regions),
    u => p149r_next_selected(regions,cursor),u => p134e_next(cursor))

# Collection is only for compatibility/control calls. Full native output uses
# p149rw_plan and consumes the same bounded stream without collecting strings.

@unsafe
def p149r_collect(+regions: U32, +emitted: P111Emission) -> P111Emission:
  nt_choose(P111Emission,p149r_limited(regions),
    u => p149r_collect_selected(regions,emitted),u => p134e_collect(emitted))


@unsafe
def p149r_collect_selected(regions: U32, emitted: P111Emission) -> P111Emission:
  match emitted:
    case P111Emission{chunks,error}: P111Emission{chunks,error}
    case P134Planned{plan}: P111Emission{p149r_collect_cursor(regions,p134e_begin(plan),[],[]),""}


@unsafe
def p149r_collect_cursor(+regions: U32, cursor: P134Cursor, pending: List<&2,String>, chunks: List<&2,String>) -> List<&2,String>:
  p149r_collect_step(regions,p149r_next(regions,cursor),pending,chunks)


@unsafe
def p149r_collect_step(+regions: U32, step: P134Step, pending: List<&2,String>, +chunks: List<&2,String>) -> List<&2,String>:
  match step:
    case P134Done{}: nt_reverse(String,chunks,[])
    case P134Piece{text,+legacy_end,+next}:
      +parts : List<&2,String> = Con{text,pending}
      nt_choose(List<&2,String>,legacy_end,
        u => p149r_collect_cursor(regions,next,[],Con{nt_text_finish(parts,""),chunks}),
        u => p149r_collect_cursor(regions,next,parts,chunks))


@unsafe
def p149rw_written(regions: U32, pair: File & Result<&1,&1,U32 & String,Unit>, next: P134Cursor) -> IO(U32):
  (file,result) = pair
  match result:
    case Done{unit}: p149rw_drain(regions,file,next)
    case Fail{error}:
      do IO<U32>:
        Unit <- File.close(file)
        IO.pass(U32,Fail{error})


@unsafe
def p149rw_end(regions: U32, ending: Bool, file: File, next: P134Cursor) -> IO(U32):
  match ending:
    case False{}: p149rw_drain(regions,file,next)
    case True{}:
      do IO<U32>:
        pair : File & Result<&1,&1,U32 & String,Unit> <- File.write(file,"\n")
        p149rw_written(regions,pair,next)


@unsafe
def p149rw_text(regions: U32, pair: File & Result<&1,&1,U32 & String,Unit>, ending: Bool, next: P134Cursor) -> IO(U32):
  (file,result) = pair
  match result:
    case Done{unit}: p149rw_end(regions,ending,file,next)
    case Fail{error}:
      do IO<U32>:
        Unit <- File.close(file)
        IO.pass(U32,Fail{error})


@unsafe
def p149rw_step(regions: U32, file: File, step: P134Step) -> IO(U32):
  match step:
    case P134Done{}:
      do IO<U32>:
        Unit <- File.close(file)
        IO.pure(U32,0)
    case P134Piece{text,legacy_end,next}:
      do IO<U32>:
        pair : File & Result<&1,&1,U32 & String,Unit> <- File.write(file,text)
        p149rw_text(regions,pair,legacy_end,next)


@unsafe
def p149rw_drain(+regions: U32, file: File, cursor: P134Cursor) -> IO(U32):
  p149rw_step(regions,file,p149r_next(regions,cursor))


@unsafe
def p149rw_selected(regions: U32, plan: P134EmissionPlan) -> IO(U32):
  do IO<U32>:
    file : File <- IO.try(File,File.open("/dev/stdout","a"))
    p149rw_drain(regions,file,p134e_begin(plan))


@unsafe
def p149rw_plan(+regions: U32, +plan: P134EmissionPlan) -> IO(U32):
  nt_choose(IO(U32),p149r_limited(regions),
    u => p149rw_selected(regions,plan),u => p134w_plan(plan))
