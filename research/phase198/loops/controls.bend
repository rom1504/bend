def p198lp_row(name: String, yes: Bool) -> String:
  name ++ "=" ++ nt_choose(String,yes,u => "1",u => "0")
@unsafe
def p198lp_ids() -> KDef:
  p111v_put(p111v_put(p111v_put(missing(),"a","X190LBit",1,0),"b","X190LBit",2,0),"c","X190LBit",4,0)
@unsafe
def p198lp_pair() -> KDef: x190_a_pair("a",N111Local{"c"},p198lp_ids(),missing())
@unsafe
def p198lp_graph(+rows: List<&2,U32>, +params: List<&2,String>) -> List<&2,U32>:
  x198lp_color(["a","b","c"],rows,params,1,[0,0,0,0,0,0,0,0,0],p198lp_pair(),p198lp_pair())
@unsafe
def p198lp_good(+rows: List<&2,U32>, +params: List<&2,String>, +shared: Bool) -> Bool:
  +groups = p198lp_graph(rows,params)
  x190_j_valid(["a","b","c"],rows,params,1,groups) &&
    nt_choose(Bool,shared,u => U32.is_eq(x190_j_home(groups,1,0),x190_j_home(groups,4,0)),
      u => Bool.not(U32.is_eq(x190_j_home(groups,1,0),x190_j_home(groups,4,0))))
@unsafe
def p198lp_scores_original() -> KDef:
  p111v_put(p111v_put(p111v_put(missing(),"a","X181Reads",16,0),"b","X181Reads",12,0),"c","X181Reads",8,0)
@unsafe
def p198lp_score_is(+scores: KDef, a: U32, b: U32, c: U32) -> Bool:
  U32.is_eq(da(p111v_get(scores,"a")),a) && U32.is_eq(da(p111v_get(scores,"b")),b) && U32.is_eq(da(p111v_get(scores,"c")),c)
@unsafe
def p198lp_controls() -> List<&2,String>:
  [p198lp_row("pair-reserves-future-color",p198lp_good([0,4,2],[],True{})),
   p198lp_row("pair-interference-refused",p198lp_good([4,0,1],[],False{})),
   p198lp_row("pair-call-live-saved",p198lp_good([1,0,4],[],True{}) && U32.is_lt(x190_j_home(p198lp_graph([1,0,4],[]),1,0),4)),
   p198lp_row("pair-abi-both-checked",p198lp_good([0,4,2],["state","a","b","c"],True{})),
   p198lp_row("pair-independent-validator",Bool.not(x190_j_valid(["a","b","c"],[4,0,1],[],1,[0,0,0,0,5,2,0,0,0]))),
   p198lp_row("pair-scores-combined",p198lp_score_is(x198lp_score_pair("a",N111Local{"c"},p198lp_scores_original(),p198lp_scores_original()),24,12,24)),
   p198lp_row("pair-identity-no-bonus",p198lp_score_is(x198lp_score_pair("a",N111Local{"a"},p198lp_scores_original(),p198lp_scores_original()),16,12,8)),
   p198lp_row("pair-constant-no-bonus",p198lp_score_is(x198lp_score_pair("a",N111Const{1,0},p198lp_scores_original(),p198lp_scores_original()),16,12,8)),
   p198lp_row("pair-branch-score-no-compounding",p198lp_score_is(x198lp_scores(
     [P113DIf{N111Const{1,0},[P113DAgain{[N111Local{"c"}]}],[P113DAgain{[N111Local{"c"}]}]}],
     ["a"],p198lp_scores_original(),p198lp_scores_original()),24,12,24)),
   p198lp_row("pair-only-backedge-affinity",U32.is_eq(da(p111v_get(x198lp_tail(
     [P113DScalar{N111Set{"a",N111U64{},N111Local{"c"}}}],p198lp_ids(),[],missing()),"a")),0))]
