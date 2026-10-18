/* Scalar public boundary over the retained production ownership operations. */
static void p111_require(bool condition, const char *message) {
  if (!condition) err_fail(message);
}

static uint32_t p111_lookup_cid(void *context, const char *name) {
  const P111Program *program = context;
  for (u32 i = 0; i < program->constructor_count; ++i)
    if (strcmp(program->cid_names[i], name) == 0) return i;
  return UINT32_MAX;
}

static void p111_bind(const P111Program *program) {
  p111_require(p111_program_active == NULL, "phase111: one program per process");
  p111_require(program && program->abi_version == P111_ABI_VERSION &&
    program->descriptor_bytes == sizeof(P111Program), "phase111: descriptor ABI mismatch");
  p111_require(program->capabilities == P111_SEQUENTIAL, "phase111: unsupported capabilities");
  p111_require(program->segment_count > 0 && program->segment_count <= 65532 &&
    program->constructor_count > 0 && program->constructor_count <= 65536,
    "phase111: program identifier capacity exceeded");
  p111_require(program->main_fid < program->segment_count && program->main_pure <= 1 &&
    program->register_width >= 2 && program->register_width <= P111_REG_CAP &&
    program->result_width >= 1 && program->result_width <= P111_RESULT_CAP,
    "phase111: program entry or width mismatch");
  p111_require(program->segments && program->fid_arity && program->fid_flags &&
    program->fid_results && program->cid_arity && program->cid_hot && program->cid_names,
    "phase111: missing program tables");
  p111_require(program->static_words < (UINT64_C(1) << 30) - STAT_OFF &&
    (!program->static_words || program->static_image), "phase111: static image exceeds initial corpus");
  p111_require(!program->main_pure || (program->show_words && program->show_desc &&
    (!program->show_name_count || program->show_names)), "phase111: missing pure result readback");
  p111_require(!program->effect_count || program->effects, "phase111: missing effects table");
  for (u32 i = 0; i < program->segment_count; ++i) {
    p111_require(program->segments[i] && program->fid_arity[i] <= program->register_width &&
      program->fid_results[i] <= program->result_width &&
      program->fid_results[i] <= program->fid_arity[i] && (program->fid_flags[i] & ~3u) == 0,
      "phase111: invalid segment metadata");
  }
  p111_require(program->fid_arity[program->main_fid] == 0 &&
    program->fid_results[program->main_fid] == 0, "phase111: main must be a closed ordinary segment");
  for (u32 i = 0; i < program->constructor_count; ++i) {
    p111_require(program->cid_names[i] && program->cid_names[i][0] && program->cid_hot[i] <= 1,
      "phase111: invalid constructor metadata");
  }
  p111_program_active = program;
  for (u32 i = 0; i < 18; ++i) {
    p111_core_cids[i] = p111_lookup_cid((void *)program, p111_core_names[i]);
    p111_require(p111_core_cids[i] != UINT32_MAX, "phase111: missing core constructor identity");
  }
  p111_effects_bind(p111_lookup_cid, (void *)program);
  for (u64 i = 0; i < program->effect_count; ++i) {
    p111_require(program->effects[i] != NULL, "phase111: missing effect name");
    u32 cid = p111_lookup_cid((void *)program, program->effects[i]);
    p111_require(cid != UINT32_MAX && io_eff_rows[cid].run != NULL,
      "phase111: foreign provider unavailable");
  }
}

uint64_t p111_rt_keep(P111State *state, uint64_t term) { return term_keep(state->e, term); }
uint64_t p111_rt_sink(P111State *state, uint64_t term) { term_sink(state->e, term); return 0; }
uint64_t p111_rt_tag(P111State *state, uint64_t term) { (void)state; return term_aux(term); }

uint64_t p111_rt_ctor(P111State *state, uint32_t cid, const uint64_t *fields, uint32_t count) {
  p111_require(cid < p111_program_active->constructor_count && count == cid_arity(cid),
    "phase111: constructor arity mismatch");
  if (!count) return term_pak(cid, 0);
  p111_require(fields != NULL, "phase111: missing constructor fields");
  Env e = state->e;
  Loc at = heap_alloc(e, cls_fit(count));
  for (u32 i = 0; i < count; ++i) e.mem[at + i] = rfc_seal(e, fields[i]);
  return term_ctr(cid, at);
}

