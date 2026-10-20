# Optional overlays only. This profile requires the stable context/heap-base
# runtime admission; it is independently measured from identity preservation.
@unsafe
def p113a_address(+n: U32) -> List<&2,N111Stmt>:
  nt_append(N111Stmt,p113a_class(n),[
    N111Set{p113a_name(n,"heap"),N111Ptr{},N111Local{"p113a_heap_base"}},
    N111Bin{p113a_name(n,"mask"),N111U64{},"sub",p113a_value(n,"size"),N111Const{1,0}},
    N111Bin{p113a_name(n,"index"),N111U64{},"and",p113a_value(n,"index"),N111Const{4294967295,0}},
    N111Bin{p113a_name(n,"index"),N111U64{},"and",p113a_value(n,"index"),p113a_value(n,"mask")},
    N111Bin{p113a_name(n,"location"),N111U64{},"and",p113a_value(n,"array"),N111Const{4294967295,255}},
    N111Bin{p113a_name(n,"location"),N111U64{},"add",p113a_value(n,"location"),p113a_value(n,"index")},
    N111Bin{p113a_name(n,"bytes"),N111U64{},"shl",p113a_value(n,"location"),N111Const{3,0}},
    N111Offset{p113a_name(n,"cell"),p113a_value(n,"heap"),p113a_value(n,"bytes")},
    N111Load{p113a_name(n,"old"),N111U64{},p113a_value(n,"cell"),0}])

@unsafe
def p113a_registered(+segments: List<&2,N111Segment>, +functions: List<&2,P113DFunction>,
    +index: P112FusionIndex, +ids: N111Ids, +heap_min: U32, registry: P112RegionRegistry) -> List<&2,String>:
  match registry:
    case P112RegionRegistry{ready,symbols,entries,workers,fusions}:
      +direct = p113e_signatures(functions,missing())
      nt_append(String,p113ah_private_chunks(functions,ids,heap_min,[]),
        p112c_attach(p113e_public_chunks(segments,direct,index,ids,ready,[]),
          nt_join(p113e_old_private_chunks(entries,direct,ids,[]),"")))
