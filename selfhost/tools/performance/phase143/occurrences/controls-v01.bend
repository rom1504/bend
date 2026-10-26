# Explicit results are independent of NU_Set implementation. Each also checks
# the original nd_comb_fresh, which stays unchanged in the appended source.
def p143ot_absent() -> KTerm:
  KTerm{"Absent","",0,0,[],[],0,0}

def p143ot_var(id: U32) -> KTerm:
  KTerm{"Var","",id,1,[],[],0,0}

def p143ot_node(children: List<&2,KTerm>) -> KTerm:
  KTerm{"App","",0,0,children,[],0,0}

def p143ot_binding(id: U32, word: String) -> NC_Binding:
  NC_Binding{id,word,N_W64{}}

@unsafe
def p143ot_check(+body: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +n: U32, +left: U32, +expected: Bool) -> Bool:
  p134v_bool(p143o_original(body,args,env,n,left),expected) &&
    p134v_bool(p143o_summary(body,args,env,n,left),expected)

@unsafe
def p143o_controls() -> List<&2,String>:
  +empty = p143ot_absent()
  +first = p143ot_var(4294967295)
  +last = p143ot_var(4294967232)
  +outside = p143ot_var(4294967231)
  +bound = p143ot_binding(4294967295,"owned")
  +sentinel = p143ot_binding(4294967295,"NATIVE_UNBOUND_VARIABLE")
  +raw_var : KTerm = KTerm{"Var","",17,1,[first],["ignored"],7,9}
  +binder : KTerm = KTerm{"Lam","",4294967295,1,[empty],[],0,0}
  +literal : KTerm = KTerm{"Lit","raw",4294967295,1,[],[],0,0}
  [p114st_row("occ-zero-skips-syntax-and-env",p143ot_check(first,[first],[bound],0,0,True{})),
   p114st_row("occ-empty64",p143ot_check(empty,[],[],0,64,True{})),
   p114st_row("occ-first-collision64",p143ot_check(first,[],[],0,64,False{})),
   p114st_row("occ-last-collision64",p143ot_check(last,[],[],0,64,False{})),
   p114st_row("occ-outside64",p143ot_check(outside,[],[],0,64,True{})),
   p114st_row("occ-before-shifted-range",p143ot_check(first,[],[],1,64,True{})),
   p114st_row("occ-first-shifted-range",p143ot_check(p143ot_var(4294967294),[],[],1,64,False{})),
   p114st_row("occ-argument-collision",p143ot_check(empty,[p143ot_node([empty,last])],[],0,64,False{})),
   p114st_row("occ-arguments-clear",p143ot_check(empty,[outside,p143ot_var(0)],[],0,64,True{})),
   p114st_row("occ-env-first-collision",p143ot_check(empty,[],[bound],0,64,False{})),
   p114st_row("occ-env-last-collision",p143ot_check(empty,[],[p143ot_binding(4294967232,"tail")],0,64,False{})),
   p114st_row("occ-env-irrelevant",p143ot_check(empty,[],[p143ot_binding(10,"old")],0,64,True{})),
   p114st_row("occ-env-sentinel-still-unbound",p143ot_check(empty,[],[sentinel],0,64,True{})),
   p114st_row("occ-env-first-sentinel-shadows",p143ot_check(empty,[],[sentinel,bound],0,64,True{})),
   p114st_row("occ-env-first-binding-shadows",p143ot_check(empty,[],[bound,sentinel],0,64,False{})),
   p114st_row("occ-env-empty-word-is-bound",p143ot_check(empty,[],[p143ot_binding(4294967295,"")],0,64,False{})),
   p114st_row("occ-raw-var-children-ignored",p143ot_check(raw_var,[],[],0,64,True{})),
   p114st_row("occ-nonvar-binder-id-ignored",p143ot_check(binder,[],[],0,64,True{})),
   p114st_row("occ-literal-id-ignored",p143ot_check(literal,[],[],0,64,True{})),
   p114st_row("occ-nested-Var-still-counts",p143ot_check(p143ot_node([binder,p143ot_node([first])]),[],[],0,64,False{})),
   p114st_row("occ-duplicate-ids",p143ot_check(p143ot_node([first,first]),[first],[],0,64,False{})),
   p114st_row("occ-zero-id",p143ot_check(p143ot_var(0),[],[],4294967295,1,False{})),
   p114st_row("occ-wrap-first-clear",p143ot_check(first,[],[],4294967295,1,True{})),
   p114st_row("occ-wrap-next-collision",p143ot_check(first,[],[],4294967295,2,False{})),
   p114st_row("occ-wrap-next-clear",p143ot_check(p143ot_var(4294967294),[],[],4294967295,2,True{})),
   p114st_row("occ-wrap-third-collision",p143ot_check(p143ot_var(4294967294),[],[],4294967295,3,False{})),
   p114st_row("occ-u32-high-bit",p143ot_check(p143ot_var(2147483648),[],[],2147483647,1,False{})),
   p114st_row("occ-single-clear",p143ot_check(empty,[],[],0,1,True{})),
   p114st_row("occ-single-collision",p143ot_check(first,[],[],0,1,False{})),
   p114st_row("occ-multiple-patricia-branches",p143ot_check(p143ot_node([p143ot_var(0),p143ot_var(2147483648),outside,p143ot_var(17)]),[],[],0,64,True{}))]
