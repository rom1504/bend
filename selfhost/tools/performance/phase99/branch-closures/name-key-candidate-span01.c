  WL_CASE(FID_36_100_105_114_101_99_116_46_110_97_109_101_95_107_101_121_)
  {
    Term v_4294953824 = r0;
    WL_OPEN
if ((term_aux(v_4294953824) == CID_SNIL)) {
r0 = term_pak(CID_SNIL, 0);
WL_RETN(1);
} else {
if ((term_aux(v_4294953824) == CID_SCON)) {
Term fields[2];
spare_free(e, cls_fit(2), ctr_take(e, v_4294953824, 2, fields));
#if !DEVICE && NATIVE_FIELD32_CID_SCON_0
u32
#else
Term
#endif
v_4294953823 = fields[0];
#if !DEVICE && NATIVE_FIELD32_CID_SCON_1
u32
#else
Term
#endif
v_4294953822 = fields[1];
v_4294953823 = term_keep(e, v_4294953823);
if (seq) {
WL_ROOM(3);
STK(0) = v_4294953823;
STK(1) = v_4294953822;
STK(2) = FID_110_97_116_105_118_101_95_107_95_49_51_53_51_56_;
WL_PUSHN(3);
} else {
u64 task_13551 = task_node(e, FID_110_97_116_105_118_101_95_107_95_49_51_53_51_56_, WL_CONT, WL_IDX, 1);
e.mem[task_13551 + 0] = v_4294953823;
e.mem[task_13551 + 1] = v_4294953822;
WL_CONT = term_tsk(FID_110_97_116_105_118_101_95_107_95_49_51_53_51_56_, task_13551);
WL_IDX = 2;
}
Term v_4294953746 = v_4294953823;
if (!seq && err_seen(e.mem)) { return 0; }
Term v_4294953745 = 58ull;
if (!seq && err_seen(e.mem)) { return 0; }
r0 = v_4294953746;
r1 = v_4294953745;
WL_JMP(FID_36_100_105_114_101_99_116_46_67_104_97_114_46_105_115_95_101_113_);
} else {
if (seq) {
WL_ROOM(2);
STK(0) = v_4294953824;
STK(1) = FID_110_97_116_105_118_101_95_107_95_49_51_53_53_51_;
WL_PUSHN(2);
} else {
u64 task_13554 = task_node(e, FID_110_97_116_105_118_101_95_107_95_49_51_53_53_51_, WL_CONT, WL_IDX, 1);
e.mem[task_13554 + 0] = v_4294953824;
WL_CONT = term_tsk(FID_110_97_116_105_118_101_95_107_95_49_51_53_53_51_, task_13554);
WL_IDX = 1;
}
err_post(e.mem, ERR_FIDS); return 0;
}
}

  }}

  WL_CASE(FID_110_97_116_105_118_101_95_107_95_49_51_53_51_56_)
  {
    WL_POPN(2);
    #if !DEVICE && NATIVE_TYPED_SCALARS
u32
#else
Term
#endif
 v_4294953823 = STK(0);
    Term v_4294953822 = STK(1);
    Term v_4294953821 = r0;
    WL_OPEN
if (native_bool(v_4294953821)) {
term_sink(e, v_4294953823);
Term v_3479;
{
v_3479 = term_pak(CID_UNIT, 0);
}
if (!seq && err_seen(e.mem)) { return 0; }
term_sink(e, v_3479);
Term v_4294953756 = term_ctr(CID_SCON, STAT_OFF + 0);
if (!seq && err_seen(e.mem)) { return 0; }
Term v_4294953755 = v_4294953822;
if (!seq && err_seen(e.mem)) { return 0; }
r0 = v_4294953756;
r1 = v_4294953755;
WL_JMP(FID_36_100_105_114_101_99_116_46_83_116_114_105_110_103_46_97_112_112_101_110_100_);
} else {
if ((!native_bool(v_4294953821))) {
Term v_3480;
{
v_3480 = term_pak(CID_UNIT, 0);
}
if (!seq && err_seen(e.mem)) { return 0; }
term_sink(e, v_3480);
Term v_4294953754 = v_4294953823;
if (!seq && err_seen(e.mem)) { return 0; }
if (seq) {
WL_ROOM(2);
STK(0) = v_4294953754;
STK(1) = FID_110_97_116_105_118_101_95_107_95_49_51_53_52_51_;
WL_PUSHN(2);
} else {
u64 task_13546 = task_node(e, FID_110_97_116_105_118_101_95_107_95_49_51_53_52_51_, WL_CONT, WL_IDX, 1);
e.mem[task_13546 + 0] = v_4294953754;
WL_CONT = term_tsk(FID_110_97_116_105_118_101_95_107_95_49_51_53_52_51_, task_13546);
WL_IDX = 1;
}
Term v_4294953750 = v_4294953822;
if (!seq && err_seen(e.mem)) { return 0; }
r0 = v_4294953750;
WL_JMP(FID_36_100_105_114_101_99_116_46_110_97_109_101_95_107_101_121_);
} else {
term_sink(e, v_4294953823);
term_sink(e, v_4294953822);
if (seq) {
WL_ROOM(2);
STK(0) = v_4294953821;
STK(1) = FID_110_97_116_105_118_101_95_107_95_49_51_53_52_56_;
WL_PUSHN(2);
} else {
u64 task_13549 = task_node(e, FID_110_97_116_105_118_101_95_107_95_49_51_53_52_56_, WL_CONT, WL_IDX, 1);
e.mem[task_13549 + 0] = v_4294953821;
WL_CONT = term_tsk(FID_110_97_116_105_118_101_95_107_95_49_51_53_52_56_, task_13549);
WL_IDX = 1;
}
err_post(e.mem, ERR_FIDS); return 0;
}
}

  }}

  WL_CASE(FID_110_97_116_105_118_101_95_107_95_49_51_53_52_51_)
  {
    WL_POPN(1);
    #if !DEVICE && NATIVE_TYPED_SCALARS
u32
#else
Term
#endif
 v_4294953754 = STK(0);
    Term v_4294953753 = r0;
    WL_OPEN
u64 nd_13544 = heap_alloc(e, cls_fit(2));
#if !DEVICE && NATIVE_COLD_CTORS && !NATIVE_HOT_CID_SCON
e.mem[nd_13544 + 0] = v_4294953754;
e.mem[nd_13544 + 1] = v_4294953753;
#else
e.mem[nd_13544 + 0] = rfc_seal(e, v_4294953754);
e.mem[nd_13544 + 1] = rfc_seal(e, v_4294953753);
#endif
r0 = term_ctr(CID_SCON, nd_13544);
WL_RETN(1);

  }}

  WL_CASE(FID_110_97_116_105_118_101_95_107_95_49_51_53_52_56_)
  {
    WL_POPN(1);
    Term v_4294953821 = STK(0);
    Term v_4294953749 = r0;
    WL_OPEN
Term v_4294953748 = v_4294953821;
if (!seq && err_seen(e.mem)) { return 0; }
{ Term fn = v_4294953749; Term arg = v_4294953748;
Fid f = (Fid)term_aux(fn);
if (!seq && fid_bangs(f)) {
  u32 war = fid_arity(f) - 1;
  Loc src = term_loc(fn);
  Loc dst = task_node(e, f, WL_CONT, WL_IDX, 0);
  for (u32 j = 0; j < war; ++j) e.mem[dst + j] = e.mem[src + j];
  e.mem[dst + war] = arg;
  spare_free(e, cls_fit(war), src);
  return term_tsk(f, dst);
}
r0 = fn; r1 = arg; WL_JMP(BEND_CLO_APPLY);
}

  }}

  WL_CASE(FID_110_97_116_105_118_101_95_107_95_49_51_53_53_51_)
  {
    WL_POPN(1);
    Term v_4294953824 = STK(0);
    Term v_4294953744 = r0;
    WL_OPEN
Term v_4294953743 = v_4294953824;
if (!seq && err_seen(e.mem)) { return 0; }
{ Term fn = v_4294953744; Term arg = v_4294953743;
Fid f = (Fid)term_aux(fn);
if (!seq && fid_bangs(f)) {
  u32 war = fid_arity(f) - 1;
  Loc src = term_loc(fn);
  Loc dst = task_node(e, f, WL_CONT, WL_IDX, 0);
  for (u32 j = 0; j < war; ++j) e.mem[dst + j] = e.mem[src + j];
  e.mem[dst + war] = arg;
  spare_free(e, cls_fit(war), src);
  return term_tsk(f, dst);
}
r0 = fn; r1 = arg; WL_JMP(BEND_CLO_APPLY);
}

  }}

