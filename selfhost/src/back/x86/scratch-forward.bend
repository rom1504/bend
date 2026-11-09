# Local stack-cell forwarding only. Stores and allocas remain in place. A fact
# dies on source reassignment, overlapping storage, any unknown-address store,
# call, branch or terminal edge. Thus copied/escaped pointers cannot silently
# mutate a remembered cell. No fact is carried around Again or out of setup.
type X185ScratchCell is Data:
  X185ScratchCell{+buffer: String, +offset: U32, +typ: N111Type, +value: N111Value}

type X185ScratchStep is Data:
  X185ScratchStep{+stmt: P113DStmt, +facts: List<&2,X185ScratchCell>}

def x185_scratch_enabled() -> Bool: True{}

@unsafe
def x185_sf_block(name: String, buffers: KDef) -> KDef:
  p111v_put(buffers,name,"X185ScratchBlocked",0,0)

@unsafe
def x185_sf_blocks(names: List<&2,String>, buffers: KDef) -> KDef:
  match names:
    case Nil{}: buffers
    case Con{name,rest}: x185_sf_blocks(rest,x185_sf_block(name,buffers))

@unsafe
def x185_sf_alloca(+name: String, +bytes: U32, +buffers: KDef) -> KDef:
  +old = p111v_get(buffers,name)
  nt_choose(KDef,(x181_register_reserved(name) && Bool.not(String.eq(name,"scratch"))),
    u => x185_sf_block(name,buffers),u => nt_choose(KDef,String.eq(dk(old),"X185ScratchBlocked"),u => buffers,
    u => nt_choose(KDef,U32.is_gt(bytes,0) && U32.is_le(bytes,2048),
      v => p111v_put(buffers,name,"X185ScratchBuffer",
        nt_choose(U32,String.eq(dk(old),"X185ScratchBuffer"),w => U32.min(bytes,da(old)),w => bytes),0),
      v => x185_sf_block(name,buffers))))

law x185_sf_buffers:
  for body: List<&2,P113DStmt>
  for buffers: KDef
  KDef

@unsafe
def x185_sf_scalar_buffer(stmt: N111Stmt, buffers: KDef) -> KDef:
  match stmt:
    case N111Alloca{name,bytes,align}: x185_sf_alloca(name,bytes,buffers)
    case N111Set{name,typ,value}: x185_sf_block(name,buffers)
    case N111Bin{name,typ,op,left,right}: x185_sf_block(name,buffers)
    case N111Load{name,typ,base,offset}: x185_sf_block(name,buffers)
    case N111Offset{name,base,bytes}: x185_sf_block(name,buffers)
    case N111Call{name,typ,symbol,args}: x185_sf_block(name,buffers)
    case N111If{condition,yes,no}:
      x185_sf_buffers(x181_scalar_rows(no),x185_sf_buffers(x181_scalar_rows(yes),buffers))
    case _: buffers

@unsafe
def x185_sf_buffers(body,buffers):
  match body:
    case Nil{}: buffers
    case Con{P113DScalar{stmt},rest}: x185_sf_buffers(rest,x185_sf_scalar_buffer(stmt,buffers))
    case Con{P113DIf{condition,yes,no},rest}:
      x185_sf_buffers(rest,x185_sf_buffers(no,x185_sf_buffers(yes,buffers)))
    case Con{P113DCall{names,target,args},rest}: x185_sf_buffers(rest,x185_sf_blocks(names,buffers))
    case Con{head,rest}: x185_sf_buffers(rest,buffers)

def x185_sf_width(typ: N111Type) -> U32:
  match typ:
    case N111U32{}: 4
    case _: 8

@unsafe
def x185_sf_cell(+buffer: String, +offset: U32, +typ: N111Type, buffers: KDef) -> Bool:
  +entry = p111v_get(buffers,buffer)
  String.eq(dk(entry),"X185ScratchBuffer") && U32.is_le(x185_sf_width(typ),da(entry)) &&
    U32.is_le(offset,U32.sub(da(entry),x185_sf_width(typ)))

