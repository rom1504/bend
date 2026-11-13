# Bounded shared effective-address selection. A window contains at most sixteen
# original rows, starting with a U64 scale. Every eliminated name has one
# unprotected definition and ALL its reads are accounted for by selected uses.
# No memory operation moves: only address arithmetic disappears. Calls, control
# flow and allocation stop the window. Writes to a delayed address input refuse.
type X192AddressAlias is Data:
  X192AddressAlias{+name: String, +address: X191Address, +reads: U32}

type X192AddressRow is Data:
  X192AddressPlain{+stmt: P113DStmt}
  X192AddressMemory{+operation: X191Operation}

type X192AddressPick is Data:
  X192AddressPick{+rest: List<&2,P113DStmt>, +rows: List<&2,X192AddressRow>}

def x192_shared_address_enabled() -> Bool: True{}

@unsafe
def x192_address_name(+name: String, +count: U32, facts: X190BranchFacts) -> Bool:
  match facts:
    case X190BranchFacts{reads,writes,pairs,protected}:
      Bool.not(x181_register_reserved(name)) && U32.is_eq(da(p111v_get(reads,name)),count) &&
        U32.is_eq(da(p111v_get(writes,name)),1) && U32.is_eq(da(p111v_get(protected,name)),0)

@unsafe
def x192_address_aliases_done(aliases: List<&2,X192AddressAlias>, +facts: X190BranchFacts) -> Bool:
  match aliases:
    case Nil{}: True{}
    case Con{X192AddressAlias{name,address,+reads},rest}:
      U32.is_gt(reads,0) && x192_address_name(name,reads,facts) && x192_address_aliases_done(rest,facts)

@unsafe
def x192_address_lookup(aliases: List<&2,X192AddressAlias>, +name: String) -> Maybe<&2,X191Address>:
  match aliases:
    case Nil{}: None{}
    case Con{X192AddressAlias{other,address,reads},rest}:
      nt_choose(Maybe<&2,X191Address>,String.eq(name,other),u => Some{address},u => x192_address_lookup(rest,name))

@unsafe
def x192_address_used(aliases: List<&2,X192AddressAlias>, +name: String) -> List<&2,X192AddressAlias>:
  match aliases:
    case Nil{}: []
    case Con{X192AddressAlias{+other,address,+reads},rest}:
      Con{X192AddressAlias{other,address,nt_choose(U32,String.eq(name,other),u => U32.inc(reads),u => reads)},
        x192_address_used(rest,name)}

@unsafe
def x192_address_writes_alias(aliases: List<&2,X192AddressAlias>, +name: String) -> Bool:
  match aliases:
    case Nil{}: False{}
    case Con{X192AddressAlias{other,X191Address{base,index,scale,disp},reads},rest}:
      String.eq(name,other) || x185_sf_source(base,name) || x185_sf_source(index,name) ||
        x192_address_writes_alias(rest,name)

@unsafe
def x192_address_write(+name: String, scaled: String, index: N111Value,
    aliases: List<&2,X192AddressAlias>) -> Bool:
  Bool.not(String.eq(name,scaled) || x185_sf_source(index,name) || x192_address_writes_alias(aliases,name))

@unsafe
def x192_address_displacement(address: X191Address, offset: U32) -> X191Address:
  match address:
    case X191Address{base,index,scale,disp}: X191Address{base,index,scale,offset}

# Fusion remains adjacent and width-exact; the loaded name's global certificate
# is the Phase191 rule. This does not move a load across an intervening store.
@unsafe
def x192_address_fuse_left(left: Maybe<&2,N111Value>, +load: X191Operation,
    +stmt: P113DStmt, name: String, typ: N111Type, op: String, address: X191Address,
    rest: List<&2,X192AddressRow>) -> List<&2,X192AddressRow>:
  match left:
    case Some{value}: Con{X192AddressMemory{X191MemoryAlu{name,typ,op,value,address}},rest}
    case None{}: Con{X192AddressMemory{load},Con{X192AddressPlain{stmt},rest}}

