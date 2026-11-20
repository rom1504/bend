"""Local code-generation alternatives on frozen profiled assembly.

Each edit specifies a half-open instruction range in a sampled straight-line
block. Full before/after projections and input hashes are frozen before timing.
"""
from dataclasses import dataclass


@dataclass(frozen=True)
class Candidate:
    name: str
    case: str
    line: int
    edits: tuple
    legality: str


TREE = 'tree-bitonic'
BST = 'coverage-bst-64'
RAY = 'variation-ray-active-64-2440'
CANDIDATES = [
    Candidate('tree-pop', TREE, 13037, ((4,5,()), (6,7,()), (8,9,())),
              'The private stack-pointer word has just been published. Loads into other registers cannot change it or its register copy.'),
    Candidate('tree-frame', TREE, 13399, tuple((n,n+1,()) for n in (9,12,22,38,41)),
              'Each removed LEA repeats the current r10 value. Intervening stores read r10 as an address.'),
    Candidate('tree-bool', TREE, 3722, ((19,27,('testl %eax, %eax','setne %r11b','movzbl %r11b, %r11d','movq %r11, %rdi')),),
              'Both sequences leave r11 and rdi equal to the nonzero predicate. The following XOR and TEST define live flags and overwrite r10.'),
    Candidate('bst-decrement', BST, 4012, ((0,2,('leaq -1(%rdi), %r10',)),),
              'LEA produces the same modular 64-bit decrement. SHR, AND and final CMP overwrite flags before use.'),
    Candidate('bst-literal', BST, 4012, ((6,7,('movl $164, %r11d',)),),
              'A 32-bit register write zero extends exactly this unsigned literal; flags preserved.'),
    Candidate('bst-frame', BST, 4220, ((3,4,()), (5,6,())),
              'The two LEAs repeat the established address; the intervening loads write r13 and rdx only.'),
    Candidate('edit-increment', 'editdist', 7273, ((3,6,('leal 1(%rdi), %r10d',)),),
              'The 32-bit modular index is zero extended. Both rsi and arithmetic flags are redefined before use.'),
    Candidate('edit-predicate', 'editdist', 7273, ((11,20,('cmpl %r8d, %r14d','setne %r10b','movzbl %r10b, %r10d')),),
              'The compared operands are zero-extended U32s (r8 came from MOVL). SETNE produces the same full-word boolean; scratch values and flags die locally.'),
    Candidate('edit-minima', 'editdist', 7273, (
        (33,47,('leal 1(%r8), %r8d','movq -2808(%rbp), %rsi','addl $1, %esi','movq %rsi, -2832(%rbp)','cmpq %rsi, %r8','cmovaeq %rsi, %r8')),
        (54,60,('cmpq %rsi, %r8','movq %rsi, %r11','cmovbq %r8, %r11'))),
        'Select the same unsigned minima, including ties. Preserve frame stores; old scratch/copy values are overwritten before use.'),
    Candidate('ray-zero', RAY, 4987, ((53,60,('movl $0, %r10d','pxor %xmm0, %xmm0','pxor %xmm2, %xmm2')),),
              'Converting integer zero produces exact positive float zero under all rounding modes. These assignments restore all live registers and SSE upper lanes.'),
    Candidate('ray-copies', RAY, 4987, tuple((n,n+1,()) for n in (26,39,42,48)),
              'Eliminate register round trips. No intervening definition of each copied value reaches a use before the next write. Scalar evaluation order is preserved.'),
    Candidate('ray-memory', RAY, 4987, (
        (1,4,('movd %r15d, %xmm2','subss -2448(%rbp), %xmm2')),
        (5,8,('movd -72(%rbp), %xmm2','subss -2456(%rbp), %xmm2')),
        (9,12,('movd -80(%rbp), %xmm2','subss -2464(%rbp), %xmm2')),
        (13,16,('movaps %xmm3, %xmm2','mulss -88(%rbp), %xmm2')),
        (17,20,('movaps %xmm4, %xmm2','mulss -96(%rbp), %xmm2')),
        (23,26,('movaps %xmm5, %xmm6','mulss -104(%rbp), %xmm6'))),
        'Memory operands read the same valid 32-bit private stack slots. FP operation order and destination upper lanes are retained; xmm1 is overwritten before its next live read.'),
    Candidate('lexer-pop', 'lexer', 12940, ((5,6,()),),
              'rdi already contains the just-stored private stack pointer.'),
    Candidate('lexer-captures', 'lexer', 12996, ((4,6,('movq %rdi, %r10',)), (9,11,('movq %rdi, %r10',))),
              'Reuse the just-published SP across private frame spills. Neither state nor rdi is modified.'),
    Candidate('lexer-immediate', 'lexer', 12940, ((2,4,('addq $-8, %rdi',)),),
              'ADD operates on identical bits and sets identical flags; the displaced r11 constant is overwritten in this block.'),
]


def transform(candidate, before):
    after = before.copy()
    for start,end,lines in reversed(candidate.edits):
        assert 0 <= start < end <= len(before)
        after[start:end] = lines
    return after
