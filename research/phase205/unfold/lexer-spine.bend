import Base
# Lexer: a tokenizer over generated source text, the suite's String
# stress case. Bend's String is a cons list, one node per character,
# so the lexer walks a linked list where C walks bytes; that gap is
# the point, and the program is spelled the natural way anyway.
# 2^size lines fork as a balanced batch tree. Leaf i hashes its index
# into a seed and expands the template
# "i = ( n o i ) o ( n o i ) o ( n o i ) ;" into one line of source:
# i becomes an identifier of 1-8 random lowercase letters, n a number
# of 1-6 random decimal digits, o one of + - * /, and any other
# template character copies itself; placeholder k draws from an
# xorshift stream salted by the seed and k, so the tail of the line
# is built first and each expansion is consed in front of it. The
# lexer then walks the line character by character as a three-mode
# machine (between tokens, inside an identifier, inside a number) and
# folds every token into the line checksum in order, acc = acc *
# 2654435761 ^ (kind * 40503 + payload): an identifier is kind 1 with
# the FNV-1a hash of its letters, a number kind 2 with its decimal
# value (wrapping), an operator or punctuation character kind 3 with
# its code; spaces are skipped. Line checksums sum up the fork tree.
# A template or source character is classified by comparisons on its
# code (there is no match on a word); a helper decides on the class.
#
# Sizes: small size = 8n (expect 1822208108), big size = 23n (expect
# 2401049475); both verified against the C twin.

type Slot is Data:
  Id{}
  Nm{}
  Op{}
  Lit{}

type Cls is Data:
  Letter{}
  Digit{}
  Space{}
  Punct{}

type Mode is Data:
  Gap{}
  InId{h: U32}
  InNm{v: U32}

# xorshift: x ^= x<<13; x ^= x>>17; x ^= x<<5
def prng(+x: U32) -> U32:
  +b = U32.xor(x, U32.shln(x, 13n))
  +d = U32.xor(b, U32.shrn(b, 17n))
  U32.xor(d, U32.shln(d, 5n))

# line seed: hash of the line index
def seed(i: U32) -> U32:
  prng(((i + 1) * 2654435761 : U32))

# placeholder seed: the line seed salted by the template position
def salt(s: U32, k: U32) -> U32:
  prng(U32.xor(s, (k * 2654435761 : U32)))

# the operator: + - * / by the two low bits of the seed
def op.pick(b1: Bool, b0: Bool) -> Char:
  match b1 b0:
    case False{} False{}:
      '+'
    case False{} True{}:
      '-'
    case True{} False{}:
      '*'
    case True{} True{}:
      '/'

def op(+t: U32, rest: String) -> String:
  SCon{op.pick(U32.is_ne(U32.and(t, 2), 0), U32.is_ne(U32.and(t, 1), 0)), rest}

# an identifier: n random lowercase letters, one prng step each
def ident(n: Nat, t: U32, rest: String) -> String:
  match n:
    case 0n:
      rest
    case 1n+p:
      +u = prng(t)
      SCon{Chr{(97 + u % 26 : U32)}, ident(p, u, rest)}

# a number: n random decimal digits, one prng step each
def num(n: Nat, t: U32, rest: String) -> String:
  match n:
    case 0n:
      rest
    case 1n+p:
      +u = prng(t)
      SCon{Chr{(48 + u % 10 : U32)}, num(p, u, rest)}

# one placeholder in front of the rest of the line: an identifier of
# 1 + (t & 7) letters, a number of 1 + t % 6 digits, an operator, or
# the template character itself
def expand(sl: Slot, c: U32, +t: U32, rest: String) -> String:
  match sl:
    case Id{}:
      ident(U32.to_nat((1 + U32.and(t, 7) : U32)), t, rest)
    case Nm{}:
      num(U32.to_nat((1 + t % 6 : U32)), t, rest)
    case Op{}:
      op(t, rest)
    case Lit{}:
      SCon{Chr{c}, rest}

# the slot of a template character: i, n, o, or a literal
def slot.go(i: Bool, n: Bool, o: Bool) -> Slot:
  match i n o:
    case True{} _ _:
      Id{}
    case _ True{} _:
      Nm{}
    case _ _ True{}:
      Op{}
    case _ _ _:
      Lit{}

