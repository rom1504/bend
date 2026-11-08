// Adapted from upstream 9a4223d577ba56a0cb53d1fd952d2b481c38930f.
// Retains the local Env/CID_* effect ABI and ownership-aware result packing.
// File
// ====

// read(2) answers what is there, not what was asked: a pipe, a terminal
// and a short read all stop before max. Fill the buffer or reach EOF, so
// a caller that asked for n bytes gets n unless the file ends first; a
// line stops after its '\n', read a byte at a time so nothing past it
// leaves the file. An error after some bytes answers them (a pipe has
// already given them up); at reads at w->made and leaves the position.
static void file_read_fill(IoWork* w, int at, int line) {
  int fd  = (int)w->hand;
  u64 got = 0;
  w->code = 0;
  do {
    u64     want = line && got < w->word ? 1 : w->word - got;
    ssize_t n;
    do {
      n = at ? pread(fd, w->data + got, want, (off_t)(w->made + got))
             : read(fd, w->data + got, want);
    } while (n < 0 && errno == EINTR);
    if (n <= 0) {
      w->size = got > 0 ? got : io_sys_end(w, n);
      return;
    }
    got += (u64)n;
  } while (got < w->word && !(line && w->data[got - 1] == '\n'));
  w->size = got;
}

static void file_read_call(IoWork* w) {
  file_read_fill(w, 0, 0);
}

static Term file_read_start(Term file, u64 max, IoWork* w,
  IoCall call, IoPack pack) {
  w->hand = (intptr_t)io_hand_v(file);
  w->word = max < INT32_MAX ? max : INT32_MAX;
  w->data = io_mem(malloc(w->word + 1));
  return io_work(w, call, pack);
}

#if defined(CID_FILE_READ) || defined(CID_FILE_READ_LINE)

static Term file_read_pack(Env e, IoWork* w) {
  Term r = w->code ? io_fail(e, w->code, NULL)
    : io_done(e, io_str(e, w->data, w->size));
  free(w->data);
  return io_tup(e, io_hand(w->hand), r);
}

#endif

#ifdef CID_FILE_READ

Term file_read_run(Env e, Term* f, IoWork* w) {
  return file_read_start(f[0], f[1], w, file_read_call, file_read_pack);
}

static void __attribute__((constructor)) file_read_use(void) {
  io_eff(CID_FILE_READ, file_read_run);
}

#endif

#ifdef CID_FILE_READ_LINE

static void file_read_line_call(IoWork* w) {
  file_read_fill(w, 0, 1);
}

Term file_read_line_run(Env e, Term* f, IoWork* w) {
  return file_read_start(f[0], f[1], w, file_read_line_call, file_read_pack);
}

static void __attribute__((constructor)) file_read_line_use(void) {
  io_eff(CID_FILE_READ_LINE, file_read_line_run);
}

#endif

#if defined(CID_FILE_READ_BYTES) || defined(CID_FILE_READ_AT)

static Term file_read_bytes_pack(Env e, IoWork* w) {
  Term r = w->code ? io_fail(e, w->code, NULL)
    : io_done(e, io_list(e, w->data, w->size));
  free(w->data);
  return io_tup(e, io_hand(w->hand), r);
}

#endif

#ifdef CID_FILE_READ_BYTES

Term file_read_bytes_run(Env e, Term* f, IoWork* w) {
  return file_read_start(f[0], f[1], w, file_read_call, file_read_bytes_pack);
}

static void __attribute__((constructor)) file_read_bytes_use(void) {
  io_eff(CID_FILE_READ_BYTES, file_read_bytes_run);
}

#endif

#ifdef CID_FILE_READ_AT

// The bytes at an offset, as file_read_bytes gives them; the position of
// the file does not move.
static void file_read_at_call(IoWork* w) {
  file_read_fill(w, 1, 0);
}

Term file_read_at_run(Env e, Term* f, IoWork* w) {
  w->made = (intptr_t)f[1];
  return file_read_start(f[0], f[2], w, file_read_at_call, file_read_bytes_pack);
}

static void __attribute__((constructor)) file_read_at_use(void) {
  io_eff(CID_FILE_READ_AT, file_read_at_run);
}

#endif
