# Finite predicate controls, not authentication of fabricated checked books.
# Actual source/runtime identities remain obligations of the public QBE entry.
@unsafe
def p173opc_def(name: String, body: KTerm, trusted: Bool) -> KDef:
  KDef{name,"Def",0,0,kt("Absent","",0,0,[]),body,[],trusted,False{}}

@unsafe
def p173opc_foreign(name: String, trusted: Bool, filled: Bool) -> KDef:
  p173opc_def(name,kt(nt_choose(String,filled,u => "Foreign",u => "Absent"),"",0,0,[]),trusted)

@unsafe
def p173opc_one(+definition: KDef) -> Bool:
  p173op_permission([definition],[definition],[dn(definition)])

@unsafe
def p173op_controls() -> List<&2,String>:
  +ordinary = p173opc_def("ordinary",kt("NWord","3",0,0,[]),False{})
  +allowed = p173opc_foreign("IO.print",True{},True{})
  +unknown = p173opc_foreign("Custom.observe",True{},True{})
  [p173odc_row("permission-empty",p173op_permission([],[],[])),
   p173odc_row("permission-ordinary",p173opc_one(ordinary)),
   p173odc_row("permission-rewrite-refused",Bool.not(p173opc_one(
     p173opc_def("rewrite",kt("Rwt","",0,0,[]),False{})))),
   p173odc_row("permission-missing-refused",Bool.not(p173op_permission([],[],["missing"]))),
   p173odc_row("permission-print",p173opc_one(allowed)),
   p173odc_row("permission-now",p173opc_one(p173opc_foreign("IO.now",True{},True{}))),
   p173odc_row("permission-file-read",p173opc_one(p173opc_foreign("File.read",True{},True{}))),
   p173odc_row("permission-file-write",p173opc_one(p173opc_foreign("File.write",True{},True{}))),
   p173odc_row("permission-untrusted-file-refused",Bool.not(p173opc_one(p173opc_foreign("File.read",False{},True{})))),
   p173odc_row("permission-unfilled-file-refused",Bool.not(p173opc_one(p173opc_foreign("File.read",True{},False{})))),
   p173odc_row("permission-unknown-provider-refused",Bool.not(p173opc_one(unknown))),
   p173odc_row("permission-nativehost-old-certificate-refused",Bool.not(p173opc_one(p173opc_foreign("NativeHost.read",True{},True{})))),
   p173odc_row("permission-byte-file-old-certificate-refused",Bool.not(p173opc_one(p173opc_foreign("File.read_bytes",True{},True{})))),
   p173odc_row("permission-annotated-foreign",p173opc_one(p173opc_def("IO.print",kt("Ann","",0,0,[kt("Foreign","",0,0,[]),kt("Absent","",0,0,[])]),True{}))),
   p173odc_row("permission-unreachable-provider-ignored",p173op_permission([allowed,unknown],[allowed,unknown],["IO.print"])),
   p173odc_row("permission-source-provider-not-hidden",Bool.not(p173op_permission([unknown],[p173opc_def("Custom.observe",kt("NWord","3",0,0,[]),False{})],["Custom.observe"]))) ]