def slot(+c: U32) -> Slot:
  slot.go(U32.is_eq(c, 105), U32.is_eq(c, 110), U32.is_eq(c, 111))

# one template character, read twice: for its slot and as a literal
def gen.at(+c: U32, t: U32, rest: String) -> String:
  expand(slot(c), c, t, rest)

# the line: the template expanded character by character, placeholder
# k seeded by salt(s, k), each expansion consed onto the built tail
def gen(tpl: String, +s: U32, +k: U32) -> String:
  match tpl:
    case SNil{}:
      SNil{}
    case SCon{Chr{c}, u}:
      gen.at(c, salt(s, k), gen(u, s, (k + 1 : U32)))

def tpl() -> String:
  "i = ( n o i ) o ( n o i ) o ( n o i ) ;"

# the class of a source character
def cls.go(l: Bool, d: Bool, s: Bool) -> Cls:
  match l d s:
    case True{} _ _:
      Letter{}
    case _ True{} _:
      Digit{}
    case _ _ True{}:
      Space{}
    case _ _ _:
      Punct{}

def cls(+c: U32) -> Cls:
  cls.go(U32.is_le(97, c) && U32.is_le(c, 122),
    U32.is_le(48, c) && U32.is_le(c, 57), U32.is_eq(c, 32))

# one token into the line checksum
def mix(acc: U32, kind: U32, x: U32) -> U32:
  U32.xor((acc * 2654435761 : U32), (kind * 40503 + x : U32))

# FNV-1a: one letter into the identifier hash
def fnv(h: U32, c: U32) -> U32:
  (U32.xor(h, c) * 16777619 : U32)

# the machine: (mode, acc) steps over one classified character; a
# letter extends an identifier, a digit a number, and anything else
# closes the open token, then starts what the character begins
def step.at(m: Mode, k: Cls, c: U32, acc: U32) -> Mode & U32:
  match m k:
    case Gap{} Letter{}:
      (InId{fnv(2166136261, c)}, acc)
    case Gap{} Digit{}:
      (InNm{(c - 48 : U32)}, acc)
    case Gap{} Space{}:
      (Gap{}, acc)
    case Gap{} Punct{}:
      (Gap{}, mix(acc, 3, c))
    case InId{h} Letter{}:
      (InId{fnv(h, c)}, acc)
    case InId{h} Digit{}:
      (InNm{(c - 48 : U32)}, mix(acc, 1, h))
    case InId{h} Space{}:
      (Gap{}, mix(acc, 1, h))
    case InId{h} Punct{}:
      (Gap{}, mix(mix(acc, 1, h), 3, c))
    case InNm{v} Letter{}:
      (InId{fnv(2166136261, c)}, mix(acc, 2, v))
    case InNm{v} Digit{}:
      (InNm{(v * 10 + (c - 48) : U32)}, acc)
    case InNm{v} Space{}:
      (Gap{}, mix(acc, 2, v))
    case InNm{v} Punct{}:
      (Gap{}, mix(mix(acc, 2, v), 3, c))

def step(m: Mode, +c: U32, acc: U32) -> Mode & U32:
  step.at(m, cls(c), c, acc)

# end of line: close the open token
def flush(m: Mode, acc: U32) -> U32:
  match m:
    case Gap{}:
      acc
    case InId{h}:
      mix(acc, 1, h)
    case InNm{v}:
      mix(acc, 2, v)

# the lexer: one step per character, (mode, acc) riding as r
def lex(s: String, r: Mode & U32) -> U32:
  match s:
    case SNil{}:
      (m, acc) = r
      flush(m, acc)
    case SCon{Chr{c}, t}:
      (m, acc) = r
      lex(t, step(m, c, acc))

