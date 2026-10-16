#!/usr/bin/env python3
"""Read ELF sections without executing binaries; report allocated-section identity."""
import argparse
import hashlib
import json
import struct
from pathlib import Path


def pin(path):
    data=path.read_bytes()
    return dict(file=str(path.resolve()),bytes=len(data),sha256=hashlib.sha256(data).hexdigest())


def sections(path):
    data=path.read_bytes()
    assert data[:6]==b'\x7fELF\x02\x01', 'ELF64 little-endian only'
    header=struct.unpack_from('<16sHHIQQQIHHHHHH',data)
    offset,width,count,names=header[6],header[11],header[12],header[13]
    assert width==64 and offset+width*count<=len(data)
    rows=[struct.unpack_from('<IIQQQQIIQQ',data,offset+i*width) for i in range(count)]
    stringrow=rows[names];strings=data[stringrow[4]:stringrow[4]+stringrow[5]]
    result={}
    for row in rows:
        end=strings.find(b'\0',row[0]);assert end>=row[0]
        name=strings[row[0]:end].decode()
        body=data[row[4]:row[4]+row[5]] if row[1]!=8 else b''
        assert row[1]==8 or len(body)==row[5]
        result[name]=dict(bytes=row[5],sha256=hashlib.sha256(body).hexdigest(),offset=row[4],flags=row[2],type=row[1],address=row[3])
    return result


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--baseline',type=Path,required=True)
    parser.add_argument('--candidate',type=Path,required=True)
    parser.add_argument('--out',type=Path,required=True)
    args=parser.parse_args();assert not args.out.exists()
    left,right=sections(args.baseline),sections(args.candidate)
    allocated={name for name,row in left.items() if row['flags']&2}
    assert allocated=={name for name,row in right.items() if row['flags']&2}
    report=dict(complete=True,dataOnly=True,targetExecuted=False,method=pin(Path(__file__)),baseline=pin(args.baseline),candidate=pin(args.candidate),allocatedSectionsExact=all(left[name]==right[name] for name in allocated),allocatedSectionNames=sorted(allocated),differences={name:dict(baseline=left.get(name),candidate=right.get(name)) for name in sorted(set(left)|set(right)) if left.get(name)!=right.get(name)},scope='All allocated ELF section records and bytes compared offline; not a runtime measurement. Symbol name size is separate from executable code size.')
    args.out.write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(dict(complete=True,allocatedSectionsExact=report['allocatedSectionsExact'],differences=list(report['differences']))))


if __name__=='__main__':main()
