# Native arrays use one 64-bit slot per element. The layout-independent path
# supports values, closures and nested arrays through the common word ABI.
law nc_array:
  for +k: String
  for +ws: List<&2, String>
  for +n: U32
  NC_Code

@unsafe
def nc_array_known(k):
  String.eq(k, "array_new") || String.eq(k, "array_get") || String.eq(k, "array_set") || String.eq(k, "array_swap") || String.eq(k, "array_size") || String.eq(k, "array_clone")

@unsafe
def nc_array_pair(code: String, a: String, b: String, n: U32) -> NC_Code:
  nc_prepend(code, nc_ctor_result(ne_constructor("Tuple", [a, b], False{}, n, True{})))

@unsafe
def nc_array(k, ws, n):
  +a = nc_head(ws)
  +i = nc_head(nc_tail(ws))
  +v = nc_head(nc_tail(nc_tail(ws)))
  nt_choose(NC_Code, String.eq(k, "array_new"), u => NC_Code{"Term init[1] = { " ++ i ++ " };\n" ++ ne_ret(["blk_new(e, 1, " ++ a ++ ", 0, 1, init)"]), Nil{}, n, ""}, u =>
  nt_choose(NC_Code, String.eq(k, "array_size"), u => nc_array_pair("", a, "(1ull << blk_cls(" ++ a ++ "))", n), u =>
  nt_choose(NC_Code, String.eq(k, "array_clone"), u => nc_array_pair("", "blk_copy(e, " ++ a ++ ")", a, n), u =>
  nt_choose(NC_Code, String.eq(k, "array_get"), u => nc_array_pair("u32 at = blk_at(" ++ a ++ ", " ++ i ++ ", 0);\n", a, "blk_keep(e, term_loc(" ++ a ++ ") + at)", n), u =>
  nt_choose(NC_Code, String.eq(k, "array_swap"), u => nc_array_pair("u32 at = blk_at(" ++ a ++ ", " ++ i ++ ", 0);\nTerm old = blk_read(e.mem, 1, term_loc(" ++ a ++ "), at);\nblk_write(e.mem, 1, term_loc(" ++ a ++ "), at, rfc_seal(e, " ++ v ++ "));\n", a, "old", n), u =>
    NC_Code{"u32 at = blk_at(" ++ a ++ ", " ++ i ++ ", 0);\nterm_sink(e, blk_read(e.mem, 1, term_loc(" ++ a ++ "), at));\nblk_write(e.mem, 1, term_loc(" ++ a ++ "), at, rfc_seal(e, " ++ v ++ "));\n" ++ ne_ret([a]), Nil{}, n, ""})))))