@unsafe
def x192_address_fuse_pair(+load: X191Operation, +stmt: P113DStmt,
    +rest: List<&2,X192AddressRow>, +facts: X190BranchFacts) -> List<&2,X192AddressRow>:
  match load stmt:
    case X191Load{+loaded,+typ,address} P113DScalar{N111Bin{name,+other,+op,left,right}}:
      nt_choose(List<&2,X192AddressRow>,x191_memory_alu_enabled() && x191_single(loaded,facts) &&
          U32.is_eq(p111v_type(typ),p111v_type(other)) && x191_alu(op),
        u => x192_address_fuse_left(x191_alu_left(loaded,op,left,right),load,stmt,name,other,op,address,
          x192_address_fuse(rest,facts)),
        u => Con{X192AddressMemory{load},x192_address_fuse(Con{X192AddressPlain{stmt},rest},facts)})
    case _ _: Con{X192AddressMemory{load},x192_address_fuse(Con{X192AddressPlain{stmt},rest},facts)}

@unsafe
def x192_address_fuse(rows: List<&2,X192AddressRow>, +facts: X190BranchFacts) -> List<&2,X192AddressRow>:
  match rows:
    case Con{X192AddressMemory{load},Con{X192AddressPlain{stmt},rest}}:
      x192_address_fuse_pair(load,stmt,rest,facts)
    case Con{head,rest}: Con{head,x192_address_fuse(rest,facts)}
    case Nil{}: []

law x192_address_scan:
  for +body: List<&2,P113DStmt>
  for +scaled: String
  for +index: N111Value
  for +scale: U32
  for +aliases: List<&2,X192AddressAlias>
  for +uses: U32
  for +accesses: U32
  for +fuel: U32
  for +reversed: List<&2,X192AddressRow>
  for +facts: X190BranchFacts
  Maybe<&2,X192AddressPick>

@unsafe
def x192_address_memory(found: Maybe<&2,X191Address>, +stmt: P113DStmt, +rest: List<&2,P113DStmt>,
    +scaled: String, +index: N111Value, +scale: U32, +aliases: List<&2,X192AddressAlias>,
    +uses: U32, +accesses: U32, +fuel: U32, +reversed: List<&2,X192AddressRow>, +facts: X190BranchFacts) -> Maybe<&2,X192AddressPick>:
  match found stmt:
    case Some{address} P113DScalar{N111Load{+name,typ,N111Local{pointer},+offset}}:
      nt_choose(Maybe<&2,X192AddressPick>,U32.is_le(offset,2147483647) && x192_address_write(name,scaled,index,aliases),
        u => x192_address_scan(rest,scaled,index,scale,x192_address_used(aliases,pointer),uses,U32.inc(accesses),fuel,
          Con{X192AddressMemory{X191Load{name,typ,x192_address_displacement(address,offset)}},reversed},facts),u => None{})
    case Some{address} P113DScalar{N111Store{typ,N111Local{pointer},+offset,value}}:
      nt_choose(Maybe<&2,X192AddressPick>,U32.is_le(offset,2147483647),
        u => x192_address_scan(rest,scaled,index,scale,x192_address_used(aliases,pointer),uses,U32.inc(accesses),fuel,
          Con{X192AddressMemory{X191Store{typ,x192_address_displacement(address,offset),value}},reversed},facts),u => None{})
    case _ _: None{}

@unsafe
def x192_address_scan_plain(+stmt: P113DStmt, rest: List<&2,P113DStmt>, +scaled: String, +index: N111Value, +scale: U32,
    +aliases: List<&2,X192AddressAlias>, +uses: U32, +accesses: U32, +fuel: U32,
    +reversed: List<&2,X192AddressRow>, +facts: X190BranchFacts) -> Maybe<&2,X192AddressPick>:
  match stmt:
    case P113DScalar{N111Load{name,typ,N111Local{pointer},offset}}:
      x192_address_memory(x192_address_lookup(aliases,pointer),stmt,rest,scaled,index,scale,aliases,uses,accesses,fuel,reversed,facts)
    case P113DScalar{N111Store{typ,N111Local{pointer},offset,value}}:
      x192_address_memory(x192_address_lookup(aliases,pointer),stmt,rest,scaled,index,scale,aliases,uses,accesses,fuel,reversed,facts)
    case P113DScalar{N111Bin{+name,typ,op,left,right}}:
      nt_choose(Maybe<&2,X192AddressPick>,x192_address_write(name,scaled,index,aliases),
        u => x192_address_scan(rest,scaled,index,scale,aliases,uses,accesses,fuel,Con{X192AddressPlain{stmt},reversed},facts),u => None{})
    case P113DScalar{N111Set{+name,typ,value}}:
      nt_choose(Maybe<&2,X192AddressPick>,x192_address_write(name,scaled,index,aliases),
        u => x192_address_scan(rest,scaled,index,scale,aliases,uses,accesses,fuel,Con{X192AddressPlain{stmt},reversed},facts),u => None{})
    case _: None{}

