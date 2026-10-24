"""ELF metadata audit for mechanical generated-symbol globalization."""
import hashlib,struct
PREFIXES=('p111_','p112w_','p113d_','p114r_','p114g_resume_','p117v_')
def metadata(path):
 b=path.read_bytes()
 if b[:6]!=b'\x7fELF\x02\x01':raise ValueError('ELF64 little endian required')
 if struct.unpack_from('<HH',b,16)!=(1,62):raise ValueError('AMD64 relocatable object required')
 off=struct.unpack_from('<Q',b,40)[0];size,count,strings=struct.unpack_from('<HHH',b,58)
 if size!=64 or not 0<strings<count:raise ValueError('Unsupported ELF table')
 sections=[struct.unpack_from('<IIQQQQIIQQ',b,off+i*size)for i in range(count)]
 def payload(s):return b[s[4]:s[4]+s[5]]
 st=payload(sections[strings])
 def string(t,n):return t[n:t.index(0,n)].decode('utf8')
 names=[string(st,s[0])for s in sections];allocated=[];symbols=[];tables={};relocs=[]
 for index,s in enumerate(sections):
  if s[2]&2:allocated.append(dict(name=names[index],type=s[1],flags=s[2],address=s[3],bytes=s[5],alignment=s[8],sha256=hashlib.sha256(b''if s[1]==8 else payload(s)).hexdigest()))
  if s[1]==2:
   if s[9]!=24:raise ValueError('Unexpected symbol record')
   strings_=payload(sections[s[6]]);table=[]
   for at in range(s[4],s[4]+s[5],24):
    n,info,other,shndx,value,length=struct.unpack_from('<IBBHQQ',b,at);name=string(strings_,n);section=names[shndx]if shndx<count else str(shndx)
    row=dict(name=name,binding=info>>4,type=info&15,other=other,section=section,defined=shndx!=0,value=value,bytes=length);table.append(row);symbols.append(row)
   tables[index]=table
 for index,s in enumerate(sections):
  if s[1]in(4,9):
   width=24 if s[1]==4 else 16
   if s[9]!=width:raise ValueError('Unexpected relocation record')
   for at in range(s[4],s[4]+s[5],width):
    offset,info=struct.unpack_from('<QQ',b,at);sym=tables[s[6]][info>>32];addend=struct.unpack_from('<q',b,at+16)[0]if width==24 else None
    relocs.append(dict(section=names[s[7]],offset=offset,type=info&0xffffffff,symbol=sym['name'],symbolSection=sym['section'],addend=addend))
 promoted=[];definitions=[]
 for x in symbols:
  if x['defined']and x['name']and x['type']not in(3,4):
   if x['name'].startswith(PREFIXES):
    definitions.append(x['name'])
    if x['binding']==0:promoted.append(x['name'])
   elif x['name']=='main':definitions.append('main')
   elif not x['name'].startswith('.L'):raise ValueError('Unknown defined generated symbol: '+x['name'])
 key=lambda x:repr(sorted(x.items()))
 return dict(allocated=allocated,symbols=sorted(symbols,key=key),relocations=sorted(relocs,key=key),promoted=sorted(set(promoted)),definitions=sorted(set(definitions)))
def compare(before,after):
 if before['allocated']!=after['allocated']or before['relocations']!=after['relocations']:raise ValueError('Object globalization changed machine data/relocations')
 expected=[dict(x,binding=1)if x['name']in before['promoted']else x for x in before['symbols']]
 key=lambda x:repr(sorted(x.items()))
 if sorted(expected,key=key)!=after['symbols']:raise ValueError('Unexpected ELF symbol change')
 if after['promoted']:raise ValueError('Generated local definitions remain')
