#!/usr/bin/env python3
"""Independent C lexical alpha-renaming oracle; leaves literals/comments intact."""
import re
TOKEN=re.compile(r'"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'|//[^\n]*|/\*.*?\*/|[A-Za-z_][A-Za-z_0-9]*',re.S)
FID=re.compile(r'(NF_)?FID_((?:[0-9]+_)+)')
def translate(source):
 mappings={};tokens=set(TOKEN.findall(source))
 def one(m):
  token=m[0];f=FID.fullmatch(token)
  if not f:return token
  codes=[int(x) for x in f[2][:-1].split('_')]
  name=''.join(chr(c) if 48<=c<=57 or 65<=c<=90 or 97<=c<=122 else '_'+str(c)+'_' for c in codes)
  new=(f[1] or '')+'FID_n'+name
  assert new not in tokens
  mappings[token]=new
  return new
 text=TOKEN.sub(one,source)
 assert len(mappings.values())==len(set(mappings.values()))
 return text,mappings