@unsafe
def x192_address_scan_step(body: List<&2,P113DStmt>, +scaled: String, +index: N111Value, +scale: U32,
    +aliases: List<&2,X192AddressAlias>, +uses: U32, +accesses: U32, +fuel: U32,
    +reversed: List<&2,X192AddressRow>, +facts: X190BranchFacts) -> Maybe<&2,X192AddressPick>:
  match body:
    case Con{P113DScalar{N111Offset{+name,+base,N111Local{source}}},rest}:
      nt_choose(Maybe<&2,X192AddressPick>,String.eq(source,scaled) &&
          x192_address_write(name,scaled,index,aliases) && Bool.not(x185_sf_source(base,name)),
        u => x192_address_scan(rest,scaled,index,scale,Con{X192AddressAlias{name,X191Address{base,index,scale,0},0},aliases},
          U32.inc(uses),accesses,fuel,reversed,facts),u => None{})
    case Con{stmt,rest}:
      x192_address_scan_plain(stmt,rest,scaled,index,scale,aliases,uses,accesses,fuel,reversed,facts)
    case Nil{}: None{}

@unsafe
def x192_address_scan(body,scaled,index,scale,aliases,uses,accesses,fuel,reversed,facts):
  nt_choose(Maybe<&2,X192AddressPick>,U32.is_ge(accesses,2) && x192_address_name(scaled,uses,facts) &&
      x192_address_aliases_done(aliases,facts),
    u => Some{X192AddressPick{body,x192_address_fuse(nt_reverse(X192AddressRow,reversed,[]),facts)}},
    u => nt_choose(Maybe<&2,X192AddressPick>,U32.is_eq(fuel,0),v => None{},
      v => x192_address_scan_step(body,scaled,index,scale,aliases,uses,accesses,U32.sub(fuel,1),reversed,facts)))

@unsafe
def x192_shared_pick(body: List<&2,P113DStmt>, +facts: X190BranchFacts) -> Maybe<&2,X192AddressPick>:
  match body:
    case Con{P113DScalar{N111Bin{+scaled,N111U64{},op,+index,factor}},rest}:
      +scale = x191_scale(op,factor)
      nt_choose(Maybe<&2,X192AddressPick>,x192_shared_address_enabled() && U32.is_gt(scale,0) &&
          Bool.not(x185_sf_source(index,scaled)),
        u => x192_address_scan(rest,scaled,index,scale,[],0,0,15,[],facts),u => None{})
    case _: None{}

# Both allocation paths consume these exact read/write rows. The original body
# still supplies frame slots, whole-function facts, setup and parameter homes.
@unsafe
def x192_address_rows(rows: List<&2,X192AddressRow>) -> List<&2,P113DStmt>:
  match rows:
    case Nil{}: []
    case Con{X192AddressPlain{stmt},rest}: Con{stmt,x192_address_rows(rest)}
    case Con{X192AddressMemory{operation},rest}: nt_append(P113DStmt,x191_rows(operation),x192_address_rows(rest))

@unsafe
def x192_shared_placement(pick: Maybe<&2,X192AddressPick>, +body: List<&2,P113DStmt>, +facts: X190BranchFacts) -> List<&2,P113DStmt>:
  match pick:
    case Some{X192AddressPick{rest,rows}}: nt_append(P113DStmt,x192_address_rows(rows),x191_placement(rest,facts))
    case None{}: x191_placement_pick(x191_pick(body,facts),body,facts)

@unsafe
def x192_address_emit(rows: List<&2,X192AddressRow>, +ids: N111Ids, +frame: X181Frame, code: X181Code) -> X181Code:
  match rows:
    case Nil{}: code
    case Con{X192AddressPlain{stmt},rest}: x192_address_emit(rest,ids,frame,x181_stmt(stmt,ids,frame,code))
    case Con{X192AddressMemory{operation},rest}: x192_address_emit(rest,ids,frame,x181_add(x191_emit(operation,ids,frame),code))

@unsafe
def x192_shared_step(pick: Maybe<&2,X192AddressPick>, +body: List<&2,P113DStmt>, +facts: X190BranchFacts,
    +ids: N111Ids, +frame: X181Frame, code: X181Code) -> X181Code:
  match pick:
    case Some{X192AddressPick{rest,rows}}: x190_stmts(rest,facts,ids,frame,x192_address_emit(rows,ids,frame,code))
    case None{}: x191_selected_step(x191_pick(body,facts),body,facts,ids,frame,code)
