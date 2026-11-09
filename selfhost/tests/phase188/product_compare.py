"""Metadata-only ELF section reader and Phase187 machine-product comparison."""
import hashlib
import json
import struct
from pathlib import Path
import common


def same(a,b):
    return a.get('bytes')==b.get('bytes') and a.get('sha256')==b.get('sha256')


def sections(item):
    data=common.verify(item).read_bytes()
    common.require(data[:7]==b'\x7fELF\x02\x01\x01' and len(data)>=64,'ELF64 little-endian input required')
    offset=struct.unpack_from('<Q',data,40)[0]
    width,count,names=struct.unpack_from('<HHH',data,58)
    common.require(width==64 and 0<names<count<65536 and offset+width*count<=len(data),'Bounded ELF section table required')
    table=[struct.unpack_from('<IIQQQQIIQQ',data,offset+i*64) for i in range(count)]
    ns=table[names];strings=data[ns[4]:ns[4]+ns[5]]
    result={}
    for row in table:
        end=strings.find(b'\0',row[0]);common.require(0<=row[0]<len(strings) and end>=row[0],'Bounded section name')
        name=strings[row[0]:end].decode('ascii')
        if name in ('.text','.data','.rodata'):
            common.require(row[1]==1 and row[4]+row[5]<=len(data),'Bounded program section')
            content=data[row[4]:row[4]+row[5]]
            result[name]=dict(bytes=len(content),sha256=hashlib.sha256(content).hexdigest())
    common.require(set(result)=={'.text','.data','.rodata'},'Complete program sections required')
    return result


def compare(current_row, prior_row):
    for key in ('source','expectedFile'):
        common.require(same(current_row[key],prior_row[key]),'Prior catalog input identity changed')
    result={}
    for role,product in current_row['products'].items():
        if 'buildReceipt' not in product:continue
        old=prior_row['products'][role]
        common.require(old.get('complete') and old.get('status')=='executed-independent-oracle-pass','Prior independent oracle absent')
        a=json.loads(common.verify(product['buildReceipt']).read_text())
        b=json.loads(common.verify(old['buildReceipt']).read_text())
        common.require(a.get('complete') and b.get('complete') and same(a['runtime'],b['runtime']),'Comparable complete builds and exact runtime required')
        common.verify(a['object']);common.verify(b['object'])
        current=sections(a['binary']);previous=sections(b['binary'])
        equal={name:current[name]==previous[name] for name in current}
        result[role]=dict(currentObject=a['object'],priorObject=b['object'],objectIdentical=same(a['object'],b['object']),
                          currentBinary=a['binary'],priorBinary=b['binary'],currentSections=current,priorSections=previous,
                          linkedSectionsIdentical=equal,priorReceipt=old['buildReceipt'])
        # Assembly formatting must not change any assembled byte, symbol or
        # relocation. Direct ELF may omit resolved local symbols/relocations.
        if role=='reference':common.require(result[role]['objectIdentical'],'Typed assembly changed GNU-as machine object')
        common.require(all(equal.values()),'Typed output changed linked program sections: '+role)
    return result
