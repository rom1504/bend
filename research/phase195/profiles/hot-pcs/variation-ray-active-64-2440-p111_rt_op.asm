
/home/ai/bend2/build/publish/bend/selfhost/build/phase194/native45-02/variation-ray-active-64-2440/machine/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000420ab0 <p111_rt_op>:
  420ab0:	push   r15
  420ab2:	push   r14
  420ab4:	push   r13
  420ab6:	push   r12
  420ab8:	push   rbp
  420ab9:	push   rbx
  420aba:	sub    rsp,0x58
  420abe:	mov    r12,QWORD PTR [rdi+0x8]
  420ac2:	mov    rbp,QWORD PTR [rdi]
  420ac5:	cmp    esi,0x56
  420ac8:	ja     421c5e <p111_rt_op+0x11ae>
  420ace:	lea    rdi,[rip+0x75c7]        # 42809c <_IO_stdin_used+0x109c>
  420ad5:	mov    rbx,rdx
  420ad8:	mov    edx,esi
  420ada:	movsxd rax,DWORD PTR [rdi+rdx*4]
  420ade:	add    rax,rdi
  420ae1:	jmp    rax
  420ae3:	nop    DWORD PTR [rax+rax*1+0x0]
  420ae8:	cmp    esi,0x54
  420aeb:	je     421a1e <p111_rt_op+0xf6e>
  420af1:	cmp    ecx,0x3
  420af4:	jne    421942 <p111_rt_op+0xe92>
  420afa:	sub    esi,0x4c
  420afd:	xor    r8d,r8d
  420b00:	movabs rdx,0xffffffffff
  420b0a:	mov    r10,QWORD PTR [rbx]
  420b0d:	mov    edi,DWORD PTR [rbx+0x10]
  420b10:	mov    r11,QWORD PTR [rbx+0x8]
  420b14:	and    rdx,r10
  420b17:	lea    r9,[rdx*8+0x0]
  420b1f:	test   r10,r10
  420b22:	js     421bad <p111_rt_op+0x10fd>
  420b28:	mov    rcx,r10
  420b2b:	mov    edx,0x1
  420b30:	shr    rcx,0x28
  420b34:	and    ecx,0x1f
  420b37:	shl    rdx,cl
  420b3a:	mov    rcx,r10
  420b3d:	mov    r10d,esi
  420b40:	lea    eax,[rdx-0x1]
  420b43:	shr    rcx,0x38
  420b47:	and    eax,r11d
  420b4a:	and    ecx,0x7f
  420b4d:	lea    edx,[rax+rax*1]
  420b50:	shl    rax,0x2
  420b54:	shl    rdx,0x2
  420b58:	cmp    rcx,0x4
  420b5c:	cmove  rdx,rax
  420b60:	add    rdx,r9
  420b63:	lea    r9,[rip+0x768e]        # 4281f8 <_IO_stdin_used+0x11f8>
  420b6a:	add    rdx,rbp
  420b6d:	mov    ecx,DWORD PTR [rdx]
  420b6f:	cmp    esi,0x9
  420b72:	ja     4219cf <p111_rt_op+0xf1f>
  420b78:	movsxd rax,DWORD PTR [r9+r10*4]
  420b7c:	add    rax,r9
  420b7f:	jmp    rax
  420b81:	nop    DWORD PTR [rax+0x0]
  420b88:	cmp    ecx,0x1
  420b8b:	jne    421942 <p111_rt_op+0xe92>
  420b91:	mov    r12,QWORD PTR [rbx]
  420b94:	add    rsp,0x58
  420b98:	mov    rax,r12
  420b9b:	pop    rbx
  420b9c:	pop    rbp
  420b9d:	pop    r12
  420b9f:	pop    r13
  420ba1:	pop    r14
  420ba3:	pop    r15
  420ba5:	ret    
  420ba6:	nop    WORD PTR cs:[rax+rax*1+0x0]
  420bb0:	cmp    ecx,0x2
  420bb3:	jne    421942 <p111_rt_op+0xe92>
  420bb9:	xor    r12d,r12d
  420bbc:	mov    eax,DWORD PTR [rbx+0x8]
  420bbf:	cmp    DWORD PTR [rbx],eax
  420bc1:	setne  r12b
  420bc5:	jmp    420b94 <p111_rt_op+0xe4>
  420bc7:	nop    WORD PTR [rax+rax*1+0x0]
  420bd0:	cmp    ecx,0x2
  420bd3:	jne    421942 <p111_rt_op+0xe92>
  420bd9:	xor    r12d,r12d
  420bdc:	mov    eax,DWORD PTR [rbx+0x8]
  420bdf:	cmp    DWORD PTR [rbx],eax
  420be1:	sete   r12b
  420be5:	jmp    420b94 <p111_rt_op+0xe4>
  420be7:	nop    WORD PTR [rax+rax*1+0x0]
  420bf0:	cmp    ecx,0x2
  420bf3:	jne    421942 <p111_rt_op+0xe92>
  420bf9:	mov    r12,QWORD PTR [rbx+0x8]
  420bfd:	imul   r12d,DWORD PTR [rbx]
  420c01:	jmp    420b94 <p111_rt_op+0xe4>
  420c03:	nop    DWORD PTR [rax+rax*1+0x0]
  420c08:	cmp    ecx,0x2
  420c0b:	jne    421942 <p111_rt_op+0xe92>
  420c11:	mov    r12,QWORD PTR [rbx+0x8]
  420c15:	xor    r12d,DWORD PTR [rbx]
  420c18:	jmp    420b94 <p111_rt_op+0xe4>
  420c1d:	nop    DWORD PTR [rax]
  420c20:	cmp    ecx,0x2
  420c23:	jne    421942 <p111_rt_op+0xe92>
  420c29:	mov    r12,QWORD PTR [rbx+0x8]
  420c2d:	or     r12d,DWORD PTR [rbx]
  420c30:	jmp    420b94 <p111_rt_op+0xe4>
  420c35:	nop    DWORD PTR [rax]
  420c38:	cmp    ecx,0x2
  420c3b:	jne    421942 <p111_rt_op+0xe92>
  420c41:	mov    r12,QWORD PTR [rbx+0x8]
  420c45:	and    r12d,DWORD PTR [rbx]
  420c48:	jmp    420b94 <p111_rt_op+0xe4>
  420c4d:	nop    DWORD PTR [rax]
  420c50:	cmp    ecx,0x2
  420c53:	jne    421942 <p111_rt_op+0xe92>
  420c59:	mov    r12,QWORD PTR [rbx]
  420c5c:	sub    r12d,DWORD PTR [rbx+0x8]
  420c60:	jmp    420b94 <p111_rt_op+0xe4>
  420c65:	nop    DWORD PTR [rax]
  420c68:	cmp    ecx,0x2
  420c6b:	jne    421942 <p111_rt_op+0xe92>
  420c71:	mov    r12,QWORD PTR [rbx+0x8]
  420c75:	add    r12d,DWORD PTR [rbx]
  420c78:	jmp    420b94 <p111_rt_op+0xe4>
  420c7d:	nop    DWORD PTR [rax]
  420c80:	cmp    ecx,0x2
  420c83:	jne    421942 <p111_rt_op+0xe92>
  420c89:	xor    r12d,r12d
  420c8c:	mov    eax,DWORD PTR [rbx+0x8]
  420c8f:	cmp    DWORD PTR [rbx],eax
  420c91:	setbe  r12b
  420c95:	jmp    420b94 <p111_rt_op+0xe4>
  420c9a:	nop    WORD PTR [rax+rax*1+0x0]
  420ca0:	cmp    ecx,0x2
  420ca3:	jne    421942 <p111_rt_op+0xe92>
  420ca9:	xor    r12d,r12d
  420cac:	mov    eax,DWORD PTR [rbx+0x8]
  420caf:	cmp    DWORD PTR [rbx],eax
  420cb1:	setb   r12b
  420cb5:	jmp    420b94 <p111_rt_op+0xe4>
  420cba:	nop    WORD PTR [rax+rax*1+0x0]
  420cc0:	cmp    ecx,0x2
  420cc3:	jne    421942 <p111_rt_op+0xe92>
  420cc9:	xor    r12d,r12d
  420ccc:	movss  xmm0,DWORD PTR [rbx+0x8]
  420cd1:	ucomiss xmm0,DWORD PTR [rbx]
  420cd4:	mov    eax,0x1
  420cd9:	setp   r12b
  420cdd:	cmovne r12,rax
  420ce1:	jmp    420b94 <p111_rt_op+0xe4>
  420ce6:	nop    WORD PTR cs:[rax+rax*1+0x0]
  420cf0:	cmp    ecx,0x2
  420cf3:	jne    421942 <p111_rt_op+0xe92>
  420cf9:	xor    r12d,r12d
  420cfc:	movss  xmm0,DWORD PTR [rbx+0x8]
  420d01:	comiss xmm0,DWORD PTR [rbx]
  420d04:	setae  r12b
  420d08:	jmp    420b94 <p111_rt_op+0xe4>
  420d0d:	nop    DWORD PTR [rax]
  420d10:	cmp    ecx,0x2
  420d13:	jne    421942 <p111_rt_op+0xe92>
  420d19:	xor    r12d,r12d
  420d1c:	movss  xmm0,DWORD PTR [rbx+0x8]
  420d21:	comiss xmm0,DWORD PTR [rbx]
  420d24:	seta   r12b
  420d28:	jmp    420b94 <p111_rt_op+0xe4>
  420d2d:	nop    DWORD PTR [rax]
  420d30:	cmp    ecx,0x2
  420d33:	jne    421942 <p111_rt_op+0xe92>
  420d39:	mov    r8,QWORD PTR [rbx+0x8]
  420d3d:	mov    rcx,QWORD PTR [rbx]
  420d40:	test   r8,r8
  420d43:	je     420d53 <p111_rt_op+0x2a3>
  420d45:	mov    rax,rcx
  420d48:	xor    edx,edx
  420d4a:	div    r8
  420d4d:	mov    rcx,rdx
  420d50:	mov    r8,rax
  420d53:	mov    rdx,r8
  420d56:	add    rsp,0x58
  420d5a:	mov    rdi,rbp
  420d5d:	mov    rsi,r12
  420d60:	pop    rbx
  420d61:	pop    rbp
  420d62:	pop    r12
  420d64:	pop    r13
  420d66:	pop    r14
  420d68:	pop    r15
  420d6a:	jmp    41ddd0 <p111_tuple>
  420d6f:	nop
  420d70:	cmp    ecx,0x2
  420d73:	jne    421942 <p111_rt_op+0xe92>
  420d79:	mov    rax,QWORD PTR [rbx]
  420d7c:	mov    r12d,0x1
  420d82:	cmp    rax,0x1
  420d86:	je     420db2 <p111_rt_op+0x302>
  420d88:	mov    rdx,rax
  420d8b:	xor    r12d,r12d
  420d8e:	shr    rdx,0x38
  420d92:	and    edx,0x7f
  420d95:	cmp    rdx,0x1
  420d99:	jne    420db2 <p111_rt_op+0x302>
  420d9b:	shr    rax,0x28
  420d9f:	mov    edx,DWORD PTR [rip+0x10db93]        # 52e938 <p111_core_cids+0x38>
  420da5:	xor    r12d,r12d
  420da8:	movzx  eax,ax
  420dab:	cmp    rax,rdx
  420dae:	sete   r12b
  420db2:	mov    rax,QWORD PTR [rbx+0x8]
  420db6:	cmp    rax,0x1
  420dba:	je     421a35 <p111_rt_op+0xf85>
  420dc0:	mov    rdx,rax
  420dc3:	shr    rdx,0x38
  420dc7:	and    edx,0x7f
  420dca:	cmp    rdx,0x1
  420dce:	jne    420df0 <p111_rt_op+0x340>
  420dd0:	shr    rax,0x28
  420dd4:	mov    edx,DWORD PTR [rip+0x10db5e]        # 52e938 <p111_core_cids+0x38>
  420dda:	movzx  eax,ax
  420ddd:	cmp    rax,rdx
  420de0:	sete   al
  420de3:	movzx  eax,al
  420de6:	xor    r12d,eax
  420de9:	nop    DWORD PTR [rax+0x0]
  420df0:	movsxd r12,r12d
  420df3:	jmp    420b94 <p111_rt_op+0xe4>
  420df8:	nop    DWORD PTR [rax+rax*1+0x0]
  420e00:	cmp    ecx,0x3
  420e03:	jne    421942 <p111_rt_op+0xe92>
  420e09:	mov    rdx,QWORD PTR [rbx]
  420e0c:	mov    eax,0x1
  420e11:	mov    r8,QWORD PTR [rbx+0x10]
  420e15:	mov    rcx,rdx
  420e18:	shr    rcx,0x28
  420e1c:	and    ecx,0x1f
  420e1f:	shl    rax,cl
  420e22:	movabs rcx,0xffffffffff
  420e2c:	and    rcx,rdx
  420e2f:	sub    eax,0x1
  420e32:	and    eax,DWORD PTR [rbx+0x8]
  420e35:	mov    r14,rcx
  420e38:	test   rdx,rdx
  420e3b:	js     421b80 <p111_rt_op+0x10d0>
  420e41:	mov    r9,QWORD PTR [rip+0x10db08]        # 52e950 <p111_program_active>
  420e48:	mov    r13d,eax
  420e4b:	test   BYTE PTR [r9+0x58],0x2
  420e50:	je     421a3e <p111_rt_op+0xf8e>
  420e56:	lea    rax,[r13*4+0x0]
  420e5e:	lea    rax,[rax+r14*8]
  420e62:	add    rax,rbp
  420e65:	mov    r15d,DWORD PTR [rax]
  420e68:	mov    DWORD PTR [rax],r8d
  420e6b:	mov    rcx,r15
  420e6e:	mov    rdx,QWORD PTR [rbx]
  420e71:	jmp    420d56 <p111_rt_op+0x2a6>
  420e76:	nop    WORD PTR cs:[rax+rax*1+0x0]
  420e80:	cmp    ecx,0x3
  420e83:	jne    421942 <p111_rt_op+0xe92>
  420e89:	mov    rdx,QWORD PTR [rbx]
  420e8c:	mov    eax,0x1
  420e91:	mov    r13,QWORD PTR [rbx+0x10]
  420e95:	mov    rcx,rdx
  420e98:	shr    rcx,0x28
  420e9c:	and    ecx,0x1f
  420e9f:	shl    rax,cl
  420ea2:	movabs rcx,0xffffffffff
  420eac:	and    rcx,rdx
  420eaf:	sub    eax,0x1
  420eb2:	and    eax,DWORD PTR [rbx+0x8]
  420eb5:	mov    r15,rcx
  420eb8:	test   rdx,rdx
  420ebb:	js     421b53 <p111_rt_op+0x10a3>
  420ec1:	mov    r8,QWORD PTR [rip+0x10da88]        # 52e950 <p111_program_active>
  420ec8:	mov    r14d,eax
  420ecb:	test   BYTE PTR [r8+0x58],0x2
  420ed0:	je     421a67 <p111_rt_op+0xfb7>
  420ed6:	lea    rax,[r14*4+0x0]
  420ede:	lea    rax,[rax+r15*8]
  420ee2:	mov    DWORD PTR [rbp+rax*1+0x0],r13d
  420ee7:	jmp    420b91 <p111_rt_op+0xe1>
  420eec:	nop    DWORD PTR [rax+0x0]
  420ef0:	cmp    ecx,0x1
  420ef3:	jne    421942 <p111_rt_op+0xe92>
  420ef9:	mov    rdx,QWORD PTR [rbx]
  420efc:	mov    eax,0x1
  420f01:	mov    rcx,rdx
  420f04:	shr    rcx,0x28
  420f08:	and    ecx,0x1f
  420f0b:	shl    rax,cl
  420f0e:	mov    rcx,rax
  420f11:	jmp    420d56 <p111_rt_op+0x2a6>
  420f16:	nop    WORD PTR cs:[rax+rax*1+0x0]
  420f20:	cmp    ecx,0x1
  420f23:	jne    421942 <p111_rt_op+0xe92>
  420f29:	pxor   xmm0,xmm0
  420f2d:	cvtss2sd xmm0,DWORD PTR [rbx]
  420f31:	call   4022f0 <log10@plt>
  420f36:	cvtsd2ss xmm0,xmm0
  420f3a:	movd   r12d,xmm0
  420f3f:	jmp    420b94 <p111_rt_op+0xe4>
  420f44:	nop    DWORD PTR [rax+0x0]
  420f48:	cmp    ecx,0x1
  420f4b:	jne    421942 <p111_rt_op+0xe92>
  420f51:	pxor   xmm0,xmm0
  420f55:	cvtss2sd xmm0,DWORD PTR [rbx]
  420f59:	call   402050 <log2@plt>
  420f5e:	cvtsd2ss xmm0,xmm0
  420f62:	movd   r12d,xmm0
  420f67:	jmp    420b94 <p111_rt_op+0xe4>
  420f6c:	nop    DWORD PTR [rax+0x0]
  420f70:	cmp    ecx,0x1
  420f73:	jne    421942 <p111_rt_op+0xe92>
  420f79:	pxor   xmm0,xmm0
  420f7d:	cvtss2sd xmm0,DWORD PTR [rbx]
  420f81:	call   402230 <log@plt>
  420f86:	cvtsd2ss xmm0,xmm0
  420f8a:	movd   r12d,xmm0
  420f8f:	jmp    420b94 <p111_rt_op+0xe4>
  420f94:	nop    DWORD PTR [rax+0x0]
  420f98:	cmp    ecx,0x1
  420f9b:	jne    421942 <p111_rt_op+0xe92>
  420fa1:	mov    rax,QWORD PTR [rbx]
  420fa4:	test   rax,rax
  420fa7:	js     4219f5 <p111_rt_op+0xf45>
  420fad:	pxor   xmm0,xmm0
  420fb1:	cvtsi2ss xmm0,rax
  420fb6:	nop    WORD PTR cs:[rax+rax*1+0x0]
  420fc0:	movd   r12d,xmm0
  420fc5:	jmp    420b94 <p111_rt_op+0xe4>
  420fca:	nop    WORD PTR [rax+rax*1+0x0]
  420fd0:	cmp    ecx,0x2
  420fd3:	jne    421942 <p111_rt_op+0xe92>
  420fd9:	mov    rdx,QWORD PTR [rbx]
  420fdc:	mov    rax,QWORD PTR [rbx+0x8]
  420fe0:	mov    r12,rdx
  420fe3:	sub    r12,rax
  420fe6:	cmp    rdx,rax
  420fe9:	mov    eax,0x0
  420fee:	cmovb  r12,rax
  420ff2:	jmp    420b94 <p111_rt_op+0xe4>
  420ff7:	nop    WORD PTR [rax+rax*1+0x0]
  421000:	cmp    ecx,0x2
  421003:	jne    421942 <p111_rt_op+0xe92>
  421009:	movabs rax,0xffffffffffff
  421013:	mov    r12,QWORD PTR [rbx+0x8]
  421017:	add    r12,QWORD PTR [rbx]
  42101a:	cmp    r12,rax
  42101d:	jbe    420b94 <p111_rt_op+0xe4>
  421023:	call   41d520 <nat_chk.part.0>
  421028:	nop    DWORD PTR [rax+rax*1+0x0]
  421030:	cmp    ecx,0x1
  421033:	jne    421942 <p111_rt_op+0xe92>
  421039:	movss  xmm0,DWORD PTR [rbx]
  42103d:	ucomiss xmm0,xmm0
  421040:	jp     421b3c <p111_rt_op+0x108c>
  421046:	lea    r13,[rsp+0x20]
  42104b:	mov    rdi,r13
  42104e:	call   41d530 <f32_text.part.0>
  421053:	mov    rsi,r12
  421056:	movsxd rcx,eax
  421059:	mov    rdx,r13
  42105c:	mov    rdi,rbp
  42105f:	call   41f140 <io_str>
  421064:	mov    r12,rax
  421067:	jmp    420b94 <p111_rt_op+0xe4>
  42106c:	nop    DWORD PTR [rax+0x0]
  421070:	cmp    ecx,0x1
  421073:	jne    421942 <p111_rt_op+0xe92>
  421079:	movss  xmm0,DWORD PTR [rbx]
  42107d:	comiss xmm0,DWORD PTR [rip+0x73b0]        # 428434 <hex.3+0x14>
  421084:	jb     4219ed <p111_rt_op+0xf3d>
  42108a:	movss  xmm1,DWORD PTR [rip+0x73ae]        # 428440 <hex.3+0x20>
  421092:	comiss xmm1,xmm0
  421095:	jbe    4219ed <p111_rt_op+0xf3d>
  42109b:	cvttss2si r12,xmm0
  4210a0:	mov    r12d,r12d
  4210a3:	jmp    420b94 <p111_rt_op+0xe4>
  4210a8:	nop    DWORD PTR [rax+rax*1+0x0]
  4210b0:	cmp    ecx,0x2
  4210b3:	jne    421942 <p111_rt_op+0xe92>
  4210b9:	pxor   xmm0,xmm0
  4210bd:	pxor   xmm1,xmm1
  4210c1:	cvtss2sd xmm0,DWORD PTR [rbx]
  4210c5:	cvtss2sd xmm1,DWORD PTR [rbx+0x8]
  4210ca:	call   402240 <fmod@plt>
  4210cf:	cvtsd2ss xmm0,xmm0
  4210d3:	movd   r12d,xmm0
  4210d8:	jmp    420b94 <p111_rt_op+0xe4>
  4210dd:	nop    DWORD PTR [rax]
  4210e0:	cmp    ecx,0x1
  4210e3:	jne    421942 <p111_rt_op+0xe92>
  4210e9:	mov    r12d,DWORD PTR [rbx]
  4210ec:	movd   xmm0,r12d
  4210f1:	xorps  xmm0,XMMWORD PTR [rip+0x7368]        # 428460 <hex.3+0x40>
  4210f8:	movd   r12d,xmm0
  4210fd:	jmp    420b94 <p111_rt_op+0xe4>
  421102:	nop    WORD PTR [rax+rax*1+0x0]
  421108:	cmp    ecx,0x2
  42110b:	jne    421942 <p111_rt_op+0xe92>
  421111:	pxor   xmm0,xmm0
  421115:	pxor   xmm1,xmm1
  421119:	cvtss2sd xmm0,DWORD PTR [rbx]
  42111d:	cvtss2sd xmm1,DWORD PTR [rbx+0x8]
  421122:	call   4023c0 <atan2@plt>
  421127:	cvtsd2ss xmm0,xmm0
  42112b:	movd   r12d,xmm0
  421130:	jmp    420b94 <p111_rt_op+0xe4>
  421135:	nop    DWORD PTR [rax]
  421138:	cmp    ecx,0x2
  42113b:	jne    421942 <p111_rt_op+0xe92>
  421141:	pxor   xmm0,xmm0
  421145:	pxor   xmm1,xmm1
  421149:	cvtss2sd xmm0,DWORD PTR [rbx]
  42114d:	cvtss2sd xmm1,DWORD PTR [rbx+0x8]
  421152:	call   402150 <pow@plt>
  421157:	cvtsd2ss xmm0,xmm0
  42115b:	movd   r12d,xmm0
  421160:	jmp    420b94 <p111_rt_op+0xe4>
  421165:	nop    DWORD PTR [rax]
  421168:	cmp    ecx,0x1
  42116b:	jne    421942 <p111_rt_op+0xe92>
  421171:	mov    r12d,DWORD PTR [rbx]
  421174:	movd   xmm0,r12d
  421179:	andps  xmm0,XMMWORD PTR [rip+0x72d0]        # 428450 <hex.3+0x30>
  421180:	movd   r12d,xmm0
  421185:	jmp    420b94 <p111_rt_op+0xe4>
  42118a:	nop    WORD PTR [rax+rax*1+0x0]
  421190:	cmp    ecx,0x1
  421193:	jne    421942 <p111_rt_op+0xe92>
  421199:	mov    eax,DWORD PTR [rbx]
  42119b:	movss  xmm1,DWORD PTR [rip+0x72ad]        # 428450 <hex.3+0x30>
  4211a3:	movss  xmm3,DWORD PTR [rip+0x728d]        # 428438 <hex.3+0x18>
  4211ab:	movd   xmm2,eax
  4211af:	movd   xmm0,eax
  4211b3:	andps  xmm2,xmm1
  4211b6:	ucomiss xmm3,xmm2
  4211b9:	jbe    420fc0 <p111_rt_op+0x510>
  4211bf:	cvttss2si edx,xmm0
  4211c3:	pxor   xmm0,xmm0
  4211c7:	movd   xmm2,eax
  4211cb:	andnps xmm1,xmm2
  4211ce:	cvtsi2ss xmm0,edx
  4211d2:	orps   xmm0,xmm1
  4211d5:	jmp    420fc0 <p111_rt_op+0x510>
  4211da:	nop    WORD PTR [rax+rax*1+0x0]
  4211e0:	cmp    ecx,0x1
  4211e3:	jne    421942 <p111_rt_op+0xe92>
  4211e9:	movss  xmm0,DWORD PTR [rbx]
  4211ed:	movss  xmm2,DWORD PTR [rip+0x725b]        # 428450 <hex.3+0x30>
  4211f5:	movss  xmm3,DWORD PTR [rip+0x723b]        # 428438 <hex.3+0x18>
  4211fd:	movaps xmm1,xmm0
  421200:	andps  xmm1,xmm2
  421203:	ucomiss xmm3,xmm1
  421206:	jbe    420fc0 <p111_rt_op+0x510>
  42120c:	cvttss2si eax,xmm0
  421210:	pxor   xmm1,xmm1
  421214:	movaps xmm3,xmm0
  421217:	movss  xmm4,DWORD PTR [rip+0x721d]        # 42843c <hex.3+0x1c>
  42121f:	andnps xmm2,xmm0
  421222:	cvtsi2ss xmm1,eax
  421226:	cmpnless xmm3,xmm1
  42122b:	andps  xmm3,xmm4
  42122e:	addss  xmm1,xmm3
  421232:	orps   xmm1,xmm2
  421235:	movaps xmm0,xmm1
  421238:	jmp    420fc0 <p111_rt_op+0x510>
  42123d:	nop    DWORD PTR [rax]
  421240:	cmp    ecx,0x1
  421243:	jne    421942 <p111_rt_op+0xe92>
  421249:	movss  xmm0,DWORD PTR [rbx]
  42124d:	movss  xmm2,DWORD PTR [rip+0x71fb]        # 428450 <hex.3+0x30>
  421255:	movss  xmm3,DWORD PTR [rip+0x71db]        # 428438 <hex.3+0x18>
  42125d:	movaps xmm1,xmm0
  421260:	andps  xmm1,xmm2
  421263:	ucomiss xmm3,xmm1
  421266:	jbe    420fc0 <p111_rt_op+0x510>
  42126c:	cvttss2si eax,xmm0
  421270:	pxor   xmm1,xmm1
  421274:	movss  xmm4,DWORD PTR [rip+0x71c0]        # 42843c <hex.3+0x1c>
  42127c:	andnps xmm2,xmm0
  42127f:	cvtsi2ss xmm1,eax
  421283:	movaps xmm3,xmm1
  421286:	cmpnless xmm3,xmm0
  42128b:	andps  xmm3,xmm4
  42128e:	subss  xmm1,xmm3
  421292:	orps   xmm1,xmm2
  421295:	movaps xmm0,xmm1
  421298:	jmp    420fc0 <p111_rt_op+0x510>
  42129d:	nop    DWORD PTR [rax]
  4212a0:	cmp    ecx,0x1
  4212a3:	jne    421942 <p111_rt_op+0xe92>
  4212a9:	pxor   xmm0,xmm0
  4212ad:	cvtss2sd xmm0,DWORD PTR [rbx]
  4212b1:	call   4024a0 <tanh@plt>
  4212b6:	cvtsd2ss xmm0,xmm0
  4212ba:	movd   r12d,xmm0
  4212bf:	jmp    420b94 <p111_rt_op+0xe4>
  4212c4:	nop    DWORD PTR [rax+0x0]
  4212c8:	cmp    ecx,0x1
  4212cb:	jne    421942 <p111_rt_op+0xe92>
  4212d1:	pxor   xmm0,xmm0
  4212d5:	cvtss2sd xmm0,DWORD PTR [rbx]
  4212d9:	call   402340 <cosh@plt>
  4212de:	cvtsd2ss xmm0,xmm0
  4212e2:	movd   r12d,xmm0
  4212e7:	jmp    420b94 <p111_rt_op+0xe4>
  4212ec:	nop    DWORD PTR [rax+0x0]
  4212f0:	cmp    ecx,0x1
  4212f3:	jne    421942 <p111_rt_op+0xe92>
  4212f9:	pxor   xmm0,xmm0
  4212fd:	cvtss2sd xmm0,DWORD PTR [rbx]
  421301:	call   402360 <sinh@plt>
  421306:	cvtsd2ss xmm0,xmm0
  42130a:	movd   r12d,xmm0
  42130f:	jmp    420b94 <p111_rt_op+0xe4>
  421314:	nop    DWORD PTR [rax+0x0]
  421318:	cmp    ecx,0x1
  42131b:	jne    421942 <p111_rt_op+0xe92>
  421321:	pxor   xmm0,xmm0
  421325:	cvtss2sd xmm0,DWORD PTR [rbx]
  421329:	call   402140 <atan@plt>
  42132e:	cvtsd2ss xmm0,xmm0
  421332:	movd   r12d,xmm0
  421337:	jmp    420b94 <p111_rt_op+0xe4>
  42133c:	nop    DWORD PTR [rax+0x0]
  421340:	cmp    ecx,0x1
  421343:	jne    421942 <p111_rt_op+0xe92>
  421349:	pxor   xmm0,xmm0
  42134d:	cvtss2sd xmm0,DWORD PTR [rbx]
  421351:	call   402280 <acos@plt>
  421356:	cvtsd2ss xmm0,xmm0
  42135a:	movd   r12d,xmm0
  42135f:	jmp    420b94 <p111_rt_op+0xe4>
  421364:	nop    DWORD PTR [rax+0x0]
  421368:	cmp    ecx,0x1
  42136b:	jne    421942 <p111_rt_op+0xe92>
  421371:	pxor   xmm0,xmm0
  421375:	cvtss2sd xmm0,DWORD PTR [rbx]
  421379:	call   4024b0 <asin@plt>
  42137e:	cvtsd2ss xmm0,xmm0
  421382:	movd   r12d,xmm0
  421387:	jmp    420b94 <p111_rt_op+0xe4>
  42138c:	nop    DWORD PTR [rax+0x0]
  421390:	cmp    ecx,0x1
  421393:	jne    421942 <p111_rt_op+0xe92>
  421399:	pxor   xmm0,xmm0
  42139d:	cvtss2sd xmm0,DWORD PTR [rbx]
  4213a1:	call   4023a0 <tan@plt>
  4213a6:	cvtsd2ss xmm0,xmm0
  4213aa:	movd   r12d,xmm0
  4213af:	jmp    420b94 <p111_rt_op+0xe4>
  4213b4:	nop    DWORD PTR [rax+0x0]
  4213b8:	cmp    ecx,0x1
  4213bb:	jne    421942 <p111_rt_op+0xe92>
  4213c1:	pxor   xmm0,xmm0
  4213c5:	cvtss2sd xmm0,DWORD PTR [rbx]
  4213c9:	call   402260 <cos@plt>
  4213ce:	cvtsd2ss xmm0,xmm0
  4213d2:	movd   r12d,xmm0
  4213d7:	jmp    420b94 <p111_rt_op+0xe4>
  4213dc:	nop    DWORD PTR [rax+0x0]
  4213e0:	cmp    ecx,0x1
  4213e3:	jne    421942 <p111_rt_op+0xe92>
  4213e9:	pxor   xmm0,xmm0
  4213ed:	cvtss2sd xmm0,DWORD PTR [rbx]
  4213f1:	call   402480 <sin@plt>
  4213f6:	cvtsd2ss xmm0,xmm0
  4213fa:	movd   r12d,xmm0
  4213ff:	jmp    420b94 <p111_rt_op+0xe4>
  421404:	nop    DWORD PTR [rax+0x0]
  421408:	cmp    ecx,0x2
  42140b:	jne    421942 <p111_rt_op+0xe92>
  421411:	xor    r12d,r12d
  421414:	movss  xmm0,DWORD PTR [rbx+0x8]
  421419:	ucomiss xmm0,DWORD PTR [rbx]
  42141c:	mov    eax,0x0
  421421:	setnp  r12b
  421425:	cmovne r12,rax
  421429:	jmp    420b94 <p111_rt_op+0xe4>
  42142e:	xchg   ax,ax
  421430:	cmp    ecx,0x2
  421433:	jne    421942 <p111_rt_op+0xe92>
  421439:	movss  xmm0,DWORD PTR [rbx]
  42143d:	divss  xmm0,DWORD PTR [rbx+0x8]
  421442:	movd   r12d,xmm0
  421447:	jmp    420b94 <p111_rt_op+0xe4>
  42144c:	nop    DWORD PTR [rax+0x0]
  421450:	cmp    ecx,0x2
  421453:	jne    421942 <p111_rt_op+0xe92>
  421459:	movss  xmm0,DWORD PTR [rbx+0x8]
  42145e:	mulss  xmm0,DWORD PTR [rbx]
  421462:	movd   r12d,xmm0
  421467:	jmp    420b94 <p111_rt_op+0xe4>
  42146c:	nop    DWORD PTR [rax+0x0]
  421470:	cmp    ecx,0x2
  421473:	jne    421942 <p111_rt_op+0xe92>
  421479:	movss  xmm0,DWORD PTR [rbx]
  42147d:	subss  xmm0,DWORD PTR [rbx+0x8]
  421482:	movd   r12d,xmm0
  421487:	jmp    420b94 <p111_rt_op+0xe4>
  42148c:	nop    DWORD PTR [rax+0x0]
  421490:	cmp    ecx,0x2
  421493:	jne    421942 <p111_rt_op+0xe92>
  421499:	mov    eax,DWORD PTR [rbx+0x8]
  42149c:	cmp    DWORD PTR [rbx],eax
  42149e:	seta   al
  4214a1:	setae  dl
  4214a4:	movzx  eax,al
  4214a7:	movzx  edx,dl
  4214aa:	add    rax,rdx
  4214ad:	je     4219d8 <p111_rt_op+0xf28>
  4214b3:	cmp    rax,0x1
  4214b7:	je     42171d <p111_rt_op+0xc6d>
  4214bd:	mov    r12d,DWORD PTR [rip+0x10d480]        # 52e944 <p111_core_cids+0x44>
  4214c4:	shl    r12,0x28
  4214c8:	bts    r12,0x38
  4214cd:	jmp    420b94 <p111_rt_op+0xe4>
  4214d2:	nop    WORD PTR [rax+rax*1+0x0]
  4214d8:	cmp    ecx,0x1
  4214db:	jne    421942 <p111_rt_op+0xe92>
  4214e1:	mov    eax,DWORD PTR [rbx]
  4214e3:	xor    r12d,r12d
  4214e6:	test   eax,eax
  4214e8:	sete   r12b
  4214ec:	jmp    420b94 <p111_rt_op+0xe4>
  4214f1:	nop    DWORD PTR [rax+0x0]
  4214f8:	cmp    ecx,0x1
  4214fb:	jne    421942 <p111_rt_op+0xe92>
  421501:	mov    r12,QWORD PTR [rbx]
  421504:	not    r12d
  421507:	jmp    420b94 <p111_rt_op+0xe4>
  42150c:	nop    DWORD PTR [rax+0x0]
  421510:	cmp    ecx,0x2
  421513:	jne    421942 <p111_rt_op+0xe92>
  421519:	mov    rax,QWORD PTR [rbx+0x8]
  42151d:	mov    r12,QWORD PTR [rbx]
  421520:	mov    ecx,eax
  421522:	test   eax,eax
  421524:	je     420b94 <p111_rt_op+0xe4>
  42152a:	mov    eax,r12d
  42152d:	xor    edx,edx
  42152f:	div    ecx
  421531:	mov    r12,rdx
  421534:	jmp    420b94 <p111_rt_op+0xe4>
  421539:	nop    DWORD PTR [rax+0x0]
  421540:	cmp    ecx,0x2
  421543:	jne    421942 <p111_rt_op+0xe92>
  421549:	mov    rax,QWORD PTR [rbx+0x8]
  42154d:	xor    r12d,r12d
  421550:	mov    ecx,eax
  421552:	test   eax,eax
  421554:	je     420b94 <p111_rt_op+0xe4>
  42155a:	mov    rax,QWORD PTR [rbx]
  42155d:	xor    edx,edx
  42155f:	div    ecx
  421561:	mov    r12,rax
  421564:	jmp    420b94 <p111_rt_op+0xe4>
  421569:	nop    DWORD PTR [rax+0x0]
  421570:	cmp    ecx,0x2
  421573:	jne    421942 <p111_rt_op+0xe92>
  421579:	mov    rcx,QWORD PTR [rbx+0x8]
  42157d:	xor    r12d,r12d
  421580:	cmp    rcx,0x1f
  421584:	ja     420b94 <p111_rt_op+0xe4>
  42158a:	mov    r12,QWORD PTR [rbx]
  42158d:	shr    r12d,cl
  421590:	jmp    420b94 <p111_rt_op+0xe4>
  421595:	nop    DWORD PTR [rax]
  421598:	cmp    ecx,0x2
  42159b:	jne    421942 <p111_rt_op+0xe92>
  4215a1:	mov    rcx,QWORD PTR [rbx+0x8]
  4215a5:	xor    r12d,r12d
  4215a8:	cmp    rcx,0x1f
  4215ac:	ja     420b94 <p111_rt_op+0xe4>
  4215b2:	mov    r12,QWORD PTR [rbx]
  4215b5:	shl    r12d,cl
  4215b8:	jmp    420b94 <p111_rt_op+0xe4>
  4215bd:	nop    DWORD PTR [rax]
  4215c0:	cmp    ecx,0x1
  4215c3:	jne    421942 <p111_rt_op+0xe92>
  4215c9:	mov    r12,QWORD PTR [rbx]
  4215cc:	shr    r12d,1
  4215cf:	jmp    420b94 <p111_rt_op+0xe4>
  4215d4:	nop    DWORD PTR [rax+0x0]
  4215d8:	cmp    ecx,0x1
  4215db:	jne    421942 <p111_rt_op+0xe92>
  4215e1:	mov    r12,QWORD PTR [rbx]
  4215e4:	add    r12d,r12d
  4215e7:	jmp    420b94 <p111_rt_op+0xe4>
  4215ec:	nop    DWORD PTR [rax+0x0]
  4215f0:	cmp    ecx,0x1
  4215f3:	jne    421942 <p111_rt_op+0xe92>
  4215f9:	mov    rax,QWORD PTR [rbx]
  4215fc:	lea    r12d,[rax+0x1]
  421600:	jmp    420b94 <p111_rt_op+0xe4>
  421605:	nop    DWORD PTR [rax]
  421608:	cmp    ecx,0x2
  42160b:	jne    421942 <p111_rt_op+0xe92>
  421611:	xor    r12d,r12d
  421614:	mov    eax,DWORD PTR [rbx+0x8]
  421617:	cmp    DWORD PTR [rbx],eax
  421619:	setae  r12b
  42161d:	jmp    420b94 <p111_rt_op+0xe4>
  421622:	nop    WORD PTR [rax+rax*1+0x0]
  421628:	cmp    ecx,0x2
  42162b:	jne    421942 <p111_rt_op+0xe92>
  421631:	xor    r12d,r12d
  421634:	mov    eax,DWORD PTR [rbx+0x8]
  421637:	cmp    DWORD PTR [rbx],eax
  421639:	seta   r12b
  42163d:	jmp    420b94 <p111_rt_op+0xe4>
  421642:	nop    WORD PTR [rax+rax*1+0x0]
  421648:	cmp    ecx,0x2
  42164b:	jne    421942 <p111_rt_op+0xe92>
  421651:	mov    rax,QWORD PTR [rbx]
  421654:	mov    r12d,0x1
  42165a:	cmp    rax,0x1
  42165e:	je     42168a <p111_rt_op+0xbda>
  421660:	mov    rdx,rax
  421663:	xor    r12d,r12d
  421666:	shr    rdx,0x38
  42166a:	and    edx,0x7f
  42166d:	cmp    rdx,0x1
  421671:	jne    42168a <p111_rt_op+0xbda>
  421673:	shr    rax,0x28
  421677:	mov    edx,DWORD PTR [rip+0x10d2bb]        # 52e938 <p111_core_cids+0x38>
  42167d:	xor    r12d,r12d
  421680:	movzx  eax,ax
  421683:	cmp    rax,rdx
  421686:	sete   r12b
  42168a:	mov    rax,QWORD PTR [rbx+0x8]
  42168e:	cmp    rax,0x1
  421692:	je     421a13 <p111_rt_op+0xf63>
  421698:	mov    rdx,rax
  42169b:	shr    rdx,0x38
  42169f:	and    edx,0x7f
  4216a2:	cmp    rdx,0x1
  4216a6:	jne    420df0 <p111_rt_op+0x340>
  4216ac:	shr    rax,0x28
  4216b0:	mov    edx,DWORD PTR [rip+0x10d282]        # 52e938 <p111_core_cids+0x38>
  4216b6:	movzx  eax,ax
  4216b9:	cmp    rax,rdx
  4216bc:	sete   al
  4216bf:	movzx  eax,al
  4216c2:	or     r12d,eax
  4216c5:	jmp    420df0 <p111_rt_op+0x340>
  4216ca:	nop    WORD PTR [rax+rax*1+0x0]
  4216d0:	cmp    ecx,0x2
  4216d3:	jne    421942 <p111_rt_op+0xe92>
  4216d9:	xor    r12d,r12d
  4216dc:	mov    rax,QWORD PTR [rbx+0x8]
  4216e0:	cmp    QWORD PTR [rbx],rax
  4216e3:	setb   r12b
  4216e7:	jmp    420b94 <p111_rt_op+0xe4>
  4216ec:	nop    DWORD PTR [rax+0x0]
  4216f0:	cmp    ecx,0x2
  4216f3:	jne    421942 <p111_rt_op+0xe92>
  4216f9:	mov    rax,QWORD PTR [rbx+0x8]
  4216fd:	cmp    QWORD PTR [rbx],rax
  421700:	seta   al
  421703:	setae  dl
  421706:	movzx  eax,al
  421709:	movzx  edx,dl
  42170c:	add    eax,edx
  42170e:	je     4219d8 <p111_rt_op+0xf28>
  421714:	cmp    eax,0x1
  421717:	jne    4214bd <p111_rt_op+0xa0d>
  42171d:	mov    r12d,DWORD PTR [rip+0x10d21c]        # 52e940 <p111_core_cids+0x40>
  421724:	shl    r12,0x28
  421728:	bts    r12,0x38
  42172d:	jmp    420b94 <p111_rt_op+0xe4>
  421732:	nop    WORD PTR [rax+rax*1+0x0]
  421738:	cmp    ecx,0x1
  42173b:	jne    421942 <p111_rt_op+0xe92>
  421741:	movabs rax,0xffffffffffff
  42174b:	mov    r12,QWORD PTR [rbx]
  42174e:	add    r12,r12
  421751:	cmp    r12,rax
  421754:	jbe    420b94 <p111_rt_op+0xe4>
  42175a:	jmp    421023 <p111_rt_op+0x573>
  42175f:	nop
  421760:	cmp    ecx,0x2
  421763:	jne    421942 <p111_rt_op+0xe92>
  421769:	mov    r12,QWORD PTR [rbx+0x8]
  42176d:	mov    rcx,QWORD PTR [rbx]
  421770:	test   r12,r12
  421773:	je     420b94 <p111_rt_op+0xe4>
  421779:	movabs rsi,0xffffffffffff
  421783:	xor    edx,edx
  421785:	mov    rax,rsi
  421788:	div    r12
  42178b:	cmp    rcx,rax
  42178e:	ja     421023 <p111_rt_op+0x573>
  421794:	imul   r12,rcx
  421798:	cmp    r12,rsi
  42179b:	jbe    420b94 <p111_rt_op+0xe4>
  4217a1:	jmp    421023 <p111_rt_op+0x573>
  4217a6:	nop    WORD PTR cs:[rax+rax*1+0x0]
  4217b0:	cmp    ecx,0x1
  4217b3:	jne    421942 <p111_rt_op+0xe92>
  4217b9:	mov    eax,DWORD PTR [rbx]
  4217bb:	pxor   xmm0,xmm0
  4217bf:	cvtsi2ss xmm0,rax
  4217c4:	movd   r12d,xmm0
  4217c9:	jmp    420b94 <p111_rt_op+0xe4>
  4217ce:	xchg   ax,ax
  4217d0:	cmp    ecx,0x2
  4217d3:	jne    421942 <p111_rt_op+0xe92>
  4217d9:	movss  xmm0,DWORD PTR [rbx+0x8]
  4217de:	addss  xmm0,DWORD PTR [rbx]
  4217e2:	movd   r12d,xmm0
  4217e7:	jmp    420b94 <p111_rt_op+0xe4>
  4217ec:	nop    DWORD PTR [rax+0x0]
  4217f0:	cmp    ecx,0x1
  4217f3:	jne    421942 <p111_rt_op+0xe92>
  4217f9:	mov    r12d,DWORD PTR [rbx]
  4217fc:	jmp    420b94 <p111_rt_op+0xe4>
  421801:	nop    DWORD PTR [rax+0x0]
  421808:	cmp    ecx,0x2
  42180b:	jne    421942 <p111_rt_op+0xe92>
  421811:	mov    rsi,QWORD PTR [rbx]
  421814:	mov    eax,0x1
  421819:	movabs rdx,0xffffffffff
  421823:	mov    rcx,rsi
  421826:	and    rdx,rsi
  421829:	shr    rcx,0x28
  42182d:	and    ecx,0x1f
  421830:	shl    rax,cl
  421833:	sub    eax,0x1
  421836:	and    eax,DWORD PTR [rbx+0x8]
  421839:	test   rsi,rsi
  42183c:	js     421bde <p111_rt_op+0x112e>
  421842:	mov    rcx,QWORD PTR [rip+0x10d107]        # 52e950 <p111_program_active>
  421849:	test   BYTE PTR [rcx+0x58],0x2
  42184d:	je     421aec <p111_rt_op+0x103c>
  421853:	shl    rax,0x2
  421857:	lea    rax,[rax+rdx*8]
  42185b:	mov    r13d,DWORD PTR [rbp+rax*1+0x0]
  421860:	mov    rcx,r13
  421863:	jmp    420e6e <p111_rt_op+0x3be>
  421868:	nop    DWORD PTR [rax+rax*1+0x0]
  421870:	cmp    ecx,0x2
  421873:	jne    421942 <p111_rt_op+0xe92>
  421879:	mov    rax,QWORD PTR [rbx+0x8]
  42187d:	mov    rcx,QWORD PTR [rbx]
  421880:	mov    rsi,r12
  421883:	lea    r8,[rsp+0x20]
  421888:	mov    rdi,rbp
  42188b:	mov    QWORD PTR [rsp+0x20],rax
  421890:	mov    rax,QWORD PTR [rip+0x10d0b9]        # 52e950 <p111_program_active>
  421897:	mov    rdx,QWORD PTR [rax+0x58]
  42189b:	shr    rdx,1
  42189e:	xor    rdx,0x1
  4218a2:	and    edx,0x1
  4218a5:	call   41e860 <blk_new.constprop.0>
  4218aa:	mov    r12,rax
  4218ad:	jmp    420b94 <p111_rt_op+0xe4>
  4218b2:	nop    WORD PTR [rax+rax*1+0x0]
  4218b8:	cmp    ecx,0x1
  4218bb:	jne    421942 <p111_rt_op+0xe92>
  4218c1:	pxor   xmm0,xmm0
  4218c5:	cvtss2sd xmm0,DWORD PTR [rbx]
  4218c9:	call   402540 <exp@plt>
  4218ce:	cvtsd2ss xmm0,xmm0
  4218d2:	jmp    420fc0 <p111_rt_op+0x510>
  4218d7:	nop    WORD PTR [rax+rax*1+0x0]
  4218e0:	cmp    ecx,0x1
  4218e3:	jne    421942 <p111_rt_op+0xe92>
  4218e5:	movss  xmm0,DWORD PTR [rbx]
  4218e9:	pxor   xmm1,xmm1
  4218ed:	ucomiss xmm1,xmm0
  4218f0:	ja     421c84 <p111_rt_op+0x11d4>
  4218f6:	sqrtss xmm0,xmm0
  4218fa:	jmp    420fc0 <p111_rt_op+0x510>
  4218ff:	nop
  421900:	cmp    ecx,0x2
  421903:	jne    421942 <p111_rt_op+0xe92>
  421905:	xor    r12d,r12d
  421908:	movss  xmm0,DWORD PTR [rbx]
  42190c:	comiss xmm0,DWORD PTR [rbx+0x8]
  421910:	setae  r12b
  421914:	jmp    420b94 <p111_rt_op+0xe4>
  421919:	nop    DWORD PTR [rax+0x0]
  421920:	cmp    ecx,0x2
  421923:	jne    421942 <p111_rt_op+0xe92>
  421925:	xor    r12d,r12d
  421928:	movss  xmm0,DWORD PTR [rbx]
  42192c:	comiss xmm0,DWORD PTR [rbx+0x8]
  421930:	seta   r12b
  421934:	jmp    420b94 <p111_rt_op+0xe4>
  421939:	sub    ecx,0x1
  42193c:	je     4045fe <p111_rt_op.cold>
  421942:	lea    rdi,[rip+0x5eb7]        # 427800 <_IO_stdin_used+0x800>
  421949:	call   41c3d0 <err_fail>
  42194e:	sub    ecx,0x1
  421951:	jne    421942 <p111_rt_op+0xe92>
  421953:	jmp    404697 <p111_rt_op.cold+0x99>
  421958:	nop    DWORD PTR [rax+rax*1+0x0]
  421960:	movd   xmm5,ecx
  421964:	movd   xmm6,edi
  421968:	addss  xmm5,xmm6
  42196c:	movd   r11d,xmm5
  421971:	nop    DWORD PTR [rax+0x0]
  421978:	mov    eax,ecx
  42197a:	lock cmpxchg DWORD PTR [rdx],r11d
  42197f:	je     420e6e <p111_rt_op+0x3be>
  421985:	mov    ecx,eax
  421987:	jmp    420b6f <p111_rt_op+0xbf>
  42198c:	nop    DWORD PTR [rax+0x0]
  421990:	mov    r11d,edi
  421993:	and    r11d,ecx
  421996:	jmp    421978 <p111_rt_op+0xec8>
  421998:	cmp    edi,ecx
  42199a:	mov    r11d,ecx
  42199d:	cmovae r11d,edi
  4219a1:	jmp    421978 <p111_rt_op+0xec8>
  4219a3:	cmp    edi,ecx
  4219a5:	mov    r11d,ecx
  4219a8:	cmovbe r11d,edi
  4219ac:	jmp    421978 <p111_rt_op+0xec8>
  4219ae:	lea    r11d,[rdi+rcx*1]
  4219b2:	jmp    421978 <p111_rt_op+0xec8>
  4219b4:	mov    r11d,edi
  4219b7:	xor    r11d,ecx
  4219ba:	jmp    421978 <p111_rt_op+0xec8>
  4219bc:	mov    r11d,edi
  4219bf:	or     r11d,ecx
  4219c2:	jmp    421978 <p111_rt_op+0xec8>
  4219c4:	cmp    edi,ecx
  4219c6:	mov    r11d,ecx
  4219c9:	cmove  r11d,r8d
  4219cd:	jmp    421978 <p111_rt_op+0xec8>
  4219cf:	mov    r11d,edi
  4219d2:	jmp    421978 <p111_rt_op+0xec8>
  4219d4:	nop    DWORD PTR [rax+0x0]
  4219d8:	mov    r12d,DWORD PTR [rip+0x10cf5d]        # 52e93c <p111_core_cids+0x3c>
  4219df:	shl    r12,0x28
  4219e3:	bts    r12,0x38
  4219e8:	jmp    420b94 <p111_rt_op+0xe4>
  4219ed:	xor    r12d,r12d
  4219f0:	jmp    420b94 <p111_rt_op+0xe4>
  4219f5:	mov    rdx,rax
  4219f8:	and    eax,0x1
  4219fb:	pxor   xmm0,xmm0
  4219ff:	shr    rdx,1
  421a02:	or     rdx,rax
  421a05:	cvtsi2ss xmm0,rdx
  421a0a:	addss  xmm0,xmm0
  421a0e:	jmp    420fc0 <p111_rt_op+0x510>
  421a13:	mov    r12d,0x1
  421a19:	jmp    420df0 <p111_rt_op+0x340>
  421a1e:	cmp    ecx,0x4
  421a21:	jne    421942 <p111_rt_op+0xe92>
  421a27:	mov    r8d,DWORD PTR [rbx+0x18]
  421a2b:	mov    esi,0x8
  421a30:	jmp    420b00 <p111_rt_op+0x50>
  421a35:	xor    r12d,0x1
  421a39:	jmp    420df0 <p111_rt_op+0x340>
  421a3e:	lea    rax,[r13+r14*1+0x0]
  421a43:	lea    r10,[rbp+rax*8+0x0]
  421a48:	mov    rax,r8
  421a4b:	shr    rax,0x38
  421a4f:	mov    r15,QWORD PTR [r10]
  421a52:	and    eax,0x7f
  421a55:	cmp    rax,0x2
  421a59:	je     421c04 <p111_rt_op+0x1154>
  421a5f:	mov    QWORD PTR [r10],r8
  421a62:	jmp    420e6b <p111_rt_op+0x3bb>
  421a67:	lea    rax,[r14+r15*1]
  421a6b:	lea    r9,[rbp+rax*8+0x0]
  421a70:	mov    rdx,QWORD PTR [r9]
  421a73:	mov    rax,rdx
  421a76:	shr    rax,0x38
  421a7a:	test   al,0x7e
  421a7c:	je     421ad0 <p111_rt_op+0x1020>
  421a7e:	cmp    rdx,0xffffffffffffffff
  421a82:	je     421ad0 <p111_rt_op+0x1020>
  421a84:	movabs rcx,0xffffffffff
  421a8e:	mov    rax,QWORD PTR [r8+0x40]
  421a92:	and    rcx,rdx
  421a95:	add    rax,0x7f
  421a99:	and    rax,0xffffffffffffff80
  421a9d:	add    rax,0x3108200
  421aa3:	cmp    rcx,rax
  421aa6:	jb     421ad0 <p111_rt_op+0x1020>
  421aa8:	mov    rdi,rbp
  421aab:	mov    rsi,r12
  421aae:	mov    QWORD PTR [rsp+0x8],r9
  421ab3:	mov    QWORD PTR [rsp],r8
  421ab7:	call   41ea00 <term_drop>
  421abc:	mov    r8,QWORD PTR [rsp]
  421ac0:	mov    r9,QWORD PTR [rsp+0x8]
  421ac5:	test   BYTE PTR [r8+0x58],0x2
  421aca:	jne    420ed6 <p111_rt_op+0x426>
  421ad0:	mov    rax,r13
  421ad3:	shr    rax,0x38
  421ad7:	and    eax,0x7f
  421ada:	cmp    rax,0x2
  421ade:	je     421c18 <p111_rt_op+0x1168>
  421ae4:	mov    QWORD PTR [r9],r13
  421ae7:	jmp    420b91 <p111_rt_op+0xe1>
  421aec:	add    rax,rdx
  421aef:	lea    r14,[rbp+rax*8+0x0]
  421af4:	mov    r13,QWORD PTR [r14]
  421af7:	test   r13,r13
  421afa:	js     421c30 <p111_rt_op+0x1180>
  421b00:	mov    rax,r13
  421b03:	shr    rax,0x38
  421b07:	test   al,0x7e
  421b09:	je     421860 <p111_rt_op+0xdb0>
  421b0f:	movabs rdx,0xffffffffff
  421b19:	mov    rax,QWORD PTR [rcx+0x40]
  421b1d:	and    rdx,r13
  421b20:	add    rax,0x7f
  421b24:	and    rax,0xffffffffffffff80
  421b28:	add    rax,0x3108200
  421b2e:	cmp    rdx,rax
  421b31:	jae    40470b <p111_rt_op.cold+0x10d>
  421b37:	jmp    421860 <p111_rt_op+0xdb0>
  421b3c:	mov    DWORD PTR [rsp+0x20],0x6e616e
  421b44:	mov    eax,0x3
  421b49:	lea    r13,[rsp+0x20]
  421b4e:	jmp    421053 <p111_rt_op+0x5a3>
  421b53:	lea    rsi,[rbp+rcx*8+0x0]
  421b58:	mov    ecx,DWORD PTR [rsi+0x4]
  421b5b:	mov    edx,DWORD PTR [rsi]
  421b5d:	shl    rcx,0x20
  421b61:	or     rcx,rdx
  421b64:	and    edx,0xffffff
  421b6a:	cmp    rdx,0x1
  421b6e:	je     421c6a <p111_rt_op+0x11ba>
  421b74:	shr    rcx,0x18
  421b78:	mov    r15,rcx
  421b7b:	jmp    420ec1 <p111_rt_op+0x411>
  421b80:	lea    rsi,[rbp+rcx*8+0x0]
  421b85:	mov    ecx,DWORD PTR [rsi+0x4]
  421b88:	mov    edx,DWORD PTR [rsi]
  421b8a:	shl    rcx,0x20
  421b8e:	or     rcx,rdx
  421b91:	and    edx,0xffffff
  421b97:	cmp    rdx,0x1
  421b9b:	je     421c75 <p111_rt_op+0x11c5>
  421ba1:	shr    rcx,0x18
  421ba5:	mov    r14,rcx
  421ba8:	jmp    420e41 <p111_rt_op+0x391>
  421bad:	add    r9,rbp
  421bb0:	mov    edx,DWORD PTR [r9+0x4]
  421bb4:	mov    eax,DWORD PTR [r9]
  421bb7:	shl    rdx,0x20
  421bbb:	or     rdx,rax
  421bbe:	and    eax,0xffffff
  421bc3:	cmp    rax,0x1
  421bc7:	je     421c7c <p111_rt_op+0x11cc>
  421bcd:	shr    rdx,0x18
  421bd1:	lea    r9,[rdx*8+0x0]
  421bd9:	jmp    420b28 <p111_rt_op+0x78>
  421bde:	lea    rsi,[rbp+rdx*8+0x0]
  421be3:	mov    edx,DWORD PTR [rsi+0x4]
  421be6:	mov    ecx,DWORD PTR [rsi]
  421be8:	shl    rdx,0x20
  421bec:	or     rdx,rcx
  421bef:	and    ecx,0xffffff
  421bf5:	cmp    rcx,0x1
  421bf9:	je     421c71 <p111_rt_op+0x11c1>
  421bfb:	shr    rdx,0x18
  421bff:	jmp    421842 <p111_rt_op+0xd92>
  421c04:	test   r8,r8
  421c07:	js     421a5f <p111_rt_op+0xfaf>
  421c0d:	jmp    4046c4 <p111_rt_op.cold+0xc6>
  421c12:	nop    WORD PTR [rax+rax*1+0x0]
  421c18:	test   r13,r13
  421c1b:	js     421ae4 <p111_rt_op+0x1034>
  421c21:	jmp    404743 <p111_rt_op.cold+0x145>
  421c26:	nop    WORD PTR cs:[rax+rax*1+0x0]
  421c30:	movabs rax,0xffffffffff
  421c3a:	and    rax,r13
  421c3d:	lea    rdx,[rbp+rax*8+0x0]
  421c42:	mov    eax,DWORD PTR [rdx]
  421c44:	lea    ecx,[rax+0x1]
  421c47:	and    eax,0xffffff
  421c4c:	mov    DWORD PTR [rdx],ecx
  421c4e:	cmp    eax,0xfffffd
  421c53:	jbe    421860 <p111_rt_op+0xdb0>
  421c59:	call   41d510 <rfc_bump.part.0>
  421c5e:	lea    rdi,[rip+0x5bc3]        # 427828 <_IO_stdin_used+0x828>
  421c65:	call   41c3d0 <err_fail>
  421c6a:	mov    edx,DWORD PTR [rsi]
  421c6c:	jmp    421b74 <p111_rt_op+0x10c4>
  421c71:	mov    ecx,DWORD PTR [rsi]
  421c73:	jmp    421bfb <p111_rt_op+0x114b>
  421c75:	mov    edx,DWORD PTR [rsi]
  421c77:	jmp    421ba1 <p111_rt_op+0x10f1>
  421c7c:	mov    eax,DWORD PTR [r9]
  421c7f:	jmp    421bcd <p111_rt_op+0x111d>
  421c84:	call   402350 <sqrtf@plt>
  421c89:	jmp    420fc0 <p111_rt_op+0x510>

Disassembly of section .fini:
