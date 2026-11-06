# Entry authority is actual maintained source lowering and its unchanged final
# verifier. Host-selected owner is only a candidate query, never a body/cert.

@unsafe
def p171d_shape(book, ty, i, roots, fuel):
  nt_choose(P171DShape,U32.is_eq(fuel,0),u => P171DShape{[],i,False{}},
    u => p171d_shape_head(book,nq_layout_type(book,ty),i,roots,U32.sub(fuel,1)))

@unsafe
def p171d_data_kind(+kind: KTerm) -> Bool:
  String.eq(tg(kind),"Data") || (String.eq(tg(kind),"Typ") && String.eq(tg(kid(kind,0)),"Qua") && U32.is_eq(qt(kid(kind,0)),2))

@unsafe
def p171d_type(book, ty):
  nol_owner(book,ty) && Bool.not(nc_native_def(lookup(book,nm(ty)))) &&
    p171d_data_kind(nq_layout_type(book,nq_layout_specialize(dt(lookup(book,nm(ty))),ks(ty),64)))

@unsafe
def p171d_shape_head(book, head, i, roots, fuel):
  nt_choose(P171DShape,String.eq(tg(head),"All"),
    u => nt_choose(P171DShape,U32.is_eq(qt(head),0),
      v => p171d_shape(book,kid(head,1),i,roots,fuel),
      v => p171d_shape_param(book,head,nq_layout_type(book,kid(head,0)),i,roots,fuel)),
    u => P171DShape{nt_reverse(U32,roots,[]),i,p171d_type(book,head) && U32.is_gt(nt_count(U32,roots),0) && U32.is_le(nt_count(U32,roots),2)})

@unsafe
def p171d_shape_param(book, head, ty, i, roots, fuel):
  nt_choose(P171DShape,nol_scalar(book,ty),
    u => p171d_shape(book,kid(head,1),U32.inc(i),roots,fuel),
    u => nt_choose(P171DShape,p171d_type(book,ty),
      v => p171d_shape(book,kid(head,1),U32.inc(i),Con{i,roots},fuel),v => P171DShape{[],i,False{}}))

@unsafe
def p171d_entry_env(params, roots, i):
  match params:
    case Nil{}: []
    case Con{NC_Binding{id,word,kind},rest}:
      Con{P171DLocal{word,P171DWord{nt_choose(String,no_root_index(roots,i),u => "root." ++ U32.show(i),u => "")}},p171d_entry_env(rest,roots,U32.inc(i))}

@unsafe
def p171d_fallback(name, args):
  [P113DCall{["p171desc_fallback"],name,args},P113DResult{[N111Local{"p171desc_fallback"}]}]

# Result-only extension for the pinned valid ordinary Data ABI. Existing guard
# remains authoritative for its old true states; newly accepted RFC count1 is
# retained BEFORE any parent drop. No raw non-RFC child is admitted.
@unsafe
def p171d_promote_ops() -> List<&2,N111Stmt>:
  [N111Bin{"p171desc_escape_bool",N111U64{},"ne",N111Local{"p171desc_escape"},N111Const{0,0}},
   N111Bin{"p171desc_rfc_bits",N111U64{},"and",N111Local{"p171desc_result"},N111Const{0,2147483648}},
   N111Bin{"p171desc_rfc_bool",N111U64{},"ne",N111Local{"p171desc_rfc_bits"},N111Const{0,0}},
   N111Bin{"p171desc_promote",N111U32{},"or",N111Local{"p171desc_escape_bool"},N111Local{"p171desc_rfc_bool"}}]

@unsafe
def p171d_wrapper(name, params, reader, roots):
  +args = p111_env_words(params)
  +held = p128bs_roots(params,roots,0)
  +fallback = p171d_fallback(name,args)
  +accepted : List<&2,P113DStmt> = Con{
    P113DScalar{N111Call{"p171desc_escape",N111U64{},"p118_rt_borrow_scalar_safe",[p111_state(),p111_word(N111Local{"p171desc_result"}),p111_word(N111Const{0,0}),p111_u32(1)]}},
    nt_append(P113DStmt,p113d_scalars(p171d_promote_ops()),[P113DIf{N111Local{"p171desc_promote"},
      Con{P113DScalar{N111Call{"p171desc_owned",N111U64{},"p111_rt_keep",[p111_state(),p111_word(N111Local{"p171desc_result"})]}},
        nt_append(P113DStmt,p128bs_drops(held,0),[P113DResult{[N111Local{"p171desc_owned"}]}])},fallback}])}
  P113DFunction{"$p171desc.entry." ++ name,params,1,False{},[
    P113DScalar{N111Call{"p171desc_roots",N111U64{},"p118_rt_borrow_scalar_safe",p128bs_guard_args(held)}},
    P113DScalar{N111Bin{"p171desc_roots_bool",N111U64{},"ne",N111Local{"p171desc_roots"},N111Const{0,0}}},
    P113DIf{N111Local{"p171desc_roots_bool"},[
      P113DCall{["p171desc_accepted","p171desc_result"],reader,args},
      P113DScalar{N111Bin{"p171desc_accepted_bool",N111U64{},"ne",N111Local{"p171desc_accepted"},N111Const{0,0}}},
      P113DIf{N111Local{"p171desc_accepted_bool"},accepted,fallback}],fallback}]}