@unsafe
def x185_sf_source(value: N111Value, name: String) -> Bool:
  match value:
    case N111Local{source}: String.eq(source,name)
    case _: False{}

# A stored local denotes its value at the store, not at the later load. Killing
# every dependent fact on a definition preserves that snapshot without adding
# hidden locals, even for repeated/mutable definitions and load destinations.
@unsafe
def x185_sf_written(facts: List<&2,X185ScratchCell>, +name: String) -> List<&2,X185ScratchCell>:
  match facts:
    case Nil{}: []
    case Con{+cell,+rest}:
      match cell:
        case X185ScratchCell{buffer,offset,typ,value}:
          nt_choose(List<&2,X185ScratchCell>,x185_sf_source(value,name),
            u => x185_sf_written(rest,name),u => Con{cell,x185_sf_written(rest,name)})

@unsafe
def x185_sf_overlap(facts: List<&2,X185ScratchCell>, +buffer: String, +offset: U32,
    +typ: N111Type) -> List<&2,X185ScratchCell>:
  match facts:
    case Nil{}: []
    case Con{+cell,+rest}:
      match cell:
        case X185ScratchCell{+other,+start,+width,value}:
          nt_choose(List<&2,X185ScratchCell>,String.eq(buffer,other) &&
              U32.is_lt(offset,U32.add(start,x185_sf_width(width))) &&
              U32.is_lt(start,U32.add(offset,x185_sf_width(typ))),
            u => x185_sf_overlap(rest,buffer,offset,typ),
            u => Con{cell,x185_sf_overlap(rest,buffer,offset,typ)})

@unsafe
def x185_sf_find(facts: List<&2,X185ScratchCell>, +buffer: String, +offset: U32,
    +typ: N111Type) -> Maybe<&2,N111Value>:
  match facts:
    case Nil{}: None{}
    case Con{X185ScratchCell{other,start,width,value},rest}:
      nt_choose(Maybe<&2,N111Value>,String.eq(buffer,other) && U32.is_eq(offset,start) &&
          U32.is_eq(p111v_type(typ),p111v_type(width)),
        u => Some{value},u => x185_sf_find(rest,buffer,offset,typ))

@unsafe
def x185_sf_insert(cell: X185ScratchCell, +facts: List<&2,X185ScratchCell>) -> List<&2,X185ScratchCell>:
  nt_choose(List<&2,X185ScratchCell>,U32.is_lt(nt_count(X185ScratchCell,facts),16),
    u => Con{cell,facts},u => facts)

def x185_sf_loaded(stmt: N111Stmt, name: String, typ: N111Type, found: Maybe<&2,N111Value>) -> P113DStmt:
  match found:
    case None{}: P113DScalar{stmt}
    case Some{value}: P113DScalar{N111Set{name,typ,value}}

# A different fixed frame allocation cannot mutate remembered cells. Drop only
# facts for the declared identity or facts that captured its previous address.
@unsafe
def x186_sf_allocated(facts: List<&2,X185ScratchCell>, +name: String) -> List<&2,X185ScratchCell>:
  match facts:
    case Nil{}: []
    case Con{+cell,+rest}:
      match cell:
        case X185ScratchCell{buffer,offset,typ,value}:
          nt_choose(List<&2,X185ScratchCell>,String.eq(buffer,name) || x185_sf_source(value,name),
            u => x186_sf_allocated(rest,name),u => Con{cell,x186_sf_allocated(rest,name)})

@unsafe
def x186_sf_inline(effect: X186InlineOp, facts: List<&2,X185ScratchCell>) -> List<&2,X185ScratchCell>:
  match effect:
    case X186InlineF32{destination,id,buffer}: x185_sf_written(facts,destination)
    case _: []

