# BST matched-set representation/control proposal (read-only)

Runtime native Sigma is a dense JavaScript pair array. `ctor('Tuple',[l,r])`
returns its fresh input array unchanged; generic Tuple construction with more
than two fields recursively nests the tail. `fields('Tuple',x)` requires
Array.isArray(x) after the fail-stop request check, whereas `project('Tuple',x)`
returns a new `[x[0],x[1]]` field vector. A proved private matcher can bind `x[0]`
and `x[1]` directly only when every value comes from a full guarded scalar root.
A List is NOT an array: Nil/Con remain `{$:tag,a:[element,tail]}`. Existing .$/ .a
private List emission therefore works for a newly admitted closed element type.

The current List ground predicate deliberately specializes to List<&2,U32>.
Changing it globally would widen list algorithm admission and is not proposed.
Existing local Sigma header/vector predicates recognize native owner identity,
but local field traversal cannot admit BST/List<BFrame> together; JPure likewise
refuses Sigma and List<BFrame>. This is a whole typed-graph admission boundary,
not a missing native runtime operation.

Facts owner supplies strict `j_pure_closed_sigma(book,ty)` and
`j_pure_closed_list(book,ty)` in the logically closed JPure source-type domain.
The earlier explicit-mode proposal is superseded: independent review found no
ownership counterexample because existing complete scalar-root guards dominate
all private component/helper calls. Public ADT inputs still retain generic
matching. Component/finite/direct admission can use those exact closed
predicates; grounded-U32 List algorithm selection stays unchanged.

The smallest representation addition is an owned Tuple emission arm. Exact
native Sigma owner/constructor identity, arity2, two nonerased fields and complete
source branch coverage establish that the only constructor is Tuple. Emit a
plain lexical block for its first arm with direct array slots; no tag test,
Array.isArray, project/fields helper or .a access is needed. Every field keeps
its original specialized type and binder identity. Default lambdas still bind
the whole pair. A dependent second type is refused in the first scope.

Constructor emission can initially retain `ctor('Tuple',[...])`: it already
creates the exact fresh pair representation. Optional owned direct pair emission
uses `[left,right]` with existing j_ctor_args sequence; it must never flatten
nested Sigma or drop an erased null slot. Native List constructors can initially
retain ctor as well, while their private fields are directly positional. This
separates admission/match savings from constructor call savings.

Structural obligations are unchanged: self calls need a proved proper child or
Nat predecessor, closed helper graphs exclude mutual backedges, and original
App shells containing the structural self call must remain discoverable before
private helper rewriting. BST down/build are self-tail loops; bst.up consumes
proper List tail. Inorder's sequential inner/outer calls require the separate
facts-owner continuation proposal. No native depth cap is a substitute.

Public pairs, List/ADT arguments, foreign conversion and generic matcher paths
remain on fields/project/force. Owned code cannot admit external array getters,
proxy arrays, replaced globals/prototypes or a function-valued/unsaturated
escape. The full original root graph must be proved and exact-guarded before any
native private field access. A missing type/callee rejects the entire new graph.

The actual normalized probe supersedes quantity assumptions: BST Sigma has
Qua1/Qua1 and List<BFrame> has Qua2. Both Sigma fields are nonerased; the first
matched-set scope should use those exact original normalized quantities. Down
already passes structural prefix, while step/insert.fin need the Tuple arm.
Up has two syntactic self calls in mutually exclusive Bool branches, each leaf
is one self-tail transfer. No mutual SCC was found.

The current build does not pass structural prefix: its sequential computed U32
Let is not an inert alias. Opening a proof alone also cannot rewrite the global
generic build body's ordinary call sites. First scope must preserve this residual
or add separately proved graph-local residual lowering. A narrower prospective
extension allows a computed pure scalar Let only when its ultimate continuation
is a direct structural self-tail call. It creates no frame and cannot replay the
RHS on resume. Broadening the current linear alias predicate for reconstructing
continuations would repeat that computation on phase3 and is unsafe without
saved-value/source-order proof. Inorder sequential recursion remains separate.