# one line: generate it, then lex it
def p205unfold_fn0(+s: U32, +k: U32) -> String:
  +p205unfold_v0 : U32 = salt(s, k)
  +p205unfold_v1 : U32 = (k + 1 : U32)
  +p205unfold_v2 : U32 = (p205unfold_v1 : U32)
  +p205unfold_v3 : U32 = salt(s, p205unfold_v2)
  +p205unfold_v4 : U32 = (p205unfold_v2 + 1 : U32)
  +p205unfold_v5 : U32 = (p205unfold_v4 : U32)
  +p205unfold_v6 : U32 = salt(s, p205unfold_v5)
  +p205unfold_v7 : U32 = (p205unfold_v5 + 1 : U32)
  +p205unfold_v8 : U32 = (p205unfold_v7 : U32)
  +p205unfold_v9 : U32 = salt(s, p205unfold_v8)
  +p205unfold_v10 : U32 = (p205unfold_v8 + 1 : U32)
  +p205unfold_v11 : U32 = (p205unfold_v10 : U32)
  +p205unfold_v12 : U32 = salt(s, p205unfold_v11)
  +p205unfold_v13 : U32 = (p205unfold_v11 + 1 : U32)
  +p205unfold_v14 : U32 = (p205unfold_v13 : U32)
  +p205unfold_v15 : U32 = salt(s, p205unfold_v14)
  +p205unfold_v16 : U32 = (p205unfold_v14 + 1 : U32)
  +p205unfold_v17 : U32 = (p205unfold_v16 : U32)
  +p205unfold_v18 : U32 = salt(s, p205unfold_v17)
  +p205unfold_v19 : U32 = (p205unfold_v17 + 1 : U32)
  +p205unfold_v20 : U32 = (p205unfold_v19 : U32)
  +p205unfold_v21 : U32 = salt(s, p205unfold_v20)
  +p205unfold_v22 : U32 = (p205unfold_v20 + 1 : U32)
  +p205unfold_v23 : U32 = (p205unfold_v22 : U32)
  +p205unfold_v24 : U32 = salt(s, p205unfold_v23)
  +p205unfold_v25 : U32 = (p205unfold_v23 + 1 : U32)
  +p205unfold_v26 : U32 = (p205unfold_v25 : U32)
  +p205unfold_v27 : U32 = salt(s, p205unfold_v26)
  +p205unfold_v28 : U32 = (p205unfold_v26 + 1 : U32)
  +p205unfold_v29 : U32 = (p205unfold_v28 : U32)
  +p205unfold_v30 : U32 = salt(s, p205unfold_v29)
  +p205unfold_v31 : U32 = (p205unfold_v29 + 1 : U32)
  +p205unfold_v32 : U32 = (p205unfold_v31 : U32)
  +p205unfold_v33 : U32 = salt(s, p205unfold_v32)
  +p205unfold_v34 : U32 = (p205unfold_v32 + 1 : U32)
  +p205unfold_v35 : U32 = (p205unfold_v34 : U32)
  +p205unfold_v36 : U32 = salt(s, p205unfold_v35)
  +p205unfold_v37 : U32 = (p205unfold_v35 + 1 : U32)
  +p205unfold_v38 : U32 = (p205unfold_v37 : U32)
  +p205unfold_v39 : U32 = salt(s, p205unfold_v38)
  +p205unfold_v40 : U32 = (p205unfold_v38 + 1 : U32)
  +p205unfold_v41 : U32 = (p205unfold_v40 : U32)
  +p205unfold_v42 : U32 = salt(s, p205unfold_v41)
  +p205unfold_v43 : U32 = (p205unfold_v41 + 1 : U32)
  +p205unfold_v44 : U32 = (p205unfold_v43 : U32)
  +p205unfold_v45 : U32 = salt(s, p205unfold_v44)
  +p205unfold_v46 : U32 = (p205unfold_v44 + 1 : U32)
  +p205unfold_v47 : U32 = (p205unfold_v46 : U32)
  +p205unfold_v48 : U32 = salt(s, p205unfold_v47)
  +p205unfold_v49 : U32 = (p205unfold_v47 + 1 : U32)
  +p205unfold_v50 : U32 = (p205unfold_v49 : U32)
  +p205unfold_v51 : U32 = salt(s, p205unfold_v50)
  +p205unfold_v52 : U32 = (p205unfold_v50 + 1 : U32)
  +p205unfold_v53 : U32 = (p205unfold_v52 : U32)
  +p205unfold_v54 : U32 = salt(s, p205unfold_v53)
  +p205unfold_v55 : U32 = (p205unfold_v53 + 1 : U32)
  +p205unfold_v56 : U32 = (p205unfold_v55 : U32)
  +p205unfold_v57 : U32 = salt(s, p205unfold_v56)
  +p205unfold_v58 : U32 = (p205unfold_v56 + 1 : U32)
  +p205unfold_v59 : U32 = (p205unfold_v58 : U32)
  +p205unfold_v60 : U32 = salt(s, p205unfold_v59)
  +p205unfold_v61 : U32 = (p205unfold_v59 + 1 : U32)
  +p205unfold_v62 : U32 = (p205unfold_v61 : U32)
  +p205unfold_v63 : U32 = salt(s, p205unfold_v62)
  +p205unfold_v64 : U32 = (p205unfold_v62 + 1 : U32)
  +p205unfold_v65 : U32 = (p205unfold_v64 : U32)
  +p205unfold_v66 : U32 = salt(s, p205unfold_v65)
  +p205unfold_v67 : U32 = (p205unfold_v65 + 1 : U32)
  +p205unfold_v68 : U32 = (p205unfold_v67 : U32)
  +p205unfold_v69 : U32 = salt(s, p205unfold_v68)
  +p205unfold_v70 : U32 = (p205unfold_v68 + 1 : U32)
  +p205unfold_v71 : U32 = (p205unfold_v70 : U32)
  +p205unfold_v72 : U32 = salt(s, p205unfold_v71)
  +p205unfold_v73 : U32 = (p205unfold_v71 + 1 : U32)
  +p205unfold_v74 : U32 = (p205unfold_v73 : U32)
  +p205unfold_v75 : U32 = salt(s, p205unfold_v74)
  +p205unfold_v76 : U32 = (p205unfold_v74 + 1 : U32)
  +p205unfold_v77 : U32 = (p205unfold_v76 : U32)
  +p205unfold_v78 : U32 = salt(s, p205unfold_v77)
  +p205unfold_v79 : U32 = (p205unfold_v77 + 1 : U32)
  +p205unfold_v80 : U32 = (p205unfold_v79 : U32)
  +p205unfold_v81 : U32 = salt(s, p205unfold_v80)
  +p205unfold_v82 : U32 = (p205unfold_v80 + 1 : U32)
  +p205unfold_v83 : U32 = (p205unfold_v82 : U32)
  +p205unfold_v84 : U32 = salt(s, p205unfold_v83)
  +p205unfold_v85 : U32 = (p205unfold_v83 + 1 : U32)
  +p205unfold_v86 : U32 = (p205unfold_v85 : U32)
  +p205unfold_v87 : U32 = salt(s, p205unfold_v86)
  +p205unfold_v88 : U32 = (p205unfold_v86 + 1 : U32)
  +p205unfold_v89 : U32 = (p205unfold_v88 : U32)
  +p205unfold_v90 : U32 = salt(s, p205unfold_v89)
  +p205unfold_v91 : U32 = (p205unfold_v89 + 1 : U32)
  +p205unfold_v92 : U32 = (p205unfold_v91 : U32)
  +p205unfold_v93 : U32 = salt(s, p205unfold_v92)
  +p205unfold_v94 : U32 = (p205unfold_v92 + 1 : U32)
  +p205unfold_v95 : U32 = (p205unfold_v94 : U32)
  +p205unfold_v96 : U32 = salt(s, p205unfold_v95)
  +p205unfold_v97 : U32 = (p205unfold_v95 + 1 : U32)
  +p205unfold_v98 : U32 = (p205unfold_v97 : U32)
  +p205unfold_v99 : U32 = salt(s, p205unfold_v98)
  +p205unfold_v100 : U32 = (p205unfold_v98 + 1 : U32)
  +p205unfold_v101 : U32 = (p205unfold_v100 : U32)
  +p205unfold_v102 : U32 = salt(s, p205unfold_v101)
  +p205unfold_v103 : U32 = (p205unfold_v101 + 1 : U32)
  +p205unfold_v104 : U32 = (p205unfold_v103 : U32)
  +p205unfold_v105 : U32 = salt(s, p205unfold_v104)
  +p205unfold_v106 : U32 = (p205unfold_v104 + 1 : U32)
  +p205unfold_v107 : U32 = (p205unfold_v106 : U32)
  +p205unfold_v108 : U32 = salt(s, p205unfold_v107)
  +p205unfold_v109 : U32 = (p205unfold_v107 + 1 : U32)
  +p205unfold_v110 : U32 = (p205unfold_v109 : U32)
  +p205unfold_v111 : U32 = salt(s, p205unfold_v110)
  +p205unfold_v112 : U32 = (p205unfold_v110 + 1 : U32)
  +p205unfold_v113 : U32 = (p205unfold_v112 : U32)
  +p205unfold_v114 : U32 = salt(s, p205unfold_v113)
  +p205unfold_v115 : U32 = (p205unfold_v113 + 1 : U32)
  +p205unfold_v117 : String = gen.at(59, p205unfold_v114, SNil{})
  +p205unfold_v118 : String = gen.at(32, p205unfold_v111, p205unfold_v117)
  +p205unfold_v119 : String = gen.at(41, p205unfold_v108, p205unfold_v118)
  +p205unfold_v120 : String = gen.at(32, p205unfold_v105, p205unfold_v119)
  +p205unfold_v121 : String = gen.at(105, p205unfold_v102, p205unfold_v120)
  +p205unfold_v122 : String = gen.at(32, p205unfold_v99, p205unfold_v121)
  +p205unfold_v123 : String = gen.at(111, p205unfold_v96, p205unfold_v122)
  +p205unfold_v124 : String = gen.at(32, p205unfold_v93, p205unfold_v123)
  +p205unfold_v125 : String = gen.at(110, p205unfold_v90, p205unfold_v124)
  +p205unfold_v126 : String = gen.at(32, p205unfold_v87, p205unfold_v125)
  +p205unfold_v127 : String = gen.at(40, p205unfold_v84, p205unfold_v126)
  +p205unfold_v128 : String = gen.at(32, p205unfold_v81, p205unfold_v127)
  +p205unfold_v129 : String = gen.at(111, p205unfold_v78, p205unfold_v128)
  +p205unfold_v130 : String = gen.at(32, p205unfold_v75, p205unfold_v129)
  +p205unfold_v131 : String = gen.at(41, p205unfold_v72, p205unfold_v130)
  +p205unfold_v132 : String = gen.at(32, p205unfold_v69, p205unfold_v131)
  +p205unfold_v133 : String = gen.at(105, p205unfold_v66, p205unfold_v132)
  +p205unfold_v134 : String = gen.at(32, p205unfold_v63, p205unfold_v133)
  +p205unfold_v135 : String = gen.at(111, p205unfold_v60, p205unfold_v134)
  +p205unfold_v136 : String = gen.at(32, p205unfold_v57, p205unfold_v135)
  +p205unfold_v137 : String = gen.at(110, p205unfold_v54, p205unfold_v136)
  +p205unfold_v138 : String = gen.at(32, p205unfold_v51, p205unfold_v137)
  +p205unfold_v139 : String = gen.at(40, p205unfold_v48, p205unfold_v138)
  +p205unfold_v140 : String = gen.at(32, p205unfold_v45, p205unfold_v139)
  +p205unfold_v141 : String = gen.at(111, p205unfold_v42, p205unfold_v140)
  +p205unfold_v142 : String = gen.at(32, p205unfold_v39, p205unfold_v141)
  +p205unfold_v143 : String = gen.at(41, p205unfold_v36, p205unfold_v142)
  +p205unfold_v144 : String = gen.at(32, p205unfold_v33, p205unfold_v143)
  +p205unfold_v145 : String = gen.at(105, p205unfold_v30, p205unfold_v144)
  +p205unfold_v146 : String = gen.at(32, p205unfold_v27, p205unfold_v145)
  +p205unfold_v147 : String = gen.at(111, p205unfold_v24, p205unfold_v146)
  +p205unfold_v148 : String = gen.at(32, p205unfold_v21, p205unfold_v147)
  +p205unfold_v149 : String = gen.at(110, p205unfold_v18, p205unfold_v148)
  +p205unfold_v150 : String = gen.at(32, p205unfold_v15, p205unfold_v149)
  +p205unfold_v151 : String = gen.at(40, p205unfold_v12, p205unfold_v150)
  +p205unfold_v152 : String = gen.at(32, p205unfold_v9, p205unfold_v151)
  +p205unfold_v153 : String = gen.at(61, p205unfold_v6, p205unfold_v152)
  +p205unfold_v154 : String = gen.at(32, p205unfold_v3, p205unfold_v153)
  +p205unfold_v155 : String = gen.at(105, p205unfold_v0, p205unfold_v154)
  p205unfold_v155

