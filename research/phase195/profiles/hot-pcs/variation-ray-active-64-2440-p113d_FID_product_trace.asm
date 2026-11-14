
/home/ai/bend2/build/publish/bend/selfhost/build/phase194/native45-02/variation-ray-active-64-2440/machine/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

000000000040bb30 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_>:
  40bb30:	push   rbp
  40bb31:	mov    rbp,rsp
  40bb34:	sub    rsp,0x1170
  40bb3b:	mov    QWORD PTR [rbp-0x10],r12
  40bb3f:	mov    QWORD PTR [rbp-0x8],rbx
  40bb43:	mov    QWORD PTR [rbp-0x18],r13
  40bb47:	mov    QWORD PTR [rbp-0x20],r14
  40bb4b:	mov    QWORD PTR [rbp-0x28],r15
  40bb4f:	mov    rax,rdi
  40bb52:	mov    r12,rax
  40bb55:	mov    rax,rsi
  40bb58:	mov    QWORD PTR [rbp-0x30],rax
  40bb5c:	mov    rax,rdx
  40bb5f:	mov    r14,rax
  40bb62:	mov    rax,rcx
  40bb65:	mov    r13,rax
  40bb68:	mov    rax,r8
  40bb6b:	mov    QWORD PTR [rbp-0x48],rax
  40bb6f:	mov    rax,r9
  40bb72:	mov    QWORD PTR [rbp-0x50],rax
  40bb76:	mov    rax,QWORD PTR [rbp+0x10]
  40bb7a:	mov    QWORD PTR [rbp-0x58],rax
  40bb7e:	mov    rax,QWORD PTR [rbp+0x18]
  40bb82:	mov    QWORD PTR [rbp-0x60],rax
  40bb86:	mov    rax,QWORD PTR [rbp+0x20]
  40bb8a:	mov    r15,rax
  40bb8d:	mov    rax,QWORD PTR [rbp+0x28]
  40bb91:	mov    QWORD PTR [rbp-0x70],rax
  40bb95:	mov    rax,QWORD PTR [rbp+0x30]
  40bb99:	mov    QWORD PTR [rbp-0x78],rax
  40bb9d:	mov    rax,QWORD PTR [rbp+0x38]
  40bba1:	mov    QWORD PTR [rbp-0x80],rax
  40bba5:	mov    rax,QWORD PTR [rbp+0x40]
  40bba9:	mov    QWORD PTR [rbp-0x88],rax
  40bbb0:	mov    r10,QWORD PTR [rbp-0x30]
  40bbb4:	cmp    r10,0x0
  40bbbb:	sete   r10b
  40bbbf:	movzx  r10d,r10b
  40bbc3:	mov    QWORD PTR [rbp-0x940],r10
  40bbca:	test   r10d,r10d
  40bbcd:	je     40cc26 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x10f6>
  40bbd3:	mov    r10,r14
  40bbd6:	cmp    r10,0x1
  40bbdd:	sete   r10b
  40bbe1:	movzx  r10d,r10b
  40bbe5:	mov    QWORD PTR [rbp-0x948],r10
  40bbec:	mov    r10,r14
  40bbef:	shr    r10,0x28
  40bbf3:	mov    QWORD PTR [rbp-0x950],r10
  40bbfa:	and    r10,0x7fffff
  40bc01:	mov    QWORD PTR [rbp-0x950],r10
  40bc08:	movabs r10,0x2
  40bc12:	or     r10,0x10000
  40bc19:	mov    QWORD PTR [rbp-0x958],r10
  40bc20:	mov    r10,QWORD PTR [rbp-0x950]
  40bc27:	mov    r11,QWORD PTR [rbp-0x958]
  40bc2e:	cmp    r10,r11
  40bc31:	sete   r10b
  40bc35:	movzx  r10d,r10b
  40bc39:	mov    QWORD PTR [rbp-0x960],r10
  40bc40:	mov    r10,QWORD PTR [rbp-0x948]
  40bc47:	mov    r11,QWORD PTR [rbp-0x960]
  40bc4e:	or     r10d,r11d
  40bc51:	mov    QWORD PTR [rbp-0x940],r10
  40bc58:	test   r10d,r10d
  40bc5b:	je     40bc7e <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x14e>
  40bc61:	mov    rax,QWORD PTR [rbp-0x80]
  40bc65:	mov    r12,QWORD PTR [rbp-0x10]
  40bc69:	mov    rbx,QWORD PTR [rbp-0x8]
  40bc6d:	mov    r13,QWORD PTR [rbp-0x18]
  40bc71:	mov    r14,QWORD PTR [rbp-0x20]
  40bc75:	mov    r15,QWORD PTR [rbp-0x28]
  40bc79:	mov    rsp,rbp
  40bc7c:	pop    rbp
  40bc7d:	ret    
  40bc7e:	mov    r10,r14
  40bc81:	cmp    r10,0x1
  40bc88:	sete   r10b
  40bc8c:	movzx  r10d,r10b
  40bc90:	mov    QWORD PTR [rbp-0x948],r10
  40bc97:	mov    r10,r14
  40bc9a:	shr    r10,0x28
  40bc9e:	mov    QWORD PTR [rbp-0x950],r10
  40bca5:	and    r10,0x7fffff
  40bcac:	mov    QWORD PTR [rbp-0x950],r10
  40bcb3:	movabs r10,0x2
  40bcbd:	or     r10,0x10000
  40bcc4:	mov    QWORD PTR [rbp-0x958],r10
  40bccb:	mov    r10,QWORD PTR [rbp-0x950]
  40bcd2:	mov    r11,QWORD PTR [rbp-0x958]
  40bcd9:	cmp    r10,r11
  40bcdc:	sete   r10b
  40bce0:	movzx  r10d,r10b
  40bce4:	mov    QWORD PTR [rbp-0x960],r10
  40bceb:	mov    r10,QWORD PTR [rbp-0x948]
  40bcf2:	mov    r11,QWORD PTR [rbp-0x960]
  40bcf9:	or     r10d,r11d
  40bcfc:	mov    QWORD PTR [rbp-0x940],r10
  40bd03:	xor    r10d,0x1
  40bd0a:	mov    QWORD PTR [rbp-0x940],r10
  40bd11:	test   r10d,r10d
  40bd14:	je     40cbe6 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x10b6>
  40bd1a:	mov    rbx,QWORD PTR [rbp-0x48]
  40bd1e:	mov    r10,rbx
  40bd21:	mov    QWORD PTR [rbp-0x970],r10
  40bd28:	mov    rdi,r12
  40bd2b:	mov    rsi,QWORD PTR [rbp-0x970]
  40bd32:	xor    eax,eax
  40bd34:	call   408b1b <p113d_FID_36_100_105_114_101_99_116_46_115_114_>
  40bd39:	mov    QWORD PTR [rbp-0x978],rax
  40bd40:	lea    r10,[rbp-0x890]
  40bd47:	mov    r11,r13
  40bd4a:	mov    QWORD PTR [r10],r11
  40bd4d:	lea    r10,[rbp-0x890]
  40bd54:	mov    r11,r15
  40bd57:	mov    QWORD PTR [r10+0x8],r11
  40bd5b:	movd   xmm1,r15d
  40bd60:	movd   xmm0,r13d
  40bd65:	mulss  xmm0,xmm1
  40bd69:	movd   ebx,xmm0
  40bd6d:	mov    rdi,rbx
  40bd70:	lea    r10,[rbp-0x890]
  40bd77:	mov    r11,QWORD PTR [rbp-0x50]
  40bd7b:	mov    QWORD PTR [r10],r11
  40bd7e:	lea    r10,[rbp-0x890]
  40bd85:	mov    r11,rdi
  40bd88:	mov    QWORD PTR [r10+0x8],r11
  40bd8c:	movd   xmm1,edi
  40bd90:	movd   xmm0,DWORD PTR [rbp-0x50]
  40bd95:	addss  xmm0,xmm1
  40bd99:	movd   ebx,xmm0
  40bd9d:	mov    r10,rbx
  40bda0:	mov    QWORD PTR [rbp-0x988],r10
  40bda7:	lea    r10,[rbp-0x890]
  40bdae:	mov    r11,r13
  40bdb1:	mov    QWORD PTR [r10],r11
  40bdb4:	lea    r10,[rbp-0x890]
  40bdbb:	mov    r11,QWORD PTR [rbp-0x70]
  40bdbf:	mov    QWORD PTR [r10+0x8],r11
  40bdc3:	movd   xmm1,DWORD PTR [rbp-0x70]
  40bdc8:	movd   xmm0,r13d
  40bdcd:	mulss  xmm0,xmm1
  40bdd1:	movd   ebx,xmm0
  40bdd5:	mov    rdi,rbx
  40bdd8:	lea    r10,[rbp-0x890]
  40bddf:	mov    r11,QWORD PTR [rbp-0x58]
  40bde3:	mov    QWORD PTR [r10],r11
  40bde6:	lea    r10,[rbp-0x890]
  40bded:	mov    r11,rdi
  40bdf0:	mov    QWORD PTR [r10+0x8],r11
  40bdf4:	movd   xmm1,edi
  40bdf8:	movd   xmm0,DWORD PTR [rbp-0x58]
  40bdfd:	addss  xmm0,xmm1
  40be01:	movd   ebx,xmm0
  40be05:	mov    r10,rbx
  40be08:	mov    QWORD PTR [rbp-0x998],r10
  40be0f:	lea    r10,[rbp-0x890]
  40be16:	mov    r11,r13
  40be19:	mov    QWORD PTR [r10],r11
  40be1c:	lea    r10,[rbp-0x890]
  40be23:	mov    r11,QWORD PTR [rbp-0x78]
  40be27:	mov    QWORD PTR [r10+0x8],r11
  40be2b:	movd   xmm1,DWORD PTR [rbp-0x78]
  40be30:	movd   xmm0,r13d
  40be35:	mulss  xmm0,xmm1
  40be39:	movd   ebx,xmm0
  40be3d:	mov    rdi,rbx
  40be40:	lea    r10,[rbp-0x890]
  40be47:	mov    r11,QWORD PTR [rbp-0x60]
  40be4b:	mov    QWORD PTR [r10],r11
  40be4e:	lea    r10,[rbp-0x890]
  40be55:	mov    r11,rdi
  40be58:	mov    QWORD PTR [r10+0x8],r11
  40be5c:	movd   xmm1,edi
  40be60:	movd   xmm0,DWORD PTR [rbp-0x60]
  40be65:	addss  xmm0,xmm1
  40be69:	movd   ebx,xmm0
  40be6d:	mov    r10,rbx
  40be70:	mov    QWORD PTR [rbp-0x9a8],r10
  40be77:	mov    rdi,r12
  40be7a:	mov    rsi,QWORD PTR [rbp-0x970]
  40be81:	xor    eax,eax
  40be83:	call   408ea5 <p113d_FID_36_100_105_114_101_99_116_46_115_120_>
  40be88:	mov    QWORD PTR [rbp-0x9b0],rax
  40be8f:	lea    r10,[rbp-0x890]
  40be96:	mov    r11,QWORD PTR [rbp-0x988]
  40be9d:	mov    QWORD PTR [r10],r11
  40bea0:	lea    r10,[rbp-0x890]
  40bea7:	mov    r11,QWORD PTR [rbp-0x9b0]
  40beae:	mov    QWORD PTR [r10+0x8],r11
  40beb2:	movd   xmm1,DWORD PTR [rbp-0x9b0]
  40beba:	movd   xmm0,DWORD PTR [rbp-0x988]
  40bec2:	subss  xmm0,xmm1
  40bec6:	movd   ebx,xmm0
  40beca:	mov    rdi,rbx
  40becd:	lea    r10,[rbp-0x890]
  40bed4:	mov    r11,rdi
  40bed7:	mov    QWORD PTR [r10],r11
  40beda:	lea    r10,[rbp-0x890]
  40bee1:	mov    r11,QWORD PTR [rbp-0x978]
  40bee8:	mov    QWORD PTR [r10+0x8],r11
  40beec:	movd   xmm1,DWORD PTR [rbp-0x978]
  40bef4:	movd   xmm0,edi
  40bef8:	divss  xmm0,xmm1
  40befc:	movd   ebx,xmm0
  40bf00:	mov    r10,rbx
  40bf03:	mov    QWORD PTR [rbp-0x9c0],r10
  40bf0a:	mov    rdi,r12
  40bf0d:	mov    rsi,QWORD PTR [rbp-0x970]
  40bf14:	xor    eax,eax
  40bf16:	call   408d77 <p113d_FID_36_100_105_114_101_99_116_46_115_121_>
  40bf1b:	mov    QWORD PTR [rbp-0x9c8],rax
  40bf22:	lea    r10,[rbp-0x890]
  40bf29:	mov    r11,QWORD PTR [rbp-0x998]
  40bf30:	mov    QWORD PTR [r10],r11
  40bf33:	lea    r10,[rbp-0x890]
  40bf3a:	mov    r11,QWORD PTR [rbp-0x9c8]
  40bf41:	mov    QWORD PTR [r10+0x8],r11
  40bf45:	movd   xmm1,DWORD PTR [rbp-0x9c8]
  40bf4d:	movd   xmm0,DWORD PTR [rbp-0x998]
  40bf55:	subss  xmm0,xmm1
  40bf59:	movd   ebx,xmm0
  40bf5d:	mov    rdi,rbx
  40bf60:	lea    r10,[rbp-0x890]
  40bf67:	mov    r11,rdi
  40bf6a:	mov    QWORD PTR [r10],r11
  40bf6d:	lea    r10,[rbp-0x890]
  40bf74:	mov    r11,QWORD PTR [rbp-0x978]
  40bf7b:	mov    QWORD PTR [r10+0x8],r11
  40bf7f:	movd   xmm1,DWORD PTR [rbp-0x978]
  40bf87:	movd   xmm0,edi
  40bf8b:	divss  xmm0,xmm1
  40bf8f:	movd   ebx,xmm0
  40bf93:	mov    r10,rbx
  40bf96:	mov    QWORD PTR [rbp-0x9d8],r10
  40bf9d:	mov    rdi,r12
  40bfa0:	mov    rsi,QWORD PTR [rbp-0x970]
  40bfa7:	xor    eax,eax
  40bfa9:	call   408c49 <p113d_FID_36_100_105_114_101_99_116_46_115_122_>
  40bfae:	mov    QWORD PTR [rbp-0x9e0],rax
  40bfb5:	lea    r10,[rbp-0x890]
  40bfbc:	mov    r11,QWORD PTR [rbp-0x9a8]
  40bfc3:	mov    QWORD PTR [r10],r11
  40bfc6:	lea    r10,[rbp-0x890]
  40bfcd:	mov    r11,QWORD PTR [rbp-0x9e0]
  40bfd4:	mov    QWORD PTR [r10+0x8],r11
  40bfd8:	movd   xmm1,DWORD PTR [rbp-0x9e0]
  40bfe0:	movd   xmm0,DWORD PTR [rbp-0x9a8]
  40bfe8:	subss  xmm0,xmm1
  40bfec:	movd   ebx,xmm0
  40bff0:	mov    rdi,rbx
  40bff3:	lea    r10,[rbp-0x890]
  40bffa:	mov    r11,rdi
  40bffd:	mov    QWORD PTR [r10],r11
  40c000:	lea    r10,[rbp-0x890]
  40c007:	mov    r11,QWORD PTR [rbp-0x978]
  40c00e:	mov    QWORD PTR [r10+0x8],r11
  40c012:	movd   xmm1,DWORD PTR [rbp-0x978]
  40c01a:	movd   xmm0,edi
  40c01e:	divss  xmm0,xmm1
  40c022:	movd   ebx,xmm0
  40c026:	mov    r10,rbx
  40c029:	mov    QWORD PTR [rbp-0x9f0],r10
  40c030:	lea    r10,[rbp-0x890]
  40c037:	movabs r11,0x0
  40c041:	mov    QWORD PTR [r10],r11
  40c044:	movabs r10,0x0
  40c04e:	movd   xmm0,r10d
  40c053:	movd   r10d,xmm0
  40c058:	pxor   xmm0,xmm0
  40c05c:	cvtsi2ss xmm0,r10
  40c061:	movd   r10d,xmm0
  40c066:	mov    rbx,r10
  40c069:	mov    rdi,rbx
  40c06c:	lea    r10,[rbp-0x890]
  40c073:	movabs r11,0x3
  40c07d:	mov    QWORD PTR [r10],r11
  40c080:	movabs r10,0x3
  40c08a:	movd   xmm0,r10d
  40c08f:	movd   r10d,xmm0
  40c094:	pxor   xmm0,xmm0
  40c098:	cvtsi2ss xmm0,r10
  40c09d:	movd   r10d,xmm0
  40c0a2:	mov    rbx,r10
  40c0a5:	mov    rsi,rbx
  40c0a8:	lea    r10,[rbp-0x890]
  40c0af:	mov    r11,rdi
  40c0b2:	mov    QWORD PTR [r10],r11
  40c0b5:	lea    r10,[rbp-0x890]
  40c0bc:	mov    r11,rsi
  40c0bf:	mov    QWORD PTR [r10+0x8],r11
  40c0c3:	movd   xmm1,esi
  40c0c7:	movd   xmm0,edi
  40c0cb:	subss  xmm0,xmm1
  40c0cf:	movd   ebx,xmm0
  40c0d3:	mov    rdi,rbx
  40c0d6:	lea    r10,[rbp-0x890]
  40c0dd:	mov    r11,rdi
  40c0e0:	mov    QWORD PTR [r10],r11
  40c0e3:	lea    r10,[rbp-0x890]
  40c0ea:	mov    r11,QWORD PTR [rbp-0x988]
  40c0f1:	mov    QWORD PTR [r10+0x8],r11
  40c0f5:	movd   xmm1,DWORD PTR [rbp-0x988]
  40c0fd:	movd   xmm0,edi
  40c101:	subss  xmm0,xmm1
  40c105:	movd   ebx,xmm0
  40c109:	mov    r10,rbx
  40c10c:	mov    QWORD PTR [rbp-0xa10],r10
  40c113:	lea    r10,[rbp-0x890]
  40c11a:	movabs r11,0x8
  40c124:	mov    QWORD PTR [r10],r11
  40c127:	movabs r10,0x8
  40c131:	movd   xmm0,r10d
  40c136:	movd   r10d,xmm0
  40c13b:	pxor   xmm0,xmm0
  40c13f:	cvtsi2ss xmm0,r10
  40c144:	movd   r10d,xmm0
  40c149:	mov    rbx,r10
  40c14c:	mov    rdi,rbx
  40c14f:	lea    r10,[rbp-0x890]
  40c156:	mov    r11,rdi
  40c159:	mov    QWORD PTR [r10],r11
  40c15c:	lea    r10,[rbp-0x890]
  40c163:	mov    r11,QWORD PTR [rbp-0x998]
  40c16a:	mov    QWORD PTR [r10+0x8],r11
  40c16e:	movd   xmm1,DWORD PTR [rbp-0x998]
  40c176:	movd   xmm0,edi
  40c17a:	subss  xmm0,xmm1
  40c17e:	movd   ebx,xmm0
  40c182:	mov    r10,rbx
  40c185:	mov    QWORD PTR [rbp-0xa20],r10
  40c18c:	lea    r10,[rbp-0x890]
  40c193:	movabs r11,0x1
  40c19d:	mov    QWORD PTR [r10],r11
  40c1a0:	movabs r10,0x1
  40c1aa:	movd   xmm0,r10d
  40c1af:	movd   r10d,xmm0
  40c1b4:	pxor   xmm0,xmm0
  40c1b8:	cvtsi2ss xmm0,r10
  40c1bd:	movd   r10d,xmm0
  40c1c2:	mov    rbx,r10
  40c1c5:	mov    rdi,rbx
  40c1c8:	lea    r10,[rbp-0x890]
  40c1cf:	mov    r11,rdi
  40c1d2:	mov    QWORD PTR [r10],r11
  40c1d5:	lea    r10,[rbp-0x890]
  40c1dc:	mov    r11,QWORD PTR [rbp-0x9a8]
  40c1e3:	mov    QWORD PTR [r10+0x8],r11
  40c1e7:	movd   xmm1,DWORD PTR [rbp-0x9a8]
  40c1ef:	movd   xmm0,edi
  40c1f3:	subss  xmm0,xmm1
  40c1f7:	movd   ebx,xmm0
  40c1fb:	mov    r10,rbx
  40c1fe:	mov    QWORD PTR [rbp-0xa30],r10
  40c205:	lea    r10,[rbp-0x890]
  40c20c:	mov    r11,QWORD PTR [rbp-0xa10]
  40c213:	mov    QWORD PTR [r10],r11
  40c216:	lea    r10,[rbp-0x890]
  40c21d:	mov    r11,QWORD PTR [rbp-0xa10]
  40c224:	mov    QWORD PTR [r10+0x8],r11
  40c228:	movd   xmm1,DWORD PTR [rbp-0xa10]
  40c230:	movd   xmm0,DWORD PTR [rbp-0xa10]
  40c238:	mulss  xmm0,xmm1
  40c23c:	movd   ebx,xmm0
  40c240:	mov    rdi,rbx
  40c243:	lea    r10,[rbp-0x890]
  40c24a:	mov    r11,QWORD PTR [rbp-0xa20]
  40c251:	mov    QWORD PTR [r10],r11
  40c254:	lea    r10,[rbp-0x890]
  40c25b:	mov    r11,QWORD PTR [rbp-0xa20]
  40c262:	mov    QWORD PTR [r10+0x8],r11
  40c266:	movd   xmm1,DWORD PTR [rbp-0xa20]
  40c26e:	movd   xmm0,DWORD PTR [rbp-0xa20]
  40c276:	mulss  xmm0,xmm1
  40c27a:	movd   ebx,xmm0
  40c27e:	mov    rsi,rbx
  40c281:	lea    r10,[rbp-0x890]
  40c288:	mov    r11,rdi
  40c28b:	mov    QWORD PTR [r10],r11
  40c28e:	lea    r10,[rbp-0x890]
  40c295:	mov    r11,rsi
  40c298:	mov    QWORD PTR [r10+0x8],r11
  40c29c:	movd   xmm1,esi
  40c2a0:	movd   xmm0,edi
  40c2a4:	addss  xmm0,xmm1
  40c2a8:	movd   ebx,xmm0
  40c2ac:	mov    rdi,rbx
  40c2af:	lea    r10,[rbp-0x890]
  40c2b6:	mov    r11,QWORD PTR [rbp-0xa30]
  40c2bd:	mov    QWORD PTR [r10],r11
  40c2c0:	lea    r10,[rbp-0x890]
  40c2c7:	mov    r11,QWORD PTR [rbp-0xa30]
  40c2ce:	mov    QWORD PTR [r10+0x8],r11
  40c2d2:	movd   xmm1,DWORD PTR [rbp-0xa30]
  40c2da:	movd   xmm0,DWORD PTR [rbp-0xa30]
  40c2e2:	mulss  xmm0,xmm1
  40c2e6:	movd   ebx,xmm0
  40c2ea:	mov    rsi,rbx
  40c2ed:	lea    r10,[rbp-0x890]
  40c2f4:	mov    r11,rdi
  40c2f7:	mov    QWORD PTR [r10],r11
  40c2fa:	lea    r10,[rbp-0x890]
  40c301:	mov    r11,rsi
  40c304:	mov    QWORD PTR [r10+0x8],r11
  40c308:	movd   xmm1,esi
  40c30c:	movd   xmm0,edi
  40c310:	addss  xmm0,xmm1
  40c314:	movd   ebx,xmm0
  40c318:	mov    rdi,rbx
  40c31b:	lea    r10,[rbp-0x890]
  40c322:	mov    r11,rdi
  40c325:	mov    QWORD PTR [r10],r11
  40c328:	mov    rdi,r12
  40c32b:	movabs rsi,0x24
  40c335:	mov    esi,esi
  40c337:	lea    rdx,[rbp-0x890]
  40c33e:	movabs rcx,0x1
  40c348:	mov    ecx,ecx
  40c34a:	xor    eax,eax
  40c34c:	call   420ab0 <p111_rt_op>
  40c351:	mov    rbx,rax
  40c354:	mov    r10,rbx
  40c357:	mov    QWORD PTR [rbp-0xa60],r10
  40c35e:	lea    r10,[rbp-0x890]
  40c365:	mov    r11,QWORD PTR [rbp-0xa10]
  40c36c:	mov    QWORD PTR [r10],r11
  40c36f:	lea    r10,[rbp-0x890]
  40c376:	mov    r11,QWORD PTR [rbp-0xa60]
  40c37d:	mov    QWORD PTR [r10+0x8],r11
  40c381:	movd   xmm1,DWORD PTR [rbp-0xa60]
  40c389:	movd   xmm0,DWORD PTR [rbp-0xa10]
  40c391:	divss  xmm0,xmm1
  40c395:	movd   ebx,xmm0
  40c399:	mov    r10,rbx
  40c39c:	mov    QWORD PTR [rbp-0xa68],r10
  40c3a3:	lea    r10,[rbp-0x890]
  40c3aa:	mov    r11,QWORD PTR [rbp-0xa20]
  40c3b1:	mov    QWORD PTR [r10],r11
  40c3b4:	lea    r10,[rbp-0x890]
  40c3bb:	mov    r11,QWORD PTR [rbp-0xa60]
  40c3c2:	mov    QWORD PTR [r10+0x8],r11
  40c3c6:	movd   xmm1,DWORD PTR [rbp-0xa60]
  40c3ce:	movd   xmm0,DWORD PTR [rbp-0xa20]
  40c3d6:	divss  xmm0,xmm1
  40c3da:	movd   ebx,xmm0
  40c3de:	mov    r10,rbx
  40c3e1:	mov    QWORD PTR [rbp-0xa70],r10
  40c3e8:	lea    r10,[rbp-0x890]
  40c3ef:	mov    r11,QWORD PTR [rbp-0xa30]
  40c3f6:	mov    QWORD PTR [r10],r11
  40c3f9:	lea    r10,[rbp-0x890]
  40c400:	mov    r11,QWORD PTR [rbp-0xa60]
  40c407:	mov    QWORD PTR [r10+0x8],r11
  40c40b:	movd   xmm1,DWORD PTR [rbp-0xa60]
  40c413:	movd   xmm0,DWORD PTR [rbp-0xa30]
  40c41b:	divss  xmm0,xmm1
  40c41f:	movd   ebx,xmm0
  40c423:	mov    r10,rbx
  40c426:	mov    QWORD PTR [rbp-0xa78],r10
  40c42d:	lea    r10,[rbp-0x890]
  40c434:	mov    r11,QWORD PTR [rbp-0x9c0]
  40c43b:	mov    QWORD PTR [r10],r11
  40c43e:	lea    r10,[rbp-0x890]
  40c445:	mov    r11,QWORD PTR [rbp-0xa68]
  40c44c:	mov    QWORD PTR [r10+0x8],r11
  40c450:	movd   xmm1,DWORD PTR [rbp-0xa68]
  40c458:	movd   xmm0,DWORD PTR [rbp-0x9c0]
  40c460:	mulss  xmm0,xmm1
  40c464:	movd   ebx,xmm0
  40c468:	mov    rdi,rbx
  40c46b:	lea    r10,[rbp-0x890]
  40c472:	mov    r11,QWORD PTR [rbp-0x9d8]
  40c479:	mov    QWORD PTR [r10],r11
  40c47c:	lea    r10,[rbp-0x890]
  40c483:	mov    r11,QWORD PTR [rbp-0xa70]
  40c48a:	mov    QWORD PTR [r10+0x8],r11
  40c48e:	movd   xmm1,DWORD PTR [rbp-0xa70]
  40c496:	movd   xmm0,DWORD PTR [rbp-0x9d8]
  40c49e:	mulss  xmm0,xmm1
  40c4a2:	movd   ebx,xmm0
  40c4a6:	mov    rsi,rbx
  40c4a9:	lea    r10,[rbp-0x890]
  40c4b0:	mov    r11,rdi
  40c4b3:	mov    QWORD PTR [r10],r11
  40c4b6:	lea    r10,[rbp-0x890]
  40c4bd:	mov    r11,rsi
  40c4c0:	mov    QWORD PTR [r10+0x8],r11
  40c4c4:	movd   xmm1,esi
  40c4c8:	movd   xmm0,edi
  40c4cc:	addss  xmm0,xmm1
  40c4d0:	movd   ebx,xmm0
  40c4d4:	mov    rdi,rbx
  40c4d7:	lea    r10,[rbp-0x890]
  40c4de:	mov    r11,QWORD PTR [rbp-0x9f0]
  40c4e5:	mov    QWORD PTR [r10],r11
  40c4e8:	lea    r10,[rbp-0x890]
  40c4ef:	mov    r11,QWORD PTR [rbp-0xa78]
  40c4f6:	mov    QWORD PTR [r10+0x8],r11
  40c4fa:	movd   xmm1,DWORD PTR [rbp-0xa78]
  40c502:	movd   xmm0,DWORD PTR [rbp-0x9f0]
  40c50a:	mulss  xmm0,xmm1
  40c50e:	movd   ebx,xmm0
  40c512:	mov    rsi,rbx
  40c515:	lea    r10,[rbp-0x890]
  40c51c:	mov    r11,rdi
  40c51f:	mov    QWORD PTR [r10],r11
  40c522:	lea    r10,[rbp-0x890]
  40c529:	mov    r11,rsi
  40c52c:	mov    QWORD PTR [r10+0x8],r11
  40c530:	movd   xmm1,esi
  40c534:	movd   xmm0,edi
  40c538:	addss  xmm0,xmm1
  40c53c:	movd   ebx,xmm0
  40c540:	mov    r10,rbx
  40c543:	mov    QWORD PTR [rbp-0xaa0],r10
  40c54a:	movabs r10,0x0
  40c554:	movd   xmm0,r10d
  40c559:	movd   r10d,xmm0
  40c55e:	pxor   xmm0,xmm0
  40c562:	cvtsi2ss xmm0,r10
  40c567:	movd   r10d,xmm0
  40c56c:	movd   xmm2,r10d
  40c571:	movaps xmm3,xmm2
  40c574:	movd   xmm0,DWORD PTR [rbp-0xaa0]
  40c57c:	movaps xmm1,xmm3
  40c57f:	ucomiss xmm0,xmm1
  40c582:	setb   r10b
  40c586:	setnp  r11b
  40c58a:	and    r10b,r11b
  40c58d:	movzx  r10d,r10b
  40c591:	movd   xmm2,r10d
  40c596:	movd   esi,xmm2
  40c59a:	mov    rdi,rsi
  40c59d:	cmp    rdi,0x1
  40c5a4:	sete   dil
  40c5a8:	movzx  edi,dil
  40c5ac:	mov    esi,edi
  40c5ae:	mov    r10,rsi
  40c5b1:	test   r10d,r10d
  40c5b4:	je     40c5f9 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0xac9>
  40c5ba:	movabs r10,0x0
  40c5c4:	movd   xmm0,r10d
  40c5c9:	movd   r10d,xmm0
  40c5ce:	pxor   xmm0,xmm0
  40c5d2:	cvtsi2ss xmm0,r10
  40c5d7:	movd   r10d,xmm0
  40c5dc:	movd   xmm2,r10d
  40c5e1:	movd   r10d,xmm2
  40c5e6:	mov    QWORD PTR [rbp-0xae0],r10
  40c5ed:	mov    QWORD PTR [rbp-0xae8],r10
  40c5f4:	jmp    40c60e <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0xade>
  40c5f9:	mov    r10,QWORD PTR [rbp-0xaa0]
  40c600:	mov    QWORD PTR [rbp-0xae0],r10
  40c607:	mov    QWORD PTR [rbp-0xae8],r10
  40c60e:	mov    r10,QWORD PTR [rbp-0xae8]
  40c615:	mov    QWORD PTR [rbp-0xaf0],r10
  40c61c:	movabs r10,0x1
  40c626:	movd   xmm0,r10d
  40c62b:	movd   r10d,xmm0
  40c630:	pxor   xmm0,xmm0
  40c634:	cvtsi2ss xmm0,r10
  40c639:	movd   r10d,xmm0
  40c63e:	movd   xmm2,r10d
  40c643:	movaps xmm3,xmm2
  40c646:	movabs r10,0x3e8
  40c650:	movd   xmm0,r10d
  40c655:	movd   r10d,xmm0
  40c65a:	pxor   xmm0,xmm0
  40c65e:	cvtsi2ss xmm0,r10
  40c663:	movd   r10d,xmm0
  40c668:	movd   xmm2,r10d
  40c66d:	movaps xmm4,xmm2
  40c670:	movaps xmm2,xmm3
  40c673:	divss  xmm2,xmm4
  40c677:	movd   esi,xmm2
  40c67b:	lea    r10,[rbp-0x890]
  40c682:	mov    r11,rsi
  40c685:	mov    QWORD PTR [r10],r11
  40c688:	lea    r10,[rbp-0x890]
  40c68f:	mov    r11,QWORD PTR [rbp-0x9c0]
  40c696:	mov    QWORD PTR [r10+0x8],r11
  40c69a:	movd   xmm1,DWORD PTR [rbp-0x9c0]
  40c6a2:	movd   xmm0,esi
  40c6a6:	mulss  xmm0,xmm1
  40c6aa:	movd   ebx,xmm0
  40c6ae:	mov    rdi,rbx
  40c6b1:	lea    r10,[rbp-0x890]
  40c6b8:	mov    r11,QWORD PTR [rbp-0x988]
  40c6bf:	mov    QWORD PTR [r10],r11
  40c6c2:	lea    r10,[rbp-0x890]
  40c6c9:	mov    r11,rdi
  40c6cc:	mov    QWORD PTR [r10+0x8],r11
  40c6d0:	movd   xmm1,edi
  40c6d4:	movd   xmm0,DWORD PTR [rbp-0x988]
  40c6dc:	addss  xmm0,xmm1
  40c6e0:	movd   ebx,xmm0
  40c6e4:	mov    r10,rbx
  40c6e7:	mov    QWORD PTR [rbp-0xb30],r10
  40c6ee:	movabs r10,0x1
  40c6f8:	movd   xmm0,r10d
  40c6fd:	movd   r10d,xmm0
  40c702:	pxor   xmm0,xmm0
  40c706:	cvtsi2ss xmm0,r10
  40c70b:	movd   r10d,xmm0
  40c710:	movd   xmm2,r10d
  40c715:	movaps xmm3,xmm2
  40c718:	movabs r10,0x3e8
  40c722:	movd   xmm0,r10d
  40c727:	movd   r10d,xmm0
  40c72c:	pxor   xmm0,xmm0
  40c730:	cvtsi2ss xmm0,r10
  40c735:	movd   r10d,xmm0
  40c73a:	movd   xmm2,r10d
  40c73f:	movaps xmm4,xmm2
  40c742:	movaps xmm2,xmm3
  40c745:	divss  xmm2,xmm4
  40c749:	movd   esi,xmm2
  40c74d:	lea    r10,[rbp-0x890]
  40c754:	mov    r11,rsi
  40c757:	mov    QWORD PTR [r10],r11
  40c75a:	lea    r10,[rbp-0x890]
  40c761:	mov    r11,QWORD PTR [rbp-0x9d8]
  40c768:	mov    QWORD PTR [r10+0x8],r11
  40c76c:	movd   xmm1,DWORD PTR [rbp-0x9d8]
  40c774:	movd   xmm0,esi
  40c778:	mulss  xmm0,xmm1
  40c77c:	movd   ebx,xmm0
  40c780:	mov    rdi,rbx
  40c783:	lea    r10,[rbp-0x890]
  40c78a:	mov    r11,QWORD PTR [rbp-0x998]
  40c791:	mov    QWORD PTR [r10],r11
  40c794:	lea    r10,[rbp-0x890]
  40c79b:	mov    r11,rdi
  40c79e:	mov    QWORD PTR [r10+0x8],r11
  40c7a2:	movd   xmm1,edi
  40c7a6:	movd   xmm0,DWORD PTR [rbp-0x998]
  40c7ae:	addss  xmm0,xmm1
  40c7b2:	movd   ebx,xmm0
  40c7b6:	mov    r10,rbx
  40c7b9:	mov    QWORD PTR [rbp-0xb70],r10
  40c7c0:	movabs r10,0x1
  40c7ca:	movd   xmm0,r10d
  40c7cf:	movd   r10d,xmm0
  40c7d4:	pxor   xmm0,xmm0
  40c7d8:	cvtsi2ss xmm0,r10
  40c7dd:	movd   r10d,xmm0
  40c7e2:	movd   xmm2,r10d
  40c7e7:	movaps xmm3,xmm2
  40c7ea:	movabs r10,0x3e8
  40c7f4:	movd   xmm0,r10d
  40c7f9:	movd   r10d,xmm0
  40c7fe:	pxor   xmm0,xmm0
  40c802:	cvtsi2ss xmm0,r10
  40c807:	movd   r10d,xmm0
  40c80c:	movd   xmm2,r10d
  40c811:	movaps xmm4,xmm2
  40c814:	movaps xmm2,xmm3
  40c817:	divss  xmm2,xmm4
  40c81b:	movd   esi,xmm2
  40c81f:	lea    r10,[rbp-0x890]
  40c826:	mov    r11,rsi
  40c829:	mov    QWORD PTR [r10],r11
  40c82c:	lea    r10,[rbp-0x890]
  40c833:	mov    r11,QWORD PTR [rbp-0x9f0]
  40c83a:	mov    QWORD PTR [r10+0x8],r11
  40c83e:	movd   xmm1,DWORD PTR [rbp-0x9f0]
  40c846:	movd   xmm0,esi
  40c84a:	mulss  xmm0,xmm1
  40c84e:	movd   ebx,xmm0
  40c852:	mov    rdi,rbx
  40c855:	lea    r10,[rbp-0x890]
  40c85c:	mov    r11,QWORD PTR [rbp-0x9a8]
  40c863:	mov    QWORD PTR [r10],r11
  40c866:	lea    r10,[rbp-0x890]
  40c86d:	mov    r11,rdi
  40c870:	mov    QWORD PTR [r10+0x8],r11
  40c874:	movd   xmm1,edi
  40c878:	movd   xmm0,DWORD PTR [rbp-0x9a8]
  40c880:	addss  xmm0,xmm1
  40c884:	movd   ebx,xmm0
  40c888:	mov    r10,rbx
  40c88b:	mov    QWORD PTR [rbp-0xbb0],r10
  40c892:	lea    r10,[rbp-0x890]
  40c899:	movabs r11,0x3b9aca00
  40c8a3:	mov    QWORD PTR [r10],r11
  40c8a6:	movabs r10,0x3b9aca00
  40c8b0:	movd   xmm0,r10d
  40c8b5:	movd   r10d,xmm0
  40c8ba:	pxor   xmm0,xmm0
  40c8be:	cvtsi2ss xmm0,r10
  40c8c3:	movd   r10d,xmm0
  40c8c8:	mov    rbx,r10
  40c8cb:	mov    r10,rbx
  40c8ce:	mov    QWORD PTR [rbp-0xbb8],r10
  40c8d5:	lea    r10,[rbp-0x890]
  40c8dc:	movabs r11,0x3b9aca00
  40c8e6:	mov    QWORD PTR [r10],r11
  40c8e9:	movabs r10,0x3b9aca00
  40c8f3:	movd   xmm0,r10d
  40c8f8:	movd   r10d,xmm0
  40c8fd:	pxor   xmm0,xmm0
  40c901:	cvtsi2ss xmm0,r10
  40c906:	movd   r10d,xmm0
  40c90b:	mov    rbx,r10
  40c90e:	mov    r10,rbx
  40c911:	mov    QWORD PTR [rbp-0xbc0],r10
  40c918:	mov    rdi,r12
  40c91b:	movabs rsi,0x9
  40c925:	mov    rdx,QWORD PTR [rbp-0xb30]
  40c92c:	mov    rcx,QWORD PTR [rbp-0xb70]
  40c933:	mov    r8,QWORD PTR [rbp-0xbb0]
  40c93a:	mov    r9,QWORD PTR [rbp-0xa68]
  40c941:	mov    r10,QWORD PTR [rbp-0xa70]
  40c948:	mov    QWORD PTR [rsp],r10
  40c94c:	mov    r10,QWORD PTR [rbp-0xa78]
  40c953:	mov    QWORD PTR [rsp+0x8],r10
  40c958:	mov    r10,QWORD PTR [rbp-0xbb8]
  40c95f:	mov    QWORD PTR [rsp+0x10],r10
  40c964:	mov    r10,QWORD PTR [rbp-0xbc0]
  40c96b:	mov    QWORD PTR [rsp+0x18],r10
  40c970:	movabs r10,0x0
  40c97a:	mov    QWORD PTR [rsp+0x20],r10
  40c97f:	xor    eax,eax
  40c981:	call   40b083 <p113d_FID_36_100_105_114_101_99_116_46_110_101_97_114_101_115_116_46_116_>
  40c986:	mov    QWORD PTR [rbp-0xbc8],rax
  40c98d:	movabs r10,0x1
  40c997:	movd   xmm0,r10d
  40c99c:	movd   r10d,xmm0
  40c9a1:	pxor   xmm0,xmm0
  40c9a5:	cvtsi2ss xmm0,r10
  40c9aa:	movd   r10d,xmm0
  40c9af:	movd   xmm2,r10d
  40c9b4:	movaps xmm3,xmm2
  40c9b7:	movabs r10,0xa
  40c9c1:	movd   xmm0,r10d
  40c9c6:	movd   r10d,xmm0
  40c9cb:	pxor   xmm0,xmm0
  40c9cf:	cvtsi2ss xmm0,r10
  40c9d4:	movd   r10d,xmm0
  40c9d9:	movd   xmm2,r10d
  40c9de:	movaps xmm4,xmm2
  40c9e1:	movaps xmm2,xmm3
  40c9e4:	divss  xmm2,xmm4
  40c9e8:	movd   r10d,xmm2
  40c9ed:	mov    QWORD PTR [rbp-0xbf8],r10
  40c9f4:	movabs r10,0x55
  40c9fe:	movd   xmm0,r10d
  40ca03:	movd   r10d,xmm0
  40ca08:	pxor   xmm0,xmm0
  40ca0c:	cvtsi2ss xmm0,r10
  40ca11:	movd   r10d,xmm0
  40ca16:	movd   xmm2,r10d
  40ca1b:	movaps xmm3,xmm2
  40ca1e:	movabs r10,0x64
  40ca28:	movd   xmm0,r10d
  40ca2d:	movd   r10d,xmm0
  40ca32:	pxor   xmm0,xmm0
  40ca36:	cvtsi2ss xmm0,r10
  40ca3b:	movd   r10d,xmm0
  40ca40:	movd   xmm2,r10d
  40ca45:	movaps xmm4,xmm2
  40ca48:	movaps xmm2,xmm3
  40ca4b:	divss  xmm2,xmm4
  40ca4f:	movd   r10d,xmm2
  40ca54:	mov    QWORD PTR [rbp-0xc28],r10
  40ca5b:	movd   xmm0,DWORD PTR [rbp-0xbc8]
  40ca63:	movd   xmm1,DWORD PTR [rbp-0xa60]
  40ca6b:	ucomiss xmm0,xmm1
  40ca6e:	setb   r10b
  40ca72:	setnp  r11b
  40ca76:	and    r10b,r11b
  40ca79:	movzx  r10d,r10b
  40ca7d:	mov    rdi,r10
  40ca80:	mov    rsi,rdi
  40ca83:	cmp    rsi,0x1
  40ca8a:	sete   sil
  40ca8e:	movzx  esi,sil
  40ca92:	mov    edi,esi
  40ca94:	mov    r10,rdi
  40ca97:	test   r10d,r10d
  40ca9a:	je     40cadf <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0xfaf>
  40caa0:	movabs r10,0x0
  40caaa:	movd   xmm0,r10d
  40caaf:	movd   r10d,xmm0
  40cab4:	pxor   xmm0,xmm0
  40cab8:	cvtsi2ss xmm0,r10
  40cabd:	movd   r10d,xmm0
  40cac2:	movd   xmm2,r10d
  40cac7:	movd   r10d,xmm2
  40cacc:	mov    QWORD PTR [rbp-0xc50],r10
  40cad3:	mov    QWORD PTR [rbp-0xc58],r10
  40cada:	jmp    40caf4 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0xfc4>
  40cadf:	mov    r10,QWORD PTR [rbp-0xaf0]
  40cae6:	mov    QWORD PTR [rbp-0xc50],r10
  40caed:	mov    QWORD PTR [rbp-0xc58],r10
  40caf4:	mov    rdi,QWORD PTR [rbp-0xc58]
  40cafb:	lea    r10,[rbp-0x890]
  40cb02:	mov    r11,QWORD PTR [rbp-0xc28]
  40cb09:	mov    QWORD PTR [r10],r11
  40cb0c:	lea    r10,[rbp-0x890]
  40cb13:	mov    r11,rdi
  40cb16:	mov    QWORD PTR [r10+0x8],r11
  40cb1a:	movd   xmm1,edi
  40cb1e:	movd   xmm0,DWORD PTR [rbp-0xc28]
  40cb26:	mulss  xmm0,xmm1
  40cb2a:	movd   ebx,xmm0
  40cb2e:	mov    rdi,rbx
  40cb31:	lea    r10,[rbp-0x890]
  40cb38:	mov    r11,QWORD PTR [rbp-0xbf8]
  40cb3f:	mov    QWORD PTR [r10],r11
  40cb42:	lea    r10,[rbp-0x890]
  40cb49:	mov    r11,rdi
  40cb4c:	mov    QWORD PTR [r10+0x8],r11
  40cb50:	movd   xmm1,edi
  40cb54:	movd   xmm0,DWORD PTR [rbp-0xbf8]
  40cb5c:	addss  xmm0,xmm1
  40cb60:	movd   ebx,xmm0
  40cb64:	mov    rdi,rbx
  40cb67:	lea    r10,[rbp-0x890]
  40cb6e:	mov    r11,QWORD PTR [rbp-0x88]
  40cb75:	mov    QWORD PTR [r10],r11
  40cb78:	lea    r10,[rbp-0x890]
  40cb7f:	mov    r11,rdi
  40cb82:	mov    QWORD PTR [r10+0x8],r11
  40cb86:	movd   xmm1,edi
  40cb8a:	movd   xmm0,DWORD PTR [rbp-0x88]
  40cb92:	mulss  xmm0,xmm1
  40cb96:	movd   ebx,xmm0
  40cb9a:	mov    rdi,rbx
  40cb9d:	lea    r10,[rbp-0x890]
  40cba4:	mov    r11,QWORD PTR [rbp-0x80]
  40cba8:	mov    QWORD PTR [r10],r11
  40cbab:	lea    r10,[rbp-0x890]
  40cbb2:	mov    r11,rdi
  40cbb5:	mov    QWORD PTR [r10+0x8],r11
  40cbb9:	movd   xmm1,edi
  40cbbd:	movd   xmm0,DWORD PTR [rbp-0x80]
  40cbc2:	addss  xmm0,xmm1
  40cbc6:	movd   ebx,xmm0
  40cbca:	mov    rax,rbx
  40cbcd:	mov    r12,QWORD PTR [rbp-0x10]
  40cbd1:	mov    rbx,QWORD PTR [rbp-0x8]
  40cbd5:	mov    r13,QWORD PTR [rbp-0x18]
  40cbd9:	mov    r14,QWORD PTR [rbp-0x20]
  40cbdd:	mov    r15,QWORD PTR [rbp-0x28]
  40cbe1:	mov    rsp,rbp
  40cbe4:	pop    rbp
  40cbe5:	ret    
  40cbe6:	mov    rdi,r12
  40cbe9:	movabs rsi,0x4
  40cbf3:	mov    esi,esi
  40cbf5:	xor    eax,eax
  40cbf7:	call   420a90 <p111_rt_fail>
  40cbfc:	mov    QWORD PTR [rbp-0xc80],rax
  40cc03:	movabs rax,0x0
  40cc0d:	mov    r12,QWORD PTR [rbp-0x10]
  40cc11:	mov    rbx,QWORD PTR [rbp-0x8]
  40cc15:	mov    r13,QWORD PTR [rbp-0x18]
  40cc19:	mov    r14,QWORD PTR [rbp-0x20]
  40cc1d:	mov    r15,QWORD PTR [rbp-0x28]
  40cc21:	mov    rsp,rbp
  40cc24:	pop    rbp
  40cc25:	ret    
  40cc26:	mov    r10,QWORD PTR [rbp-0x30]
  40cc2a:	cmp    r10,0x0
  40cc31:	setne  r10b
  40cc35:	movzx  r10d,r10b
  40cc39:	mov    QWORD PTR [rbp-0x940],r10
  40cc40:	test   r10d,r10d
  40cc43:	je     40e21b <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x26eb>
  40cc49:	mov    r10,QWORD PTR [rbp-0x30]
  40cc4d:	sub    r10,0x1
  40cc54:	mov    QWORD PTR [rbp-0xc88],r10
  40cc5b:	mov    r10,r14
  40cc5e:	cmp    r10,0x1
  40cc65:	sete   r10b
  40cc69:	movzx  r10d,r10b
  40cc6d:	mov    QWORD PTR [rbp-0x948],r10
  40cc74:	mov    r10,r14
  40cc77:	shr    r10,0x28
  40cc7b:	mov    QWORD PTR [rbp-0x950],r10
  40cc82:	and    r10,0x7fffff
  40cc89:	mov    QWORD PTR [rbp-0x950],r10
  40cc90:	movabs r10,0x2
  40cc9a:	or     r10,0x10000
  40cca1:	mov    QWORD PTR [rbp-0x958],r10
  40cca8:	mov    r10,QWORD PTR [rbp-0x950]
  40ccaf:	mov    r11,QWORD PTR [rbp-0x958]
  40ccb6:	cmp    r10,r11
  40ccb9:	sete   r10b
  40ccbd:	movzx  r10d,r10b
  40ccc1:	mov    QWORD PTR [rbp-0x960],r10
  40ccc8:	mov    r10,QWORD PTR [rbp-0x948]
  40cccf:	mov    r11,QWORD PTR [rbp-0x960]
  40ccd6:	or     r10d,r11d
  40ccd9:	mov    QWORD PTR [rbp-0x940],r10
  40cce0:	test   r10d,r10d
  40cce3:	je     40cd06 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x11d6>
  40cce9:	mov    rax,QWORD PTR [rbp-0x80]
  40cced:	mov    r12,QWORD PTR [rbp-0x10]
  40ccf1:	mov    rbx,QWORD PTR [rbp-0x8]
  40ccf5:	mov    r13,QWORD PTR [rbp-0x18]
  40ccf9:	mov    r14,QWORD PTR [rbp-0x20]
  40ccfd:	mov    r15,QWORD PTR [rbp-0x28]
  40cd01:	mov    rsp,rbp
  40cd04:	pop    rbp
  40cd05:	ret    
  40cd06:	mov    r10,r14
  40cd09:	cmp    r10,0x1
  40cd10:	sete   r10b
  40cd14:	movzx  r10d,r10b
  40cd18:	mov    QWORD PTR [rbp-0x948],r10
  40cd1f:	mov    r10,r14
  40cd22:	shr    r10,0x28
  40cd26:	mov    QWORD PTR [rbp-0x950],r10
  40cd2d:	and    r10,0x7fffff
  40cd34:	mov    QWORD PTR [rbp-0x950],r10
  40cd3b:	movabs r10,0x2
  40cd45:	or     r10,0x10000
  40cd4c:	mov    QWORD PTR [rbp-0x958],r10
  40cd53:	mov    r10,QWORD PTR [rbp-0x950]
  40cd5a:	mov    r11,QWORD PTR [rbp-0x958]
  40cd61:	cmp    r10,r11
  40cd64:	sete   r10b
  40cd68:	movzx  r10d,r10b
  40cd6c:	mov    QWORD PTR [rbp-0x960],r10
  40cd73:	mov    r10,QWORD PTR [rbp-0x948]
  40cd7a:	mov    r11,QWORD PTR [rbp-0x960]
  40cd81:	or     r10d,r11d
  40cd84:	mov    QWORD PTR [rbp-0x940],r10
  40cd8b:	xor    r10d,0x1
  40cd92:	mov    QWORD PTR [rbp-0x940],r10
  40cd99:	test   r10d,r10d
  40cd9c:	je     40e1db <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x26ab>
  40cda2:	mov    rbx,QWORD PTR [rbp-0x48]
  40cda6:	mov    r10,rbx
  40cda9:	mov    QWORD PTR [rbp-0xc90],r10
  40cdb0:	mov    rdi,r12
  40cdb3:	mov    rsi,QWORD PTR [rbp-0xc90]
  40cdba:	xor    eax,eax
  40cdbc:	call   408b1b <p113d_FID_36_100_105_114_101_99_116_46_115_114_>
  40cdc1:	mov    QWORD PTR [rbp-0xc98],rax
  40cdc8:	lea    r10,[rbp-0x890]
  40cdcf:	mov    r11,r13
  40cdd2:	mov    QWORD PTR [r10],r11
  40cdd5:	lea    r10,[rbp-0x890]
  40cddc:	mov    r11,r15
  40cddf:	mov    QWORD PTR [r10+0x8],r11
  40cde3:	movd   xmm1,r15d
  40cde8:	movd   xmm0,r13d
  40cded:	mulss  xmm0,xmm1
  40cdf1:	movd   ebx,xmm0
  40cdf5:	mov    rdi,rbx
  40cdf8:	lea    r10,[rbp-0x890]
  40cdff:	mov    r11,QWORD PTR [rbp-0x50]
  40ce03:	mov    QWORD PTR [r10],r11
  40ce06:	lea    r10,[rbp-0x890]
  40ce0d:	mov    r11,rdi
  40ce10:	mov    QWORD PTR [r10+0x8],r11
  40ce14:	movd   xmm1,edi
  40ce18:	movd   xmm0,DWORD PTR [rbp-0x50]
  40ce1d:	addss  xmm0,xmm1
  40ce21:	movd   ebx,xmm0
  40ce25:	mov    r10,rbx
  40ce28:	mov    QWORD PTR [rbp-0xca8],r10
  40ce2f:	lea    r10,[rbp-0x890]
  40ce36:	mov    r11,r13
  40ce39:	mov    QWORD PTR [r10],r11
  40ce3c:	lea    r10,[rbp-0x890]
  40ce43:	mov    r11,QWORD PTR [rbp-0x70]
  40ce47:	mov    QWORD PTR [r10+0x8],r11
  40ce4b:	movd   xmm1,DWORD PTR [rbp-0x70]
  40ce50:	movd   xmm0,r13d
  40ce55:	mulss  xmm0,xmm1
  40ce59:	movd   ebx,xmm0
  40ce5d:	mov    rdi,rbx
  40ce60:	lea    r10,[rbp-0x890]
  40ce67:	mov    r11,QWORD PTR [rbp-0x58]
  40ce6b:	mov    QWORD PTR [r10],r11
  40ce6e:	lea    r10,[rbp-0x890]
  40ce75:	mov    r11,rdi
  40ce78:	mov    QWORD PTR [r10+0x8],r11
  40ce7c:	movd   xmm1,edi
  40ce80:	movd   xmm0,DWORD PTR [rbp-0x58]
  40ce85:	addss  xmm0,xmm1
  40ce89:	movd   ebx,xmm0
  40ce8d:	mov    r10,rbx
  40ce90:	mov    QWORD PTR [rbp-0xcb8],r10
  40ce97:	lea    r10,[rbp-0x890]
  40ce9e:	mov    r11,r13
  40cea1:	mov    QWORD PTR [r10],r11
  40cea4:	lea    r10,[rbp-0x890]
  40ceab:	mov    r11,QWORD PTR [rbp-0x78]
  40ceaf:	mov    QWORD PTR [r10+0x8],r11
  40ceb3:	movd   xmm1,DWORD PTR [rbp-0x78]
  40ceb8:	movd   xmm0,r13d
  40cebd:	mulss  xmm0,xmm1
  40cec1:	movd   ebx,xmm0
  40cec5:	mov    rdi,rbx
  40cec8:	lea    r10,[rbp-0x890]
  40cecf:	mov    r11,QWORD PTR [rbp-0x60]
  40ced3:	mov    QWORD PTR [r10],r11
  40ced6:	lea    r10,[rbp-0x890]
  40cedd:	mov    r11,rdi
  40cee0:	mov    QWORD PTR [r10+0x8],r11
  40cee4:	movd   xmm1,edi
  40cee8:	movd   xmm0,DWORD PTR [rbp-0x60]
  40ceed:	addss  xmm0,xmm1
  40cef1:	movd   ebx,xmm0
  40cef5:	mov    r10,rbx
  40cef8:	mov    QWORD PTR [rbp-0xcc8],r10
  40ceff:	mov    rdi,r12
  40cf02:	mov    rsi,QWORD PTR [rbp-0xc90]
  40cf09:	xor    eax,eax
  40cf0b:	call   408ea5 <p113d_FID_36_100_105_114_101_99_116_46_115_120_>
  40cf10:	mov    QWORD PTR [rbp-0xcd0],rax
  40cf17:	lea    r10,[rbp-0x890]
  40cf1e:	mov    r11,QWORD PTR [rbp-0xca8]
  40cf25:	mov    QWORD PTR [r10],r11
  40cf28:	lea    r10,[rbp-0x890]
  40cf2f:	mov    r11,QWORD PTR [rbp-0xcd0]
  40cf36:	mov    QWORD PTR [r10+0x8],r11
  40cf3a:	movd   xmm1,DWORD PTR [rbp-0xcd0]
  40cf42:	movd   xmm0,DWORD PTR [rbp-0xca8]
  40cf4a:	subss  xmm0,xmm1
  40cf4e:	movd   ebx,xmm0
  40cf52:	mov    rdi,rbx
  40cf55:	lea    r10,[rbp-0x890]
  40cf5c:	mov    r11,rdi
  40cf5f:	mov    QWORD PTR [r10],r11
  40cf62:	lea    r10,[rbp-0x890]
  40cf69:	mov    r11,QWORD PTR [rbp-0xc98]
  40cf70:	mov    QWORD PTR [r10+0x8],r11
  40cf74:	movd   xmm1,DWORD PTR [rbp-0xc98]
  40cf7c:	movd   xmm0,edi
  40cf80:	divss  xmm0,xmm1
  40cf84:	movd   ebx,xmm0
  40cf88:	mov    r10,rbx
  40cf8b:	mov    QWORD PTR [rbp-0xce0],r10
  40cf92:	mov    rdi,r12
  40cf95:	mov    rsi,QWORD PTR [rbp-0xc90]
  40cf9c:	xor    eax,eax
  40cf9e:	call   408d77 <p113d_FID_36_100_105_114_101_99_116_46_115_121_>
  40cfa3:	mov    QWORD PTR [rbp-0xce8],rax
  40cfaa:	lea    r10,[rbp-0x890]
  40cfb1:	mov    r11,QWORD PTR [rbp-0xcb8]
  40cfb8:	mov    QWORD PTR [r10],r11
  40cfbb:	lea    r10,[rbp-0x890]
  40cfc2:	mov    r11,QWORD PTR [rbp-0xce8]
  40cfc9:	mov    QWORD PTR [r10+0x8],r11
  40cfcd:	movd   xmm1,DWORD PTR [rbp-0xce8]
  40cfd5:	movd   xmm0,DWORD PTR [rbp-0xcb8]
  40cfdd:	subss  xmm0,xmm1
  40cfe1:	movd   ebx,xmm0
  40cfe5:	mov    rdi,rbx
  40cfe8:	lea    r10,[rbp-0x890]
  40cfef:	mov    r11,rdi
  40cff2:	mov    QWORD PTR [r10],r11
  40cff5:	lea    r10,[rbp-0x890]
  40cffc:	mov    r11,QWORD PTR [rbp-0xc98]
  40d003:	mov    QWORD PTR [r10+0x8],r11
  40d007:	movd   xmm1,DWORD PTR [rbp-0xc98]
  40d00f:	movd   xmm0,edi
  40d013:	divss  xmm0,xmm1
  40d017:	movd   ebx,xmm0
  40d01b:	mov    r10,rbx
  40d01e:	mov    QWORD PTR [rbp-0xcf8],r10
  40d025:	mov    rdi,r12
  40d028:	mov    rsi,QWORD PTR [rbp-0xc90]
  40d02f:	xor    eax,eax
  40d031:	call   408c49 <p113d_FID_36_100_105_114_101_99_116_46_115_122_>
  40d036:	mov    QWORD PTR [rbp-0xd00],rax
  40d03d:	lea    r10,[rbp-0x890]
  40d044:	mov    r11,QWORD PTR [rbp-0xcc8]
  40d04b:	mov    QWORD PTR [r10],r11
  40d04e:	lea    r10,[rbp-0x890]
  40d055:	mov    r11,QWORD PTR [rbp-0xd00]
  40d05c:	mov    QWORD PTR [r10+0x8],r11
  40d060:	movd   xmm1,DWORD PTR [rbp-0xd00]
  40d068:	movd   xmm0,DWORD PTR [rbp-0xcc8]
  40d070:	subss  xmm0,xmm1
  40d074:	movd   ebx,xmm0
  40d078:	mov    rdi,rbx
  40d07b:	lea    r10,[rbp-0x890]
  40d082:	mov    r11,rdi
  40d085:	mov    QWORD PTR [r10],r11
  40d088:	lea    r10,[rbp-0x890]
  40d08f:	mov    r11,QWORD PTR [rbp-0xc98]
  40d096:	mov    QWORD PTR [r10+0x8],r11
  40d09a:	movd   xmm1,DWORD PTR [rbp-0xc98]
  40d0a2:	movd   xmm0,edi
  40d0a6:	divss  xmm0,xmm1
  40d0aa:	movd   ebx,xmm0
  40d0ae:	mov    r10,rbx
  40d0b1:	mov    QWORD PTR [rbp-0xd10],r10
  40d0b8:	lea    r10,[rbp-0x890]
  40d0bf:	movabs r11,0x0
  40d0c9:	mov    QWORD PTR [r10],r11
  40d0cc:	movabs r10,0x0
  40d0d6:	movd   xmm0,r10d
  40d0db:	movd   r10d,xmm0
  40d0e0:	pxor   xmm0,xmm0
  40d0e4:	cvtsi2ss xmm0,r10
  40d0e9:	movd   r10d,xmm0
  40d0ee:	mov    rbx,r10
  40d0f1:	mov    rdi,rbx
  40d0f4:	lea    r10,[rbp-0x890]
  40d0fb:	movabs r11,0x3
  40d105:	mov    QWORD PTR [r10],r11
  40d108:	movabs r10,0x3
  40d112:	movd   xmm0,r10d
  40d117:	movd   r10d,xmm0
  40d11c:	pxor   xmm0,xmm0
  40d120:	cvtsi2ss xmm0,r10
  40d125:	movd   r10d,xmm0
  40d12a:	mov    rbx,r10
  40d12d:	mov    rsi,rbx
  40d130:	lea    r10,[rbp-0x890]
  40d137:	mov    r11,rdi
  40d13a:	mov    QWORD PTR [r10],r11
  40d13d:	lea    r10,[rbp-0x890]
  40d144:	mov    r11,rsi
  40d147:	mov    QWORD PTR [r10+0x8],r11
  40d14b:	movd   xmm1,esi
  40d14f:	movd   xmm0,edi
  40d153:	subss  xmm0,xmm1
  40d157:	movd   ebx,xmm0
  40d15b:	mov    rdi,rbx
  40d15e:	lea    r10,[rbp-0x890]
  40d165:	mov    r11,rdi
  40d168:	mov    QWORD PTR [r10],r11
  40d16b:	lea    r10,[rbp-0x890]
  40d172:	mov    r11,QWORD PTR [rbp-0xca8]
  40d179:	mov    QWORD PTR [r10+0x8],r11
  40d17d:	movd   xmm1,DWORD PTR [rbp-0xca8]
  40d185:	movd   xmm0,edi
  40d189:	subss  xmm0,xmm1
  40d18d:	movd   ebx,xmm0
  40d191:	mov    r10,rbx
  40d194:	mov    QWORD PTR [rbp-0xd30],r10
  40d19b:	lea    r10,[rbp-0x890]
  40d1a2:	movabs r11,0x8
  40d1ac:	mov    QWORD PTR [r10],r11
  40d1af:	movabs r10,0x8
  40d1b9:	movd   xmm0,r10d
  40d1be:	movd   r10d,xmm0
  40d1c3:	pxor   xmm0,xmm0
  40d1c7:	cvtsi2ss xmm0,r10
  40d1cc:	movd   r10d,xmm0
  40d1d1:	mov    rbx,r10
  40d1d4:	mov    rdi,rbx
  40d1d7:	lea    r10,[rbp-0x890]
  40d1de:	mov    r11,rdi
  40d1e1:	mov    QWORD PTR [r10],r11
  40d1e4:	lea    r10,[rbp-0x890]
  40d1eb:	mov    r11,QWORD PTR [rbp-0xcb8]
  40d1f2:	mov    QWORD PTR [r10+0x8],r11
  40d1f6:	movd   xmm1,DWORD PTR [rbp-0xcb8]
  40d1fe:	movd   xmm0,edi
  40d202:	subss  xmm0,xmm1
  40d206:	movd   ebx,xmm0
  40d20a:	mov    r10,rbx
  40d20d:	mov    QWORD PTR [rbp-0xd40],r10
  40d214:	lea    r10,[rbp-0x890]
  40d21b:	movabs r11,0x1
  40d225:	mov    QWORD PTR [r10],r11
  40d228:	movabs r10,0x1
  40d232:	movd   xmm0,r10d
  40d237:	movd   r10d,xmm0
  40d23c:	pxor   xmm0,xmm0
  40d240:	cvtsi2ss xmm0,r10
  40d245:	movd   r10d,xmm0
  40d24a:	mov    rbx,r10
  40d24d:	mov    rdi,rbx
  40d250:	lea    r10,[rbp-0x890]
  40d257:	mov    r11,rdi
  40d25a:	mov    QWORD PTR [r10],r11
  40d25d:	lea    r10,[rbp-0x890]
  40d264:	mov    r11,QWORD PTR [rbp-0xcc8]
  40d26b:	mov    QWORD PTR [r10+0x8],r11
  40d26f:	movd   xmm1,DWORD PTR [rbp-0xcc8]
  40d277:	movd   xmm0,edi
  40d27b:	subss  xmm0,xmm1
  40d27f:	movd   ebx,xmm0
  40d283:	mov    r10,rbx
  40d286:	mov    QWORD PTR [rbp-0xd50],r10
  40d28d:	lea    r10,[rbp-0x890]
  40d294:	mov    r11,QWORD PTR [rbp-0xd30]
  40d29b:	mov    QWORD PTR [r10],r11
  40d29e:	lea    r10,[rbp-0x890]
  40d2a5:	mov    r11,QWORD PTR [rbp-0xd30]
  40d2ac:	mov    QWORD PTR [r10+0x8],r11
  40d2b0:	movd   xmm1,DWORD PTR [rbp-0xd30]
  40d2b8:	movd   xmm0,DWORD PTR [rbp-0xd30]
  40d2c0:	mulss  xmm0,xmm1
  40d2c4:	movd   ebx,xmm0
  40d2c8:	mov    rdi,rbx
  40d2cb:	lea    r10,[rbp-0x890]
  40d2d2:	mov    r11,QWORD PTR [rbp-0xd40]
  40d2d9:	mov    QWORD PTR [r10],r11
  40d2dc:	lea    r10,[rbp-0x890]
  40d2e3:	mov    r11,QWORD PTR [rbp-0xd40]
  40d2ea:	mov    QWORD PTR [r10+0x8],r11
  40d2ee:	movd   xmm1,DWORD PTR [rbp-0xd40]
  40d2f6:	movd   xmm0,DWORD PTR [rbp-0xd40]
  40d2fe:	mulss  xmm0,xmm1
  40d302:	movd   ebx,xmm0
  40d306:	mov    rsi,rbx
  40d309:	lea    r10,[rbp-0x890]
  40d310:	mov    r11,rdi
  40d313:	mov    QWORD PTR [r10],r11
  40d316:	lea    r10,[rbp-0x890]
  40d31d:	mov    r11,rsi
  40d320:	mov    QWORD PTR [r10+0x8],r11
  40d324:	movd   xmm1,esi
  40d328:	movd   xmm0,edi
  40d32c:	addss  xmm0,xmm1
  40d330:	movd   ebx,xmm0
  40d334:	mov    rdi,rbx
  40d337:	lea    r10,[rbp-0x890]
  40d33e:	mov    r11,QWORD PTR [rbp-0xd50]
  40d345:	mov    QWORD PTR [r10],r11
  40d348:	lea    r10,[rbp-0x890]
  40d34f:	mov    r11,QWORD PTR [rbp-0xd50]
  40d356:	mov    QWORD PTR [r10+0x8],r11
  40d35a:	movd   xmm1,DWORD PTR [rbp-0xd50]
  40d362:	movd   xmm0,DWORD PTR [rbp-0xd50]
  40d36a:	mulss  xmm0,xmm1
  40d36e:	movd   ebx,xmm0
  40d372:	mov    rsi,rbx
  40d375:	lea    r10,[rbp-0x890]
  40d37c:	mov    r11,rdi
  40d37f:	mov    QWORD PTR [r10],r11
  40d382:	lea    r10,[rbp-0x890]
  40d389:	mov    r11,rsi
  40d38c:	mov    QWORD PTR [r10+0x8],r11
  40d390:	movd   xmm1,esi
  40d394:	movd   xmm0,edi
  40d398:	addss  xmm0,xmm1
  40d39c:	movd   ebx,xmm0
  40d3a0:	mov    rdi,rbx
  40d3a3:	lea    r10,[rbp-0x890]
  40d3aa:	mov    r11,rdi
  40d3ad:	mov    QWORD PTR [r10],r11
  40d3b0:	mov    rdi,r12
  40d3b3:	movabs rsi,0x24
  40d3bd:	mov    esi,esi
  40d3bf:	lea    rdx,[rbp-0x890]
  40d3c6:	movabs rcx,0x1
  40d3d0:	mov    ecx,ecx
  40d3d2:	xor    eax,eax
  40d3d4:	call   420ab0 <p111_rt_op>
  40d3d9:	mov    rbx,rax
  40d3dc:	mov    r10,rbx
  40d3df:	mov    QWORD PTR [rbp-0xd80],r10
  40d3e6:	lea    r10,[rbp-0x890]
  40d3ed:	mov    r11,QWORD PTR [rbp-0xd30]
  40d3f4:	mov    QWORD PTR [r10],r11
  40d3f7:	lea    r10,[rbp-0x890]
  40d3fe:	mov    r11,QWORD PTR [rbp-0xd80]
  40d405:	mov    QWORD PTR [r10+0x8],r11
  40d409:	movd   xmm1,DWORD PTR [rbp-0xd80]
  40d411:	movd   xmm0,DWORD PTR [rbp-0xd30]
  40d419:	divss  xmm0,xmm1
  40d41d:	movd   ebx,xmm0
  40d421:	mov    r10,rbx
  40d424:	mov    QWORD PTR [rbp-0xd88],r10
  40d42b:	lea    r10,[rbp-0x890]
  40d432:	mov    r11,QWORD PTR [rbp-0xd40]
  40d439:	mov    QWORD PTR [r10],r11
  40d43c:	lea    r10,[rbp-0x890]
  40d443:	mov    r11,QWORD PTR [rbp-0xd80]
  40d44a:	mov    QWORD PTR [r10+0x8],r11
  40d44e:	movd   xmm1,DWORD PTR [rbp-0xd80]
  40d456:	movd   xmm0,DWORD PTR [rbp-0xd40]
  40d45e:	divss  xmm0,xmm1
  40d462:	movd   ebx,xmm0
  40d466:	mov    r10,rbx
  40d469:	mov    QWORD PTR [rbp-0xd90],r10
  40d470:	lea    r10,[rbp-0x890]
  40d477:	mov    r11,QWORD PTR [rbp-0xd50]
  40d47e:	mov    QWORD PTR [r10],r11
  40d481:	lea    r10,[rbp-0x890]
  40d488:	mov    r11,QWORD PTR [rbp-0xd80]
  40d48f:	mov    QWORD PTR [r10+0x8],r11
  40d493:	movd   xmm1,DWORD PTR [rbp-0xd80]
  40d49b:	movd   xmm0,DWORD PTR [rbp-0xd50]
  40d4a3:	divss  xmm0,xmm1
  40d4a7:	movd   ebx,xmm0
  40d4ab:	mov    r10,rbx
  40d4ae:	mov    QWORD PTR [rbp-0xd98],r10
  40d4b5:	lea    r10,[rbp-0x890]
  40d4bc:	mov    r11,QWORD PTR [rbp-0xce0]
  40d4c3:	mov    QWORD PTR [r10],r11
  40d4c6:	lea    r10,[rbp-0x890]
  40d4cd:	mov    r11,QWORD PTR [rbp-0xd88]
  40d4d4:	mov    QWORD PTR [r10+0x8],r11
  40d4d8:	movd   xmm1,DWORD PTR [rbp-0xd88]
  40d4e0:	movd   xmm0,DWORD PTR [rbp-0xce0]
  40d4e8:	mulss  xmm0,xmm1
  40d4ec:	movd   ebx,xmm0
  40d4f0:	mov    rdi,rbx
  40d4f3:	lea    r10,[rbp-0x890]
  40d4fa:	mov    r11,QWORD PTR [rbp-0xcf8]
  40d501:	mov    QWORD PTR [r10],r11
  40d504:	lea    r10,[rbp-0x890]
  40d50b:	mov    r11,QWORD PTR [rbp-0xd90]
  40d512:	mov    QWORD PTR [r10+0x8],r11
  40d516:	movd   xmm1,DWORD PTR [rbp-0xd90]
  40d51e:	movd   xmm0,DWORD PTR [rbp-0xcf8]
  40d526:	mulss  xmm0,xmm1
  40d52a:	movd   ebx,xmm0
  40d52e:	mov    rsi,rbx
  40d531:	lea    r10,[rbp-0x890]
  40d538:	mov    r11,rdi
  40d53b:	mov    QWORD PTR [r10],r11
  40d53e:	lea    r10,[rbp-0x890]
  40d545:	mov    r11,rsi
  40d548:	mov    QWORD PTR [r10+0x8],r11
  40d54c:	movd   xmm1,esi
  40d550:	movd   xmm0,edi
  40d554:	addss  xmm0,xmm1
  40d558:	movd   ebx,xmm0
  40d55c:	mov    rdi,rbx
  40d55f:	lea    r10,[rbp-0x890]
  40d566:	mov    r11,QWORD PTR [rbp-0xd10]
  40d56d:	mov    QWORD PTR [r10],r11
  40d570:	lea    r10,[rbp-0x890]
  40d577:	mov    r11,QWORD PTR [rbp-0xd98]
  40d57e:	mov    QWORD PTR [r10+0x8],r11
  40d582:	movd   xmm1,DWORD PTR [rbp-0xd98]
  40d58a:	movd   xmm0,DWORD PTR [rbp-0xd10]
  40d592:	mulss  xmm0,xmm1
  40d596:	movd   ebx,xmm0
  40d59a:	mov    rsi,rbx
  40d59d:	lea    r10,[rbp-0x890]
  40d5a4:	mov    r11,rdi
  40d5a7:	mov    QWORD PTR [r10],r11
  40d5aa:	lea    r10,[rbp-0x890]
  40d5b1:	mov    r11,rsi
  40d5b4:	mov    QWORD PTR [r10+0x8],r11
  40d5b8:	movd   xmm1,esi
  40d5bc:	movd   xmm0,edi
  40d5c0:	addss  xmm0,xmm1
  40d5c4:	movd   ebx,xmm0
  40d5c8:	mov    r10,rbx
  40d5cb:	mov    QWORD PTR [rbp-0xdc0],r10
  40d5d2:	movabs r10,0x0
  40d5dc:	movd   xmm0,r10d
  40d5e1:	movd   r10d,xmm0
  40d5e6:	pxor   xmm0,xmm0
  40d5ea:	cvtsi2ss xmm0,r10
  40d5ef:	movd   r10d,xmm0
  40d5f4:	movd   xmm2,r10d
  40d5f9:	movaps xmm3,xmm2
  40d5fc:	movd   xmm0,DWORD PTR [rbp-0xdc0]
  40d604:	movaps xmm1,xmm3
  40d607:	ucomiss xmm0,xmm1
  40d60a:	setb   r10b
  40d60e:	setnp  r11b
  40d612:	and    r10b,r11b
  40d615:	movzx  r10d,r10b
  40d619:	movd   xmm2,r10d
  40d61e:	movd   esi,xmm2
  40d622:	mov    rdi,rsi
  40d625:	cmp    rdi,0x1
  40d62c:	sete   dil
  40d630:	movzx  edi,dil
  40d634:	mov    esi,edi
  40d636:	mov    r10,rsi
  40d639:	test   r10d,r10d
  40d63c:	je     40d681 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x1b51>
  40d642:	movabs r10,0x0
  40d64c:	movd   xmm0,r10d
  40d651:	movd   r10d,xmm0
  40d656:	pxor   xmm0,xmm0
  40d65a:	cvtsi2ss xmm0,r10
  40d65f:	movd   r10d,xmm0
  40d664:	movd   xmm2,r10d
  40d669:	movd   r10d,xmm2
  40d66e:	mov    QWORD PTR [rbp-0xe00],r10
  40d675:	mov    QWORD PTR [rbp-0xe08],r10
  40d67c:	jmp    40d696 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x1b66>
  40d681:	mov    r10,QWORD PTR [rbp-0xdc0]
  40d688:	mov    QWORD PTR [rbp-0xe00],r10
  40d68f:	mov    QWORD PTR [rbp-0xe08],r10
  40d696:	mov    r10,QWORD PTR [rbp-0xe08]
  40d69d:	mov    QWORD PTR [rbp-0xe10],r10
  40d6a4:	movabs r10,0x1
  40d6ae:	movd   xmm0,r10d
  40d6b3:	movd   r10d,xmm0
  40d6b8:	pxor   xmm0,xmm0
  40d6bc:	cvtsi2ss xmm0,r10
  40d6c1:	movd   r10d,xmm0
  40d6c6:	movd   xmm2,r10d
  40d6cb:	movaps xmm3,xmm2
  40d6ce:	movabs r10,0x3e8
  40d6d8:	movd   xmm0,r10d
  40d6dd:	movd   r10d,xmm0
  40d6e2:	pxor   xmm0,xmm0
  40d6e6:	cvtsi2ss xmm0,r10
  40d6eb:	movd   r10d,xmm0
  40d6f0:	movd   xmm2,r10d
  40d6f5:	movaps xmm4,xmm2
  40d6f8:	movaps xmm2,xmm3
  40d6fb:	divss  xmm2,xmm4
  40d6ff:	movd   esi,xmm2
  40d703:	lea    r10,[rbp-0x890]
  40d70a:	mov    r11,rsi
  40d70d:	mov    QWORD PTR [r10],r11
  40d710:	lea    r10,[rbp-0x890]
  40d717:	mov    r11,QWORD PTR [rbp-0xce0]
  40d71e:	mov    QWORD PTR [r10+0x8],r11
  40d722:	movd   xmm1,DWORD PTR [rbp-0xce0]
  40d72a:	movd   xmm0,esi
  40d72e:	mulss  xmm0,xmm1
  40d732:	movd   ebx,xmm0
  40d736:	mov    rdi,rbx
  40d739:	lea    r10,[rbp-0x890]
  40d740:	mov    r11,QWORD PTR [rbp-0xca8]
  40d747:	mov    QWORD PTR [r10],r11
  40d74a:	lea    r10,[rbp-0x890]
  40d751:	mov    r11,rdi
  40d754:	mov    QWORD PTR [r10+0x8],r11
  40d758:	movd   xmm1,edi
  40d75c:	movd   xmm0,DWORD PTR [rbp-0xca8]
  40d764:	addss  xmm0,xmm1
  40d768:	movd   ebx,xmm0
  40d76c:	mov    r10,rbx
  40d76f:	mov    QWORD PTR [rbp-0xe50],r10
  40d776:	movabs r10,0x1
  40d780:	movd   xmm0,r10d
  40d785:	movd   r10d,xmm0
  40d78a:	pxor   xmm0,xmm0
  40d78e:	cvtsi2ss xmm0,r10
  40d793:	movd   r10d,xmm0
  40d798:	movd   xmm2,r10d
  40d79d:	movaps xmm3,xmm2
  40d7a0:	movabs r10,0x3e8
  40d7aa:	movd   xmm0,r10d
  40d7af:	movd   r10d,xmm0
  40d7b4:	pxor   xmm0,xmm0
  40d7b8:	cvtsi2ss xmm0,r10
  40d7bd:	movd   r10d,xmm0
  40d7c2:	movd   xmm2,r10d
  40d7c7:	movaps xmm4,xmm2
  40d7ca:	movaps xmm2,xmm3
  40d7cd:	divss  xmm2,xmm4
  40d7d1:	movd   esi,xmm2
  40d7d5:	lea    r10,[rbp-0x890]
  40d7dc:	mov    r11,rsi
  40d7df:	mov    QWORD PTR [r10],r11
  40d7e2:	lea    r10,[rbp-0x890]
  40d7e9:	mov    r11,QWORD PTR [rbp-0xcf8]
  40d7f0:	mov    QWORD PTR [r10+0x8],r11
  40d7f4:	movd   xmm1,DWORD PTR [rbp-0xcf8]
  40d7fc:	movd   xmm0,esi
  40d800:	mulss  xmm0,xmm1
  40d804:	movd   ebx,xmm0
  40d808:	mov    rdi,rbx
  40d80b:	lea    r10,[rbp-0x890]
  40d812:	mov    r11,QWORD PTR [rbp-0xcb8]
  40d819:	mov    QWORD PTR [r10],r11
  40d81c:	lea    r10,[rbp-0x890]
  40d823:	mov    r11,rdi
  40d826:	mov    QWORD PTR [r10+0x8],r11
  40d82a:	movd   xmm1,edi
  40d82e:	movd   xmm0,DWORD PTR [rbp-0xcb8]
  40d836:	addss  xmm0,xmm1
  40d83a:	movd   ebx,xmm0
  40d83e:	mov    r10,rbx
  40d841:	mov    QWORD PTR [rbp-0xe90],r10
  40d848:	movabs r10,0x1
  40d852:	movd   xmm0,r10d
  40d857:	movd   r10d,xmm0
  40d85c:	pxor   xmm0,xmm0
  40d860:	cvtsi2ss xmm0,r10
  40d865:	movd   r10d,xmm0
  40d86a:	movd   xmm2,r10d
  40d86f:	movaps xmm3,xmm2
  40d872:	movabs r10,0x3e8
  40d87c:	movd   xmm0,r10d
  40d881:	movd   r10d,xmm0
  40d886:	pxor   xmm0,xmm0
  40d88a:	cvtsi2ss xmm0,r10
  40d88f:	movd   r10d,xmm0
  40d894:	movd   xmm2,r10d
  40d899:	movaps xmm4,xmm2
  40d89c:	movaps xmm2,xmm3
  40d89f:	divss  xmm2,xmm4
  40d8a3:	movd   esi,xmm2
  40d8a7:	lea    r10,[rbp-0x890]
  40d8ae:	mov    r11,rsi
  40d8b1:	mov    QWORD PTR [r10],r11
  40d8b4:	lea    r10,[rbp-0x890]
  40d8bb:	mov    r11,QWORD PTR [rbp-0xd10]
  40d8c2:	mov    QWORD PTR [r10+0x8],r11
  40d8c6:	movd   xmm1,DWORD PTR [rbp-0xd10]
  40d8ce:	movd   xmm0,esi
  40d8d2:	mulss  xmm0,xmm1
  40d8d6:	movd   ebx,xmm0
  40d8da:	mov    rdi,rbx
  40d8dd:	lea    r10,[rbp-0x890]
  40d8e4:	mov    r11,QWORD PTR [rbp-0xcc8]
  40d8eb:	mov    QWORD PTR [r10],r11
  40d8ee:	lea    r10,[rbp-0x890]
  40d8f5:	mov    r11,rdi
  40d8f8:	mov    QWORD PTR [r10+0x8],r11
  40d8fc:	movd   xmm1,edi
  40d900:	movd   xmm0,DWORD PTR [rbp-0xcc8]
  40d908:	addss  xmm0,xmm1
  40d90c:	movd   ebx,xmm0
  40d910:	mov    r10,rbx
  40d913:	mov    QWORD PTR [rbp-0xed0],r10
  40d91a:	lea    r10,[rbp-0x890]
  40d921:	movabs r11,0x3b9aca00
  40d92b:	mov    QWORD PTR [r10],r11
  40d92e:	movabs r10,0x3b9aca00
  40d938:	movd   xmm0,r10d
  40d93d:	movd   r10d,xmm0
  40d942:	pxor   xmm0,xmm0
  40d946:	cvtsi2ss xmm0,r10
  40d94b:	movd   r10d,xmm0
  40d950:	mov    rbx,r10
  40d953:	mov    r10,rbx
  40d956:	mov    QWORD PTR [rbp-0xed8],r10
  40d95d:	lea    r10,[rbp-0x890]
  40d964:	movabs r11,0x3b9aca00
  40d96e:	mov    QWORD PTR [r10],r11
  40d971:	movabs r10,0x3b9aca00
  40d97b:	movd   xmm0,r10d
  40d980:	movd   r10d,xmm0
  40d985:	pxor   xmm0,xmm0
  40d989:	cvtsi2ss xmm0,r10
  40d98e:	movd   r10d,xmm0
  40d993:	mov    rbx,r10
  40d996:	mov    r10,rbx
  40d999:	mov    QWORD PTR [rbp-0xee0],r10
  40d9a0:	mov    rdi,r12
  40d9a3:	movabs rsi,0x9
  40d9ad:	mov    rdx,QWORD PTR [rbp-0xe50]
  40d9b4:	mov    rcx,QWORD PTR [rbp-0xe90]
  40d9bb:	mov    r8,QWORD PTR [rbp-0xed0]
  40d9c2:	mov    r9,QWORD PTR [rbp-0xd88]
  40d9c9:	mov    r10,QWORD PTR [rbp-0xd90]
  40d9d0:	mov    QWORD PTR [rsp],r10
  40d9d4:	mov    r10,QWORD PTR [rbp-0xd98]
  40d9db:	mov    QWORD PTR [rsp+0x8],r10
  40d9e0:	mov    r10,QWORD PTR [rbp-0xed8]
  40d9e7:	mov    QWORD PTR [rsp+0x10],r10
  40d9ec:	mov    r10,QWORD PTR [rbp-0xee0]
  40d9f3:	mov    QWORD PTR [rsp+0x18],r10
  40d9f8:	movabs r10,0x0
  40da02:	mov    QWORD PTR [rsp+0x20],r10
  40da07:	xor    eax,eax
  40da09:	call   40b083 <p113d_FID_36_100_105_114_101_99_116_46_110_101_97_114_101_115_116_46_116_>
  40da0e:	mov    QWORD PTR [rbp-0xee8],rax
  40da15:	movabs r10,0x1
  40da1f:	movd   xmm0,r10d
  40da24:	movd   r10d,xmm0
  40da29:	pxor   xmm0,xmm0
  40da2d:	cvtsi2ss xmm0,r10
  40da32:	movd   r10d,xmm0
  40da37:	movd   xmm2,r10d
  40da3c:	movaps xmm3,xmm2
  40da3f:	movabs r10,0xa
  40da49:	movd   xmm0,r10d
  40da4e:	movd   r10d,xmm0
  40da53:	pxor   xmm0,xmm0
  40da57:	cvtsi2ss xmm0,r10
  40da5c:	movd   r10d,xmm0
  40da61:	movd   xmm2,r10d
  40da66:	movaps xmm4,xmm2
  40da69:	movaps xmm2,xmm3
  40da6c:	divss  xmm2,xmm4
  40da70:	movd   r10d,xmm2
  40da75:	mov    QWORD PTR [rbp-0xf18],r10
  40da7c:	movabs r10,0x55
  40da86:	movd   xmm0,r10d
  40da8b:	movd   r10d,xmm0
  40da90:	pxor   xmm0,xmm0
  40da94:	cvtsi2ss xmm0,r10
  40da99:	movd   r10d,xmm0
  40da9e:	movd   xmm2,r10d
  40daa3:	movaps xmm3,xmm2
  40daa6:	movabs r10,0x64
  40dab0:	movd   xmm0,r10d
  40dab5:	movd   r10d,xmm0
  40daba:	pxor   xmm0,xmm0
  40dabe:	cvtsi2ss xmm0,r10
  40dac3:	movd   r10d,xmm0
  40dac8:	movd   xmm2,r10d
  40dacd:	movaps xmm4,xmm2
  40dad0:	movaps xmm2,xmm3
  40dad3:	divss  xmm2,xmm4
  40dad7:	movd   r10d,xmm2
  40dadc:	mov    QWORD PTR [rbp-0xf48],r10
  40dae3:	movd   xmm0,DWORD PTR [rbp-0xee8]
  40daeb:	movd   xmm1,DWORD PTR [rbp-0xd80]
  40daf3:	ucomiss xmm0,xmm1
  40daf6:	setb   r10b
  40dafa:	setnp  r11b
  40dafe:	and    r10b,r11b
  40db01:	movzx  r10d,r10b
  40db05:	mov    rdi,r10
  40db08:	mov    rsi,rdi
  40db0b:	cmp    rsi,0x1
  40db12:	sete   sil
  40db16:	movzx  esi,sil
  40db1a:	mov    edi,esi
  40db1c:	mov    r10,rdi
  40db1f:	test   r10d,r10d
  40db22:	je     40db67 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x2037>
  40db28:	movabs r10,0x0
  40db32:	movd   xmm0,r10d
  40db37:	movd   r10d,xmm0
  40db3c:	pxor   xmm0,xmm0
  40db40:	cvtsi2ss xmm0,r10
  40db45:	movd   r10d,xmm0
  40db4a:	movd   xmm2,r10d
  40db4f:	movd   r10d,xmm2
  40db54:	mov    QWORD PTR [rbp-0xf70],r10
  40db5b:	mov    QWORD PTR [rbp-0xf78],r10
  40db62:	jmp    40db7c <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x204c>
  40db67:	mov    r10,QWORD PTR [rbp-0xe10]
  40db6e:	mov    QWORD PTR [rbp-0xf70],r10
  40db75:	mov    QWORD PTR [rbp-0xf78],r10
  40db7c:	mov    rdi,QWORD PTR [rbp-0xf78]
  40db83:	lea    r10,[rbp-0x890]
  40db8a:	mov    r11,QWORD PTR [rbp-0xf48]
  40db91:	mov    QWORD PTR [r10],r11
  40db94:	lea    r10,[rbp-0x890]
  40db9b:	mov    r11,rdi
  40db9e:	mov    QWORD PTR [r10+0x8],r11
  40dba2:	movd   xmm1,edi
  40dba6:	movd   xmm0,DWORD PTR [rbp-0xf48]
  40dbae:	mulss  xmm0,xmm1
  40dbb2:	movd   ebx,xmm0
  40dbb6:	mov    rdi,rbx
  40dbb9:	lea    r10,[rbp-0x890]
  40dbc0:	mov    r11,QWORD PTR [rbp-0xf18]
  40dbc7:	mov    QWORD PTR [r10],r11
  40dbca:	lea    r10,[rbp-0x890]
  40dbd1:	mov    r11,rdi
  40dbd4:	mov    QWORD PTR [r10+0x8],r11
  40dbd8:	movd   xmm1,edi
  40dbdc:	movd   xmm0,DWORD PTR [rbp-0xf18]
  40dbe4:	addss  xmm0,xmm1
  40dbe8:	movd   ebx,xmm0
  40dbec:	mov    r10,rbx
  40dbef:	mov    QWORD PTR [rbp-0xf90],r10
  40dbf6:	mov    rdi,r12
  40dbf9:	mov    rsi,QWORD PTR [rbp-0xc90]
  40dc00:	xor    eax,eax
  40dc02:	call   4087fe <p113d_FID_36_100_105_114_101_99_116_46_115_107_114_>
  40dc07:	mov    QWORD PTR [rbp-0xf98],rax
  40dc0e:	lea    r10,[rbp-0x890]
  40dc15:	movabs r11,0x2
  40dc1f:	mov    QWORD PTR [r10],r11
  40dc22:	movabs r10,0x2
  40dc2c:	movd   xmm0,r10d
  40dc31:	movd   r10d,xmm0
  40dc36:	pxor   xmm0,xmm0
  40dc3a:	cvtsi2ss xmm0,r10
  40dc3f:	movd   r10d,xmm0
  40dc44:	mov    rbx,r10
  40dc47:	mov    rdi,rbx
  40dc4a:	lea    r10,[rbp-0x890]
  40dc51:	mov    r11,r15
  40dc54:	mov    QWORD PTR [r10],r11
  40dc57:	lea    r10,[rbp-0x890]
  40dc5e:	mov    r11,QWORD PTR [rbp-0xce0]
  40dc65:	mov    QWORD PTR [r10+0x8],r11
  40dc69:	movd   xmm1,DWORD PTR [rbp-0xce0]
  40dc71:	movd   xmm0,r15d
  40dc76:	mulss  xmm0,xmm1
  40dc7a:	movd   ebx,xmm0
  40dc7e:	mov    rsi,rbx
  40dc81:	lea    r10,[rbp-0x890]
  40dc88:	mov    r11,QWORD PTR [rbp-0x70]
  40dc8c:	mov    QWORD PTR [r10],r11
  40dc8f:	lea    r10,[rbp-0x890]
  40dc96:	mov    r11,QWORD PTR [rbp-0xcf8]
  40dc9d:	mov    QWORD PTR [r10+0x8],r11
  40dca1:	movd   xmm1,DWORD PTR [rbp-0xcf8]
  40dca9:	movd   xmm0,DWORD PTR [rbp-0x70]
  40dcae:	mulss  xmm0,xmm1
  40dcb2:	movd   ebx,xmm0
  40dcb6:	mov    rdx,rbx
  40dcb9:	lea    r10,[rbp-0x890]
  40dcc0:	mov    r11,rsi
  40dcc3:	mov    QWORD PTR [r10],r11
  40dcc6:	lea    r10,[rbp-0x890]
  40dccd:	mov    r11,rdx
  40dcd0:	mov    QWORD PTR [r10+0x8],r11
  40dcd4:	movd   xmm1,edx
  40dcd8:	movd   xmm0,esi
  40dcdc:	addss  xmm0,xmm1
  40dce0:	movd   ebx,xmm0
  40dce4:	mov    rsi,rbx
  40dce7:	lea    r10,[rbp-0x890]
  40dcee:	mov    r11,QWORD PTR [rbp-0x78]
  40dcf2:	mov    QWORD PTR [r10],r11
  40dcf5:	lea    r10,[rbp-0x890]
  40dcfc:	mov    r11,QWORD PTR [rbp-0xd10]
  40dd03:	mov    QWORD PTR [r10+0x8],r11
  40dd07:	movd   xmm1,DWORD PTR [rbp-0xd10]
  40dd0f:	movd   xmm0,DWORD PTR [rbp-0x78]
  40dd14:	mulss  xmm0,xmm1
  40dd18:	movd   ebx,xmm0
  40dd1c:	mov    rdx,rbx
  40dd1f:	lea    r10,[rbp-0x890]
  40dd26:	mov    r11,rsi
  40dd29:	mov    QWORD PTR [r10],r11
  40dd2c:	lea    r10,[rbp-0x890]
  40dd33:	mov    r11,rdx
  40dd36:	mov    QWORD PTR [r10+0x8],r11
  40dd3a:	movd   xmm1,edx
  40dd3e:	movd   xmm0,esi
  40dd42:	addss  xmm0,xmm1
  40dd46:	movd   ebx,xmm0
  40dd4a:	mov    rsi,rbx
  40dd4d:	lea    r10,[rbp-0x890]
  40dd54:	mov    r11,rdi
  40dd57:	mov    QWORD PTR [r10],r11
  40dd5a:	lea    r10,[rbp-0x890]
  40dd61:	mov    r11,rsi
  40dd64:	mov    QWORD PTR [r10+0x8],r11
  40dd68:	movd   xmm1,esi
  40dd6c:	movd   xmm0,edi
  40dd70:	mulss  xmm0,xmm1
  40dd74:	movd   ebx,xmm0
  40dd78:	mov    rdi,rbx
  40dd7b:	lea    r10,[rbp-0x890]
  40dd82:	mov    r11,rdi
  40dd85:	mov    QWORD PTR [r10],r11
  40dd88:	lea    r10,[rbp-0x890]
  40dd8f:	mov    r11,QWORD PTR [rbp-0xce0]
  40dd96:	mov    QWORD PTR [r10+0x8],r11
  40dd9a:	movd   xmm1,DWORD PTR [rbp-0xce0]
  40dda2:	movd   xmm0,edi
  40dda6:	mulss  xmm0,xmm1
  40ddaa:	movd   ebx,xmm0
  40ddae:	mov    rsi,rbx
  40ddb1:	lea    r10,[rbp-0x890]
  40ddb8:	mov    r11,r15
  40ddbb:	mov    QWORD PTR [r10],r11
  40ddbe:	lea    r10,[rbp-0x890]
  40ddc5:	mov    r11,rsi
  40ddc8:	mov    QWORD PTR [r10+0x8],r11
  40ddcc:	movd   xmm1,esi
  40ddd0:	movd   xmm0,r15d
  40ddd5:	subss  xmm0,xmm1
  40ddd9:	movd   ebx,xmm0
  40dddd:	mov    r10,rbx
  40dde0:	mov    QWORD PTR [rbp-0xfe0],r10
  40dde7:	lea    r10,[rbp-0x890]
  40ddee:	mov    r11,rdi
  40ddf1:	mov    QWORD PTR [r10],r11
  40ddf4:	lea    r10,[rbp-0x890]
  40ddfb:	mov    r11,QWORD PTR [rbp-0xcf8]
  40de02:	mov    QWORD PTR [r10+0x8],r11
  40de06:	movd   xmm1,DWORD PTR [rbp-0xcf8]
  40de0e:	movd   xmm0,edi
  40de12:	mulss  xmm0,xmm1
  40de16:	movd   ebx,xmm0
  40de1a:	mov    rsi,rbx
  40de1d:	lea    r10,[rbp-0x890]
  40de24:	mov    r11,QWORD PTR [rbp-0x70]
  40de28:	mov    QWORD PTR [r10],r11
  40de2b:	lea    r10,[rbp-0x890]
  40de32:	mov    r11,rsi
  40de35:	mov    QWORD PTR [r10+0x8],r11
  40de39:	movd   xmm1,esi
  40de3d:	movd   xmm0,DWORD PTR [rbp-0x70]
  40de42:	subss  xmm0,xmm1
  40de46:	movd   ebx,xmm0
  40de4a:	mov    r10,rbx
  40de4d:	mov    QWORD PTR [rbp-0xff0],r10
  40de54:	lea    r10,[rbp-0x890]
  40de5b:	mov    r11,rdi
  40de5e:	mov    QWORD PTR [r10],r11
  40de61:	lea    r10,[rbp-0x890]
  40de68:	mov    r11,QWORD PTR [rbp-0xd10]
  40de6f:	mov    QWORD PTR [r10+0x8],r11
  40de73:	movd   xmm1,DWORD PTR [rbp-0xd10]
  40de7b:	movd   xmm0,edi
  40de7f:	mulss  xmm0,xmm1
  40de83:	movd   ebx,xmm0
  40de87:	mov    rdi,rbx
  40de8a:	lea    r10,[rbp-0x890]
  40de91:	mov    r11,QWORD PTR [rbp-0x78]
  40de95:	mov    QWORD PTR [r10],r11
  40de98:	lea    r10,[rbp-0x890]
  40de9f:	mov    r11,rdi
  40dea2:	mov    QWORD PTR [r10+0x8],r11
  40dea6:	movd   xmm1,edi
  40deaa:	movd   xmm0,DWORD PTR [rbp-0x78]
  40deaf:	subss  xmm0,xmm1
  40deb3:	movd   ebx,xmm0
  40deb7:	mov    r10,rbx
  40deba:	mov    QWORD PTR [rbp-0x1000],r10
  40dec1:	lea    r10,[rbp-0x890]
  40dec8:	movabs r11,0x3b9aca00
  40ded2:	mov    QWORD PTR [r10],r11
  40ded5:	movabs r10,0x3b9aca00
  40dedf:	movd   xmm0,r10d
  40dee4:	movd   r10d,xmm0
  40dee9:	pxor   xmm0,xmm0
  40deed:	cvtsi2ss xmm0,r10
  40def2:	movd   r10d,xmm0
  40def7:	mov    rbx,r10
  40defa:	mov    r10,rbx
  40defd:	mov    QWORD PTR [rbp-0x1008],r10
  40df04:	lea    r10,[rbp-0x890]
  40df0b:	movabs r11,0x3b9aca00
  40df15:	mov    QWORD PTR [r10],r11
  40df18:	movabs r10,0x3b9aca00
  40df22:	movd   xmm0,r10d
  40df27:	movd   r10d,xmm0
  40df2c:	pxor   xmm0,xmm0
  40df30:	cvtsi2ss xmm0,r10
  40df35:	movd   r10d,xmm0
  40df3a:	mov    rbx,r10
  40df3d:	mov    r10,rbx
  40df40:	mov    QWORD PTR [rbp-0x1010],r10
  40df47:	mov    rdi,r12
  40df4a:	lea    rsi,[rbp-0x8d0]
  40df51:	movabs rdx,0x9
  40df5b:	mov    rcx,QWORD PTR [rbp-0xe50]
  40df62:	mov    r8,QWORD PTR [rbp-0xe90]
  40df69:	mov    r9,QWORD PTR [rbp-0xed0]
  40df70:	mov    r10,QWORD PTR [rbp-0xfe0]
  40df77:	mov    QWORD PTR [rsp],r10
  40df7b:	mov    r10,QWORD PTR [rbp-0xff0]
  40df82:	mov    QWORD PTR [rsp+0x8],r10
  40df87:	mov    r10,QWORD PTR [rbp-0x1000]
  40df8e:	mov    QWORD PTR [rsp+0x10],r10
  40df93:	mov    r10,QWORD PTR [rbp-0x1008]
  40df9a:	mov    QWORD PTR [rsp+0x18],r10
  40df9f:	movabs r10,0x9
  40dfa9:	mov    QWORD PTR [rsp+0x20],r10
  40dfae:	mov    r10,QWORD PTR [rbp-0x1010]
  40dfb5:	mov    QWORD PTR [rsp+0x28],r10
  40dfba:	movabs r10,0x9
  40dfc4:	mov    QWORD PTR [rsp+0x30],r10
  40dfc9:	movabs r10,0x0
  40dfd3:	mov    QWORD PTR [rsp+0x38],r10
  40dfd8:	xor    eax,eax
  40dfda:	call   409b58 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_>
  40dfdf:	lea    r11,[rbp-0x8d0]
  40dfe6:	mov    rax,QWORD PTR [r11]
  40dfe9:	mov    QWORD PTR [rbp-0x1018],rax
  40dff0:	lea    r11,[rbp-0x8d0]
  40dff7:	mov    rax,QWORD PTR [r11+0x8]
  40dffb:	mov    QWORD PTR [rbp-0x1020],rax
  40e002:	lea    r11,[rbp-0x8d0]
  40e009:	mov    rax,QWORD PTR [r11+0x10]
  40e00d:	mov    QWORD PTR [rbp-0x1028],rax
  40e014:	lea    r10,[rbp-0x890]
  40e01b:	mov    r11,QWORD PTR [rbp-0x88]
  40e022:	mov    QWORD PTR [r10],r11
  40e025:	lea    r10,[rbp-0x890]
  40e02c:	mov    r11,QWORD PTR [rbp-0xf90]
  40e033:	mov    QWORD PTR [r10+0x8],r11
  40e037:	movd   xmm1,DWORD PTR [rbp-0xf90]
  40e03f:	movd   xmm0,DWORD PTR [rbp-0x88]
  40e047:	mulss  xmm0,xmm1
  40e04b:	movd   ebx,xmm0
  40e04f:	mov    rdi,rbx
  40e052:	lea    r10,[rbp-0x890]
  40e059:	movabs r11,0x1
  40e063:	mov    QWORD PTR [r10],r11
  40e066:	movabs r10,0x1
  40e070:	movd   xmm0,r10d
  40e075:	movd   r10d,xmm0
  40e07a:	pxor   xmm0,xmm0
  40e07e:	cvtsi2ss xmm0,r10
  40e083:	movd   r10d,xmm0
  40e088:	mov    rbx,r10
  40e08b:	mov    rsi,rbx
  40e08e:	lea    r10,[rbp-0x890]
  40e095:	mov    r11,rsi
  40e098:	mov    QWORD PTR [r10],r11
  40e09b:	lea    r10,[rbp-0x890]
  40e0a2:	mov    r11,QWORD PTR [rbp-0xf98]
  40e0a9:	mov    QWORD PTR [r10+0x8],r11
  40e0ad:	movd   xmm1,DWORD PTR [rbp-0xf98]
  40e0b5:	movd   xmm0,esi
  40e0b9:	subss  xmm0,xmm1
  40e0bd:	movd   ebx,xmm0
  40e0c1:	mov    rsi,rbx
  40e0c4:	lea    r10,[rbp-0x890]
  40e0cb:	mov    r11,rdi
  40e0ce:	mov    QWORD PTR [r10],r11
  40e0d1:	lea    r10,[rbp-0x890]
  40e0d8:	mov    r11,rsi
  40e0db:	mov    QWORD PTR [r10+0x8],r11
  40e0df:	movd   xmm1,esi
  40e0e3:	movd   xmm0,edi
  40e0e7:	mulss  xmm0,xmm1
  40e0eb:	movd   ebx,xmm0
  40e0ef:	mov    rdi,rbx
  40e0f2:	lea    r10,[rbp-0x890]
  40e0f9:	mov    r11,QWORD PTR [rbp-0x80]
  40e0fd:	mov    QWORD PTR [r10],r11
  40e100:	lea    r10,[rbp-0x890]
  40e107:	mov    r11,rdi
  40e10a:	mov    QWORD PTR [r10+0x8],r11
  40e10e:	movd   xmm1,edi
  40e112:	movd   xmm0,DWORD PTR [rbp-0x80]
  40e117:	addss  xmm0,xmm1
  40e11b:	movd   ebx,xmm0
  40e11f:	mov    rdi,rbx
  40e122:	lea    r10,[rbp-0x890]
  40e129:	mov    r11,QWORD PTR [rbp-0x88]
  40e130:	mov    QWORD PTR [r10],r11
  40e133:	lea    r10,[rbp-0x890]
  40e13a:	mov    r11,QWORD PTR [rbp-0xf98]
  40e141:	mov    QWORD PTR [r10+0x8],r11
  40e145:	movd   xmm1,DWORD PTR [rbp-0xf98]
  40e14d:	movd   xmm0,DWORD PTR [rbp-0x88]
  40e155:	mulss  xmm0,xmm1
  40e159:	movd   ebx,xmm0
  40e15d:	mov    rsi,rbx
  40e160:	mov    r10,QWORD PTR [rbp-0xc88]
  40e167:	mov    QWORD PTR [rbp-0x30],r10
  40e16b:	mov    r10,QWORD PTR [rbp-0x1018]
  40e172:	mov    r14,r10
  40e175:	mov    r10,QWORD PTR [rbp-0x1020]
  40e17c:	mov    r13,r10
  40e17f:	mov    r10,QWORD PTR [rbp-0x1028]
  40e186:	mov    QWORD PTR [rbp-0x48],r10
  40e18a:	mov    r10,QWORD PTR [rbp-0xe50]
  40e191:	mov    QWORD PTR [rbp-0x50],r10
  40e195:	mov    r10,QWORD PTR [rbp-0xe90]
  40e19c:	mov    QWORD PTR [rbp-0x58],r10
  40e1a0:	mov    r10,QWORD PTR [rbp-0xed0]
  40e1a7:	mov    QWORD PTR [rbp-0x60],r10
  40e1ab:	mov    r10,QWORD PTR [rbp-0xfe0]
  40e1b2:	mov    r15,r10
  40e1b5:	mov    r10,QWORD PTR [rbp-0xff0]
  40e1bc:	mov    QWORD PTR [rbp-0x70],r10
  40e1c0:	mov    r10,QWORD PTR [rbp-0x1000]
  40e1c7:	mov    QWORD PTR [rbp-0x78],r10
  40e1cb:	mov    QWORD PTR [rbp-0x80],rdi
  40e1cf:	mov    QWORD PTR [rbp-0x88],rsi
  40e1d6:	jmp    40bbb0 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x80>
  40e1db:	mov    rdi,r12
  40e1de:	movabs rsi,0x4
  40e1e8:	mov    esi,esi
  40e1ea:	xor    eax,eax
  40e1ec:	call   420a90 <p111_rt_fail>
  40e1f1:	mov    QWORD PTR [rbp-0xc80],rax
  40e1f8:	movabs rax,0x0
  40e202:	mov    r12,QWORD PTR [rbp-0x10]
  40e206:	mov    rbx,QWORD PTR [rbp-0x8]
  40e20a:	mov    r13,QWORD PTR [rbp-0x18]
  40e20e:	mov    r14,QWORD PTR [rbp-0x20]
  40e212:	mov    r15,QWORD PTR [rbp-0x28]
  40e216:	mov    rsp,rbp
  40e219:	pop    rbp
  40e21a:	ret    
  40e21b:	mov    rdi,r12
  40e21e:	movabs rsi,0x4
  40e228:	mov    esi,esi
  40e22a:	xor    eax,eax
  40e22c:	call   420a90 <p111_rt_fail>
  40e231:	mov    QWORD PTR [rbp-0xc80],rax
  40e238:	movabs rax,0x0
  40e242:	mov    r12,QWORD PTR [rbp-0x10]
  40e246:	mov    rbx,QWORD PTR [rbp-0x8]
  40e24a:	mov    r13,QWORD PTR [rbp-0x18]
  40e24e:	mov    r14,QWORD PTR [rbp-0x20]
  40e252:	mov    r15,QWORD PTR [rbp-0x28]
  40e256:	mov    rsp,rbp
  40e259:	pop    rbp
  40e25a:	ret    

Disassembly of section .fini:
