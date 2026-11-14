
/home/ai/bend2/build/publish/bend/selfhost/build/phase194/native45-02/lexer/machine/program:     file format elf64-x86-64


Disassembly of section .text:

000000000041cd00 <p111_rt_op+0xa60>:
  41cd00:	cmp    ecx,0x2
  41cd03:	jne    41d132 <p111_rt_op+0xe92>
  41cd09:	mov    rax,QWORD PTR [rbx+0x8]
  41cd0d:	mov    r12,QWORD PTR [rbx]
  41cd10:	mov    ecx,eax
  41cd12:	test   eax,eax
  41cd14:	je     41c384 <p111_rt_op+0xe4>
  41cd1a:	mov    eax,r12d
  41cd1d:	xor    edx,edx
  41cd1f:	div    ecx
  41cd21:	mov    r12,rdx
  41cd24:	jmp    41c384 <p111_rt_op+0xe4>
