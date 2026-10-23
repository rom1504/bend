@unsafe
def p128bl_test_error(graph: P128BLGraph) -> String:
  match graph:
    case P128BLGraph{types,specs,error}: error

@unsafe
def p128bl_controls() -> List<&2,String>:
  +strings = kt("ADT","List",0,0,[ref("String")])
  +words = kt("ADT","List",0,0,[ref("U32")])
  [p128bs_control_row("layout-single-recursive-child",p128bl_recursive(strings,[kt("ADT","String",0,0,[]),strings],0)),
   p128bs_control_row("layout-two-recursive-children-refused",Bool.not(p128bl_recursive(strings,[strings,strings],0))),
   p128bs_control_row("layout-changed-instantiation-refused",Bool.not(p128bl_recursive(strings,[words],0))),
   p128bs_control_row("layout-no-recursive-child-refused",Bool.not(p128bl_recursive(strings,[kt("ADT","String",0,0,[])],0))),
   p128bs_control_row("layout-instance-conflict-refused",Bool.not(String.is_empty(p128bl_test_error(p128bl_seen([],words,[],[strings],[],8,strings))))),
   p128bs_control_row("layout-identical-instance-reused",String.is_empty(p128bl_test_error(p128bl_seen([],strings,[],[strings],[],8,strings)))),
   p128bs_control_row("layout-budget-refused",Bool.not(String.is_empty(p128bl_test_error(p128bl_graph([],[strings],[],[],0)))))]
