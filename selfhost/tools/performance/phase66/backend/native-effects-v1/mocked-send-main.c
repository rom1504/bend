#undef send

static Term test_field(Env e, Term t, u32 index) {
  return e.mem[term_peek(e, t) + index];
}
static void test_items(Env e, Term t, u64 cons, const u32* items, u32 size) {
  for (u32 i = 0; i < size; i += 1) {
    assert(term_aux(t) == cons);
    assert(test_field(e, t, 0) == items[i]);
    t = test_field(e, t, 1);
  }
  assert(term_aux(t) == (cons == CID_CON ? CID_NIL : CID_SNIL));
}
static Term test_result(Env e, Term pair, u64 kind) {
  assert(term_aux(pair) == CID_TUPLE);
  assert(io_hand_v(test_field(e, pair, 0)) == 17);
  Term result = test_field(e, pair, 1);
  assert(term_aux(result) == kind);
  return test_field(e, result, 0);
}
static Term test_failure(Env e, Term pair, u32 code) {
  Term failure = test_result(e, pair, CID_FAIL);
  assert(term_aux(failure) == CID_TUPLE);
  Term error = test_field(e, failure, 0);
  assert(term_aux(error) == CID_TUPLE);
  assert(test_field(e, error, 0) == code);
  return test_field(e, failure, 1);
}
static Term test_send(Env e, int mode, bool bytes, Term data) {
  test_mode = mode;
  test_calls = 0;
  IoWork work = {0};
  Term fields[] = { io_hand(17), data };
  return bytes ? tcp_send_bytes_run(e, fields, &work) : tcp_send_run(e, fields, &work);
}
int main(void) {
  Corpus H = corpus_setup(false, 1, 0);
  Env e = { H, ALC[0] };
  u32 passed = 0;

  Term p = test_send(e, 0, false, io_str(e, "abcdef", 6));
  const u32 suffix[] = { 'c', 'd', 'e', 'f' };
  test_items(e, test_failure(e, p, EPIPE), CID_SCON, suffix, 4);
  assert(test_calls == 2); term_drop(e, p); passed += 1;

  const char raw[] = { 0, (char)255, 7, 8 };
  p = test_send(e, 1, true, io_list(e, raw, 4));
  const u32 bytes[] = { 255, 7, 8 };
  test_items(e, test_failure(e, p, EPIPE), CID_CON, bytes, 3);
  assert(test_calls == 2); term_drop(e, p); passed += 1;

  Term invalid = io_node(e, CID_CON, 1,
    io_node(e, CID_CON, 256, term_pak(CID_NIL, 0)));
  Loc original = term_peek(e, invalid);
  p = test_send(e, 2, true, invalid);
  const u32 bad[] = { 1, 256 };
  Term kept = test_failure(e, p, EINVAL);
  assert(term_peek(e, kept) == original);
  test_items(e, kept, CID_CON, bad, 2);
  assert(test_calls == 0); term_drop(e, p); passed += 1;

  p = test_send(e, 3, false, io_str(e, "\xc3\xa1z", 3));
  const u32 split_utf8[] = { 0xfffd, 'z' };
  test_items(e, test_failure(e, p, EPIPE), CID_SCON, split_utf8, 2);
  assert(test_calls == 2); term_drop(e, p); passed += 1;

  p = test_send(e, 4, false, io_str(e, "all", 3));
  const u32 complete[] = { 'a', 'l', 'l' };
  test_items(e, test_failure(e, p, EPIPE), CID_SCON, complete, 3);
  assert(test_calls == 1); term_drop(e, p); passed += 1;

  p = test_send(e, 5, false, io_str(e, "sent", 4));
  assert(term_aux(test_result(e, p, CID_DONE)) == CID_UNIT);
  assert(test_calls == 2); term_drop(e, p); passed += 1;

  p = test_send(e, 6, true, term_pak(CID_NIL, 0));
  assert(term_aux(test_result(e, p, CID_DONE)) == CID_UNIT);
  assert(test_calls == 0); term_drop(e, p); passed += 1;

  printf("native blocking ABI controls %u passed\n", passed);
  return 0;
}
