NF_INLINE Term NF_FID_110_116_95_114_101_118_101_114_115_101_(Env e, bool seq, Term* nf_out, Term v_4294967295, Term v_4294967294) {
u32 nf_poll = 0;
nf_again:;
if (err_spun(e.mem, &nf_poll)) { return 0; }
{
Term v_4294967293;
{
v_4294967293 = v_4294967295;
goto nf_join_4;
}
nf_join_4:;
if (!seq && err_seen(e.mem)) { return 0; }
Term v_4294967292;
{
v_4294967292 = v_4294967294;
goto nf_join_5;
}
nf_join_5:;
if (!seq && err_seen(e.mem)) { return 0; }
if ((term_aux(v_4294967293) == CID_NIL)) {
nf_out[0] = v_4294967292;
return 1;
} else {
Term v_4294967289;
{
v_4294967289 = v_4294967293;
goto nf_join_8;
}
nf_join_8:;
if (!seq && err_seen(e.mem)) { return 0; }
Term v_4294967288;
{
v_4294967288 = v_4294967292;
goto nf_join_9;
}
nf_join_9:;
if (!seq && err_seen(e.mem)) { return 0; }
if ((term_aux(v_4294967289) == CID_CON)) {
Term fields[2];
spare_free(e, cls_fit(2), ctr_take(e, v_4294967289, 2, fields));
#if !DEVICE && NATIVE_FIELD32_CID_CON_0
u32
#else
Term
#endif
v_4294967285 = fields[0];
#if !DEVICE && NATIVE_FIELD32_CID_CON_1
u32
#else
Term
#endif
v_4294967284 = fields[1];
Term v_4294967283;
{
v_4294967283 = v_4294967284;
goto nf_join_14;
}
nf_join_14:;
if (!seq && err_seen(e.mem)) { return 0; }
Term v_4294967282;
{
Term v_4294967279;
{
v_4294967279 = v_4294967285;
goto nf_join_18;
}
nf_join_18:;
if (!seq && err_seen(e.mem)) { return 0; }
Term v_4294967278;
{
v_4294967278 = v_4294967288;
goto nf_join_19;
}
nf_join_19:;
if (!seq && err_seen(e.mem)) { return 0; }
u64 nd_20 = heap_alloc(e, cls_fit(2));
#if !DEVICE && NATIVE_COLD_CTORS && !NATIVE_HOT_CID_CON
e.mem[nd_20 + 0] = v_4294967279;
e.mem[nd_20 + 1] = v_4294967278;
#else
e.mem[nd_20 + 0] = rfc_seal(e, v_4294967279);
e.mem[nd_20 + 1] = rfc_seal(e, v_4294967278);
#endif
v_4294967282 = term_ctr(CID_CON, nd_20);
goto nf_join_15;
}
nf_join_15:;
if (!seq && err_seen(e.mem)) { return 0; }
{
Term nf_arg_0 = v_4294967283;
Term nf_arg_1 = v_4294967282;
v_4294967295 = nf_arg_0;
v_4294967294 = nf_arg_1;
goto nf_again;
}
} else {
term_sink(e, v_4294967289);
term_sink(e, v_4294967288);
err_post(e.mem, ERR_FIDS); return 0;
}
}
}
return 0;
}

NF_INLINE Term NF_FID_83_116_114_105_110_103_46_114_101_118_101_114_115_101_46_103_111_(Env e, bool seq, Term* nf_out, Term v_4294967295, Term v_4294967294) {
u32 nf_poll = 0;
nf_again:;
if (err_spun(e.mem, &nf_poll)) { return 0; }
{
Term v_4294967293;
{
v_4294967293 = v_4294967295;
goto nf_join_4;
}
nf_join_4:;
if (!seq && err_seen(e.mem)) { return 0; }
Term v_4294967292;
{
v_4294967292 = v_4294967294;
goto nf_join_5;
}
nf_join_5:;
if (!seq && err_seen(e.mem)) { return 0; }
if ((term_aux(v_4294967293) == CID_SNIL)) {
nf_out[0] = v_4294967292;
return 1;
} else {
Term v_4294967289;
{
v_4294967289 = v_4294967293;
goto nf_join_8;
}
nf_join_8:;
if (!seq && err_seen(e.mem)) { return 0; }
Term v_4294967288;
{
v_4294967288 = v_4294967292;
goto nf_join_9;
}
nf_join_9:;
if (!seq && err_seen(e.mem)) { return 0; }
if ((term_aux(v_4294967289) == CID_SCON)) {
Term fields[2];
spare_free(e, cls_fit(2), ctr_take(e, v_4294967289, 2, fields));
#if !DEVICE && NATIVE_FIELD32_CID_SCON_0
u32
#else
Term
#endif
v_4294967285 = fields[0];
#if !DEVICE && NATIVE_FIELD32_CID_SCON_1
u32
#else
Term
#endif
v_4294967284 = fields[1];
Term v_4294967283;
{
v_4294967283 = v_4294967284;
goto nf_join_14;
}
nf_join_14:;
if (!seq && err_seen(e.mem)) { return 0; }
Term v_4294967282;
{
Term v_4294967279;
{
v_4294967279 = v_4294967285;
goto nf_join_18;
}
nf_join_18:;
if (!seq && err_seen(e.mem)) { return 0; }
Term v_4294967278;
{
v_4294967278 = v_4294967288;
goto nf_join_19;
}
nf_join_19:;
if (!seq && err_seen(e.mem)) { return 0; }
u64 nd_20 = heap_alloc(e, cls_fit(2));
#if !DEVICE && NATIVE_COLD_CTORS && !NATIVE_HOT_CID_SCON
e.mem[nd_20 + 0] = v_4294967279;
e.mem[nd_20 + 1] = v_4294967278;
#else
e.mem[nd_20 + 0] = rfc_seal(e, v_4294967279);
e.mem[nd_20 + 1] = rfc_seal(e, v_4294967278);
#endif
v_4294967282 = term_ctr(CID_SCON, nd_20);
goto nf_join_15;
}
nf_join_15:;
if (!seq && err_seen(e.mem)) { return 0; }
{
Term nf_arg_0 = v_4294967283;
Term nf_arg_1 = v_4294967282;
v_4294967295 = nf_arg_0;
v_4294967294 = nf_arg_1;
goto nf_again;
}
} else {
term_sink(e, v_4294967289);
term_sink(e, v_4294967288);
err_post(e.mem, ERR_FIDS); return 0;
}
}
}
return 0;
}
