.intel_syntax noprefix
.text
.Lloop:
  cmp rdi,0
  jne .Lbody
.Lbody:
  lea r13,[rdi-0x1]
  mov edi,esi
  mov r14,rdi
  add r14d,0x1
  mov r8,rsi
  and r8,rbx
  mov edi,DWORD PTR [rdx+r8*4]
  mov r9d,r9d
  add edi,r9d
  mov r9,rdi
  mov esi,esi
  xor rdi,rsi
  mov DWORD PTR [rdx+r8*4],edi
  mov rdi,r13
  mov rsi,r14
  jmp .Lloop
