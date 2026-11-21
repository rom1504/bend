.intel_syntax noprefix
.text
.Lloop:
  mov r9d,ecx
  and r9d,r11d
  add edi,DWORD PTR [r15+r9*4]
  mov r10d,edi
  xor r10d,ecx
  mov DWORD PTR [r15+r9*4],r10d
  lea r9d,[rcx+0x1]
  mov r10d,r9d
  and r10d,r11d
  add edi,DWORD PTR [r15+r10*4]
  xor r9d,edi
  mov DWORD PTR [r15+r10*4],r9d
  add rcx,0x2
  cmp rbx,rcx
  jne .Lloop
