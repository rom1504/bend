# Optional profitability consumer only. Original p112c_plan_index remains the
# semantic planner; this hook receives its already constructed complete plan.
# Two existing linear statement counts run only when that plan fused a site.
# Rejection still permits the independent ready-tail optimization on ORIGINAL
# input, never a prefix of an over-budget fused candidate.
# Count nested branches with the same existing p112f_size convention as the
# original continuation admission: one per statement, including each If.

def x193fb_ratio() -> U32: 2
def x193fb_slack() -> U32: 16

@unsafe
def x193fb_budget(+before: U32, after: U32) -> Bool:
  U32.is_le(before,2147483639) &&
    U32.is_le(after,U32.add(U32.mul(before,x193fb_ratio()),x193fb_slack()))

@unsafe
def x193fb_candidate(+segment: N111Segment, +ready: KDef, +tail: Bool, +plan: P112FusionBody) -> X193FBody:
  match segment plan:
    case N111Segment{name,arity,result,incoming,flags,+original} P112FusionBody{+body,+count,site}:
      nt_choose(X193FBody,U32.is_eq(count,0),u => x193f_candidate(segment,ready,tail,plan),u =>
        nt_choose(X193FBody,x193fb_budget(p112f_size(original),p112f_size(body)),
          v => x193f_candidate(segment,ready,tail,plan),v => x193f_tail(segment,ready,tail)))

@unsafe
def x193fb_row(+name: String, pass: Bool) -> String:
  nt_choose(String,pass,u => "PASS " ++ name,u => "FAIL " ++ name)

@unsafe
def x193fb_controls() -> List<&2,String>:
  [x193fb_row("budget-small-slack-accepted",x193fb_budget(0,16)),
   x193fb_row("budget-small-slack-over-refused",Bool.not(x193fb_budget(0,17))),
   x193fb_row("budget-exact-limit-accepted",x193fb_budget(32,80)),
   x193fb_row("budget-limit-plus-one-refused",Bool.not(x193fb_budget(32,81))),
   x193fb_row("budget-linear-growth-accepted",x193fb_budget(200,250)),
   x193fb_row("budget-sixfold-growth-refused",Bool.not(x193fb_budget(100,600))),
   x193fb_row("budget-arithmetic-overflow-refused",Bool.not(x193fb_budget(2147483640,0)))]