@unsafe
def p171d_proposal_done(owner, original, roots, ids, dependencies, worker):
  match original worker:
    case P113DFunction{+name,+params,+result,+public,+body} P171DWorker{+reader,P171DCode{readerBody,+helpers,next,+accepted,+declined,rooted}}:
      +added = nt_append(P113DFunction,helpers,[p171d_wrapper(name,params,reader,roots)])
      +projected = p118b_project_functions(added,ids)
      p171d_proposal_checked(owner,P113DFunction{name,params,result,public,body},reader,added,accepted,declined,ids,dependencies,projected)

@unsafe
def p171d_proposal_checked(owner, original, reader, functions, accepted, declined, ids, dependencies, projected):
  match projected:
    case P118BWorkers{body,+error}:
      P171DProposal{owner,original,reader,functions,accepted,declined,
        nt_choose(String,U32.is_eq(accepted,0),u => "descendant: no accepted return",u =>
          nt_choose(String,String.is_empty(error),v => p113e_functions(body,ids,p113e_signatures(dependencies,missing())),v => error))}

@unsafe
def p171d_select(owner, book, functions, ids, shape, found):
  match shape found:
    case P171DShape{+roots,+count,+valid} Some{+function}:
      match function:
        case P113DFunction{name,+params,result,public,body}:
          nt_choose(P171DProposal,valid && U32.is_eq(count,nt_count(NC_Binding,params)),
            u => p171d_proposal_done(owner,function,roots,ids,functions,
              p171d_worker(P171DContext{functions,ids,[],0},function,p111_env_words(params),p171d_entry_env(params,roots,0),0)),
            u => p171d_refuse(owner,"descendant: source parameter/result shape"))
    case _ _: p171d_refuse(owner,"descendant: no actual direct owner")

@unsafe
def p171d_refuse(owner, error):
  P171DProposal{owner,P113DFunction{"",[],0,False{},[]},"",[],0,0,error}

@unsafe
def p171d_checked(owner, book, base, adapters, error):
  match base:
    case P113DProgram{P112StaticProgram{P111Program{+segments,+constructors,show,names,effects,pure},nodes},+functions}:
      +view = p168v_functions(functions,adapters)
      nt_choose(P171DProposal,String.is_empty(error),
        u => p171d_view_checked(owner,book,view,N111Ids{p113e_originals(segments,missing()),ns_ctor_index(constructors,missing())},
          p118b_verify_functions(view,P111Program{segments,constructors,show,names,effects,pure})),
        u => p171d_refuse(owner,error))

@unsafe
def p171d_lowered(request, owner, lowered):
  match request lowered:
    case NR_Request{source,+book,+names,paths,scope,bound} P167Lowered{+base,+adapters,+error,stats}:
      nt_choose(P171DProposal,String.is_empty(error),
        u => p171d_checked(owner,book,base,adapters,p167ob_final(book,nc_bangs_names(book,names),adapters,base)),
        u => p171d_refuse(owner,error))

@unsafe
def p171d_request(request, owner):
  p171d_lowered(request,owner,p168_request_mode(1,request))

@unsafe
def p171d_summary(proposal):
  match proposal:
    case P171DProposal{owner,original,reader,functions,accepted,declined,error}:
      [owner,reader,U32.show(nt_count(P113DFunction,functions)),U32.show(accepted),U32.show(declined),error]

@unsafe
def p171d_view_checked(owner, book, functions, ids, error):
  +definition = lookup(book,owner)
  nt_choose(P171DProposal,String.is_empty(error) && String.eq(dk(definition),"Def") && Bool.not(nc_foreign(definition) || nc_native_def(definition)),
    u => p171d_select(owner,book,functions,ids,p171d_shape(book,dt(definition),0,[],32),p171d_find(p113d_public(book,owner),functions)),
    u => p171d_refuse(owner,nt_choose(String,String.is_empty(error),v => "descendant: ordinary source definition required",v => error)))