uint64_t p111_rt_take(P111State *state, uint64_t term, uint64_t *out, uint32_t count) {
  u32 cid = (u32)term_aux(term);
  p111_require(cid < p111_program_active->constructor_count && count == cid_arity(cid),
    "phase111: take arity mismatch");
  if (!count) return 0;
  p111_require(out != NULL, "phase111: missing take outputs");
  if (count == 1 && term_tag(term) == TAG_PAK) out[0] = term_loc(term);
  else {
    p111_require(term_tag(term) == TAG_CTR, "phase111: expected constructor owner");
    spare_free(state->e, cls_fit(count), ctr_take(state->e, term, count, out));
  }
  return count;
}

uint64_t p111_rt_closure(P111State *state, uint32_t fid, const uint64_t *fields, uint32_t count) {
  p111_require(fid < FID_IO_EMIT && count < 255 && count + 1 == fid_arity(fid),
    "phase111: closure capture arity mismatch");
  if (!count) return term_clo(fid, 0);
  p111_require(fields != NULL, "phase111: missing closure captures");
  Loc at = heap_alloc(state->e, cls_fit(count));
  for (u32 i = 0; i < count; ++i) state->e.mem[at + i] = fields[i];
  return term_clo(fid, at);
}

uint64_t p111_rt_frame(P111State *state, uint32_t next_fid, const uint64_t *captures, uint32_t count) {
  p111_require(next_fid < FID_IO_EMIT && count < P111_REG_CAP && (!count || captures),
    "phase111: invalid continuation frame");
  for (u32 i = 0; i < count; ++i) state->sp[i] = captures[i];
  state->sp[count] = next_fid;
  state->sp += count + 1;
  return 0;
}

static void p111_set_regs(P111State *state, const uint64_t *values, uint32_t count) {
  p111_require(count <= P111_REG_CAP && (!count || values), "phase111: invalid register transfer");
  if (count) memmove(state->regs, values, count * sizeof(uint64_t));
  memset(state->regs + count, 0, (P111_REG_CAP - count) * sizeof(uint64_t));
}

uint64_t p111_rt_jump(P111State *state, uint32_t fid, const uint64_t *args, uint32_t count) {
  p111_require(fid < FID_IO_EMIT && count == fid_arity(fid), "phase111: direct jump arity mismatch");
  p111_set_regs(state, args, count);
  state->rn = 0;
  state->next = fid;
  return 0;
}

uint64_t p111_rt_return(P111State *state, const uint64_t *values, uint32_t count) {
  p111_require(count <= p111_program_active->result_width, "phase111: return width mismatch");
  p111_set_regs(state, values, count);
  state->rn = count;
  state->next = (u32)*--state->sp;
  return 0;
}

uint64_t p111_rt_apply(P111State *state, uint64_t closure, uint64_t argument) {
  u32 fid = (u32)term_aux(closure);
  p111_require(state->seq && term_tag(closure) == TAG_CLO && fid <= FID_IO_EMIT && fid_arity(fid),
    "phase111: invalid sequential closure apply");
  uint64_t args[2] = {closure, argument};
  p111_set_regs(state, args, 2);
  state->rn = 0;
  state->next = BEND_CLO_APPLY;
  return 0;
}

uint64_t p111_rt_stack_pop(P111State *state, uint32_t count) { state->sp -= count; return 0; }
uint64_t p111_rt_stack_get(P111State *state, uint32_t index) { return state->sp[index]; }
uint64_t p111_rt_reg_get(P111State *state, uint32_t index) {
  p111_require(index < P111_REG_CAP, "phase111: invalid register index");
  return state->regs[index];
}
uint64_t p111_rt_fail(P111State *state, uint32_t code) { err_post(state->e.mem, code); return 0; }
