# Optional exact pure-gap extension; all original frame/target gates remain.
@unsafe
def p112c_try_frame(frame: Maybe<&2,P112FusionFrame>, +index: P112FusionIndex, +ready: KDef, +site: U32, +buffer: String) -> Maybe<&2,List<&2,N111Stmt>>:
  match frame:
    case None{}: None{}
    case Some{+value}:
      match value:
        case P112FusionFrame{+captures,+name,+dest,+tail}: p112g_finish(value,index,ready,site,buffer,p112g_split(tail,0,[]))
