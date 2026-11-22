import Base

def random_word(+s: U32) -> U32:
  +x = U32.xor(s,U32.shln(s,13n))
  +y = U32.xor(x,U32.shrn(x,17n))
  U32.xor(y,U32.shln(y,5n))

type Masks is Data:
  Masks4{a: U32,b: U32,c: U32,d: U32}

def add_bit(idx: Nat,bit: U32,m: Masks) -> Masks:
  match idx m:
    case 0n Masks4{a,b,c,d}: Masks4{U32.or(a,bit),b,c,d}
    case 1n+0n Masks4{a,b,c,d}: Masks4{a,U32.or(b,bit),c,d}
    case 1n+1n+0n Masks4{a,b,c,d}: Masks4{a,b,U32.or(c,bit),d}
    case 1n+1n+1n+p Masks4{a,b,c,d}: Masks4{a,b,c,U32.or(d,bit)}

def build_masks(left: Nat,seed: U32,+bit: U32,m: Masks) -> U32 & Masks:
  match left:
    case 0n: (seed,m)
    case 1n+p:
      +s = random_word(seed)
      build_masks(p,s,U32.shl(bit),add_bit(U32.to_nat(U32.and(s,3)),bit,m))

def symbol(idx: Nat,m: Masks) -> U32:
  match idx m:
    case 0n Masks4{a,b,c,d}: a
    case 1n+0n Masks4{a,b,c,d}: b
    case 1n+1n+0n Masks4{a,b,c,d}: c
    case 1n+1n+1n+p Masks4{a,b,c,d}: d

def columns(left: Nat,+j: U32,seed: U32,+m: Masks,+pv: U32,+mv: U32,score: U32,r: Array<U32> & U32) -> Array<U32> & U32:
  match left r:
    case 0n Tuple{arr,unused}: (arr,score)
    case 1n+p Tuple{arr,+hin}:
      +s = random_word(seed)
      +eq = symbol(U32.to_nat(U32.and(s,3)),m)
      +xv = U32.or(eq,mv)
      +neg = Bool.to_u32(U32.is_eq(hin,0))
      +e = U32.or(eq,neg)
      +xh = U32.or(U32.xor(U32.add(U32.and(e,pv),pv),pv),e)
      +ph = U32.or(mv,U32.not(U32.or(xh,pv)))
      +mh = U32.and(pv,xh)
      +diff = U32.sub(U32.shrn(ph,31n),U32.shrn(mh,31n))
      +hp = U32.or(U32.shl(ph),Bool.to_u32(U32.is_eq(hin,2)))
      hm = U32.or(U32.shl(mh),neg)
      arr2 = Array.set(U32,arr,j,U32.inc(diff))
      +next = U32.and(U32.inc(j),255)
      columns(p,next,s,m,U32.or(hm,U32.not(U32.or(xv,hp))),U32.and(hp,xv),U32.add(score,diff),Array.get_unchecked(U32,arr2,next))

def stripe(start: U32,text: U32,m: Masks,a: Array<U32>) -> Array<U32> & U32:
  columns(256n,0,text,m,4294967295,0,start,Array.get_unchecked(U32,a,0))

def stripes(left: Nat,+base: U32,+text: U32,pattern: U32 & Masks,prev: Array<U32> & U32) -> U32:
  match left pattern prev:
    case 0n Tuple{s,m} Tuple{a,v}: v
    case 1n+p Tuple{s,m} Tuple{a,v}:
      stripes(p,U32.add(base,32),text,build_masks(32n,s,1,Masks4{0,0,0,0}),stripe(base,text,m,a))

def pair(+index: U32) -> U32:
  +s = U32.mul(U32.inc(index),2654435761)
  score = stripes(8n,32,U32.mul(s,340573321),build_masks(32n,s,1,Masks4{0,0,0,0}),([2 : U32*256n],0))
  U32.xor(U32.mul(score,2654435761),U32.inc(index))

def batch(+left: Nat,+index: U32) -> U32:
  match left:
    case 0n: pair(index)
    case 1n+p:
      a b = batch(p,index) batch(p,U32.add(index,U32.shln(1,p)))
      U32.add(a,b)

def bench(n: U32,seed: U32) -> U32:
  batch(U32.to_nat(n),seed)
