@unsafe
def x202e_write(parts: List<&2,List<&2,U32>>, file: File) -> IO(U32):
  match parts:
    case Nil{}: do IO<U32>:
      Unit <- File.close(file)
      IO.pure(U32,0)
    case Con{Nil{},rest}: x202e_write(rest,file)
    case Con{bytes,rest}: do IO<U32>:
      pair : File & Result<&1,&1,U32 & String,Unit> <- File.write_bytes(file,bytes)
      x202e_after(rest,pair)

@unsafe
def x202e_after(rest: List<&2,List<&2,U32>>, pair: File & Result<&1,&1,U32 & String,Unit>) -> IO(U32):
  (file,result) = pair
  x202e_status(result,file,rest)

@unsafe
def x202e_status(result: Result<&1,&1,U32 & String,Unit>, file: File, rest: List<&2,List<&2,U32>>) -> IO(U32):
  match result:
    case Done{unit}: x202e_write(rest,file)
    case Fail{error}: do IO<U32>:
      Unit <- File.close(file)
      IO.pass(U32,Fail{error})

@unsafe
def x202e_open(parts: List<&2,List<&2,U32>>) -> IO(U32):
  do IO<U32>:
    file : File <- IO.try(File,File.open("/dev/stdout","w"))
    x202e_write(parts,file)

@unsafe
def x202e_plan(sections: List<&2,X187ElfSection>, +offset: U32, parts: List<&2,List<&2,U32>>, headers: List<&2,U32>) -> IO(U32):
  match sections:
    case Nil{}:
      +shoff = x187_elf_align(offset,8)
      x202e_open(Con{x187_elf_header(shoff),nt_reverse(List<&2,U32>,parts,
        [x187_elf_zero(U32.sub(shoff,offset),[]),nt_reverse(U32,headers,[])])})
    case Con{+section,rest}:
      match section:
        case X187ElfSection{name,kind,flags,+alignment,entry,link,info,+bytes}:
          +start = x187_elf_align(offset,alignment)
          +size = nt_count(U32,bytes)
          x202e_plan(rest,U32.add(start,size),Con{bytes,Con{x187_elf_zero(U32.sub(start,offset),[]),parts}},
            nt_reverse(U32,x187_elf_section_header(section,start,size),headers))
