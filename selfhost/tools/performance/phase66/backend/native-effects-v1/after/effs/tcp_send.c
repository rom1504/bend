// Phase66: current Base blocking result ABI on the retained IoAct scheduler.
// Adapted from upstream b2111cf43244e65f76ddc278ee695e669f720cbf.
// Uses the retained selfhost runtime and its CID_* constructor ABI.
// TCP
// ===

// Sends what is left; a full socket (non-blocking, so EAGAIN) parks the
// computation until the socket is writable, and the loop resumes here.
static Term tcp_send_with(Env e, IoWork* w, IoPack more,
  Term (*make)(Env, const char*, u64)) {
  int fd = (int)w->hand;
  while (w->code == 0 && (u64)w->made < w->size) {
    ssize_t n = send(fd, w->data + w->made, w->size - (u64)w->made, 0);
    if (n < 0 && errno == EAGAIN) {
      return io_wait_on(w, fd, POLLOUT, 0, more);
    }
    w->made += io_sys_end(w, n);
  }
  Term r = w->code != 0 ? io_box(e, CID_FAIL, io_tup(e,
      io_err(e, w->code, NULL), make(e, w->data + w->made, w->size - (u64)w->made)))
    : io_done(e, term_pak(CID_UNIT, 0));
  free(w->data);
  return io_tup(e, io_hand(w->hand), r);
}

static Term tcp_send_more(Env e, IoWork* w) {
  return tcp_send_with(e, w, tcp_send_more, io_str);
}

#ifdef CID_TCP_SEND

Term tcp_send_run(Env e, Term* f, IoWork* w) {
  w->hand = (intptr_t)io_hand_v(f[0]);
  w->data = io_cstr(e, f[1], &w->size);
  w->made = 0;
  w->code = 0;
  return tcp_send_more(e, w);
}

static void __attribute__((constructor)) tcp_send_use(void) {
  io_eff(CID_TCP_SEND, tcp_send_run, 0);
}

#endif

#ifdef CID_TCP_SEND_BYTES

static Term tcp_send_bytes_more(Env e, IoWork* w) {
  return tcp_send_with(e, w, tcp_send_bytes_more, io_list);
}

// Validate before consuming: failure must return the exact original list.
Term tcp_send_bytes_run(Env e, Term* f, IoWork* w) {
  w->hand = (intptr_t)io_hand_v(f[0]);
  for (Term s = f[1]; term_aux(s) == CID_CON;) {
    Loc at = term_peek(e, s);
    if (e.mem[at] > 255) {
      return io_tup(e, f[0], io_box(e, CID_FAIL,
        io_tup(e, io_err(e, EINVAL, NULL), f[1])));
    }
    s = e.mem[at + 1];
  }
  w->data = io_cbuf(e, f[1], &w->size, CID_CON);
  w->made = 0;
  w->code = 0;
  return tcp_send_bytes_more(e, w);
}

static void __attribute__((constructor)) tcp_send_bytes_use(void) {
  io_eff(CID_TCP_SEND_BYTES, tcp_send_bytes_run, 0);
}

#endif
