# One genuine scheduler entry around a CLOSED direct library. The sole adapter
# is the existing p113e_public(owner,0), checked against its fixed zero-argument
# ABI below. No generic lowering, fake body, or generic-program certificate.

# This independently written fixed shape guards the only new boundary: one
# borrowed state pointer, one owned result word, and the existing rt_return.
# Do not generalize this to arbitrary direct imports without another contract.
@unsafe
def p163x_adapter_expected(+owner: String) -> String:
  "export function l $" ++ p111q_symbol(owner) ++ "(l %state) {\n@entry\n%p113_public_out =l alloc8 8\n" ++
  "%p113_public_value =l call $" ++ p113e_symbol(owner) ++ "(l %state)\n" ++
  "storel %p113_public_value, %p113_public_out\n%p113_public_reply =l call $p111_rt_return(l %state, l %p113_public_out, w 1)\nret %p113_public_reply\n}\n"

@unsafe
def p163x_adapter_contract(+owner: String, +signature: KDef, text: String) -> Bool:
  String.eq(dn(signature),owner) && String.eq(dk(signature),"P113Direct") &&
  U32.is_eq(da(signature),0) && U32.is_eq(dx(signature),1) &&
  U32.is_eq(ix(dv(signature)),0) && String.eq(text,p163x_adapter_expected(owner))

# The descriptor helpers inspect only segment metadata. Still record the actual
# body of that real adapter, rather than an empty/fictitious generic body. It is
# governed by the fixed adapter contract, NOT passed to p111_verify_program.
def p163x_adapter_body(owner: String) -> List<&2,N111Stmt>:
  [N111Alloca{"p113_public_out",8,8},
   N111Call{"p113_public_value",N111U64{},p113e_symbol(owner),
     [N111Arg{N111Ptr{},N111Local{"state"}}]},
   N111Store{N111U64{},N111Local{"p113_public_out"},0,N111Local{"p113_public_value"}},
   N111Call{"p113_public_reply",N111U64{},"p111_rt_return",
     [N111Arg{N111Ptr{},N111Local{"state"}},
      N111Arg{N111Ptr{},N111Local{"p113_public_out"}},N111Arg{N111U32{},N111Const{1,0}}]},
   N111Return{N111Local{"p113_public_reply"}}]

@unsafe
def p163x_emit(+owner: String, +constructors: List<&2,N_Constructor>,
    +nodes: List<&2,P112SNode>, +functions: List<&2,P113DFunction>, show: P111Show) -> P111Emission:
  match show:
    case P111Show{words,names,+error}:
      nt_choose(P111Emission,String.is_empty(error),
        u => p163x_tables(owner,nodes,functions,
          P111Program{[N111Segment{owner,0,1,0,0,p163x_adapter_body(owner)}],
            constructors,words,names,[],True{}}),
        u => P111Emission{[],"direct executable readback: " ++ error})

@unsafe
def p163x_tables(+owner: String, +nodes: List<&2,P112SNode>,
    +functions: List<&2,P113DFunction>, +metadata: P111Program) -> P111Emission:
  match metadata:
    case P111Program{segments,+constructors,show,show_names,effects,pure}:
      # main is the descriptor's entry alias, never a usable library FuncId.
      # There is exactly one segment, whose machine symbol uses derived owner.
      +ids : N111Ids = N111Ids{p111q_insert(p111q_insert(missing(),owner,0),"main",0),
        p111q_constructor_ids(constructors,0,missing())}
      +private_ids : N111Ids = N111Ids{missing(),p111q_constructor_ids(constructors,0,missing())}
      P111Emission{nt_append(String,p113e_private_chunks(functions,private_ids,[]),
        Con{p113e_public(owner,0),nt_append(String,
          p111q_data_chunks(nt_choose(List<&2,P111QData>,List.is_empty(&2,P112SNode,nodes),
            u => p111q_tables(metadata,ids),u => p112s_tables(metadata,nodes,ids))),[p111q_main()])}),""}

@unsafe
def p163x_export(+source: List<&2,KDef>, +book: List<&2,KDef>,
    +constructors: List<&2,N_Constructor>, +nodes: List<&2,P112SNode>,
    +functions: List<&2,P113DFunction>, exports: List<&2,P163DExport>) -> P111Emission:
  match exports:
    case Con{P163DExport{+name,+owner,arity},Nil{}}:
      +signature = p111v_get(p113e_signatures(functions,missing()),owner)
      nt_choose(P111Emission,String.eq(name,"main") && U32.is_eq(arity,0) &&
        String.eq(owner,p113d_public(book,"main")) &&
        U32.is_eq(nd_arity(book,"main"),0) && Bool.not(nc_is_io(source,dt(lookup(source,"main")))) &&
        p163x_adapter_contract(owner,signature,p113e_public(owner,0)),
        u => p163x_emit(owner,constructors,nodes,functions,
          p111_show(source,dt(lookup(source,"main")),constructors)),
        u => P111Emission{[],"direct executable: requires ordinary pure main, arity 0, one result, exact adapter ABI"})
    case _: P111Emission{[],"direct executable: requires exactly one main export"}

@unsafe
def p163x_library(+source: List<&2,KDef>, +book: List<&2,KDef>, library: P163DLibrary) -> P111Emission:
  match library:
    case P163DLibrary{exports,constructors,nodes,functions,text,+error}:
      nt_choose(P111Emission,String.is_empty(error),
        u => p163x_export(source,book,constructors,nodes,functions,exports),
        u => P111Emission{[],error})

@unsafe
def p163d_executable(+request: NR_Request) -> P111Emission:
  match request:
    case NR_Request{source,book,names,paths,scope,bound}:
      p163x_library(source,book,p163d_plan(request,["main"]))

# Adapter controls are independent of the source/request workload oracles.
@unsafe
def p163x_controls() -> List<&2,String>:
  +signature = p113e_signature(P113DFunction{"p163.main",[],1,False{},[P113DResult{[N111Const{7,0}]}]})
  [p163dc_row("entry-exact-ABI",p163x_adapter_contract("p163.main",signature,p113e_public("p163.main",0))),
   p163dc_row("entry-mutated-text-refused",Bool.not(p163x_adapter_contract("p163.main",signature,"ret 0\n"))),
   p163dc_row("entry-other-owner-refused",Bool.not(p163x_adapter_contract("other",signature,p113e_public("other",0)))),
   p163dc_row("entry-arguments-refused",Bool.not(p163x_adapter_contract("p163.main",signature,p113e_public("p163.main",1))))]
