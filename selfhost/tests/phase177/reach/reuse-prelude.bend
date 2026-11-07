law p177rr_walk:
  for +book: List<&2,KDef>
  for todo: List<&2,String>
  for +members: KDef
  for +stops: List<&2,String>
  KDef

law p177rr_name:
  for +book: List<&2,KDef>
  for +todo: List<&2,String>
  for +members: KDef
  for +stops: List<&2,String>
  for +name: String
  for +hash: U32
  KDef

law p177rr_def:
  for +book: List<&2,KDef>
  for +todo: List<&2,String>
  for +members: KDef
  for +stops: List<&2,String>
  for +definition: KDef
  KDef

law p177rr_filter:
  for book: List<&2,KDef>
  for +members: KDef
  List<&2,KDef>

law p177rr_reach:
  for +book: List<&2,KDef>
  for roots: List<&2,String>
  for +stops: List<&2,String>
  List<&2,KDef>
