import Base

# The public classifier remains unchanged. This export-local context always
# overwrites the reserved fact, including on proof failure. Definition output
# still uses the original selected list, never this analysis-only declaration.
@unsafe
def jd_host_native_proof(+book: List<&2,KDef>, +name: String) -> U32:
  +d = lookup(book, name)
  kc(U32, String.eq(dk(d), "ADT") && db(d) && U32.is_eq(da(d), 0) && U32.is_eq(dx(d), 0),
    u => kc(U32, U32.is_eq(jd_host_nat_status(book, [kt("ADT", name, 0, 0, Nil{})], Nil{}, 1024), 0), u => 1, u => 0),
    u => 0)

@unsafe
def jd_host_native_context(+book: List<&2,KDef>) -> List<&2,KDef>:
  +flags = U32.add(jd_host_native_proof(book, "U32"), U32.mul(2, jd_host_native_proof(book, "F32")))
  book_put(book, KDef{"$JD.Host.NativeWord", "JDHostNativeWord", flags, 0, atom("Absent"), atom("Absent"), Nil{}, False{}, False{}})

@unsafe
def jd_host_nat_known(+book: List<&2,KDef>, +ty: KTerm) -> U32:
  +fact = lookup(book, "$JD.Host.NativeWord")
  kc(U32, String.eq(dk(fact), "JDHostNativeWord") && U32.is_gt(da(fact), 0) && U32.is_le(da(fact), 3),
    u => jd_host_native_walk(book, [ty], Nil{}, 1024, da(fact)),
    u => jd_host_nat_status(book, [ty], Nil{}, 1024))

law jd_host_native_walk:
  for +book: List<&2,KDef>
  for +todo: List<&2,KTerm>
  for +seen: List<&2,String>
  for +fuel: U32
  for +flags: U32
  U32

@unsafe
def jd_host_native_leaf(+t: KTerm, +flags: U32) -> Bool:
  List.is_empty(&2,KTerm, ks(t)) &&
    ((String.eq(nm(t), "U32") && Bool.not(U32.is_eq(U32.and(flags, 1), 0))) ||
     (String.eq(nm(t), "F32") && Bool.not(U32.is_eq(U32.and(flags, 2), 0))))

@unsafe
def jd_host_native_on(+book: List<&2,KDef>, +t: KTerm, +rest: List<&2,KTerm>, +seen: List<&2,String>, +fuel: U32, +flags: U32) -> U32:
  kc(U32, String.eq(tg(t), "All"), u =>
    jd_host_native_walk(book, kc(List<&2,KTerm>, U32.is_eq(qt(t), 0),
      u => Con{j_app_type(t, atom("Absent")), rest}, u => Con{kid(t, 0), Con{j_app_type(t, atom("Absent")), rest}}), seen, fuel, flags), u =>
    kc(U32, String.eq(tg(t), "ADT"), u =>
      kc(U32, String.eq(nm(t), "Nat") && db(lookup(book, nm(t))), u => 1, u =>
        kc(U32, jd_host_native_leaf(t, flags), u => jd_host_native_walk(book, rest, seen, fuel, flags), u =>
          kc(U32, has_name(seen, term_key(t)), u => jd_host_native_walk(book, rest, seen, fuel, flags), u =>
            jd_host_native_walk(book, List.append(&2,KTerm,
              jd_host_ctor_types(book, dc(lookup(book, nm(t))), ks(t)), rest),
              Con{term_key(t), seen}, fuel, flags)))), u => jd_host_native_walk(book, rest, seen, fuel, flags)))

# Same finite worklist bound, now charged to the optimized graph. A proved native
# scalar is one leaf visit. Some formerly budget-refused graphs may complete;
# no positive/unknown proof can suppress a Nat conversion.
@unsafe
def jd_host_native_walk(book, todo, seen, fuel, flags):
  match todo:
    case Nil{}: 0
    case Con{t, rest}:
      kc(U32, U32.is_gt(fuel, 0),
        u => jd_host_native_on(book, wnf(book, t), rest, seen, U32.sub(fuel, 1), flags), u => 2)
