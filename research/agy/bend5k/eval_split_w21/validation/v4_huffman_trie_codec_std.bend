import Base
# v4_huffman_trie_codec (std): Binary Prefix-Code Trie builder & bitstream decoder
# Validation family 4: balanced depth-6 prefix trie (64 symbols), 45 rounds x 2048 words.

type Trie is Data:
  TLeaf{sym: U32}
  TNode{l: Trie, r: Trie}

type DecSt is Data:
  DSt{cur: Trie, plen: U32, h: U32, total: U32}

type RoundSt is Data:
  RSt{h: U32, total: U32, seed: U32}

def prng(+x: U32) -> U32:
  +b = U32.xor(x, U32.shln(x, 13n))
  +d = U32.xor(b, U32.shrn(b, 17n))
  U32.xor(d, U32.shln(d, 5n))

def build_balanced(+depth: Nat, +base_sym: U32, +salt: U32) -> Trie:
  match depth:
    case 0n:
      TLeaf{U32.and(U32.xor(base_sym, salt), 255)}
    case 1n+p:
      +half = U32.shln(1, p)
      TNode{build_balanced(p, base_sym, salt), build_balanced(p, U32.add(base_sym, half), salt)}

def check_leaf(+root: Trie, next: Trie, +nplen: U32, +h: U32, +total: U32) -> DecSt:
  match next:
    case TLeaf{+sym}:
      +nh = U32.xor(U32.xor(U32.mul(h, 16777619), sym), U32.shln(nplen, 8n))
      DSt{root, 0, nh, U32.inc(total)}
    case TNode{l, r}:
      DSt{TNode{l, r}, nplen, h, total}

def choose_branch(is_one: Bool, l: Trie, r: Trie) -> Trie:
  match is_one:
    case True{}:
      r
    case False{}:
      l

def step_bit(+root: Trie, +bit: U32, st: DecSt) -> DecSt:
  DSt{cur, +plen, +h, +total} = st
  match cur:
    case TLeaf{+sym}:
      DSt{root, 0, h, total}
    case TNode{l, r}:
      next = choose_branch(U32.is_ne(bit, 0), l, r)
      check_leaf(root, next, U32.inc(plen), h, total)

def decode_bits(+rem: Nat, +bits: U32, +root: Trie, st: DecSt) -> DecSt:
  match rem:
    case 0n:
      st
    case 1n+p:
      decode_bits(p, U32.shrn(bits, 1n), root, step_bit(root, U32.and(bits, 1), st))

def decode_words(+rem: Nat, +seed: U32, +root: Trie, st: DecSt) -> RoundSt:
  match rem:
    case 0n:
      DSt{cur, +plen, +h, +total} = st
      RSt{U32.xor(U32.mul(h, 2654435761), plen), total, seed}
    case 1n+p:
      +ns = prng(seed)
      decode_words(p, ns, root, decode_bits(32n, ns, root, st))

def run_rounds(+rem: Nat, +rd: U32, rs: RoundSt) -> U32:
  match rem:
    case 0n:
      RSt{+h, +total, +seed} = rs
      U32.xor(h, U32.mul(total, 2654435761))
    case 1n+p:
      RSt{+h, +total, +seed} = rs
      +root = build_balanced(6n, rd, U32.mul(rd, 31))
      run_rounds(p, U32.inc(rd), decode_words(2048n, seed, root, DSt{root, 0, h, total}))

def main() -> U32:
  run_rounds(45n, 0, RSt{2166136261, 0, 246813579})
