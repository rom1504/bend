# Full-manifest control: exercise actual child lowering and fresh/error threading.
# Synthetic compiler-owned erased core, not a user-program conformance suite.
import Base

type P89Code is Data:
  P89Code{+body: String, +segments: List<&2, N_Segment>, +fresh: U32, +error: String, +calls: List<&2, String>}

@unsafe
def p89_materialize(+code: NC_Code) -> P89Code:
  P89Code{nc_body(code), nc_segs(code), nc_fresh(code), nc_error(code), nc_calls(code)}

type P89LowerCase is Data:
  P89LowerCase{+name: String, +code: P89Code}

@unsafe
def p89_lam(id: U32, body: KTerm) -> KTerm:
  kt("Lam", "x", id, 1, [body])

@unsafe
def p89_word(name: String) -> KTerm:
  kt("NWord", name, 0, 0, Nil{})

@unsafe
def p89_fields(+count: U32, +body: KTerm) -> KTerm:
  nt_choose(KTerm, U32.is_eq(count, 0), u => body,
    u => p89_lam(U32.add(1000, count), p89_fields(U32.sub(count, 1), body)))

@unsafe
def p89_lower(name: String, ctor: String, +count: U32, hit: KTerm, miss: KTerm, target: NC_Target) -> P89LowerCase:
  P89LowerCase{name, p89_materialize(nc_match_apply_slow_to(Nil{},
    kt("NMatch", "", 0, 0, [kt("Mat", ctor, U32.inc(count), 0, [p89_fields(count, hit), p89_lam(71, miss)]), var("scrutinee", 70)]),
    [NC_Binding{70, "scrutinee", N_Box{}}], 100, target))}

@unsafe
def main() -> List<&2, P89LowerCase>:
  +scheduler: NC_Target = NC_Scheduler{}
  +flat: NC_Target = NC_Destination{["result"], atom("Absent"), "join", "owner", Nil{}, False{}, Nil{}}
  [p89_lower("scalar", "True", 0, p89_word("7"), p89_word("9"), scheduler),
   p89_lower("field-count", "Box", 2, p89_word("7"), p89_word("9"), scheduler),
   p89_lower("hit-error", "True", 0, atom("HitUnsupported"), p89_word("9"), scheduler),
   p89_lower("miss-error", "True", 0, p89_word("7"), atom("MissUnsupported"), scheduler),
   p89_lower("both-errors", "True", 0, atom("HitUnsupported"), atom("MissUnsupported"), scheduler),
   p89_lower("hit-closure", "True", 0, p89_lam(81, var("x", 81)), p89_word("9"), scheduler),
   p89_lower("both-closures", "True", 0, p89_lam(81, var("x", 81)), p89_lam(82, var("x", 82)), scheduler),
   p89_lower("flat-scalar", "True", 0, p89_word("7"), p89_word("9"), flat),
   p89_lower("flat-closure-refusal", "True", 0, p89_lam(81, var("x", 81)), p89_word("9"), flat)]
