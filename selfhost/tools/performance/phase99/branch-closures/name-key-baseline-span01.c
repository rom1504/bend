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
STK(2) = FID_110_97_116_105_118_101_95_107_95_49_51_52_55_55_;
WL_PUSHN(3);
} else {
u64 task_13493 = task_node(e, FID_110_97_116_105_118_101_95_107_95_49_51_52_55_55_, WL_CONT, WL_IDX, 1);
e.mem[task_13493 + 0] = v_4294953823;
e.mem[task_13493 + 1] = v_4294953822;
WL_CONT = term_tsk(FID_110_97_116_105_118_101_95_107_95_49_51_52_55_55_, task_13493);
WL_IDX = 2;
}
Term v_4294953804 = v_4294953823;
if (!seq && err_seen(e.mem)) { return 0; }
Term v_4294953803 = 58ull;
if (!seq && err_seen(e.mem)) { return 0; }
r0 = v_4294953804;
r1 = v_4294953803;
WL_JMP(FID_36_100_105_114_101_99_116_46_67_104_97_114_46_105_115_95_101_113_);
} else {
if (seq) {
WL_ROOM(2);
STK(0) = v_4294953824;
STK(1) = FID_110_97_116_105_118_101_95_107_95_49_51_52_57_53_;
WL_PUSHN(2);
} else {
u64 task_13496 = task_node(e, FID_110_97_116_105_118_101_95_107_95_49_51_52_57_53_, WL_CONT, WL_IDX, 1);
e.mem[task_13496 + 0] = v_4294953824;
WL_CONT = term_tsk(FID_110_97_116_105_118_101_95_107_95_49_51_52_57_53_, task_13496);
WL_IDX = 1;
}
err_post(e.mem, ERR_FIDS); return 0;
}
}

  }}

  WL_CASE(FID_110_97_116_105_118_101_95_107_95_49_51_52_55_55_)
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
v_4294953822 = term_keep(e, v_4294953822);
if (seq) {
WL_ROOM(4);
STK(0) = v_4294953823;
STK(1) = v_4294953822;
STK(2) = v_4294953821;
STK(3) = FID_110_97_116_105_118_101_95_107_95_49_51_52_55_56_;
WL_PUSHN(4);
} else {
u64 task_13491 = task_node(e, FID_110_97_116_105_118_101_95_107_95_49_51_52_55_56_, WL_CONT, WL_IDX, 1);
e.mem[task_13491 + 0] = v_4294953823;
e.mem[task_13491 + 1] = v_4294953822;
e.mem[task_13491 + 2] = v_4294953821;
WL_CONT = term_tsk(FID_110_97_116_105_118_101_95_107_95_49_51_52_55_56_, task_13491);
WL_IDX = 3;
}
u64 cl_13490 = heap_alloc(e, cls_fit(1));
e.mem[cl_13490 + 0] = v_4294953822;
r0 = term_clo(FID_110_97_116_105_118_101_95_107_95_49_51_52_56_55_, cl_13490);
WL_RETN(1);

  }}

  WL_CASE(FID_110_97_116_105_118_101_95_107_95_49_51_52_55_56_)
  {
    WL_POPN(3);
    #if !DEVICE && NATIVE_TYPED_SCALARS
u32
#else
Term
#endif
 v_4294953823 = STK(0);
    Term v_4294953822 = STK(1);
    Term v_4294953821 = STK(2);
    Term v_4294953820 = r0;
    WL_OPEN
if (seq) {
WL_ROOM(3);
STK(0) = v_4294953821;
STK(1) = v_4294953820;
STK(2) = FID_110_97_116_105_118_101_95_107_95_49_51_52_55_57_;
WL_PUSHN(3);
} else {
u64 task_13487 = task_node(e, FID_110_97_116_105_118_101_95_107_95_49_51_52_55_57_, WL_CONT, WL_IDX, 1);
e.mem[task_13487 + 0] = v_4294953821;
e.mem[task_13487 + 1] = v_4294953820;
WL_CONT = term_tsk(FID_110_97_116_105_118_101_95_107_95_49_51_52_55_57_, task_13487);
WL_IDX = 2;
}
u64 cl_13486 = heap_alloc(e, cls_fit(2));
e.mem[cl_13486 + 0] = v_4294953823;
e.mem[cl_13486 + 1] = v_4294953822;
r0 = term_clo(FID_110_97_116_105_118_101_95_107_95_49_51_52_56_48_, cl_13486);
WL_RETN(1);

  }}

  WL_CASE(FID_110_97_116_105_118_101_95_107_95_49_51_52_55_57_)
  {
    WL_POPN(2);
    Term v_4294953821 = STK(0);
    Term v_4294953820 = STK(1);
    Term v_4294953819 = r0;
    WL_OPEN
r0 = v_4294953821;
r1 = v_4294953820;
r2 = v_4294953819;
WL_JMP(FID_36_100_105_114_101_99_116_46_115_101_108_101_99_116_95_98_114_97_110_99_104_);

  }}

  WL_CASE(FID_110_97_116_105_118_101_95_107_95_49_51_52_56_48_)
  {
    #if !DEVICE && NATIVE_TYPED_SCALARS
u32
#else
Term
#endif
 v_4294953823 = r0;
    Term v_4294953822 = r1;
    Term v_3480 = r2;
    WL_OPEN
term_sink(e, v_3480);
Term v_4294953814 = v_4294953823;
if (!seq && err_seen(e.mem)) { return 0; }
if (seq) {
WL_ROOM(2);
STK(0) = v_4294953814;
STK(1) = FID_110_97_116_105_118_101_95_107_95_49_51_52_56_51_;
WL_PUSHN(2);
} else {
u64 task_13486 = task_node(e, FID_110_97_116_105_118_101_95_107_95_49_51_52_56_51_, WL_CONT, WL_IDX, 1);
e.mem[task_13486 + 0] = v_4294953814;
WL_CONT = term_tsk(FID_110_97_116_105_118_101_95_107_95_49_51_52_56_51_, task_13486);
WL_IDX = 1;
}
Term v_4294953810 = v_4294953822;
if (!seq && err_seen(e.mem)) { return 0; }
r0 = v_4294953810;
WL_JMP(FID_36_100_105_114_101_99_116_46_110_97_109_101_95_107_101_121_);

  }}

  WL_CASE(FID_110_97_116_105_118_101_95_107_95_49_51_52_56_51_)
  {
    WL_POPN(1);
    #if !DEVICE && NATIVE_TYPED_SCALARS
u32
#else
Term
#endif
 v_4294953814 = STK(0);
    Term v_4294953813 = r0;
    WL_OPEN
u64 nd_13484 = heap_alloc(e, cls_fit(2));
#if !DEVICE && NATIVE_COLD_CTORS && !NATIVE_HOT_CID_SCON
e.mem[nd_13484 + 0] = v_4294953814;
e.mem[nd_13484 + 1] = v_4294953813;
#else
e.mem[nd_13484 + 0] = rfc_seal(e, v_4294953814);
e.mem[nd_13484 + 1] = rfc_seal(e, v_4294953813);
#endif
r0 = term_ctr(CID_SCON, nd_13484);
WL_RETN(1);

  }}

  WL_CASE(FID_110_97_116_105_118_101_95_107_95_49_51_52_56_55_)
  {
    Term v_4294953822 = r0;
    Term v_3479 = r1;
    WL_OPEN
term_sink(e, v_3479);
Term v_4294953807 = term_ctr(CID_SCON, STAT_OFF + 0);
if (!seq && err_seen(e.mem)) { return 0; }
Term v_4294953806 = v_4294953822;
if (!seq && err_seen(e.mem)) { return 0; }
r0 = v_4294953807;
r1 = v_4294953806;
WL_JMP(FID_36_100_105_114_101_99_116_46_83_116_114_105_110_103_46_97_112_112_101_110_100_);

  }}

  WL_CASE(FID_110_97_116_105_118_101_95_107_95_49_51_52_57_53_)
  {
    WL_POPN(1);
    Term v_4294953824 = STK(0);
    Term v_4294953802 = r0;
    WL_OPEN
Term v_4294953801 = v_4294953824;
if (!seq && err_seen(e.mem)) { return 0; }
{ Term fn = v_4294953802; Term arg = v_4294953801;
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

