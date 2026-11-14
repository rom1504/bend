
/home/ai/bend2/build/publish/bend/selfhost/build/phase186/release-native45-acquire01/tree-bitonic/phase186-qbe-n2/machine/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

000000000040cbf0 <p114r_FID_36_100_105_114_101_99_116_46_119_97_114_112_>:
  40cbf0:	endbr64 
  40cbf4:	push   rbp
  40cbf5:	mov    rbp,rsp
  40cbf8:	sub    rsp,0x1818
  40cbff:	push   rbx
  40cc00:	push   r12
  40cc02:	push   r13
  40cc04:	push   r14
  40cc06:	push   r15
  40cc08:	mov    ebx,0x0
  40cc0d:	nop    DWORD PTR [rax]
  40cc10:	mov    r8,rsi
  40cc13:	shr    r8,0x28
  40cc17:	mov    rax,r8
  40cc1a:	and    rax,0xffff
  40cc20:	cmp    rax,0xa4
  40cc26:	sete   r10b
  40cc2a:	movzx  r10d,r10b
  40cc2e:	mov    r11,rdx
  40cc31:	shr    r11,0x28
  40cc35:	mov    r15,rcx
  40cc38:	mov    rcx,r11
  40cc3b:	and    rcx,0x7fffff
  40cc42:	mov    QWORD PTR [rbp-0x10],rcx
  40cc46:	mov    r9,rax
  40cc49:	movabs rax,0xffffffffff
  40cc53:	and    rax,rdx
  40cc56:	mov    QWORD PTR [rbp-0x8],rax
  40cc5a:	mov    r12,r11
  40cc5d:	and    r12,0xffff
  40cc64:	cmp    r10d,0x0
  40cc68:	jne    40ceb1 <p114r_FID_36_100_105_114_101_99_116_46_119_97_114_112_+0x2c1>
  40cc6e:	mov    rax,r9
  40cc71:	cmp    rax,0xa5
  40cc77:	jne    40ce45 <p114r_FID_36_100_105_114_101_99_116_46_119_97_114_112_+0x255>
  40cc7d:	mov    r14,rdx
  40cc80:	lea    rdx,[rbp-0x1810]
  40cc87:	mov    r13,rdi
  40cc8a:	call   41a200 <p125_rt_take2>
  40cc8f:	mov    rcx,r15
  40cc92:	mov    rdx,r14
  40cc95:	mov    rdi,r13
  40cc98:	mov    rax,QWORD PTR [rbp-0x8]
  40cc9c:	mov    r15,rcx
  40cc9f:	mov    rcx,QWORD PTR [rbp-0x10]
  40cca3:	mov    rsi,QWORD PTR [rbp-0x1810]
  40ccaa:	mov    r14,QWORD PTR [rbp-0x1808]
  40ccb1:	cmp    r12,0xa4
  40ccb8:	je     40cdd5 <p114r_FID_36_100_105_114_101_99_116_46_119_97_114_112_+0x1e5>
  40ccbe:	xchg   ax,ax
  40ccc0:	cmp    r12,0xa5
  40ccc7:	jne    40cd65 <p114r_FID_36_100_105_114_101_99_116_46_119_97_114_112_+0x175>
  40cccd:	cs cs cs mov r12,rdx
  40ccd3:	lea    rdx,[rbp-0x1810]
  40ccda:	mov    r13,rsi
  40ccdd:	mov    rsi,r12
  40cce0:	mov    r12,rdi
  40cce3:	call   41a200 <p125_rt_take2>
  40cce8:	mov    rcx,r15
  40cceb:	mov    rsi,r13
  40ccee:	mov    rdi,r12
  40ccf1:	mov    rdx,QWORD PTR [rbp-0x1810]
  40ccf8:	mov    rax,QWORD PTR [rbp-0x1808]
  40ccff:	mov    QWORD PTR [rbp-0x1810],r14
  40cd06:	mov    QWORD PTR [rbp-0x1808],rcx
  40cd0d:	mov    QWORD PTR [rbp-0x1800],rax
  40cd14:	mov    rax,QWORD PTR [rdi+0x10]
  40cd18:	mov    QWORD PTR [rax],r14
  40cd1b:	mov    r8,QWORD PTR [rbp-0x1808]
  40cd22:	mov    QWORD PTR [rax+0x8],r8
  40cd26:	mov    r15,rcx
  40cd29:	mov    rcx,QWORD PTR [rbp-0x1800]
  40cd30:	mov    QWORD PTR [rax+0x10],rcx
  40cd34:	mov    QWORD PTR [rax+0x18],0x74
  40cd3c:	add    rax,0x20
  40cd40:	mov    QWORD PTR [rdi+0x10],rax
  40cd44:	add    rbx,0x1
  40cd48:	mov    QWORD PTR [rbp-0x1810],rsi
  40cd4f:	mov    QWORD PTR [rbp-0x1808],rdx
  40cd56:	mov    QWORD PTR [rbp-0x1800],r15
  40cd5d:	mov    rcx,r15
  40cd60:	jmp    40cc10 <p114r_FID_36_100_105_114_101_99_116_46_119_97_114_112_+0x20>
  40cd65:	mov    r12,rdx
  40cd68:	mov    r13,r15
  40cd6b:	mov    rbx,rdi
  40cd6e:	call   414460 <p111_rt_sink>
  40cd73:	mov    rsi,r14
  40cd76:	mov    rdi,rbx
  40cd79:	mov    rbx,rdi
  40cd7c:	call   414460 <p111_rt_sink>
  40cd81:	mov    rcx,r13
  40cd84:	mov    rdx,r12
  40cd87:	mov    rdi,rbx
  40cd8a:	mov    QWORD PTR [rbp-0x1810],rcx
  40cd91:	mov    rax,QWORD PTR [rdi+0x10]
  40cd95:	mov    QWORD PTR [rax],rcx
  40cd98:	mov    QWORD PTR [rax+0x8],0x76
  40cda0:	add    rax,0x10
  40cda4:	mov    QWORD PTR [rdi+0x10],rax
  40cda8:	mov    QWORD PTR [rbp-0x1810],rdx
  40cdaf:	mov    rax,QWORD PTR [rdi+0x10]
  40cdb3:	mov    QWORD PTR [rax],rdx
  40cdb6:	mov    QWORD PTR [rax+0x8],0x77
  40cdbe:	add    rax,0x10
  40cdc2:	mov    QWORD PTR [rdi+0x10],rax
  40cdc6:	mov    esi,0x4
  40cdcb:	call   414bf0 <p111_rt_fail>
  40cdd0:	jmp    40d11c <p114r_FID_36_100_105_114_101_99_116_46_119_97_114_112_+0x52c>
  40cdd5:	cmp    rcx,0x100a4
  40cddc:	je     40cdfe <p114r_FID_36_100_105_114_101_99_116_46_119_97_114_112_+0x20e>
  40cdde:	mov    r12,rdx
  40cde1:	lea    rdx,[rbp-0x1810]
  40cde8:	mov    r13,rsi
  40cdeb:	mov    rsi,r12
  40cdee:	mov    r12,rdi
  40cdf1:	call   419f80 <p125_rt_take1>
  40cdf6:	mov    rsi,r13
  40cdf9:	mov    rdi,r12
  40cdfc:	jmp    40ce08 <p114r_FID_36_100_105_114_101_99_116_46_119_97_114_112_+0x218>
  40cdfe:	cs cs mov QWORD PTR cs:[rbp-0x1810],rax
  40ce08:	mov    r13,QWORD PTR [rbp-0x1810]
  40ce0f:	mov    r12,rdi
  40ce12:	call   414460 <p111_rt_sink>
  40ce17:	mov    rsi,r14
  40ce1a:	mov    rdi,r12
  40ce1d:	mov    r12,rdi
  40ce20:	call   414460 <p111_rt_sink>
  40ce25:	mov    rsi,r13
  40ce28:	mov    rdi,r12
  40ce2b:	mov    r12,rdi
  40ce2e:	call   414460 <p111_rt_sink>
  40ce33:	mov    rdi,r12
  40ce36:	movabs rax,0x100a40000000000
  40ce40:	jmp    40d050 <p114r_FID_36_100_105_114_101_99_116_46_119_97_114_112_+0x460>
  40ce45:	mov    rcx,r15
  40ce48:	mov    QWORD PTR [rbp-0x1810],rcx
  40ce4f:	mov    rax,QWORD PTR [rdi+0x10]
  40ce53:	mov    QWORD PTR [rax],rcx
  40ce56:	mov    QWORD PTR [rax+0x8],0x78
  40ce5e:	add    rax,0x10
  40ce62:	mov    QWORD PTR [rdi+0x10],rax
  40ce66:	mov    QWORD PTR [rbp-0x1810],rdx
  40ce6d:	mov    rax,QWORD PTR [rdi+0x10]
  40ce71:	mov    QWORD PTR [rax],rdx
  40ce74:	mov    QWORD PTR [rax+0x8],0x79
  40ce7c:	add    rax,0x10
  40ce80:	mov    QWORD PTR [rdi+0x10],rax
  40ce84:	mov    QWORD PTR [rbp-0x1810],rsi
  40ce8b:	mov    rax,QWORD PTR [rdi+0x10]
  40ce8f:	mov    QWORD PTR [rax],rsi
  40ce92:	mov    QWORD PTR [rax+0x8],0x7a
  40ce9a:	add    rax,0x10
  40ce9e:	mov    QWORD PTR [rdi+0x10],rax
  40cea2:	mov    esi,0x4
  40cea7:	call   414bf0 <p111_rt_fail>
  40ceac:	jmp    40d11c <p114r_FID_36_100_105_114_101_99_116_46_119_97_114_112_+0x52c>
  40ceb1:	and    r8,0x7fffff
  40ceb8:	nop    DWORD PTR [rax+rax*1+0x0]
  40cec0:	cmp    r8,0x100a4
  40cec7:	je     40cef4 <p114r_FID_36_100_105_114_101_99_116_46_119_97_114_112_+0x304>
  40cec9:	mov    r14,rdx
  40cecc:	lea    rdx,[rbp-0x1810]
  40ced3:	mov    r13,rdi
  40ced6:	call   419f80 <p125_rt_take1>
  40cedb:	mov    rcx,r15
  40cede:	mov    rdx,r14
  40cee1:	mov    rdi,r13
  40cee4:	mov    rax,QWORD PTR [rbp-0x8]
  40cee8:	mov    r14,rcx
  40ceeb:	mov    rcx,QWORD PTR [rbp-0x10]
  40ceef:	mov    r15,rdx
  40cef2:	jmp    40cf19 <p114r_FID_36_100_105_114_101_99_116_46_119_97_114_112_+0x329>
  40cef4:	cs cs cs cs mov r14,r15
  40cefb:	cs cs cs cs mov r15,rdx
  40cf02:	cs cs cs movabs rdx,0xffffffffff
  40cf0f:	and    rdx,rsi
  40cf12:	mov    QWORD PTR [rbp-0x1810],rdx
  40cf19:	mov    rsi,QWORD PTR [rbp-0x1810]
  40cf20:	cmp    r12,0xa4
  40cf27:	je     40cfe5 <p114r_FID_36_100_105_114_101_99_116_46_119_97_114_112_+0x3f5>
  40cf2d:	cs cs cs cs mov r13,rdi
  40cf34:	call   414460 <p111_rt_sink>
  40cf39:	cs mov rdx,r15
  40cf3d:	mov    rdi,r13
  40cf40:	cmp    r12,0xa5
  40cf47:	jne    40cf97 <p114r_FID_36_100_105_114_101_99_116_46_119_97_114_112_+0x3a7>
  40cf49:	mov    r12,rdx
  40cf4c:	lea    rdx,[rbp-0x1810]
  40cf53:	mov    rsi,r12
  40cf56:	mov    r12,rdi
  40cf59:	call   41a200 <p125_rt_take2>
  40cf5e:	mov    rdi,r12
  40cf61:	mov    rsi,QWORD PTR [rbp-0x1810]
  40cf68:	mov    r13,QWORD PTR [rbp-0x1808]
  40cf6f:	mov    r12,rdi
  40cf72:	call   414460 <p111_rt_sink>
  40cf77:	mov    rsi,r13
  40cf7a:	mov    rdi,r12
  40cf7d:	mov    r12,rdi
  40cf80:	call   414460 <p111_rt_sink>
  40cf85:	mov    rdi,r12
  40cf88:	movabs rax,0x100a40000000000
  40cf92:	jmp    40d050 <p114r_FID_36_100_105_114_101_99_116_46_119_97_114_112_+0x460>
  40cf97:	mov    rcx,r14
  40cf9a:	mov    QWORD PTR [rbp-0x1810],rcx
  40cfa1:	mov    rax,QWORD PTR [rdi+0x10]
  40cfa5:	mov    QWORD PTR [rax],rcx
  40cfa8:	mov    QWORD PTR [rax+0x8],0x72
  40cfb0:	add    rax,0x10
  40cfb4:	mov    QWORD PTR [rdi+0x10],rax
  40cfb8:	mov    QWORD PTR [rbp-0x1810],rdx
  40cfbf:	mov    rax,QWORD PTR [rdi+0x10]
  40cfc3:	mov    QWORD PTR [rax],rdx
  40cfc6:	mov    QWORD PTR [rax+0x8],0x73
  40cfce:	add    rax,0x10
  40cfd2:	mov    QWORD PTR [rdi+0x10],rax
  40cfd6:	mov    esi,0x4
  40cfdb:	call   414bf0 <p111_rt_fail>
  40cfe0:	jmp    40d11c <p114r_FID_36_100_105_114_101_99_116_46_119_97_114_112_+0x52c>
  40cfe5:	mov    rdx,r15
  40cfe8:	cmp    rcx,0x100a4
  40cfef:	je     40d014 <p114r_FID_36_100_105_114_101_99_116_46_119_97_114_112_+0x424>
  40cff1:	mov    r12,rdx
  40cff4:	lea    rdx,[rbp-0x1810]
  40cffb:	mov    r13,rsi
  40cffe:	mov    rsi,r12
  40d001:	mov    r12,rdi
  40d004:	call   419f80 <p125_rt_take1>
  40d009:	mov    rcx,r14
  40d00c:	mov    rsi,r13
  40d00f:	mov    rdi,r12
  40d012:	jmp    40d01e <p114r_FID_36_100_105_114_101_99_116_46_119_97_114_112_+0x42e>
  40d014:	mov    rcx,r14
  40d017:	mov    QWORD PTR [rbp-0x1810],rax
  40d01e:	mov    rdx,QWORD PTR [rbp-0x1810]
  40d025:	mov    QWORD PTR [rbp-0x1810],rsi
  40d02c:	mov    QWORD PTR [rbp-0x1808],rdx
  40d033:	mov    QWORD PTR [rbp-0x1800],rcx
  40d03a:	mov    r12,rdi
  40d03d:	call   405340 <p112w_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_108_101_97_102_>
  40d042:	mov    rdi,r12
  40d045:	mov    r9,rax
  40d048:	mov    rax,r9
  40d04b:	nop    DWORD PTR [rax+rax*1+0x0]
  40d050:	cmp    rbx,0x0
  40d054:	je     40d11c <p114r_FID_36_100_105_114_101_99_116_46_119_97_114_112_+0x52c>
  40d05a:	mov    rcx,QWORD PTR [rdi+0x10]
  40d05e:	mov    rdx,rcx
  40d061:	add    rdx,0xfffffffffffffff8
  40d065:	mov    QWORD PTR [rdi+0x10],rdx
  40d069:	mov    rsi,QWORD PTR [rcx-0x8]
  40d06d:	cmp    rsi,0x74
  40d071:	sete   r8b
  40d075:	movzx  r8d,r8b
  40d079:	mov    rdx,rcx
  40d07c:	sub    rdx,0x10
  40d080:	cmp    r8d,0x0
  40d084:	jne    40d0c5 <p114r_FID_36_100_105_114_101_99_116_46_119_97_114_112_+0x4d5>
  40d086:	cmp    rsi,0x75
  40d08a:	jne    40d0b9 <p114r_FID_36_100_105_114_101_99_116_46_119_97_114_112_+0x4c9>
  40d08c:	mov    QWORD PTR [rdi+0x10],rdx
  40d090:	sub    rcx,0x10
  40d094:	mov    rsi,QWORD PTR [rcx]
  40d097:	mov    QWORD PTR [rbp-0x810],rsi
  40d09e:	mov    QWORD PTR [rbp-0x808],rax
  40d0a5:	mov    rdx,rax
  40d0a8:	mov    r12,rdi
  40d0ab:	call   405330 <p112w_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_>
  40d0b0:	mov    rdi,r12
  40d0b3:	sub    rbx,0x1
  40d0b7:	jmp    40d050 <p114r_FID_36_100_105_114_101_99_116_46_119_97_114_112_+0x460>
  40d0b9:	mov    esi,0x4
  40d0be:	call   414bf0 <p111_rt_fail>
  40d0c3:	jmp    40d11c <p114r_FID_36_100_105_114_101_99_116_46_119_97_114_112_+0x52c>
  40d0c5:	mov    r9,rax
  40d0c8:	mov    rax,rdx
  40d0cb:	mov    rdx,rcx
  40d0ce:	mov    r10,rdx
  40d0d1:	sub    r10,0x20
  40d0d5:	mov    QWORD PTR [rdi+0x10],r10
  40d0d9:	mov    rsi,QWORD PTR [r10]
  40d0dc:	mov    r8,rdx
  40d0df:	sub    r8,0x18
  40d0e3:	mov    rcx,QWORD PTR [r8]
  40d0e6:	sub    rdx,0x10
  40d0ea:	mov    rdx,QWORD PTR [rdx]
  40d0ed:	mov    QWORD PTR [rbp-0x1010],r9
  40d0f4:	mov    QWORD PTR [r10],r9
  40d0f7:	mov    QWORD PTR [r8],0x75
  40d0fe:	mov    QWORD PTR [rdi+0x10],rax
  40d102:	mov    QWORD PTR [rbp-0x1010],rsi
  40d109:	mov    QWORD PTR [rbp-0x1008],rdx
  40d110:	mov    QWORD PTR [rbp-0x1000],rcx
  40d117:	jmp    40cc10 <p114r_FID_36_100_105_114_101_99_116_46_119_97_114_112_+0x20>
  40d11c:	pop    r15
  40d11e:	pop    r14
  40d120:	pop    r13
  40d122:	pop    r12
  40d124:	pop    rbx
  40d125:	leave  
  40d126:	ret    

Disassembly of section .fini:
