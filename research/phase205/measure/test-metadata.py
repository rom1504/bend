#!/usr/bin/env python3
"""Synthetic metadata/sealing checks only; never execute a program."""
import errno,gzip,hashlib,json,os,tempfile
from pathlib import Path
from support import image_binding
from screen import load_image
with tempfile.TemporaryDirectory(prefix='phase205-meta-') as directory:
 root=Path(directory);source=root/'compiler.bend';source.write_text('synthetic fixture, never executed\n');elf=b'\x7fELF\x02\x01'+bytes(122);gz=root/'program.gz'
 with gzip.open(gz,'wb') as out:out.write(elf)
 receipt=root/'results.json';data=dict(source=str(source),sourceSha256=hashlib.sha256(source.read_bytes()).hexdigest(),productRuntimeSha256='0'*64,runs=[dict(complete=1.0,elfSha256=hashlib.sha256(elf).hexdigest())]);receipt.write_text(json.dumps(data))
 binding=image_binding(gz,receipt);fd,identity=load_image(binding)
 try:
  assert identity['bytes']==len(elf) and identity['sha256']==data['runs'][0]['elfSha256']
  try:os.write(fd,b'x');raise AssertionError('Writable compiler memfd')
  except OSError as e:assert e.errno==errno.EPERM
 finally:os.close(fd)
 wrong=dict(binding,elfSha256='1'*64)
 try:load_image(wrong);raise AssertionError('Wrong ELF hash admitted')
 except AssertionError as e:assert str(e)!='Wrong ELF hash admitted'
 source.write_text('changed')
 try:image_binding(gz,receipt);raise AssertionError('Changed source admitted')
 except AssertionError as e:assert str(e)!='Changed source admitted'
print('PASS synthetic gzip/receipt/source bindings and sealed memfd; zero target executions')