def line(i: U32) -> U32:
  lex(p205unfold_fn0(seed(i), 0), (Gap{}, 0))

# batch tree over the line index space; line checksums sum
def batch(+d: Nat, +i: U32) -> U32:
  match d:
    case 0n:
      line(i)
    case 1n+p:
      a b = batch(p, i) batch(p, (i + U32.shln(1, p) : U32))
      (a + b : U32)

def size.small() -> Nat:
  8n

def expect.small() -> U32:
  1822208108

def size.big() -> Nat:
  23n

def expect.big() -> U32:
  2401049475

def p88_original_main() -> IO(Unit):
  IO.print(U32.show(batch!(size.big(), 0)))

# Phase28: original source above is unchanged; dynamic documented-small input.
def bench(size: U32, seed: U32) -> U32:
  batch(U32.to_nat(size), seed)

# Phase93: fixed catalog inputs, repeated complete-result validation.
# Final four argv words: repetitions warmups arg0 arg1.
# The measured interval includes result validation and success-count printing.
def p93.parsed(value: Maybe<&2, Nat>, fallback: Nat) -> Nat:
  match value:
    case None{}:
      fallback
    case Some{n}:
      n

def p93.number(text: String, fallback: Nat) -> Nat:
  p93.parsed(Nat.read(text), fallback)

