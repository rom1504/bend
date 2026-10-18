/* Program-dependent tables move into the authenticated QBE descriptor. */
static const P111Program *p111_program_active;
static uint32_t p111_core_cids[18];
static const char *const p111_core_names[18] = {
  "SNil", "SCon", "WNil", "WCon", "Nil", "Con", "Tuple", "Unit",
  "None", "Some", "Fail", "Done", "Emit", "Halt", "True", "LT", "EQ", "GT"
};
#define CID_SNIL p111_core_cids[0]
#define CID_SCON p111_core_cids[1]
#define CID_WNIL p111_core_cids[2]
#define CID_WCON p111_core_cids[3]
#define CID_NIL p111_core_cids[4]
#define CID_CON p111_core_cids[5]
#define CID_TUPLE p111_core_cids[6]
#define CID_UNIT p111_core_cids[7]
#define CID_NONE p111_core_cids[8]
#define CID_SOME p111_core_cids[9]
#define CID_FAIL p111_core_cids[10]
#define CID_DONE p111_core_cids[11]
#define CID_EMIT p111_core_cids[12]
#define CID_HALT p111_core_cids[13]
#define CID_TRUE p111_core_cids[14]
#define CID_LT p111_core_cids[15]
#define CID_EQ p111_core_cids[16]
#define CID_GT p111_core_cids[17]
#define CID_ARITY_T (p111_program_active->cid_arity)
#define CID_HOT_T (p111_program_active->cid_hot)
#define FID_IO_EMIT ((u32)p111_program_active->segment_count)
#define BEND_CLO_APPLY (FID_IO_EMIT + 1u)
#define FID_EXIT (FID_IO_EMIT + 2u)
#define FID_ENTER (FID_IO_EMIT + 3u)
#define MAIN_FID ((u32)p111_program_active->main_fid)
#define MAIN_PURE (p111_program_active->main_pure != 0)
#define BANGS 0
#define WL_WIDTH P111_REG_CAP
#define WL_RESW P111_RESULT_CAP
#define STAT_LEN (p111_program_active->static_words)
#define STAT_IMG (p111_program_active->static_image)
#define SHOW_DESC (p111_program_active->show_desc)
#define SHOW_NAMES (p111_program_active->show_names)

#define WL_BANK Term p111_regs[P111_REG_CAP];
#define r0 p111_regs[0]
#define r1 p111_regs[1]
#define WL_INIT_BANK memset(p111_regs, 0, sizeof p111_regs);
#define WL_READ_STATE(V) memcpy(p111_regs, (V), sizeof p111_regs);
#define WL_WRITE_STATE(V) memcpy((V), p111_regs, sizeof p111_regs);
#define WL_LOAD(A,N) do { u32 p111_n = (N); \
  if (p111_n > P111_REG_CAP) { err_post(e.mem, ERR_FIDS); return 0; } \
  for (u32 p111_j = 0; p111_j < p111_n; ++p111_j) \
    p111_regs[p111_j] = e.mem[(A) + p111_j]; } while (0);
#define WL_LAST(X) do { \
  if (war >= P111_REG_CAP) { err_post(e.mem, ERR_FIDS); return 0; } \
  p111_regs[war] = (X); } while (0);
#define WL_SAVE(V) memcpy((V), p111_regs, sizeof(Term) * P111_RESULT_CAP);
#define WL_TAKE(V) memcpy(p111_regs, (V), sizeof(Term) * P111_RESULT_CAP);

static inline u32 p111_fid_arity(u32 fid) {
  return fid < FID_IO_EMIT ? p111_program_active->fid_arity[fid]
    : fid == FID_IO_EMIT ? 1u : fid == BEND_CLO_APPLY ? 2u : 0u;
}
static inline u32 p111_fid_flags(u32 fid) {
  return fid < FID_IO_EMIT ? p111_program_active->fid_flags[fid]
    : fid == FID_IO_EMIT ? 2u : 0u;
}
static inline u32 p111_fid_results(u32 fid) {
  return fid < FID_IO_EMIT ? p111_program_active->fid_results[fid] : 0u;
}
