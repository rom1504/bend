# Same immutable absence sentinel as selected Phase130 missing(). Exposing the
# complete closed constructor tree before static preparation is the experiment;
# no new pooling mechanism or runtime representation is introduced.
@unsafe
def missing() -> KDef:
  KDef{"", "Absent", 0, 0,
    KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0},
    KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0},
    Nil{}, False{}, False{}}