@unsafe
def x185_sf_scalar(+stmt: N111Stmt, +buffers: KDef, +facts: List<&2,X185ScratchCell>) -> X185ScratchStep:
  match stmt:
    case N111Store{+typ,N111Local{+buffer},+offset,value}:
      X185ScratchStep{P113DScalar{stmt},nt_choose(List<&2,X185ScratchCell>,x185_sf_cell(buffer,offset,typ,buffers),
        u => x185_sf_insert(X185ScratchCell{buffer,offset,typ,value},x185_sf_overlap(facts,buffer,offset,typ)),u => [])}
    case N111Store{typ,base,offset,value}: X185ScratchStep{P113DScalar{stmt},[]}
    case N111Load{+name,+typ,N111Local{+buffer},+offset}:
      X185ScratchStep{x185_sf_loaded(stmt,name,typ,nt_choose(Maybe<&2,N111Value>,x185_sf_cell(buffer,offset,typ,buffers),
        u => x185_sf_find(facts,buffer,offset,typ),u => None{})),x185_sf_written(facts,name)}
    case N111Load{name,typ,base,offset}: X185ScratchStep{P113DScalar{stmt},x185_sf_written(facts,name)}
    case N111Set{name,typ,value}: X185ScratchStep{P113DScalar{stmt},x185_sf_written(facts,name)}
    case N111Bin{name,typ,op,left,right}: X185ScratchStep{P113DScalar{stmt},x185_sf_written(facts,name)}
    case N111Offset{name,base,bytes}: X185ScratchStep{P113DScalar{stmt},x185_sf_written(facts,name)}
    case N111Alloca{name,bytes,align}: X185ScratchStep{P113DScalar{stmt},x186_sf_allocated(facts,name)}
    case N111Call{name,typ,symbol,args}: X185ScratchStep{P113DScalar{stmt},x186_sf_inline(x186_inline_op(stmt),facts)}
    case _: X185ScratchStep{P113DScalar{stmt},[]}

law x185_sf_body:
  for body: List<&2,P113DStmt>
  for +buffers: KDef
  for facts: List<&2,X185ScratchCell>
  List<&2,P113DStmt>

@unsafe
def x185_sf_after(rest: List<&2,P113DStmt>, buffers: KDef, step: X185ScratchStep) -> List<&2,P113DStmt>:
  match step:
    case X185ScratchStep{stmt,facts}: Con{stmt,x185_sf_body(rest,buffers,facts)}

@unsafe
def x185_sf_if(condition: N111Value, yes: List<&2,P113DStmt>, no: List<&2,P113DStmt>,
    rest: List<&2,P113DStmt>, +buffers: KDef) -> List<&2,P113DStmt>:
  Con{P113DIf{condition,x185_sf_body(yes,buffers,[]),x185_sf_body(no,buffers,[])},x185_sf_body(rest,buffers,[])}

@unsafe
def x185_sf_body(body,buffers,facts):
  match body:
    case Nil{}: []
    case Con{P113DScalar{N111If{condition,yes,no}},rest}:
      x185_sf_if(condition,x181_scalar_rows(yes),x181_scalar_rows(no),rest,buffers)
    case Con{P113DIf{condition,yes,no},rest}: x185_sf_if(condition,yes,no,rest,buffers)
    case Con{P113DScalar{stmt},rest}: x185_sf_after(rest,buffers,x185_sf_scalar(stmt,buffers,facts))
    case Con{head,rest}: Con{head,x185_sf_body(rest,buffers,[])}

@unsafe
def x185_scratch_body(params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  nt_choose(List<&2,P113DStmt>,x185_scratch_enabled() &&
      U32.is_lt(p113i_add(p113i_size(setup),p113i_size(body)),4096),
    u => x185_sf_body(body,x185_sf_buffers(body,x185_sf_buffers(setup,
      x185_sf_blocks(params,p111v_put(missing(),"scratch","X185ScratchBuffer",2048,0)))),[]),u => body)
