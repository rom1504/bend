"""Compare allocated ELF sections, including their address, file size and content."""
import hashlib
import struct

def image(path):
    with open(path,"rb") as f: data=f.read()
    assert data[:6]==b'\x7fELF\x02\x01'
    base=struct.unpack_from("<Q",data,40)[0]
    stride,n,si=struct.unpack_from("<HHH",data,58)
    rows=[struct.unpack_from("<IIQQQQIIQQ",data,base+stride*i) for i in range(n)]
    result={}
    for row in rows:
        if row[2]&2:
            start=rows[si][4]+row[0]
            name=data[start:data.index(0,start)].decode('ascii')
            h=None if row[1]==8 else hashlib.sha256(data[row[4]:row[4]+row[5]]).hexdigest()
            result[name]=(row[1],row[2],row[3],row[5],h)
    return result