def p93.word_parsed(value: Maybe<&2, U32>, fallback: U32) -> U32:
  match value:
    case None{}:
      fallback
    case Some{n}:
      n

def p93.word(text: String, fallback: U32) -> U32:
  p93.word_parsed(U32.read(text), fallback)

def p93.arguments(args: List<String>) -> (Nat & Nat) & (U32 & U32):
  match args:
    case repetitions <> warmups <> first <> second <> Nil{}:
      ((p93.number(repetitions, 8n), p93.number(warmups, 2n)), (p93.word(first, 8), p93.word(second, 0)))
    case head <> rest:
      p93.arguments(rest)
    case Nil{}:
      ((8n, 2n), (8, 0))

def p93.value(a: U32, b: U32) -> U32:
  bench(a, b)

def p93.loop(n: Nat, +a: U32, +b: U32, h: U32) -> U32:
  match n:
    case 0n:
      h
    case 1n+p:
      value = p93.value(a, b)
      valid = U32.is_eq(value, 1822208108)
      p93.loop(p, a, b, U32.add(h, Bool.to_u32(valid)))

def p93.execute(repetitions: Nat, warmups: Nat, +a: U32, +b: U32) -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(U32.show(p93.value(a, b)))
    Unit <- IO.print(U32.show(p93.loop(warmups, a, b, 0)))
    t0 : Nat <- IO.now()
    Unit <- IO.print(U32.show(p93.loop(repetitions, a, b, 0)))
    t1 : Nat <- IO.now()
    IO.print(Nat.show(Nat.sub(t1, t0)))

def p93.run(options: (Nat & Nat) & (U32 & U32)) -> IO(Unit):
  (counts, arguments) = options
  (repetitions, warmups) = counts
  (a, b) = arguments
  p93.execute(repetitions, warmups, a, b)

def main() -> IO(Unit):
  do IO<Unit>:
    args : List<String> <- IO.args()
    p93.run(p93.arguments(args))
