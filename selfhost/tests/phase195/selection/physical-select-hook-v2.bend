@unsafe
def x194_ps_emit(+plan: X194Select, +ids: N111Ids, +frame: X181Frame) -> X188Seq:
  nt_choose(X188Seq,x195_pm_enabled(),u => x195_pm_emit(plan,ids,frame),u => x195_pm_previous(plan,ids,frame))
