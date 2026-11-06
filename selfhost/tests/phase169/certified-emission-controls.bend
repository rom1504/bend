# Finite renderer/namespace boundaries. Real source authority is exercised by
# complete checked requests; no fixture certificate is accepted by native entry.
@unsafe
def p169ac_original() -> P111Program:
  P111Program{[p169svc_generic()],[],[0],[],[],True{}}

@unsafe
def p169ac_worker(word: String) -> P113DFunction:
  P113DFunction{"helper",[NC_Binding{0,word,N_W64{}}],1,False{},[P113DResult{[N111Const{7,0}]}]}

@unsafe
def p169ac_namespace(word: String, certificate: P113ACertificate, expected: String) -> Bool:
  String.eq(p169a_namespace(p169ac_original(),[],[p169ac_worker(word)],certificate),expected)

@unsafe
def p169ac_unchanged(+functions: List<&2,P113DFunction>, arrays: Bool) -> Bool:
  +original = p169ac_original()
  p169svc_emissions(p169s_collect(p169a_seeded(original,[],functions,False{},arrays)),
    p169s_collect(p169s_seeded(original,[],functions,False{})),True{})

@unsafe
def p169a_controls() -> List<&2,String>:
  [p167c_row("mode2-certificate-neither",Bool.not(p113a_enabled(P113ACertificate{False{},False{}}))),
   p167c_row("mode2-certificate-scalar-only",Bool.not(p113a_enabled(P113ACertificate{True{},False{}}))),
   p167c_row("mode2-certificate-unshared-only",Bool.not(p113a_enabled(P113ACertificate{False{},True{}}))),
   p167c_row("mode2-certificate-both",p113a_enabled(P113ACertificate{True{},True{}})),
   p167c_row("mode2-clean-namespace",p169ac_namespace("value",P113ACertificate{True{},True{}},"")),
   p167c_row("mode2-array-namespace-refused",p169ac_namespace("p113a_reserved",P113ACertificate{True{},True{}},
     "reserved private array-template local")),
   p167c_row("mode2-transport-namespace-refused",p169ac_namespace("p114t_reserved",P113ACertificate{True{},True{}},
     "reserved transport-template local")),
   p167c_row("mode2-array-namespace-only-when-enabled",p169ac_namespace("p113a_reserved",P113ACertificate{False{},False{}},"")),
   p167c_row("mode2-empty-keeps-old-output",p169ac_unchanged([],True{})),
   p167c_row("mode2-disabled-keeps-old-output",p169ac_unchanged([p169ac_worker("value")],False{}))]
