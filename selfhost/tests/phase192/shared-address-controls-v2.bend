# Finite compiler-data controls. Append to the checked compiler API source and
# export p192sa_controls. Every row must end in =1 in enabled and disabled cells.
def p192sa_v(name: String) -> N111Value: N111Local{name}
def p192sa_c(n: U32) -> N111Value: N111Const{n,0}
def p192sa_row(name: String, ok: Bool) -> String:
  name ++ "=" ++ nt_choose(String,ok,u => "1",u => "0")
def p192sa_present(pick: Maybe<&2,X192AddressPick>) -> Bool:
  match pick:
    case Some{p}: True{}
    case None{}: False{}

def p192sa_scale(typ: N111Type) -> P113DStmt:
  P113DScalar{N111Bin{"scaled",typ,"mul",p192sa_v("index"),p192sa_c(4)}}
def p192sa_offset(name: String, base: String) -> P113DStmt:
  P113DScalar{N111Offset{name,p192sa_v(base),p192sa_v("scaled")}}
def p192sa_load() -> P113DStmt:
  P113DScalar{N111Load{"loaded",N111U32{},p192sa_v("pointer"),0}}
def p192sa_store(pointer: String, offset: U32) -> P113DStmt:
  P113DScalar{N111Store{N111U32{},p192sa_v(pointer),offset,p192sa_v("result")}}
def p192sa_add() -> P113DStmt:
  P113DScalar{N111Bin{"result",N111U32{},"add",p192sa_v("accumulator"),p192sa_v("loaded")}}
def p192sa_set(name: String) -> P113DStmt:
  P113DScalar{N111Set{name,N111U64{},p192sa_c(3)}}
def p192sa_shared(typ: N111Type, middle: List<&2,P113DStmt>, offset: U32) -> List<&2,P113DStmt>:
  nt_append(P113DStmt,[p192sa_scale(typ),p192sa_offset("pointer","base"),p192sa_load()],
    nt_append(P113DStmt,middle,[p192sa_store("pointer",offset),P113DResult{[p192sa_v("result")]}]))

@unsafe
def p192sa_select(+body: List<&2,P113DStmt>, params: List<&2,String>, setup: List<&2,P113DStmt>) -> Bool:
  p192sa_present(x192_shared_pick(body,x190_branch_facts(params,setup,body)))
@unsafe
def p192sa_expect(body: List<&2,P113DStmt>) -> Bool:
  Bool.not(Bool.xor(p192sa_select(body,[],[]),x192_shared_address_enabled()))
@unsafe
def p192sa_refuse(body: List<&2,P113DStmt>) -> Bool:
  Bool.not(p192sa_select(body,[],[]))

@unsafe
def p192sa_fused(pick: Maybe<&2,X192AddressPick>) -> Bool:
  match pick:
    case Some{X192AddressPick{rest,Con{X192AddressMemory{X191MemoryAlu{name,typ,op,left,address}},rows}}}: True{}
    case _: False{}

def p192sa_ordered(pick: Maybe<&2,X192AddressPick>) -> Bool:
  match pick:
    case Some{X192AddressPick{rest,Con{X192AddressMemory{X191Store{t,a,v}},
      Con{X192AddressMemory{X191Load{n,t2,a2}},Nil{}}}}}: True{}
    case _: False{}

@unsafe
def p192sa_padding(+count: U32) -> List<&2,P113DStmt>:
  nt_choose(List<&2,P113DStmt>,U32.is_eq(count,0),u => [],u =>
    Con{p192sa_set("padding"),p192sa_padding(U32.sub(count,1))})

