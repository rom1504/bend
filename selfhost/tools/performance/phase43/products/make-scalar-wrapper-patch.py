"""Allow only acyclic scalar-first/data-result wrappers around admitted recursion."""
from pathlib import Path
import difflib
root=Path(__file__).resolve().parents[5]
p=root/'selfhost/src/back/js/tree.bend';s=p.read_text()
old='''      (j_primitive_type(book, wnf(book, kid(head, 0)), "Nat") && j_nat_loop_native(book) &&
        Bool.not(j_region_scalar(book, j_fold_root_result(book, dt(d), da(d))))), u =>'''
new='''      (j_primitive_type(book, wnf(book, kid(head, 0)), "Nat") && j_nat_loop_native(book) &&
        Bool.not(j_region_scalar(book, j_fold_root_result(book, dt(d), da(d))))) ||
      (j_component_scalar_wrapper_arg(book, wnf(book, kid(head, 0))) &&
        U32.is_eq(j_component_refs([dv(d)], dn(d), 1024, 0), 0) &&
        Bool.not(j_region_scalar(book, j_fold_root_result(book, dt(d), da(d))))), u =>'''
assert s.count(old)==1
newsource=s.replace(old,new)
old='''      j_primitive_type(book, wnf(book, kid(wnf(book, dt(d)), 0)), "Nat")))'''
new='''      j_primitive_type(book, wnf(book, kid(wnf(book, dt(d)), 0)), "Nat") ||
      j_component_scalar_wrapper_arg(book, wnf(book, kid(wnf(book, dt(d)), 0)))))'''
assert newsource.count(old)==1
newsource=newsource.replace(old,new)
needle='@unsafe\ndef j_component_wrapper_arg('
helper='''# Acyclic data wrappers only: recursive scalar-first loops and scalar results
# retain their existing scalar island selection. Nat keeps its stronger ABI gate.
@unsafe
def j_component_scalar_wrapper_arg(+book: List<&2,KDef>, +arg: KTerm) -> Bool:
  j_primitive_type(book, arg, "U32") || j_primitive_type(book, arg, "Bool") || j_primitive_type(book, arg, "F32")

'''
assert newsource.count(needle)==1
newsource=newsource.replace(needle,helper+needle)
out=Path(__file__).with_name('scalar-wrapper.patch')
out.write_text(''.join(difflib.unified_diff(s.splitlines(True),newsource.splitlines(True),fromfile='a/selfhost/src/back/js/tree.bend',tofile='b/selfhost/src/back/js/tree.bend')))
print(out)
