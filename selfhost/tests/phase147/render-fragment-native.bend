# Matched complete-render/write workload. Each iteration constructs a fresh whole
# function String and makes exactly one File.write; no length/checksum traversal.
@unsafe
def p147qn_segment(index: U32) -> N111Segment:
  match index:
    case 0: p147q_fixture_segment0()
    case 1: p147q_fixture_segment1()
    case _: p147q_fixture_segment2()

@unsafe
def p147qn_ids(index: U32) -> N111Ids:
  match index:
    case 0: p147q_fixture_ids0()
    case 1: p147q_fixture_ids1()
    case _: p147q_fixture_ids2()

@unsafe
def p147qn_written(pair: File & Result<&1,&1,U32 & String,Unit>, +segment: N111Segment, +ids: N111Ids, +candidate: U32, left: U32) -> IO(U32):
  (file,result) = pair
  match result:
    case Done{unit}: p147qn_loop(segment,ids,candidate,left,file)
    case Fail{error}:
      do IO<U32>:
        Unit <- File.close(file)
        IO.pass(U32,Fail{error})

@unsafe
def p147qn_loop(+segment: N111Segment, +ids: N111Ids, +candidate: U32, +left: U32, file: File) -> IO(U32):
  match left:
    case 0:
      do IO<U32>:
        Unit <- File.close(file)
        IO.pure(U32,0)
    case _:
      do IO<U32>:
        pair : File & Result<&1,&1,U32 & String,Unit> <- File.write(file,p147f_render_segment(segment,ids,candidate))
        p147qn_written(pair,segment,ids,candidate,U32.sub(left,1))

@unsafe
def p147qn_open(+candidate: U32, +index: U32, count: U32, path: String) -> IO(U32):
  do IO<U32>:
    file : File <- IO.try(File,File.open(path,"a"))
    p147qn_loop(p147qn_segment(index),p147qn_ids(index),candidate,count,file)

@unsafe
def p147qn_mode(+candidate: U32, +mode: String, +index: U32, +count: U32) -> IO(U32):
  nt_choose(IO(U32),U32.is_lt(index,3) && U32.is_ge(count,1) && U32.is_le(count,100000) &&
    (String.eq(mode,"bench") || (String.eq(mode,"oracle") && U32.is_eq(count,1))),
    u => p147qn_open(candidate,index,count,nt_choose(String,String.eq(mode,"oracle"),v => "/dev/stdout",v => "/dev/null")),
    u => IO.die(U32,2,"expected oracle INDEX 1 or bench INDEX COUNT (INDEX<3,1<=COUNT<=100000)"))

@unsafe
def p147qn_parsed(candidate: U32, mode: String, index: Maybe<&2,U32>, count: Maybe<&2,U32>) -> IO(U32):
  match index count:
    case Some{i} Some{n}: p147qn_mode(candidate,mode,i,n)
    case _ _: IO.die(U32,2,"expected unsigned INDEX and COUNT")

@unsafe
def p147qn_args(candidate: U32, args: List<&1,String>) -> IO(U32):
  match args:
    case Con{mode,Con{index,Con{count,Nil{}}}}: p147qn_parsed(candidate,mode,U32.read(index),U32.read(count))
    case _: IO.die(U32,2,"expected MODE INDEX COUNT")

@unsafe
def p147qn_main(+candidate: U32) -> IO(U32):
  do IO<U32>:
    args : List<&1,String> <- IO.args()
    p147qn_args(candidate,args)