@unsafe
def p192sa_controls() -> List<&2,String>:
  +shared: List<&2,P113DStmt> = p192sa_shared(N111U64{},[p192sa_add()],0)
  +twoBases: List<&2,P113DStmt> = [p192sa_scale(N111U64{}),p192sa_offset("pointer","source"),p192sa_load(),p192sa_add(),
    p192sa_offset("target","destination"),p192sa_store("target",12),P113DResult{[p192sa_v("result")]}]
  +ordered: List<&2,P113DStmt> = [p192sa_scale(N111U64{}),p192sa_offset("pointer","base"),p192sa_store("pointer",0),p192sa_load(),
    P113DResult{[p192sa_v("loaded")]}]
  [p192sa_row("shared-pointer",p192sa_expect(shared)),
   p192sa_row("distinct-bases-shared-scale",p192sa_expect(twoBases)),
   p192sa_row("store-load-order",Bool.not(Bool.xor(p192sa_ordered(x192_shared_pick(ordered,
     x190_branch_facts([],[],ordered))),x192_shared_address_enabled()))),
   p192sa_row("memory-alu-composes",Bool.not(Bool.xor(p192sa_fused(x192_shared_pick(shared,
     x190_branch_facts([],[],shared))),x192_shared_address_enabled() && x191_memory_alu_enabled()))),
   p192sa_row("u32-wrap-refused",p192sa_refuse(p192sa_shared(N111U32{},[p192sa_add()],0))),
   p192sa_row("large-displacement-refused",p192sa_refuse(p192sa_shared(N111U64{},[p192sa_add()],2147483648))),
   p192sa_row("index-mutation-refused",p192sa_refuse(p192sa_shared(N111U64{},[p192sa_set("index"),p192sa_add()],0))),
   p192sa_row("base-mutation-refused",p192sa_refuse(p192sa_shared(N111U64{},[p192sa_set("base"),p192sa_add()],0))),
   p192sa_row("pointer-mutation-refused",p192sa_refuse(p192sa_shared(N111U64{},[p192sa_set("pointer"),p192sa_add()],0))),
   p192sa_row("scale-mutation-refused",p192sa_refuse(p192sa_shared(N111U64{},[p192sa_set("scaled"),p192sa_add()],0))),
   p192sa_row("unrelated-computation",p192sa_expect(p192sa_shared(N111U64{},[p192sa_set("other"),p192sa_add()],0))),
   p192sa_row("eight-original-rows",p192sa_expect(p192sa_shared(N111U64{},
     [p192sa_set("a"),p192sa_set("b"),p192sa_set("c"),p192sa_add()],0))),
   p192sa_row("nine-original-rows",p192sa_expect(p192sa_shared(N111U64{},
     [p192sa_set("a"),p192sa_set("b"),p192sa_set("c"),p192sa_set("d"),p192sa_add()],0))),
   p192sa_row("sixteen-original-rows",p192sa_expect(p192sa_shared(N111U64{},
     nt_append(P113DStmt,p192sa_padding(11),[p192sa_add()]),0))),
   p192sa_row("seventeen-original-rows-refused",p192sa_refuse(p192sa_shared(N111U64{},
     nt_append(P113DStmt,p192sa_padding(12),[p192sa_add()]),0))),
   p192sa_row("scaled-extra-use-refused",p192sa_refuse(nt_append(P113DStmt,shared,[P113DResult{[p192sa_v("scaled")]}]))),
   p192sa_row("pointer-backedge-refused",p192sa_refuse(nt_append(P113DStmt,shared,[P113DAgain{[p192sa_v("pointer")]}]))),
   p192sa_row("pointer-branch-use-refused",p192sa_refuse(nt_append(P113DStmt,shared,
     [P113DIf{p192sa_v("condition"),[P113DResult{[p192sa_v("pointer")]}],[]}]))),
   p192sa_row("pointer-parameter-refused",Bool.not(p192sa_select(shared,["pointer"],[]))),
   p192sa_row("scale-parameter-refused",Bool.not(p192sa_select(shared,["scaled"],[]))),
   p192sa_row("pointer-setup-refused",Bool.not(p192sa_select(shared,[],[p192sa_set("pointer")]))),
   p192sa_row("scale-setup-refused",Bool.not(p192sa_select(shared,[],[p192sa_set("scaled")]))),
   p192sa_row("call-barrier-refused",p192sa_refuse(p192sa_shared(N111U64{},
     [P113DScalar{N111Call{"other",N111U32{},"external",[]}},p192sa_add()],0))),
   p192sa_row("allocation-barrier-refused",p192sa_refuse(p192sa_shared(N111U64{},
     [P113DScalar{N111Alloca{"other",16,8}},p192sa_add()],0))),
   p192sa_row("branch-barrier-refused",p192sa_refuse(p192sa_shared(N111U64{},
     [P113DIf{p192sa_v("condition"),[],[]},p192sa_add()],0)))]
