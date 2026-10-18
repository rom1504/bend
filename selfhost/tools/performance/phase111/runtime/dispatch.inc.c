/* Ordinary ABI dispatcher; scheduler Reply and next-FID remain separate. */
typedef Reply (*WlFn)(WlState *state);
WL_FN WL_FID_ENTER(WlState *state);
WL_FN WL_FID_IO_EMIT(WlState *state);
WL_FN WL_BEND_CLO_APPLY(WlState *state);
WL_FN WL_FID_EXIT(WlState *state);

static Reply work_loop(Env e, Stk sp, Term t, bool seq) {
  WlState state = {0};
  state.e = e;
  state.sp = sp;
  state.seq = seq;
  state.next = FID_ENTER;
  state.regs[0] = t;
  for (;;) {
    Fid next = state.next;
    state.next = P111_STOP;
    WlFn run;
    if (next < FID_IO_EMIT) run = p111_program_active->segments[next];
    else if (next == FID_IO_EMIT) run = WL_FID_IO_EMIT;
    else if (next == BEND_CLO_APPLY) run = WL_BEND_CLO_APPLY;
    else if (next == FID_EXIT) run = WL_FID_EXIT;
    else if (next == FID_ENTER) run = WL_FID_ENTER;
    else { err_post(state.e.mem, ERR_FIDS); return 0; }
    Reply reply = run(&state);
    if (state.next == P111_STOP) return reply;
  }
}
