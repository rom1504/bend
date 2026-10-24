"""Byte framing only. No QBE grammar, symbols, calls or instructions are parsed."""
import re
PREFIX=b'# P135/1 '
class Reader:
 def __init__(self,stream):self.stream=stream;self.buf=b'';self.eof=False;self.reads=0;self.maxRead=0;self.maxPending=0
 def more(self):
  if self.eof:return False
  b=self.stream.read(65536);self.reads+=1;self.maxRead=max(self.maxRead,len(b));self.buf+=b;self.maxPending=max(self.maxPending,len(self.buf))
  if not b:self.eof=True
  return bool(b)
 def header(self):
  while b'\n'not in self.buf:
   if len(self.buf)>128:raise ValueError('Oversized frame header')
   if not self.more():raise ValueError('Truncated frame header')
  end=self.buf.index(b'\n')+1
  if end>128:raise ValueError('Oversized frame header')
  line,self.buf=self.buf[:end],self.buf[end:];return line
 def payload(self,write):
  marker=b'\n'+PREFIX;total=0
  while True:
   pos=self.buf.find(marker)
   if pos>=0:
    part=self.buf[:pos+1];write(part);total+=len(part);self.buf=self.buf[pos+1:]
    return total,self.header()
   keep=len(marker)-1
   if len(self.buf)>keep:
    part,self.buf=self.buf[:-keep],self.buf[-keep:];write(part);total+=len(part)
   if not self.more():raise ValueError('Truncated payload/end marker')
 def finish(self):
  if self.buf or self.more():raise ValueError('Trailing bytes after DONE')

def units(stream,begin,end):
 reader=Reader(stream);count=0;last_kind=0
 while True:
  line=reader.header();done=re.fullmatch(rb'# P135/1 DONE (\d+)\n',line)
  if done:
   if int(done[1])!=count:raise ValueError('DONE count mismatch')
   reader.finish();return dict(units=count,reads=reader.reads,maximumReadBytes=reader.maxRead,maximumPendingBytes=reader.maxPending)
  h=re.fullmatch(rb'# P135/1 BEGIN ([012]) (\d+)\n',line)
  if not h:raise ValueError('Unknown BEGIN frame')
  kind,index=map(int,h.groups())
  if index!=count or kind<last_kind:raise ValueError('Noncanonical frame order')
  if kind==last_kind and kind!=0 and count:raise ValueError('Repeated data/main unit')
  last_kind=kind;write=begin(kind,index)
  size,trailer=reader.payload(write)
  if size==0 or trailer!=f'# P135/1 END {kind} {index}\n'.encode():raise ValueError('Wrong/empty END frame')
  end(kind,index,size);count+=1
