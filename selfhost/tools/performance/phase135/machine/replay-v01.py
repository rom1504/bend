#!/usr/bin/env python3
"""Reframe explicitly retained current qualification units; no text discovery."""
import argparse,hashlib,json,pathlib,sys
p=argparse.ArgumentParser();p.add_argument('--build',type=pathlib.Path,required=True);a=p.parse_args();r=json.loads(a.build.read_text());assert r['complete']and r['kind']=='phase135-framed-machine-build'
stream=sys.stdout.buffer;whole=hashlib.sha256();total=0
for i,u in enumerate(r['units']):
 assert u['index']==i and u['textRetained'];meta=u['text'];f=pathlib.Path(meta['file']);h=hashlib.sha256();n=0
 stream.write(f"# P135/1 BEGIN {u['kind']} {i}\n".encode())
 with f.open('rb')as src:
  while b:=src.read(65536):stream.write(b);h.update(b);whole.update(b);n+=len(b);total+=len(b)
 assert n==meta['bytes']==u['payload']['bytes'] and h.hexdigest()==meta['sha256']==u['payload']['sha256']
 stream.write(f"# P135/1 END {u['kind']} {i}\n".encode())
assert dict(bytes=total,sha256=whole.hexdigest())==r['payloadDigest'];stream.write(f"# P135/1 DONE {len(r['units'])}\n".encode());stream.flush()
