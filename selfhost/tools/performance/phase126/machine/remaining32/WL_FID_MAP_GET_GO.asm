
/home/ai/bend2/build/publish/bend/selfhost/build/phase93/broad01/coverage-record-aggregation-256/upstream.program:     file format elf64-x86-64


Disassembly of section .text:

0000000000011d50 <WL_FID_MAP_GET_GO>:
   11d50:	55                   	push   %rbp
   11d51:	48 83 ec 60          	sub    $0x60,%rsp
   11d55:	48 89 d3             	mov    %rdx,%rbx
   11d58:	48 89 f5             	mov    %rsi,%rbp
   11d5b:	48 b8 ff ff ff ff ff 	movabs $0xffffffffff,%rax
   11d62:	00 00 00 
   11d65:	48 ba 00 00 00 00 00 	movabs $0xffff0000000000,%rdx
   11d6c:	ff ff 00 
   11d6f:	48 21 f2             	and    %rsi,%rdx
   11d72:	48 be 00 00 00 00 00 	movabs $0x140000000000,%rsi
   11d79:	14 00 00 
   11d7c:	48 39 f2             	cmp    %rsi,%rdx
   11d7f:	0f 85 aa 00 00 00    	jne    11e2f <WL_FID_MAP_GET_GO+0xdf>
   11d85:	48 89 5c 24 40       	mov    %rbx,0x40(%rsp)
   11d8a:	48 21 c5             	and    %rax,%rbp
   11d8d:	49 8b 34 ec          	mov    (%r12,%rbp,8),%rsi
   11d91:	49 8b 5c ec 08       	mov    0x8(%r12,%rbp,8),%rbx
   11d96:	48 89 6c 24 38       	mov    %rbp,0x38(%rsp)
   11d9b:	49 8b 6c ec 10       	mov    0x10(%r12,%rbp,8),%rbp
   11da0:	48 89 da             	mov    %rbx,%rdx
   11da3:	48 c1 ea 28          	shr    $0x28,%rdx
   11da7:	66 83 fa 13          	cmp    $0x13,%dx
   11dab:	0f 84 d5 00 00 00    	je     11e86 <WL_FID_MAP_GET_GO+0x136>
   11db1:	0f b7 d2             	movzwl %dx,%edx
   11db4:	83 fa 12             	cmp    $0x12,%edx
   11db7:	0f 85 b3 01 00 00    	jne    11f70 <WL_FID_MAP_GET_GO+0x220>
   11dbd:	48 89 ea             	mov    %rbp,%rdx
   11dc0:	48 c1 ea 28          	shr    $0x28,%rdx
   11dc4:	66 83 fa 13          	cmp    $0x13,%dx
   11dc8:	0f 84 9e 02 00 00    	je     1206c <WL_FID_MAP_GET_GO+0x31c>
   11dce:	0f b7 d2             	movzwl %dx,%edx
   11dd1:	83 fa 12             	cmp    $0x12,%edx
   11dd4:	0f 85 15 04 00 00    	jne    121ef <WL_FID_MAP_GET_GO+0x49f>
   11dda:	48 83 f9 ff          	cmp    $0xffffffffffffffff,%rcx
   11dde:	74 32                	je     11e12 <WL_FID_MAP_GET_GO+0xc2>
   11de0:	48 ba 00 00 00 00 00 	movabs $0x7e00000000000000,%rdx
   11de7:	00 00 7e 
   11dea:	48 21 ca             	and    %rcx,%rdx
   11ded:	74 23                	je     11e12 <WL_FID_MAP_GET_GO+0xc2>
   11def:	48 83 c0 81          	add    $0xffffffffffffff81,%rax
   11df3:	48 21 c8             	and    %rcx,%rax
   11df6:	48 3d 80 82 10 03    	cmp    $0x3108280,%rax
   11dfc:	72 14                	jb     11e12 <WL_FID_MAP_GET_GO+0xc2>
   11dfe:	4c 89 e7             	mov    %r12,%rdi
   11e01:	48 89 f3             	mov    %rsi,%rbx
   11e04:	4c 89 ee             	mov    %r13,%rsi
   11e07:	48 89 ca             	mov    %rcx,%rdx
   11e0a:	e8 d1 5d ff ff       	callq  7be0 <term_drop>
   11e0f:	48 89 de             	mov    %rbx,%rsi
   11e12:	48 8b 4c 24 38       	mov    0x38(%rsp),%rcx
   11e17:	49 89 34 cc          	mov    %rsi,(%r12,%rcx,8)
   11e1b:	48 b8 00 00 00 00 00 	movabs $0x100120000000000,%rax
   11e22:	12 00 01 
   11e25:	49 89 44 cc 08       	mov    %rax,0x8(%r12,%rcx,8)
   11e2a:	e9 19 08 00 00       	jmpq   12648 <WL_FID_MAP_GET_GO+0x8f8>
   11e2f:	48 83 f9 ff          	cmp    $0xffffffffffffffff,%rcx
   11e33:	74 2c                	je     11e61 <WL_FID_MAP_GET_GO+0x111>
   11e35:	48 ba 00 00 00 00 00 	movabs $0x7e00000000000000,%rdx
   11e3c:	00 00 7e 
   11e3f:	48 21 ca             	and    %rcx,%rdx
   11e42:	74 1d                	je     11e61 <WL_FID_MAP_GET_GO+0x111>
   11e44:	48 83 c0 81          	add    $0xffffffffffffff81,%rax
   11e48:	48 21 c8             	and    %rcx,%rax
   11e4b:	48 3d 80 82 10 03    	cmp    $0x3108280,%rax
   11e51:	72 0e                	jb     11e61 <WL_FID_MAP_GET_GO+0x111>
   11e53:	4c 89 e7             	mov    %r12,%rdi
   11e56:	4c 89 ee             	mov    %r13,%rsi
   11e59:	48 89 ca             	mov    %rcx,%rdx
   11e5c:	e8 7f 5d ff ff       	callq  7be0 <term_drop>
   11e61:	41 8b 46 f8          	mov    -0x8(%r14),%eax
   11e65:	49 83 c6 f8          	add    $0xfffffffffffffff8,%r14
   11e69:	48 8d 0d 50 d8 00 00 	lea    0xd850(%rip),%rcx        # 1f6c0 <wl_tab>
   11e70:	48 8b 04 c1          	mov    (%rcx,%rax,8),%rax
   11e74:	bf 02 00 00 00       	mov    $0x2,%edi
   11e79:	48 89 ee             	mov    %rbp,%rsi
   11e7c:	48 89 da             	mov    %rbx,%rdx
   11e7f:	48 83 c4 60          	add    $0x60,%rsp
   11e83:	5d                   	pop    %rbp
   11e84:	ff e0                	jmpq   *%rax
   11e86:	48 21 c3             	and    %rax,%rbx
   11e89:	4d 8b 14 dc          	mov    (%r12,%rbx,8),%r10
   11e8d:	4d 8b 4c dc 08       	mov    0x8(%r12,%rbx,8),%r9
   11e92:	48 89 ea             	mov    %rbp,%rdx
   11e95:	48 c1 ea 28          	shr    $0x28,%rdx
   11e99:	66 83 fa 13          	cmp    $0x13,%dx
   11e9d:	0f 84 82 02 00 00    	je     12125 <WL_FID_MAP_GET_GO+0x3d5>
   11ea3:	0f b7 d2             	movzwl %dx,%edx
   11ea6:	83 fa 12             	cmp    $0x12,%edx
   11ea9:	0f 85 02 04 00 00    	jne    122b1 <WL_FID_MAP_GET_GO+0x561>
   11eaf:	45 85 c0             	test   %r8d,%r8d
   11eb2:	4c 8b 44 24 40       	mov    0x40(%rsp),%r8
   11eb7:	0f 84 78 06 00 00    	je     12535 <WL_FID_MAP_GET_GO+0x7e5>
   11ebd:	48 83 f9 ff          	cmp    $0xffffffffffffffff,%rcx
   11ec1:	74 4b                	je     11f0e <WL_FID_MAP_GET_GO+0x1be>
   11ec3:	48 ba 00 00 00 00 00 	movabs $0x7e00000000000000,%rdx
   11eca:	00 00 7e 
   11ecd:	48 21 ca             	and    %rcx,%rdx
   11ed0:	74 3c                	je     11f0e <WL_FID_MAP_GET_GO+0x1be>
   11ed2:	48 83 c0 81          	add    $0xffffffffffffff81,%rax
   11ed6:	48 21 c8             	and    %rcx,%rax
   11ed9:	48 3d 80 82 10 03    	cmp    $0x3108280,%rax
   11edf:	72 2d                	jb     11f0e <WL_FID_MAP_GET_GO+0x1be>
   11ee1:	4c 89 e7             	mov    %r12,%rdi
   11ee4:	48 89 74 24 10       	mov    %rsi,0x10(%rsp)
   11ee9:	4c 89 ee             	mov    %r13,%rsi
   11eec:	48 89 ca             	mov    %rcx,%rdx
   11eef:	4c 89 d5             	mov    %r10,%rbp
   11ef2:	4c 89 4c 24 30       	mov    %r9,0x30(%rsp)
   11ef7:	e8 e4 5c ff ff       	callq  7be0 <term_drop>
   11efc:	4c 8b 44 24 40       	mov    0x40(%rsp),%r8
   11f01:	4c 8b 4c 24 30       	mov    0x30(%rsp),%r9
   11f06:	49 89 ea             	mov    %rbp,%r10
   11f09:	48 8b 74 24 10       	mov    0x10(%rsp),%rsi
   11f0e:	4d 89 14 dc          	mov    %r10,(%r12,%rbx,8)
   11f12:	4d 89 4c dc 08       	mov    %r9,0x8(%r12,%rbx,8)
   11f17:	48 8b 4c 24 38       	mov    0x38(%rsp),%rcx
   11f1c:	49 89 34 cc          	mov    %rsi,(%r12,%rcx,8)
   11f20:	48 b8 00 00 00 00 00 	movabs $0x200130000000000,%rax
   11f27:	13 00 02 
   11f2a:	48 09 d8             	or     %rbx,%rax
   11f2d:	49 89 44 cc 08       	mov    %rax,0x8(%r12,%rcx,8)
   11f32:	48 b8 00 00 00 00 00 	movabs $0x100120000000000,%rax
   11f39:	12 00 01 
   11f3c:	49 89 44 cc 10       	mov    %rax,0x10(%r12,%rcx,8)
   11f41:	48 be 00 00 00 00 00 	movabs $0x200140000000000,%rsi
   11f48:	14 00 02 
   11f4b:	48 09 ce             	or     %rcx,%rsi
   11f4e:	41 8b 46 f8          	mov    -0x8(%r14),%eax
   11f52:	49 83 c6 f8          	add    $0xfffffffffffffff8,%r14
   11f56:	48 8d 0d 63 d7 00 00 	lea    0xd763(%rip),%rcx        # 1f6c0 <wl_tab>
   11f5d:	48 8b 04 c1          	mov    (%rcx,%rax,8),%rax
   11f61:	bf 02 00 00 00       	mov    $0x2,%edi
   11f66:	4c 89 c2             	mov    %r8,%rdx
   11f69:	48 83 c4 60          	add    $0x60,%rsp
   11f6d:	5d                   	pop    %rbp
   11f6e:	ff e0                	jmpq   *%rax
   11f70:	48 21 c3             	and    %rax,%rbx
   11f73:	49 8b 14 dc          	mov    (%r12,%rbx,8),%rdx
   11f77:	48 89 54 24 18       	mov    %rdx,0x18(%rsp)
   11f7c:	49 8b 54 dc 08       	mov    0x8(%r12,%rbx,8),%rdx
   11f81:	48 89 54 24 28       	mov    %rdx,0x28(%rsp)
   11f86:	49 8b 54 dc 10       	mov    0x10(%r12,%rbx,8),%rdx
   11f8b:	48 89 54 24 30       	mov    %rdx,0x30(%rsp)
   11f90:	48 89 ea             	mov    %rbp,%rdx
   11f93:	48 c1 ea 28          	shr    $0x28,%rdx
   11f97:	66 83 fa 13          	cmp    $0x13,%dx
   11f9b:	0f 84 e8 03 00 00    	je     12389 <WL_FID_MAP_GET_GO+0x639>
   11fa1:	0f b7 d2             	movzwl %dx,%edx
   11fa4:	83 fa 12             	cmp    $0x12,%edx
   11fa7:	0f 85 a8 04 00 00    	jne    12455 <WL_FID_MAP_GET_GO+0x705>
   11fad:	45 85 c0             	test   %r8d,%r8d
   11fb0:	4c 8b 54 24 40       	mov    0x40(%rsp),%r10
   11fb5:	0f 84 1b 07 00 00    	je     126d6 <WL_FID_MAP_GET_GO+0x986>
   11fbb:	48 83 f9 ff          	cmp    $0xffffffffffffffff,%rcx
   11fbf:	74 3c                	je     11ffd <WL_FID_MAP_GET_GO+0x2ad>
   11fc1:	48 ba 00 00 00 00 00 	movabs $0x7e00000000000000,%rdx
   11fc8:	00 00 7e 
   11fcb:	48 21 ca             	and    %rcx,%rdx
   11fce:	74 2d                	je     11ffd <WL_FID_MAP_GET_GO+0x2ad>
   11fd0:	48 83 c0 81          	add    $0xffffffffffffff81,%rax
   11fd4:	48 21 c8             	and    %rcx,%rax
   11fd7:	48 3d 80 82 10 03    	cmp    $0x3108280,%rax
   11fdd:	72 1e                	jb     11ffd <WL_FID_MAP_GET_GO+0x2ad>
   11fdf:	4c 89 e7             	mov    %r12,%rdi
   11fe2:	48 89 74 24 10       	mov    %rsi,0x10(%rsp)
   11fe7:	4c 89 ee             	mov    %r13,%rsi
   11fea:	48 89 ca             	mov    %rcx,%rdx
   11fed:	4c 89 d5             	mov    %r10,%rbp
   11ff0:	e8 eb 5b ff ff       	callq  7be0 <term_drop>
   11ff5:	49 89 ea             	mov    %rbp,%r10
   11ff8:	48 8b 74 24 10       	mov    0x10(%rsp),%rsi
   11ffd:	48 8b 4c 24 38       	mov    0x38(%rsp),%rcx
   12002:	48 8b 44 24 18       	mov    0x18(%rsp),%rax
   12007:	49 89 04 cc          	mov    %rax,(%r12,%rcx,8)
   1200b:	48 8b 44 24 28       	mov    0x28(%rsp),%rax
   12010:	49 89 44 cc 08       	mov    %rax,0x8(%r12,%rcx,8)
   12015:	48 8b 44 24 30       	mov    0x30(%rsp),%rax
   1201a:	49 89 44 cc 10       	mov    %rax,0x10(%r12,%rcx,8)
   1201f:	49 89 34 dc          	mov    %rsi,(%r12,%rbx,8)
   12023:	48 b8 00 00 00 00 00 	movabs $0x200140000000000,%rax
   1202a:	14 00 02 
   1202d:	48 09 c1             	or     %rax,%rcx
   12030:	49 89 4c dc 08       	mov    %rcx,0x8(%r12,%rbx,8)
   12035:	48 b9 00 00 00 00 00 	movabs $0x100120000000000,%rcx
   1203c:	12 00 01 
   1203f:	49 89 4c dc 10       	mov    %rcx,0x10(%r12,%rbx,8)
   12044:	48 09 c3             	or     %rax,%rbx
   12047:	41 8b 46 f8          	mov    -0x8(%r14),%eax
   1204b:	49 83 c6 f8          	add    $0xfffffffffffffff8,%r14
   1204f:	48 8d 0d 6a d6 00 00 	lea    0xd66a(%rip),%rcx        # 1f6c0 <wl_tab>
   12056:	48 8b 04 c1          	mov    (%rcx,%rax,8),%rax
   1205a:	bf 02 00 00 00       	mov    $0x2,%edi
   1205f:	48 89 de             	mov    %rbx,%rsi
   12062:	4c 89 d2             	mov    %r10,%rdx
   12065:	48 83 c4 60          	add    $0x60,%rsp
   12069:	5d                   	pop    %rbp
   1206a:	ff e0                	jmpq   *%rax
   1206c:	48 21 c5             	and    %rax,%rbp
   1206f:	4d 8b 0c ec          	mov    (%r12,%rbp,8),%r9
   12073:	49 8b 5c ec 08       	mov    0x8(%r12,%rbp,8),%rbx
   12078:	45 85 c0             	test   %r8d,%r8d
   1207b:	0f 84 53 05 00 00    	je     125d4 <WL_FID_MAP_GET_GO+0x884>
   12081:	49 8b 45 08          	mov    0x8(%r13),%rax
   12085:	49 89 04 ec          	mov    %rax,(%r12,%rbp,8)
   12089:	49 89 6d 08          	mov    %rbp,0x8(%r13)
   1208d:	49 8b 95 08 01 00 00 	mov    0x108(%r13),%rdx
   12094:	48 83 c2 02          	add    $0x2,%rdx
   12098:	49 89 95 08 01 00 00 	mov    %rdx,0x108(%r13)
   1209f:	0f b6 05 ea f0 00 00 	movzbl 0xf0ea(%rip),%eax        # 21190 <KEEP_WORDS>
   120a6:	3c 01                	cmp    $0x1,%al
   120a8:	0f 85 e7 0d 00 00    	jne    12e95 <WL_FID_MAP_GET_GO+0x1145>
   120ae:	48 81 fa 00 80 00 00 	cmp    $0x8000,%rdx
   120b5:	0f 83 da 0d 00 00    	jae    12e95 <WL_FID_MAP_GET_GO+0x1145>
   120bb:	49 8b 55 10          	mov    0x10(%r13),%rdx
   120bf:	48 8b 7c 24 38       	mov    0x38(%rsp),%rdi
   120c4:	49 89 14 fc          	mov    %rdx,(%r12,%rdi,8)
   120c8:	49 89 7d 10          	mov    %rdi,0x10(%r13)
   120cc:	49 8b 95 10 01 00 00 	mov    0x110(%r13),%rdx
   120d3:	48 83 c2 04          	add    $0x4,%rdx
   120d7:	49 89 95 10 01 00 00 	mov    %rdx,0x110(%r13)
   120de:	48 81 fa 00 80 00 00 	cmp    $0x8000,%rdx
   120e5:	0f 92 c2             	setb   %dl
   120e8:	84 d0                	test   %dl,%al
   120ea:	48 8b 6c 24 40       	mov    0x40(%rsp),%rbp
   120ef:	0f 84 3c 0c 00 00    	je     12d31 <WL_FID_MAP_GET_GO+0xfe1>
   120f5:	45 85 ff             	test   %r15d,%r15d
   120f8:	0f 84 52 0c 00 00    	je     12d50 <WL_FID_MAP_GET_GO+0x1000>
   120fe:	49 89 36             	mov    %rsi,(%r14)
   12101:	49 89 5e 08          	mov    %rbx,0x8(%r14)
   12105:	49 89 6e 10          	mov    %rbp,0x10(%r14)
   12109:	49 c7 46 18 3e 00 00 	movq   $0x3e,0x18(%r14)
   12110:	00 
   12111:	49 83 c6 20          	add    $0x20,%r14
   12115:	48 89 ce             	mov    %rcx,%rsi
   12118:	4c 89 ca             	mov    %r9,%rdx
   1211b:	48 83 c4 60          	add    $0x60,%rsp
   1211f:	5d                   	pop    %rbp
   12120:	e9 db 24 00 00       	jmpq   14600 <WL_FID_STRING_CMP>
   12125:	4c 89 4c 24 30       	mov    %r9,0x30(%rsp)
   1212a:	4c 89 54 24 18       	mov    %r10,0x18(%rsp)
   1212f:	48 89 74 24 10       	mov    %rsi,0x10(%rsp)
   12134:	48 89 4c 24 08       	mov    %rcx,0x8(%rsp)
   12139:	48 21 c5             	and    %rax,%rbp
   1213c:	49 8b 04 ec          	mov    (%r12,%rbp,8),%rax
   12140:	48 89 44 24 20       	mov    %rax,0x20(%rsp)
   12145:	49 8b 44 ec 08       	mov    0x8(%r12,%rbp,8),%rax
   1214a:	48 89 44 24 28       	mov    %rax,0x28(%rsp)
   1214f:	4c 89 44 24 48       	mov    %r8,0x48(%rsp)
   12154:	4c 89 e7             	mov    %r12,%rdi
   12157:	4c 89 ee             	mov    %r13,%rsi
   1215a:	ba 01 00 00 00       	mov    $0x1,%edx
   1215f:	48 89 e9             	mov    %rbp,%rcx
   12162:	e8 29 5a ff ff       	callq  7b90 <heap_free>
   12167:	4c 89 e7             	mov    %r12,%rdi
   1216a:	4c 89 ee             	mov    %r13,%rsi
   1216d:	ba 01 00 00 00       	mov    $0x1,%edx
   12172:	48 89 d9             	mov    %rbx,%rcx
   12175:	e8 16 5a ff ff       	callq  7b90 <heap_free>
   1217a:	4c 89 e7             	mov    %r12,%rdi
   1217d:	4c 89 ee             	mov    %r13,%rsi
   12180:	ba 02 00 00 00       	mov    $0x2,%edx
   12185:	48 8b 4c 24 38       	mov    0x38(%rsp),%rcx
   1218a:	e8 01 5a ff ff       	callq  7b90 <heap_free>
   1218f:	83 7c 24 48 00       	cmpl   $0x0,0x48(%rsp)
   12194:	0f 84 e4 04 00 00    	je     1267e <WL_FID_MAP_GET_GO+0x92e>
   1219a:	45 85 ff             	test   %r15d,%r15d
   1219d:	48 8b 74 24 08       	mov    0x8(%rsp),%rsi
   121a2:	48 8b 6c 24 40       	mov    0x40(%rsp),%rbp
   121a7:	48 8b 4c 24 18       	mov    0x18(%rsp),%rcx
   121ac:	48 8b 7c 24 30       	mov    0x30(%rsp),%rdi
   121b1:	0f 84 b7 07 00 00    	je     1296e <WL_FID_MAP_GET_GO+0xc1e>
   121b7:	48 8b 44 24 10       	mov    0x10(%rsp),%rax
   121bc:	49 89 06             	mov    %rax,(%r14)
   121bf:	49 89 4e 08          	mov    %rcx,0x8(%r14)
   121c3:	49 89 7e 10          	mov    %rdi,0x10(%r14)
   121c7:	48 8b 44 24 28       	mov    0x28(%rsp),%rax
   121cc:	49 89 46 18          	mov    %rax,0x18(%r14)
   121d0:	49 89 6e 20          	mov    %rbp,0x20(%r14)
   121d4:	49 c7 46 28 43 00 00 	movq   $0x43,0x28(%r14)
   121db:	00 
   121dc:	49 83 c6 30          	add    $0x30,%r14
   121e0:	48 8b 54 24 20       	mov    0x20(%rsp),%rdx
   121e5:	48 83 c4 60          	add    $0x60,%rsp
   121e9:	5d                   	pop    %rbp
   121ea:	e9 11 24 00 00       	jmpq   14600 <WL_FID_STRING_CMP>
   121ef:	48 21 c5             	and    %rax,%rbp
   121f2:	49 8b 1c ec          	mov    (%r12,%rbp,8),%rbx
   121f6:	4d 8b 54 ec 08       	mov    0x8(%r12,%rbp,8),%r10
   121fb:	4d 8b 4c ec 10       	mov    0x10(%r12,%rbp,8),%r9
   12200:	45 85 c0             	test   %r8d,%r8d
   12203:	0f 84 7f 05 00 00    	je     12788 <WL_FID_MAP_GET_GO+0xa38>
   12209:	49 8b 45 10          	mov    0x10(%r13),%rax
   1220d:	49 89 04 ec          	mov    %rax,(%r12,%rbp,8)
   12211:	49 89 6d 10          	mov    %rbp,0x10(%r13)
   12215:	49 8b 95 10 01 00 00 	mov    0x110(%r13),%rdx
   1221c:	48 83 c2 04          	add    $0x4,%rdx
   12220:	49 89 95 10 01 00 00 	mov    %rdx,0x110(%r13)
   12227:	0f b6 05 62 ef 00 00 	movzbl 0xef62(%rip),%eax        # 21190 <KEEP_WORDS>
   1222e:	3c 01                	cmp    $0x1,%al
   12230:	0f 85 7a 0c 00 00    	jne    12eb0 <WL_FID_MAP_GET_GO+0x1160>
   12236:	48 81 fa 00 80 00 00 	cmp    $0x8000,%rdx
   1223d:	0f 83 6d 0c 00 00    	jae    12eb0 <WL_FID_MAP_GET_GO+0x1160>
   12243:	48 8b 54 24 38       	mov    0x38(%rsp),%rdx
   12248:	49 89 2c d4          	mov    %rbp,(%r12,%rdx,8)
   1224c:	49 89 55 10          	mov    %rdx,0x10(%r13)
   12250:	49 8b 95 10 01 00 00 	mov    0x110(%r13),%rdx
   12257:	48 83 c2 04          	add    $0x4,%rdx
   1225b:	49 89 95 10 01 00 00 	mov    %rdx,0x110(%r13)
   12262:	48 81 fa 00 80 00 00 	cmp    $0x8000,%rdx
   12269:	0f 92 c2             	setb   %dl
   1226c:	84 d0                	test   %dl,%al
   1226e:	0f 84 60 0b 00 00    	je     12dd4 <WL_FID_MAP_GET_GO+0x1084>
   12274:	45 85 ff             	test   %r15d,%r15d
   12277:	48 8b 6c 24 40       	mov    0x40(%rsp),%rbp
   1227c:	0f 84 76 0b 00 00    	je     12df8 <WL_FID_MAP_GET_GO+0x10a8>
   12282:	49 89 36             	mov    %rsi,(%r14)
   12285:	49 89 5e 08          	mov    %rbx,0x8(%r14)
   12289:	4d 89 56 10          	mov    %r10,0x10(%r14)
   1228d:	4d 89 4e 18          	mov    %r9,0x18(%r14)
   12291:	49 89 6e 20          	mov    %rbp,0x20(%r14)
   12295:	49 c7 46 28 3f 00 00 	movq   $0x3f,0x28(%r14)
   1229c:	00 
   1229d:	49 83 c6 30          	add    $0x30,%r14
   122a1:	48 89 ce             	mov    %rcx,%rsi
   122a4:	48 89 da             	mov    %rbx,%rdx
   122a7:	48 83 c4 60          	add    $0x60,%rsp
   122ab:	5d                   	pop    %rbp
   122ac:	e9 ff f9 ff ff       	jmpq   11cb0 <WL_FID_MAP_BIT>
   122b1:	4c 89 4c 24 30       	mov    %r9,0x30(%rsp)
   122b6:	4c 89 54 24 18       	mov    %r10,0x18(%rsp)
   122bb:	48 89 74 24 10       	mov    %rsi,0x10(%rsp)
   122c0:	48 89 4c 24 08       	mov    %rcx,0x8(%rsp)
   122c5:	48 21 c5             	and    %rax,%rbp
   122c8:	49 8b 04 ec          	mov    (%r12,%rbp,8),%rax
   122cc:	48 89 44 24 28       	mov    %rax,0x28(%rsp)
   122d1:	49 8b 44 ec 08       	mov    0x8(%r12,%rbp,8),%rax
   122d6:	48 89 44 24 50       	mov    %rax,0x50(%rsp)
   122db:	49 8b 44 ec 10       	mov    0x10(%r12,%rbp,8),%rax
   122e0:	48 89 44 24 20       	mov    %rax,0x20(%rsp)
   122e5:	4c 89 44 24 48       	mov    %r8,0x48(%rsp)
   122ea:	4c 89 e7             	mov    %r12,%rdi
   122ed:	4c 89 ee             	mov    %r13,%rsi
   122f0:	ba 02 00 00 00       	mov    $0x2,%edx
   122f5:	48 89 e9             	mov    %rbp,%rcx
   122f8:	e8 93 58 ff ff       	callq  7b90 <heap_free>
   122fd:	4c 89 e7             	mov    %r12,%rdi
   12300:	4c 89 ee             	mov    %r13,%rsi
   12303:	ba 01 00 00 00       	mov    $0x1,%edx
   12308:	48 89 d9             	mov    %rbx,%rcx
   1230b:	e8 80 58 ff ff       	callq  7b90 <heap_free>
   12310:	4c 89 e7             	mov    %r12,%rdi
   12313:	4c 89 ee             	mov    %r13,%rsi
   12316:	ba 02 00 00 00       	mov    $0x2,%edx
   1231b:	48 8b 4c 24 38       	mov    0x38(%rsp),%rcx
   12320:	e8 6b 58 ff ff       	callq  7b90 <heap_free>
   12325:	83 7c 24 48 00       	cmpl   $0x0,0x48(%rsp)
   1232a:	0f 84 0a 05 00 00    	je     1283a <WL_FID_MAP_GET_GO+0xaea>
   12330:	45 85 ff             	test   %r15d,%r15d
   12333:	48 8b 44 24 08       	mov    0x8(%rsp),%rax
   12338:	48 8b 6c 24 40       	mov    0x40(%rsp),%rbp
   1233d:	48 8b 54 24 10       	mov    0x10(%rsp),%rdx
   12342:	48 8b 5c 24 18       	mov    0x18(%rsp),%rbx
   12347:	48 8b 74 24 30       	mov    0x30(%rsp),%rsi
   1234c:	0f 84 42 06 00 00    	je     12994 <WL_FID_MAP_GET_GO+0xc44>
   12352:	49 89 16             	mov    %rdx,(%r14)
   12355:	49 89 5e 08          	mov    %rbx,0x8(%r14)
   12359:	49 89 76 10          	mov    %rsi,0x10(%r14)
   1235d:	48 8b 54 24 28       	mov    0x28(%rsp),%rdx
   12362:	49 89 56 18          	mov    %rdx,0x18(%r14)
   12366:	48 8b 4c 24 50       	mov    0x50(%rsp),%rcx
   1236b:	49 89 4e 20          	mov    %rcx,0x20(%r14)
   1236f:	48 8b 4c 24 20       	mov    0x20(%rsp),%rcx
   12374:	49 89 4e 28          	mov    %rcx,0x28(%r14)
   12378:	49 89 6e 30          	mov    %rbp,0x30(%r14)
   1237c:	49 c7 46 38 45 00 00 	movq   $0x45,0x38(%r14)
   12383:	00 
   12384:	e9 69 05 00 00       	jmpq   128f2 <WL_FID_MAP_GET_GO+0xba2>
   12389:	48 89 74 24 10       	mov    %rsi,0x10(%rsp)
   1238e:	48 89 4c 24 08       	mov    %rcx,0x8(%rsp)
   12393:	48 21 c5             	and    %rax,%rbp
   12396:	49 8b 04 ec          	mov    (%r12,%rbp,8),%rax
   1239a:	48 89 44 24 20       	mov    %rax,0x20(%rsp)
   1239f:	49 8b 44 ec 08       	mov    0x8(%r12,%rbp,8),%rax
   123a4:	48 89 44 24 50       	mov    %rax,0x50(%rsp)
   123a9:	4c 89 44 24 48       	mov    %r8,0x48(%rsp)
   123ae:	4c 89 e7             	mov    %r12,%rdi
   123b1:	4c 89 ee             	mov    %r13,%rsi
   123b4:	ba 01 00 00 00       	mov    $0x1,%edx
   123b9:	48 89 e9             	mov    %rbp,%rcx
   123bc:	e8 cf 57 ff ff       	callq  7b90 <heap_free>
   123c1:	4c 89 e7             	mov    %r12,%rdi
   123c4:	4c 89 ee             	mov    %r13,%rsi
   123c7:	ba 02 00 00 00       	mov    $0x2,%edx
   123cc:	48 89 d9             	mov    %rbx,%rcx
   123cf:	e8 bc 57 ff ff       	callq  7b90 <heap_free>
   123d4:	4c 89 e7             	mov    %r12,%rdi
   123d7:	4c 89 ee             	mov    %r13,%rsi
   123da:	ba 02 00 00 00       	mov    $0x2,%edx
   123df:	48 8b 4c 24 38       	mov    0x38(%rsp),%rcx
   123e4:	e8 a7 57 ff ff       	callq  7b90 <heap_free>
   123e9:	83 7c 24 48 00       	cmpl   $0x0,0x48(%rsp)
   123ee:	0f 84 aa 04 00 00    	je     1289e <WL_FID_MAP_GET_GO+0xb4e>
   123f4:	45 85 ff             	test   %r15d,%r15d
   123f7:	48 8b 44 24 08       	mov    0x8(%rsp),%rax
   123fc:	48 8b 6c 24 40       	mov    0x40(%rsp),%rbp
   12401:	48 8b 54 24 10       	mov    0x10(%rsp),%rdx
   12406:	0f 84 0e 06 00 00    	je     12a1a <WL_FID_MAP_GET_GO+0xcca>
   1240c:	49 89 16             	mov    %rdx,(%r14)
   1240f:	48 8b 4c 24 18       	mov    0x18(%rsp),%rcx
   12414:	49 89 4e 08          	mov    %rcx,0x8(%r14)
   12418:	48 8b 4c 24 28       	mov    0x28(%rsp),%rcx
   1241d:	49 89 4e 10          	mov    %rcx,0x10(%r14)
   12421:	48 8b 4c 24 30       	mov    0x30(%rsp),%rcx
   12426:	49 89 4e 18          	mov    %rcx,0x18(%r14)
   1242a:	48 8b 4c 24 50       	mov    0x50(%rsp),%rcx
   1242f:	49 89 4e 20          	mov    %rcx,0x20(%r14)
   12433:	49 89 6e 28          	mov    %rbp,0x28(%r14)
   12437:	49 c7 46 30 4b 00 00 	movq   $0x4b,0x30(%r14)
   1243e:	00 
   1243f:	49 83 c6 38          	add    $0x38,%r14
   12443:	48 89 c6             	mov    %rax,%rsi
   12446:	48 8b 54 24 20       	mov    0x20(%rsp),%rdx
   1244b:	48 83 c4 60          	add    $0x60,%rsp
   1244f:	5d                   	pop    %rbp
   12450:	e9 ab 21 00 00       	jmpq   14600 <WL_FID_STRING_CMP>
   12455:	48 89 74 24 10       	mov    %rsi,0x10(%rsp)
   1245a:	48 89 4c 24 08       	mov    %rcx,0x8(%rsp)
   1245f:	48 21 c5             	and    %rax,%rbp
   12462:	49 8b 04 ec          	mov    (%r12,%rbp,8),%rax
   12466:	48 89 44 24 20       	mov    %rax,0x20(%rsp)
   1246b:	49 8b 44 ec 08       	mov    0x8(%r12,%rbp,8),%rax
   12470:	48 89 44 24 58       	mov    %rax,0x58(%rsp)
   12475:	49 8b 44 ec 10       	mov    0x10(%r12,%rbp,8),%rax
   1247a:	48 89 44 24 50       	mov    %rax,0x50(%rsp)
   1247f:	4c 89 44 24 48       	mov    %r8,0x48(%rsp)
   12484:	4c 89 e7             	mov    %r12,%rdi
   12487:	4c 89 ee             	mov    %r13,%rsi
   1248a:	ba 02 00 00 00       	mov    $0x2,%edx
   1248f:	48 89 e9             	mov    %rbp,%rcx
   12492:	e8 f9 56 ff ff       	callq  7b90 <heap_free>
   12497:	4c 89 e7             	mov    %r12,%rdi
   1249a:	4c 89 ee             	mov    %r13,%rsi
   1249d:	ba 02 00 00 00       	mov    $0x2,%edx
   124a2:	48 89 d9             	mov    %rbx,%rcx
   124a5:	e8 e6 56 ff ff       	callq  7b90 <heap_free>
   124aa:	4c 89 e7             	mov    %r12,%rdi
   124ad:	4c 89 ee             	mov    %r13,%rsi
   124b0:	ba 02 00 00 00       	mov    $0x2,%edx
   124b5:	48 8b 4c 24 38       	mov    0x38(%rsp),%rcx
   124ba:	e8 d1 56 ff ff       	callq  7b90 <heap_free>
   124bf:	83 7c 24 48 00       	cmpl   $0x0,0x48(%rsp)
   124c4:	0f 84 39 04 00 00    	je     12903 <WL_FID_MAP_GET_GO+0xbb3>
   124ca:	45 85 ff             	test   %r15d,%r15d
   124cd:	48 8b 74 24 08       	mov    0x8(%rsp),%rsi
   124d2:	48 8b 6c 24 40       	mov    0x40(%rsp),%rbp
   124d7:	0f 84 d5 05 00 00    	je     12ab2 <WL_FID_MAP_GET_GO+0xd62>
   124dd:	48 8b 44 24 10       	mov    0x10(%rsp),%rax
   124e2:	49 89 06             	mov    %rax,(%r14)
   124e5:	48 8b 44 24 18       	mov    0x18(%rsp),%rax
   124ea:	49 89 46 08          	mov    %rax,0x8(%r14)
   124ee:	48 8b 44 24 28       	mov    0x28(%rsp),%rax
   124f3:	49 89 46 10          	mov    %rax,0x10(%r14)
   124f7:	48 8b 44 24 30       	mov    0x30(%rsp),%rax
   124fc:	49 89 46 18          	mov    %rax,0x18(%r14)
   12500:	48 8b 54 24 20       	mov    0x20(%rsp),%rdx
   12505:	49 89 56 20          	mov    %rdx,0x20(%r14)
   12509:	48 8b 44 24 58       	mov    0x58(%rsp),%rax
   1250e:	49 89 46 28          	mov    %rax,0x28(%r14)
   12512:	48 8b 44 24 50       	mov    0x50(%rsp),%rax
   12517:	49 89 46 30          	mov    %rax,0x30(%r14)
   1251b:	49 89 6e 38          	mov    %rbp,0x38(%r14)
   1251f:	49 c7 46 40 4e 00 00 	movq   $0x4e,0x40(%r14)
   12526:	00 
   12527:	49 83 c6 48          	add    $0x48,%r14
   1252b:	48 83 c4 60          	add    $0x60,%rsp
   1252f:	5d                   	pop    %rbp
   12530:	e9 7b f7 ff ff       	jmpq   11cb0 <WL_FID_MAP_BIT>
   12535:	49 8b 45 08          	mov    0x8(%r13),%rax
   12539:	49 89 04 dc          	mov    %rax,(%r12,%rbx,8)
   1253d:	49 89 5d 08          	mov    %rbx,0x8(%r13)
   12541:	49 8b 95 08 01 00 00 	mov    0x108(%r13),%rdx
   12548:	48 83 c2 02          	add    $0x2,%rdx
   1254c:	49 89 95 08 01 00 00 	mov    %rdx,0x108(%r13)
   12553:	0f b6 05 36 ec 00 00 	movzbl 0xec36(%rip),%eax        # 21190 <KEEP_WORDS>
   1255a:	3c 01                	cmp    $0x1,%al
   1255c:	48 8b 6c 24 38       	mov    0x38(%rsp),%rbp
   12561:	0f 85 e7 0a 00 00    	jne    1304e <WL_FID_MAP_GET_GO+0x12fe>
   12567:	48 81 fa 00 80 00 00 	cmp    $0x8000,%rdx
   1256e:	0f 83 da 0a 00 00    	jae    1304e <WL_FID_MAP_GET_GO+0x12fe>
   12574:	49 8b 55 10          	mov    0x10(%r13),%rdx
   12578:	49 89 14 ec          	mov    %rdx,(%r12,%rbp,8)
   1257c:	49 89 6d 10          	mov    %rbp,0x10(%r13)
   12580:	49 8b 95 10 01 00 00 	mov    0x110(%r13),%rdx
   12587:	48 83 c2 04          	add    $0x4,%rdx
   1258b:	49 89 95 10 01 00 00 	mov    %rdx,0x110(%r13)
   12592:	48 81 fa 00 80 00 00 	cmp    $0x8000,%rdx
   12599:	0f 92 c2             	setb   %dl
   1259c:	84 d0                	test   %dl,%al
   1259e:	0f 84 2b 09 00 00    	je     12ecf <WL_FID_MAP_GET_GO+0x117f>
   125a4:	45 85 ff             	test   %r15d,%r15d
   125a7:	0f 84 41 09 00 00    	je     12eee <WL_FID_MAP_GET_GO+0x119e>
   125ad:	49 89 36             	mov    %rsi,(%r14)
   125b0:	4d 89 4e 08          	mov    %r9,0x8(%r14)
   125b4:	4d 89 46 10          	mov    %r8,0x10(%r14)
   125b8:	49 c7 46 18 41 00 00 	movq   $0x41,0x18(%r14)
   125bf:	00 
   125c0:	49 83 c6 20          	add    $0x20,%r14
   125c4:	48 89 ce             	mov    %rcx,%rsi
   125c7:	4c 89 d2             	mov    %r10,%rdx
   125ca:	48 83 c4 60          	add    $0x60,%rsp
   125ce:	5d                   	pop    %rbp
   125cf:	e9 2c 20 00 00       	jmpq   14600 <WL_FID_STRING_CMP>
   125d4:	48 83 f9 ff          	cmp    $0xffffffffffffffff,%rcx
   125d8:	74 40                	je     1261a <WL_FID_MAP_GET_GO+0x8ca>
   125da:	48 ba 00 00 00 00 00 	movabs $0x7e00000000000000,%rdx
   125e1:	00 00 7e 
   125e4:	48 21 ca             	and    %rcx,%rdx
   125e7:	74 31                	je     1261a <WL_FID_MAP_GET_GO+0x8ca>
   125e9:	48 83 c0 81          	add    $0xffffffffffffff81,%rax
   125ed:	48 21 c8             	and    %rcx,%rax
   125f0:	48 3d 80 82 10 03    	cmp    $0x3108280,%rax
   125f6:	72 22                	jb     1261a <WL_FID_MAP_GET_GO+0x8ca>
   125f8:	4c 89 e7             	mov    %r12,%rdi
   125fb:	48 89 74 24 10       	mov    %rsi,0x10(%rsp)
   12600:	4c 89 ee             	mov    %r13,%rsi
   12603:	48 89 ca             	mov    %rcx,%rdx
   12606:	4c 89 4c 24 48       	mov    %r9,0x48(%rsp)
   1260b:	e8 d0 55 ff ff       	callq  7be0 <term_drop>
   12610:	4c 8b 4c 24 48       	mov    0x48(%rsp),%r9
   12615:	48 8b 74 24 10       	mov    0x10(%rsp),%rsi
   1261a:	4d 89 0c ec          	mov    %r9,(%r12,%rbp,8)
   1261e:	49 89 5c ec 08       	mov    %rbx,0x8(%r12,%rbp,8)
   12623:	48 8b 4c 24 38       	mov    0x38(%rsp),%rcx
   12628:	49 89 34 cc          	mov    %rsi,(%r12,%rcx,8)
   1262c:	48 b8 00 00 00 00 00 	movabs $0x100120000000000,%rax
   12633:	12 00 01 
   12636:	49 89 44 cc 08       	mov    %rax,0x8(%r12,%rcx,8)
   1263b:	48 b8 00 00 00 00 00 	movabs $0x200130000000000,%rax
   12642:	13 00 02 
   12645:	48 09 e8             	or     %rbp,%rax
   12648:	49 89 44 cc 10       	mov    %rax,0x10(%r12,%rcx,8)
   1264d:	48 be 00 00 00 00 00 	movabs $0x200140000000000,%rsi
   12654:	14 00 02 
   12657:	48 09 ce             	or     %rcx,%rsi
   1265a:	41 8b 46 f8          	mov    -0x8(%r14),%eax
   1265e:	49 83 c6 f8          	add    $0xfffffffffffffff8,%r14
   12662:	48 8d 0d 57 d0 00 00 	lea    0xd057(%rip),%rcx        # 1f6c0 <wl_tab>
   12669:	48 8b 04 c1          	mov    (%rcx,%rax,8),%rax
   1266d:	bf 02 00 00 00       	mov    $0x2,%edi
   12672:	48 8b 54 24 40       	mov    0x40(%rsp),%rdx
   12677:	48 83 c4 60          	add    $0x60,%rsp
   1267b:	5d                   	pop    %rbp
   1267c:	ff e0                	jmpq   *%rax
   1267e:	45 85 ff             	test   %r15d,%r15d
   12681:	48 8b 74 24 08       	mov    0x8(%rsp),%rsi
   12686:	48 8b 6c 24 40       	mov    0x40(%rsp),%rbp
   1268b:	48 8b 4c 24 18       	mov    0x18(%rsp),%rcx
   12690:	48 8b 7c 24 30       	mov    0x30(%rsp),%rdi
   12695:	0f 84 35 04 00 00    	je     12ad0 <WL_FID_MAP_GET_GO+0xd80>
   1269b:	48 8b 44 24 10       	mov    0x10(%rsp),%rax
   126a0:	49 89 06             	mov    %rax,(%r14)
   126a3:	49 89 7e 08          	mov    %rdi,0x8(%r14)
   126a7:	48 8b 44 24 20       	mov    0x20(%rsp),%rax
   126ac:	49 89 46 10          	mov    %rax,0x10(%r14)
   126b0:	48 8b 44 24 28       	mov    0x28(%rsp),%rax
   126b5:	49 89 46 18          	mov    %rax,0x18(%r14)
   126b9:	49 89 6e 20          	mov    %rbp,0x20(%r14)
   126bd:	49 c7 46 28 42 00 00 	movq   $0x42,0x28(%r14)
   126c4:	00 
   126c5:	49 83 c6 30          	add    $0x30,%r14
   126c9:	48 89 ca             	mov    %rcx,%rdx
   126cc:	48 83 c4 60          	add    $0x60,%rsp
   126d0:	5d                   	pop    %rbp
   126d1:	e9 2a 1f 00 00       	jmpq   14600 <WL_FID_STRING_CMP>
   126d6:	49 8b 45 10          	mov    0x10(%r13),%rax
   126da:	49 89 04 dc          	mov    %rax,(%r12,%rbx,8)
   126de:	49 89 5d 10          	mov    %rbx,0x10(%r13)
   126e2:	49 8b 95 10 01 00 00 	mov    0x110(%r13),%rdx
   126e9:	48 83 c2 04          	add    $0x4,%rdx
   126ed:	49 89 95 10 01 00 00 	mov    %rdx,0x110(%r13)
   126f4:	0f b6 05 95 ea 00 00 	movzbl 0xea95(%rip),%eax        # 21190 <KEEP_WORDS>
   126fb:	3c 01                	cmp    $0x1,%al
   126fd:	4c 8b 4c 24 38       	mov    0x38(%rsp),%r9
   12702:	48 8b 6c 24 18       	mov    0x18(%rsp),%rbp
   12707:	0f 85 68 09 00 00    	jne    13075 <WL_FID_MAP_GET_GO+0x1325>
   1270d:	48 81 fa 00 80 00 00 	cmp    $0x8000,%rdx
   12714:	0f 83 5b 09 00 00    	jae    13075 <WL_FID_MAP_GET_GO+0x1325>
   1271a:	4b 89 1c cc          	mov    %rbx,(%r12,%r9,8)
   1271e:	4d 89 4d 10          	mov    %r9,0x10(%r13)
   12722:	49 8b 95 10 01 00 00 	mov    0x110(%r13),%rdx
   12729:	48 83 c2 04          	add    $0x4,%rdx
   1272d:	49 89 95 10 01 00 00 	mov    %rdx,0x110(%r13)
   12734:	48 81 fa 00 80 00 00 	cmp    $0x8000,%rdx
   1273b:	0f 92 c2             	setb   %dl
   1273e:	84 d0                	test   %dl,%al
   12740:	0f 84 45 08 00 00    	je     12f8b <WL_FID_MAP_GET_GO+0x123b>
   12746:	45 85 ff             	test   %r15d,%r15d
   12749:	0f 84 5b 08 00 00    	je     12faa <WL_FID_MAP_GET_GO+0x125a>
   1274f:	49 89 36             	mov    %rsi,(%r14)
   12752:	49 89 6e 08          	mov    %rbp,0x8(%r14)
   12756:	48 8b 44 24 28       	mov    0x28(%rsp),%rax
   1275b:	49 89 46 10          	mov    %rax,0x10(%r14)
   1275f:	48 8b 44 24 30       	mov    0x30(%rsp),%rax
   12764:	49 89 46 18          	mov    %rax,0x18(%r14)
   12768:	4d 89 56 20          	mov    %r10,0x20(%r14)
   1276c:	49 c7 46 28 47 00 00 	movq   $0x47,0x28(%r14)
   12773:	00 
   12774:	49 83 c6 30          	add    $0x30,%r14
   12778:	48 89 ce             	mov    %rcx,%rsi
   1277b:	48 89 ea             	mov    %rbp,%rdx
   1277e:	48 83 c4 60          	add    $0x60,%rsp
   12782:	5d                   	pop    %rbp
   12783:	e9 28 f5 ff ff       	jmpq   11cb0 <WL_FID_MAP_BIT>
   12788:	48 83 f9 ff          	cmp    $0xffffffffffffffff,%rcx
   1278c:	74 4a                	je     127d8 <WL_FID_MAP_GET_GO+0xa88>
   1278e:	48 ba 00 00 00 00 00 	movabs $0x7e00000000000000,%rdx
   12795:	00 00 7e 
   12798:	48 21 ca             	and    %rcx,%rdx
   1279b:	74 3b                	je     127d8 <WL_FID_MAP_GET_GO+0xa88>
   1279d:	48 83 c0 81          	add    $0xffffffffffffff81,%rax
   127a1:	48 21 c8             	and    %rcx,%rax
   127a4:	48 3d 80 82 10 03    	cmp    $0x3108280,%rax
   127aa:	72 2c                	jb     127d8 <WL_FID_MAP_GET_GO+0xa88>
   127ac:	4c 89 e7             	mov    %r12,%rdi
   127af:	48 89 74 24 10       	mov    %rsi,0x10(%rsp)
   127b4:	4c 89 ee             	mov    %r13,%rsi
   127b7:	48 89 ca             	mov    %rcx,%rdx
   127ba:	4c 89 4c 24 48       	mov    %r9,0x48(%rsp)
   127bf:	4c 89 54 24 08       	mov    %r10,0x8(%rsp)
   127c4:	e8 17 54 ff ff       	callq  7be0 <term_drop>
   127c9:	4c 8b 54 24 08       	mov    0x8(%rsp),%r10
   127ce:	4c 8b 4c 24 48       	mov    0x48(%rsp),%r9
   127d3:	48 8b 74 24 10       	mov    0x10(%rsp),%rsi
   127d8:	48 8b 4c 24 38       	mov    0x38(%rsp),%rcx
   127dd:	49 89 1c cc          	mov    %rbx,(%r12,%rcx,8)
   127e1:	4d 89 54 cc 08       	mov    %r10,0x8(%r12,%rcx,8)
   127e6:	4d 89 4c cc 10       	mov    %r9,0x10(%r12,%rcx,8)
   127eb:	49 89 34 ec          	mov    %rsi,(%r12,%rbp,8)
   127ef:	48 b8 00 00 00 00 00 	movabs $0x100120000000000,%rax
   127f6:	12 00 01 
   127f9:	49 89 44 ec 08       	mov    %rax,0x8(%r12,%rbp,8)
   127fe:	48 b8 00 00 00 00 00 	movabs $0x200140000000000,%rax
   12805:	14 00 02 
   12808:	48 09 c1             	or     %rax,%rcx
   1280b:	49 89 4c ec 10       	mov    %rcx,0x10(%r12,%rbp,8)
   12810:	48 09 c5             	or     %rax,%rbp
   12813:	41 8b 46 f8          	mov    -0x8(%r14),%eax
   12817:	49 83 c6 f8          	add    $0xfffffffffffffff8,%r14
   1281b:	48 8d 0d 9e ce 00 00 	lea    0xce9e(%rip),%rcx        # 1f6c0 <wl_tab>
   12822:	48 8b 04 c1          	mov    (%rcx,%rax,8),%rax
   12826:	bf 02 00 00 00       	mov    $0x2,%edi
   1282b:	48 89 ee             	mov    %rbp,%rsi
   1282e:	48 8b 54 24 40       	mov    0x40(%rsp),%rdx
   12833:	48 83 c4 60          	add    $0x60,%rsp
   12837:	5d                   	pop    %rbp
   12838:	ff e0                	jmpq   *%rax
   1283a:	45 85 ff             	test   %r15d,%r15d
   1283d:	48 8b 44 24 08       	mov    0x8(%rsp),%rax
   12842:	48 8b 6c 24 40       	mov    0x40(%rsp),%rbp
   12847:	48 8b 54 24 10       	mov    0x10(%rsp),%rdx
   1284c:	4c 8b 54 24 18       	mov    0x18(%rsp),%r10
   12851:	48 8b 5c 24 30       	mov    0x30(%rsp),%rbx
   12856:	0f 84 f5 02 00 00    	je     12b51 <WL_FID_MAP_GET_GO+0xe01>
   1285c:	49 89 16             	mov    %rdx,(%r14)
   1285f:	49 89 5e 08          	mov    %rbx,0x8(%r14)
   12863:	48 8b 4c 24 28       	mov    0x28(%rsp),%rcx
   12868:	49 89 4e 10          	mov    %rcx,0x10(%r14)
   1286c:	48 8b 4c 24 50       	mov    0x50(%rsp),%rcx
   12871:	49 89 4e 18          	mov    %rcx,0x18(%r14)
   12875:	48 8b 4c 24 20       	mov    0x20(%rsp),%rcx
   1287a:	49 89 4e 20          	mov    %rcx,0x20(%r14)
   1287e:	49 89 6e 28          	mov    %rbp,0x28(%r14)
   12882:	49 c7 46 30 44 00 00 	movq   $0x44,0x30(%r14)
   12889:	00 
   1288a:	49 83 c6 38          	add    $0x38,%r14
   1288e:	48 89 c6             	mov    %rax,%rsi
   12891:	4c 89 d2             	mov    %r10,%rdx
   12894:	48 83 c4 60          	add    $0x60,%rsp
   12898:	5d                   	pop    %rbp
   12899:	e9 62 1d 00 00       	jmpq   14600 <WL_FID_STRING_CMP>
   1289e:	45 85 ff             	test   %r15d,%r15d
   128a1:	48 8b 44 24 08       	mov    0x8(%rsp),%rax
   128a6:	48 8b 6c 24 40       	mov    0x40(%rsp),%rbp
   128ab:	48 8b 54 24 10       	mov    0x10(%rsp),%rdx
   128b0:	0f 84 17 03 00 00    	je     12bcd <WL_FID_MAP_GET_GO+0xe7d>
   128b6:	49 89 16             	mov    %rdx,(%r14)
   128b9:	48 8b 54 24 18       	mov    0x18(%rsp),%rdx
   128be:	49 89 56 08          	mov    %rdx,0x8(%r14)
   128c2:	48 8b 4c 24 28       	mov    0x28(%rsp),%rcx
   128c7:	49 89 4e 10          	mov    %rcx,0x10(%r14)
   128cb:	48 8b 4c 24 30       	mov    0x30(%rsp),%rcx
   128d0:	49 89 4e 18          	mov    %rcx,0x18(%r14)
   128d4:	48 8b 4c 24 20       	mov    0x20(%rsp),%rcx
   128d9:	49 89 4e 20          	mov    %rcx,0x20(%r14)
   128dd:	48 8b 4c 24 50       	mov    0x50(%rsp),%rcx
   128e2:	49 89 4e 28          	mov    %rcx,0x28(%r14)
   128e6:	49 89 6e 30          	mov    %rbp,0x30(%r14)
   128ea:	49 c7 46 38 49 00 00 	movq   $0x49,0x38(%r14)
   128f1:	00 
   128f2:	49 83 c6 40          	add    $0x40,%r14
   128f6:	48 89 c6             	mov    %rax,%rsi
   128f9:	48 83 c4 60          	add    $0x60,%rsp
   128fd:	5d                   	pop    %rbp
   128fe:	e9 ad f3 ff ff       	jmpq   11cb0 <WL_FID_MAP_BIT>
   12903:	45 85 ff             	test   %r15d,%r15d
   12906:	48 8b 74 24 08       	mov    0x8(%rsp),%rsi
   1290b:	48 8b 6c 24 40       	mov    0x40(%rsp),%rbp
   12910:	0f 84 59 03 00 00    	je     12c6f <WL_FID_MAP_GET_GO+0xf1f>
   12916:	48 8b 44 24 10       	mov    0x10(%rsp),%rax
   1291b:	49 89 06             	mov    %rax,(%r14)
   1291e:	48 8b 54 24 18       	mov    0x18(%rsp),%rdx
   12923:	49 89 56 08          	mov    %rdx,0x8(%r14)
   12927:	48 8b 44 24 28       	mov    0x28(%rsp),%rax
   1292c:	49 89 46 10          	mov    %rax,0x10(%r14)
   12930:	48 8b 44 24 30       	mov    0x30(%rsp),%rax
   12935:	49 89 46 18          	mov    %rax,0x18(%r14)
   12939:	48 8b 44 24 20       	mov    0x20(%rsp),%rax
   1293e:	49 89 46 20          	mov    %rax,0x20(%r14)
   12942:	48 8b 44 24 58       	mov    0x58(%rsp),%rax
   12947:	49 89 46 28          	mov    %rax,0x28(%r14)
   1294b:	48 8b 44 24 50       	mov    0x50(%rsp),%rax
   12950:	49 89 46 30          	mov    %rax,0x30(%r14)
   12954:	49 89 6e 38          	mov    %rbp,0x38(%r14)
   12958:	49 c7 46 40 4c 00 00 	movq   $0x4c,0x40(%r14)
   1295f:	00 
   12960:	49 83 c6 48          	add    $0x48,%r14
   12964:	48 83 c4 60          	add    $0x60,%rsp
   12968:	5d                   	pop    %rbp
   12969:	e9 42 f3 ff ff       	jmpq   11cb0 <WL_FID_MAP_BIT>
   1296e:	48 bb 00 00 00 00 00 	movabs $0x500430000000000,%rbx
   12975:	43 00 05 
   12978:	ba 43 00 00 00       	mov    $0x43,%edx
   1297d:	48 89 4c 24 38       	mov    %rcx,0x38(%rsp)
   12982:	48 8b 44 24 20       	mov    0x20(%rsp),%rax
   12987:	48 89 44 24 18       	mov    %rax,0x18(%rsp)
   1298c:	49 89 ff             	mov    %rdi,%r15
   1298f:	e9 55 01 00 00       	jmpq   12ae9 <WL_FID_MAP_GET_GO+0xd99>
   12994:	49 8b 4e e8          	mov    -0x18(%r14),%rcx
   12998:	45 8b 46 f0          	mov    -0x10(%r14),%r8d
   1299c:	4c 89 e7             	mov    %r12,%rdi
   1299f:	49 89 d7             	mov    %rdx,%r15
   129a2:	4c 89 ee             	mov    %r13,%rsi
   129a5:	ba 45 00 00 00       	mov    $0x45,%edx
   129aa:	41 b9 01 00 00 00    	mov    $0x1,%r9d
   129b0:	e8 9b 56 ff ff       	callq  8050 <task_node>
   129b5:	4d 89 3c c4          	mov    %r15,(%r12,%rax,8)
   129b9:	49 89 5c c4 08       	mov    %rbx,0x8(%r12,%rax,8)
   129be:	48 8b 4c 24 30       	mov    0x30(%rsp),%rcx
   129c3:	49 89 4c c4 10       	mov    %rcx,0x10(%r12,%rax,8)
   129c8:	48 8b 5c 24 28       	mov    0x28(%rsp),%rbx
   129cd:	49 89 5c c4 18       	mov    %rbx,0x18(%r12,%rax,8)
   129d2:	48 8b 4c 24 50       	mov    0x50(%rsp),%rcx
   129d7:	49 89 4c c4 20       	mov    %rcx,0x20(%r12,%rax,8)
   129dc:	48 8b 4c 24 20       	mov    0x20(%rsp),%rcx
   129e1:	49 89 4c c4 28       	mov    %rcx,0x28(%r12,%rax,8)
   129e6:	49 89 6c c4 30       	mov    %rbp,0x30(%r12,%rax,8)
   129eb:	48 b9 00 00 00 00 00 	movabs $0x500450000000000,%rcx
   129f2:	45 00 05 
   129f5:	48 09 c1             	or     %rax,%rcx
   129f8:	49 89 4e e8          	mov    %rcx,-0x18(%r14)
   129fc:	49 c7 46 f0 07 00 00 	movq   $0x7,-0x10(%r14)
   12a03:	00 
   12a04:	4c 89 e7             	mov    %r12,%rdi
   12a07:	4c 89 ee             	mov    %r13,%rsi
   12a0a:	ba 3c 00 00 00       	mov    $0x3c,%edx
   12a0f:	41 b8 07 00 00 00    	mov    $0x7,%r8d
   12a15:	e9 5d 04 00 00       	jmpq   12e77 <WL_FID_MAP_GET_GO+0x1127>
   12a1a:	49 8b 4e e8          	mov    -0x18(%r14),%rcx
   12a1e:	45 8b 46 f0          	mov    -0x10(%r14),%r8d
   12a22:	4c 89 e7             	mov    %r12,%rdi
   12a25:	49 89 d7             	mov    %rdx,%r15
   12a28:	4c 89 ee             	mov    %r13,%rsi
   12a2b:	ba 4b 00 00 00       	mov    $0x4b,%edx
   12a30:	48 89 c3             	mov    %rax,%rbx
   12a33:	41 b9 01 00 00 00    	mov    $0x1,%r9d
   12a39:	e8 12 56 ff ff       	callq  8050 <task_node>
   12a3e:	4d 89 3c c4          	mov    %r15,(%r12,%rax,8)
   12a42:	48 8b 4c 24 18       	mov    0x18(%rsp),%rcx
   12a47:	49 89 4c c4 08       	mov    %rcx,0x8(%r12,%rax,8)
   12a4c:	48 8b 4c 24 28       	mov    0x28(%rsp),%rcx
   12a51:	49 89 4c c4 10       	mov    %rcx,0x10(%r12,%rax,8)
   12a56:	48 8b 4c 24 30       	mov    0x30(%rsp),%rcx
   12a5b:	49 89 4c c4 18       	mov    %rcx,0x18(%r12,%rax,8)
   12a60:	48 8b 4c 24 50       	mov    0x50(%rsp),%rcx
   12a65:	49 89 4c c4 20       	mov    %rcx,0x20(%r12,%rax,8)
   12a6a:	49 89 6c c4 28       	mov    %rbp,0x28(%r12,%rax,8)
   12a6f:	48 b9 00 00 00 00 00 	movabs $0x5004b0000000000,%rcx
   12a76:	4b 00 05 
   12a79:	48 09 c1             	or     %rax,%rcx
   12a7c:	49 89 4e e8          	mov    %rcx,-0x18(%r14)
   12a80:	49 c7 46 f0 06 00 00 	movq   $0x6,-0x10(%r14)
   12a87:	00 
   12a88:	4c 89 e7             	mov    %r12,%rdi
   12a8b:	4c 89 ee             	mov    %r13,%rsi
   12a8e:	ba 50 00 00 00       	mov    $0x50,%edx
   12a93:	41 b8 06 00 00 00    	mov    $0x6,%r8d
   12a99:	45 31 c9             	xor    %r9d,%r9d
   12a9c:	e8 af 55 ff ff       	callq  8050 <task_node>
   12aa1:	48 89 c1             	mov    %rax,%rcx
   12aa4:	49 89 1c c4          	mov    %rbx,(%r12,%rax,8)
   12aa8:	48 8b 44 24 20       	mov    0x20(%rsp),%rax
   12aad:	e9 c1 04 00 00       	jmpq   12f73 <WL_FID_MAP_GET_GO+0x1223>
   12ab2:	48 bb 00 00 00 00 00 	movabs $0x5004e0000000000,%rbx
   12ab9:	4e 00 05 
   12abc:	ba 4e 00 00 00       	mov    $0x4e,%edx
   12ac1:	4c 8b 7c 24 20       	mov    0x20(%rsp),%r15
   12ac6:	4c 89 7c 24 38       	mov    %r15,0x38(%rsp)
   12acb:	e9 bd 01 00 00       	jmpq   12c8d <WL_FID_MAP_GET_GO+0xf3d>
   12ad0:	48 bb 00 00 00 00 00 	movabs $0x500420000000000,%rbx
   12ad7:	42 00 05 
   12ada:	ba 42 00 00 00       	mov    $0x42,%edx
   12adf:	48 89 7c 24 38       	mov    %rdi,0x38(%rsp)
   12ae4:	4c 8b 7c 24 20       	mov    0x20(%rsp),%r15
   12ae9:	49 8b 4e e8          	mov    -0x18(%r14),%rcx
   12aed:	45 8b 46 f0          	mov    -0x10(%r14),%r8d
   12af1:	4c 89 e7             	mov    %r12,%rdi
   12af4:	4c 89 ee             	mov    %r13,%rsi
   12af7:	41 b9 01 00 00 00    	mov    $0x1,%r9d
   12afd:	e8 4e 55 ff ff       	callq  8050 <task_node>
   12b02:	48 8b 4c 24 10       	mov    0x10(%rsp),%rcx
   12b07:	49 89 0c c4          	mov    %rcx,(%r12,%rax,8)
   12b0b:	48 8b 4c 24 38       	mov    0x38(%rsp),%rcx
   12b10:	49 89 4c c4 08       	mov    %rcx,0x8(%r12,%rax,8)
   12b15:	4d 89 7c c4 10       	mov    %r15,0x10(%r12,%rax,8)
   12b1a:	48 8b 4c 24 28       	mov    0x28(%rsp),%rcx
   12b1f:	49 89 4c c4 18       	mov    %rcx,0x18(%r12,%rax,8)
   12b24:	49 89 6c c4 20       	mov    %rbp,0x20(%r12,%rax,8)
   12b29:	48 09 c3             	or     %rax,%rbx
   12b2c:	49 89 5e e8          	mov    %rbx,-0x18(%r14)
   12b30:	49 c7 46 f0 05 00 00 	movq   $0x5,-0x10(%r14)
   12b37:	00 
   12b38:	4c 89 e7             	mov    %r12,%rdi
   12b3b:	4c 89 ee             	mov    %r13,%rsi
   12b3e:	ba 50 00 00 00       	mov    $0x50,%edx
   12b43:	48 89 d9             	mov    %rbx,%rcx
   12b46:	41 b8 05 00 00 00    	mov    $0x5,%r8d
   12b4c:	e9 09 04 00 00       	jmpq   12f5a <WL_FID_MAP_GET_GO+0x120a>
   12b51:	49 8b 4e e8          	mov    -0x18(%r14),%rcx
   12b55:	45 8b 46 f0          	mov    -0x10(%r14),%r8d
   12b59:	4c 89 e7             	mov    %r12,%rdi
   12b5c:	49 89 d7             	mov    %rdx,%r15
   12b5f:	4c 89 ee             	mov    %r13,%rsi
   12b62:	ba 44 00 00 00       	mov    $0x44,%edx
   12b67:	41 b9 01 00 00 00    	mov    $0x1,%r9d
   12b6d:	e8 de 54 ff ff       	callq  8050 <task_node>
   12b72:	4d 89 3c c4          	mov    %r15,(%r12,%rax,8)
   12b76:	49 89 5c c4 08       	mov    %rbx,0x8(%r12,%rax,8)
   12b7b:	48 8b 4c 24 28       	mov    0x28(%rsp),%rcx
   12b80:	49 89 4c c4 10       	mov    %rcx,0x10(%r12,%rax,8)
   12b85:	48 8b 4c 24 50       	mov    0x50(%rsp),%rcx
   12b8a:	49 89 4c c4 18       	mov    %rcx,0x18(%r12,%rax,8)
   12b8f:	48 8b 4c 24 20       	mov    0x20(%rsp),%rcx
   12b94:	49 89 4c c4 20       	mov    %rcx,0x20(%r12,%rax,8)
   12b99:	49 89 6c c4 28       	mov    %rbp,0x28(%r12,%rax,8)
   12b9e:	48 b9 00 00 00 00 00 	movabs $0x500440000000000,%rcx
   12ba5:	44 00 05 
   12ba8:	48 09 c1             	or     %rax,%rcx
   12bab:	49 89 4e e8          	mov    %rcx,-0x18(%r14)
   12baf:	49 c7 46 f0 06 00 00 	movq   $0x6,-0x10(%r14)
   12bb6:	00 
   12bb7:	4c 89 e7             	mov    %r12,%rdi
   12bba:	4c 89 ee             	mov    %r13,%rsi
   12bbd:	ba 50 00 00 00       	mov    $0x50,%edx
   12bc2:	41 b8 06 00 00 00    	mov    $0x6,%r8d
   12bc8:	e9 8d 03 00 00       	jmpq   12f5a <WL_FID_MAP_GET_GO+0x120a>
   12bcd:	49 8b 4e e8          	mov    -0x18(%r14),%rcx
   12bd1:	45 8b 46 f0          	mov    -0x10(%r14),%r8d
   12bd5:	4c 89 e7             	mov    %r12,%rdi
   12bd8:	49 89 d7             	mov    %rdx,%r15
   12bdb:	4c 89 ee             	mov    %r13,%rsi
   12bde:	ba 49 00 00 00       	mov    $0x49,%edx
   12be3:	48 89 c3             	mov    %rax,%rbx
   12be6:	41 b9 01 00 00 00    	mov    $0x1,%r9d
   12bec:	e8 5f 54 ff ff       	callq  8050 <task_node>
   12bf1:	4d 89 3c c4          	mov    %r15,(%r12,%rax,8)
   12bf5:	4c 8b 7c 24 18       	mov    0x18(%rsp),%r15
   12bfa:	4d 89 7c c4 08       	mov    %r15,0x8(%r12,%rax,8)
   12bff:	48 8b 4c 24 28       	mov    0x28(%rsp),%rcx
   12c04:	49 89 4c c4 10       	mov    %rcx,0x10(%r12,%rax,8)
   12c09:	48 8b 4c 24 30       	mov    0x30(%rsp),%rcx
   12c0e:	49 89 4c c4 18       	mov    %rcx,0x18(%r12,%rax,8)
   12c13:	48 8b 4c 24 20       	mov    0x20(%rsp),%rcx
   12c18:	49 89 4c c4 20       	mov    %rcx,0x20(%r12,%rax,8)
   12c1d:	48 8b 4c 24 50       	mov    0x50(%rsp),%rcx
   12c22:	49 89 4c c4 28       	mov    %rcx,0x28(%r12,%rax,8)
   12c27:	49 89 6c c4 30       	mov    %rbp,0x30(%r12,%rax,8)
   12c2c:	48 b9 00 00 00 00 00 	movabs $0x500490000000000,%rcx
   12c33:	49 00 05 
   12c36:	48 09 c1             	or     %rax,%rcx
   12c39:	49 89 4e e8          	mov    %rcx,-0x18(%r14)
   12c3d:	49 c7 46 f0 07 00 00 	movq   $0x7,-0x10(%r14)
   12c44:	00 
   12c45:	4c 89 e7             	mov    %r12,%rdi
   12c48:	4c 89 ee             	mov    %r13,%rsi
   12c4b:	ba 3c 00 00 00       	mov    $0x3c,%edx
   12c50:	41 b8 07 00 00 00    	mov    $0x7,%r8d
   12c56:	45 31 c9             	xor    %r9d,%r9d
   12c59:	e8 f2 53 ff ff       	callq  8050 <task_node>
   12c5e:	48 89 c1             	mov    %rax,%rcx
   12c61:	49 89 1c c4          	mov    %rbx,(%r12,%rax,8)
   12c65:	4d 89 7c c4 08       	mov    %r15,0x8(%r12,%rax,8)
   12c6a:	e9 cc 03 00 00       	jmpq   1303b <WL_FID_MAP_GET_GO+0x12eb>
   12c6f:	48 bb 00 00 00 00 00 	movabs $0x5004c0000000000,%rbx
   12c76:	4c 00 05 
   12c79:	ba 4c 00 00 00       	mov    $0x4c,%edx
   12c7e:	48 8b 44 24 18       	mov    0x18(%rsp),%rax
   12c83:	48 89 44 24 38       	mov    %rax,0x38(%rsp)
   12c88:	4c 8b 7c 24 20       	mov    0x20(%rsp),%r15
   12c8d:	49 8b 4e e8          	mov    -0x18(%r14),%rcx
   12c91:	45 8b 46 f0          	mov    -0x10(%r14),%r8d
   12c95:	4c 89 e7             	mov    %r12,%rdi
   12c98:	4c 89 ee             	mov    %r13,%rsi
   12c9b:	41 b9 01 00 00 00    	mov    $0x1,%r9d
   12ca1:	e8 aa 53 ff ff       	callq  8050 <task_node>
   12ca6:	48 8b 4c 24 10       	mov    0x10(%rsp),%rcx
   12cab:	49 89 0c c4          	mov    %rcx,(%r12,%rax,8)
   12caf:	48 8b 4c 24 18       	mov    0x18(%rsp),%rcx
   12cb4:	49 89 4c c4 08       	mov    %rcx,0x8(%r12,%rax,8)
   12cb9:	48 8b 4c 24 28       	mov    0x28(%rsp),%rcx
   12cbe:	49 89 4c c4 10       	mov    %rcx,0x10(%r12,%rax,8)
   12cc3:	48 8b 4c 24 30       	mov    0x30(%rsp),%rcx
   12cc8:	49 89 4c c4 18       	mov    %rcx,0x18(%r12,%rax,8)
   12ccd:	4d 89 7c c4 20       	mov    %r15,0x20(%r12,%rax,8)
   12cd2:	48 8b 4c 24 58       	mov    0x58(%rsp),%rcx
   12cd7:	49 89 4c c4 28       	mov    %rcx,0x28(%r12,%rax,8)
   12cdc:	48 8b 4c 24 50       	mov    0x50(%rsp),%rcx
   12ce1:	49 89 4c c4 30       	mov    %rcx,0x30(%r12,%rax,8)
   12ce6:	49 89 6c c4 38       	mov    %rbp,0x38(%r12,%rax,8)
   12ceb:	48 09 c3             	or     %rax,%rbx
   12cee:	49 89 5e e8          	mov    %rbx,-0x18(%r14)
   12cf2:	49 c7 46 f0 08 00 00 	movq   $0x8,-0x10(%r14)
   12cf9:	00 
   12cfa:	4c 89 e7             	mov    %r12,%rdi
   12cfd:	4c 89 ee             	mov    %r13,%rsi
   12d00:	ba 3c 00 00 00       	mov    $0x3c,%edx
   12d05:	48 89 d9             	mov    %rbx,%rcx
   12d08:	41 b8 08 00 00 00    	mov    $0x8,%r8d
   12d0e:	45 31 c9             	xor    %r9d,%r9d
   12d11:	e8 3a 53 ff ff       	callq  8050 <task_node>
   12d16:	48 89 c1             	mov    %rax,%rcx
   12d19:	48 8b 44 24 08       	mov    0x8(%rsp),%rax
   12d1e:	49 89 04 cc          	mov    %rax,(%r12,%rcx,8)
   12d22:	48 8b 44 24 38       	mov    0x38(%rsp),%rax
   12d27:	49 89 44 cc 08       	mov    %rax,0x8(%r12,%rcx,8)
   12d2c:	e9 0a 03 00 00       	jmpq   1303b <WL_FID_MAP_GET_GO+0x12eb>
   12d31:	4c 89 e7             	mov    %r12,%rdi
   12d34:	48 89 f0             	mov    %rsi,%rax
   12d37:	4c 89 ee             	mov    %r13,%rsi
   12d3a:	ba 02 00 00 00       	mov    $0x2,%edx
   12d3f:	e8 91 a9 00 00       	callq  1d6d5 <heap_hand>
   12d44:	48 89 c6             	mov    %rax,%rsi
   12d47:	45 85 ff             	test   %r15d,%r15d
   12d4a:	0f 85 ae f3 ff ff    	jne    120fe <WL_FID_MAP_GET_GO+0x3ae>
   12d50:	49 8b 46 e8          	mov    -0x18(%r14),%rax
   12d54:	45 8b 46 f0          	mov    -0x10(%r14),%r8d
   12d58:	4c 89 e7             	mov    %r12,%rdi
   12d5b:	49 89 f7             	mov    %rsi,%r15
   12d5e:	4c 89 ee             	mov    %r13,%rsi
   12d61:	ba 3e 00 00 00       	mov    $0x3e,%edx
   12d66:	48 89 4c 24 08       	mov    %rcx,0x8(%rsp)
   12d6b:	48 89 c1             	mov    %rax,%rcx
   12d6e:	4c 89 4c 24 48       	mov    %r9,0x48(%rsp)
   12d73:	41 b9 01 00 00 00    	mov    $0x1,%r9d
   12d79:	e8 d2 52 ff ff       	callq  8050 <task_node>
   12d7e:	4d 89 3c c4          	mov    %r15,(%r12,%rax,8)
   12d82:	49 89 5c c4 08       	mov    %rbx,0x8(%r12,%rax,8)
   12d87:	49 89 6c c4 10       	mov    %rbp,0x10(%r12,%rax,8)
   12d8c:	48 b9 00 00 00 00 00 	movabs $0x5003e0000000000,%rcx
   12d93:	3e 00 05 
   12d96:	48 09 c1             	or     %rax,%rcx
   12d99:	49 89 4e e8          	mov    %rcx,-0x18(%r14)
   12d9d:	49 c7 46 f0 03 00 00 	movq   $0x3,-0x10(%r14)
   12da4:	00 
   12da5:	4c 89 e7             	mov    %r12,%rdi
   12da8:	4c 89 ee             	mov    %r13,%rsi
   12dab:	ba 50 00 00 00       	mov    $0x50,%edx
   12db0:	41 b8 03 00 00 00    	mov    $0x3,%r8d
   12db6:	45 31 c9             	xor    %r9d,%r9d
   12db9:	e8 92 52 ff ff       	callq  8050 <task_node>
   12dbe:	48 89 c1             	mov    %rax,%rcx
   12dc1:	48 8b 44 24 08       	mov    0x8(%rsp),%rax
   12dc6:	49 89 04 cc          	mov    %rax,(%r12,%rcx,8)
   12dca:	48 8b 44 24 48       	mov    0x48(%rsp),%rax
   12dcf:	e9 9f 01 00 00       	jmpq   12f73 <WL_FID_MAP_GET_GO+0x1223>
   12dd4:	4c 89 e7             	mov    %r12,%rdi
   12dd7:	48 89 f0             	mov    %rsi,%rax
   12dda:	4c 89 ee             	mov    %r13,%rsi
   12ddd:	ba 02 00 00 00       	mov    $0x2,%edx
   12de2:	e8 ee a8 00 00       	callq  1d6d5 <heap_hand>
   12de7:	48 89 c6             	mov    %rax,%rsi
   12dea:	45 85 ff             	test   %r15d,%r15d
   12ded:	48 8b 6c 24 40       	mov    0x40(%rsp),%rbp
   12df2:	0f 85 8a f4 ff ff    	jne    12282 <WL_FID_MAP_GET_GO+0x532>
   12df8:	49 8b 46 e8          	mov    -0x18(%r14),%rax
   12dfc:	45 8b 46 f0          	mov    -0x10(%r14),%r8d
   12e00:	4c 89 e7             	mov    %r12,%rdi
   12e03:	48 89 74 24 10       	mov    %rsi,0x10(%rsp)
   12e08:	4c 89 ee             	mov    %r13,%rsi
   12e0b:	ba 3f 00 00 00       	mov    $0x3f,%edx
   12e10:	48 89 4c 24 08       	mov    %rcx,0x8(%rsp)
   12e15:	48 89 c1             	mov    %rax,%rcx
   12e18:	4c 89 4c 24 48       	mov    %r9,0x48(%rsp)
   12e1d:	41 b9 01 00 00 00    	mov    $0x1,%r9d
   12e23:	4d 89 d7             	mov    %r10,%r15
   12e26:	e8 25 52 ff ff       	callq  8050 <task_node>
   12e2b:	48 8b 4c 24 10       	mov    0x10(%rsp),%rcx
   12e30:	49 89 0c c4          	mov    %rcx,(%r12,%rax,8)
   12e34:	49 89 5c c4 08       	mov    %rbx,0x8(%r12,%rax,8)
   12e39:	4d 89 7c c4 10       	mov    %r15,0x10(%r12,%rax,8)
   12e3e:	48 8b 4c 24 48       	mov    0x48(%rsp),%rcx
   12e43:	49 89 4c c4 18       	mov    %rcx,0x18(%r12,%rax,8)
   12e48:	49 89 6c c4 20       	mov    %rbp,0x20(%r12,%rax,8)
   12e4d:	48 b9 00 00 00 00 00 	movabs $0x5003f0000000000,%rcx
   12e54:	3f 00 05 
   12e57:	48 09 c1             	or     %rax,%rcx
   12e5a:	49 89 4e e8          	mov    %rcx,-0x18(%r14)
   12e5e:	49 c7 46 f0 05 00 00 	movq   $0x5,-0x10(%r14)
   12e65:	00 
   12e66:	4c 89 e7             	mov    %r12,%rdi
   12e69:	4c 89 ee             	mov    %r13,%rsi
   12e6c:	ba 3c 00 00 00       	mov    $0x3c,%edx
   12e71:	41 b8 05 00 00 00    	mov    $0x5,%r8d
   12e77:	45 31 c9             	xor    %r9d,%r9d
   12e7a:	e8 d1 51 ff ff       	callq  8050 <task_node>
   12e7f:	48 89 c1             	mov    %rax,%rcx
   12e82:	48 8b 44 24 08       	mov    0x8(%rsp),%rax
   12e87:	49 89 04 cc          	mov    %rax,(%r12,%rcx,8)
   12e8b:	49 89 5c cc 08       	mov    %rbx,0x8(%r12,%rcx,8)
   12e90:	e9 a6 01 00 00       	jmpq   1303b <WL_FID_MAP_GET_GO+0x12eb>
   12e95:	4c 89 e7             	mov    %r12,%rdi
   12e98:	49 89 f0             	mov    %rsi,%r8
   12e9b:	4c 89 ee             	mov    %r13,%rsi
   12e9e:	ba 01 00 00 00       	mov    $0x1,%edx
   12ea3:	e8 2d a8 00 00       	callq  1d6d5 <heap_hand>
   12ea8:	4c 89 c6             	mov    %r8,%rsi
   12eab:	e9 0b f2 ff ff       	jmpq   120bb <WL_FID_MAP_GET_GO+0x36b>
   12eb0:	4c 89 e7             	mov    %r12,%rdi
   12eb3:	49 89 f0             	mov    %rsi,%r8
   12eb6:	4c 89 ee             	mov    %r13,%rsi
   12eb9:	ba 02 00 00 00       	mov    $0x2,%edx
   12ebe:	e8 12 a8 00 00       	callq  1d6d5 <heap_hand>
   12ec3:	4c 89 c6             	mov    %r8,%rsi
   12ec6:	49 8b 6d 10          	mov    0x10(%r13),%rbp
   12eca:	e9 74 f3 ff ff       	jmpq   12243 <WL_FID_MAP_GET_GO+0x4f3>
   12ecf:	4c 89 e7             	mov    %r12,%rdi
   12ed2:	48 89 f0             	mov    %rsi,%rax
   12ed5:	4c 89 ee             	mov    %r13,%rsi
   12ed8:	ba 02 00 00 00       	mov    $0x2,%edx
   12edd:	e8 f3 a7 00 00       	callq  1d6d5 <heap_hand>
   12ee2:	48 89 c6             	mov    %rax,%rsi
   12ee5:	45 85 ff             	test   %r15d,%r15d
   12ee8:	0f 85 bf f6 ff ff    	jne    125ad <WL_FID_MAP_GET_GO+0x85d>
   12eee:	49 8b 46 e8          	mov    -0x18(%r14),%rax
   12ef2:	4c 89 cb             	mov    %r9,%rbx
   12ef5:	4c 89 c5             	mov    %r8,%rbp
   12ef8:	45 8b 46 f0          	mov    -0x10(%r14),%r8d
   12efc:	4c 89 e7             	mov    %r12,%rdi
   12eff:	49 89 f7             	mov    %rsi,%r15
   12f02:	4c 89 ee             	mov    %r13,%rsi
   12f05:	ba 41 00 00 00       	mov    $0x41,%edx
   12f0a:	48 89 4c 24 08       	mov    %rcx,0x8(%rsp)
   12f0f:	48 89 c1             	mov    %rax,%rcx
   12f12:	41 b9 01 00 00 00    	mov    $0x1,%r9d
   12f18:	4c 89 54 24 18       	mov    %r10,0x18(%rsp)
   12f1d:	e8 2e 51 ff ff       	callq  8050 <task_node>
   12f22:	4d 89 3c c4          	mov    %r15,(%r12,%rax,8)
   12f26:	49 89 5c c4 08       	mov    %rbx,0x8(%r12,%rax,8)
   12f2b:	49 89 6c c4 10       	mov    %rbp,0x10(%r12,%rax,8)
   12f30:	48 b9 00 00 00 00 00 	movabs $0x500410000000000,%rcx
   12f37:	41 00 05 
   12f3a:	48 09 c1             	or     %rax,%rcx
   12f3d:	49 89 4e e8          	mov    %rcx,-0x18(%r14)
   12f41:	49 c7 46 f0 03 00 00 	movq   $0x3,-0x10(%r14)
   12f48:	00 
   12f49:	4c 89 e7             	mov    %r12,%rdi
   12f4c:	4c 89 ee             	mov    %r13,%rsi
   12f4f:	ba 50 00 00 00       	mov    $0x50,%edx
   12f54:	41 b8 03 00 00 00    	mov    $0x3,%r8d
   12f5a:	45 31 c9             	xor    %r9d,%r9d
   12f5d:	e8 ee 50 ff ff       	callq  8050 <task_node>
   12f62:	48 89 c1             	mov    %rax,%rcx
   12f65:	48 8b 44 24 08       	mov    0x8(%rsp),%rax
   12f6a:	49 89 04 cc          	mov    %rax,(%r12,%rcx,8)
   12f6e:	48 8b 44 24 18       	mov    0x18(%rsp),%rax
   12f73:	49 89 44 cc 08       	mov    %rax,0x8(%r12,%rcx,8)
   12f78:	48 b8 00 00 00 00 00 	movabs $0x500500000000000,%rax
   12f7f:	50 00 05 
   12f82:	48 09 c8             	or     %rcx,%rax
   12f85:	48 83 c4 60          	add    $0x60,%rsp
   12f89:	5d                   	pop    %rbp
   12f8a:	c3                   	retq   
   12f8b:	4c 89 e7             	mov    %r12,%rdi
   12f8e:	48 89 f0             	mov    %rsi,%rax
   12f91:	4c 89 ee             	mov    %r13,%rsi
   12f94:	ba 02 00 00 00       	mov    $0x2,%edx
   12f99:	e8 37 a7 00 00       	callq  1d6d5 <heap_hand>
   12f9e:	48 89 c6             	mov    %rax,%rsi
   12fa1:	45 85 ff             	test   %r15d,%r15d
   12fa4:	0f 85 a5 f7 ff ff    	jne    1274f <WL_FID_MAP_GET_GO+0x9ff>
   12faa:	49 8b 46 e8          	mov    -0x18(%r14),%rax
   12fae:	45 8b 46 f0          	mov    -0x10(%r14),%r8d
   12fb2:	4c 89 e7             	mov    %r12,%rdi
   12fb5:	49 89 f7             	mov    %rsi,%r15
   12fb8:	4c 89 ee             	mov    %r13,%rsi
   12fbb:	ba 47 00 00 00       	mov    $0x47,%edx
   12fc0:	48 89 4c 24 08       	mov    %rcx,0x8(%rsp)
   12fc5:	48 89 c1             	mov    %rax,%rcx
   12fc8:	41 b9 01 00 00 00    	mov    $0x1,%r9d
   12fce:	4c 89 d3             	mov    %r10,%rbx
   12fd1:	e8 7a 50 ff ff       	callq  8050 <task_node>
   12fd6:	4d 89 3c c4          	mov    %r15,(%r12,%rax,8)
   12fda:	49 89 6c c4 08       	mov    %rbp,0x8(%r12,%rax,8)
   12fdf:	48 8b 4c 24 28       	mov    0x28(%rsp),%rcx
   12fe4:	49 89 4c c4 10       	mov    %rcx,0x10(%r12,%rax,8)
   12fe9:	48 8b 4c 24 30       	mov    0x30(%rsp),%rcx
   12fee:	49 89 4c c4 18       	mov    %rcx,0x18(%r12,%rax,8)
   12ff3:	49 89 5c c4 20       	mov    %rbx,0x20(%r12,%rax,8)
   12ff8:	48 b9 00 00 00 00 00 	movabs $0x500470000000000,%rcx
   12fff:	47 00 05 
   13002:	48 09 c1             	or     %rax,%rcx
   13005:	49 89 4e e8          	mov    %rcx,-0x18(%r14)
   13009:	49 c7 46 f0 05 00 00 	movq   $0x5,-0x10(%r14)
   13010:	00 
   13011:	4c 89 e7             	mov    %r12,%rdi
   13014:	4c 89 ee             	mov    %r13,%rsi
   13017:	ba 3c 00 00 00       	mov    $0x3c,%edx
   1301c:	41 b8 05 00 00 00    	mov    $0x5,%r8d
   13022:	45 31 c9             	xor    %r9d,%r9d
   13025:	e8 26 50 ff ff       	callq  8050 <task_node>
   1302a:	48 89 c1             	mov    %rax,%rcx
   1302d:	48 8b 44 24 08       	mov    0x8(%rsp),%rax
   13032:	49 89 04 cc          	mov    %rax,(%r12,%rcx,8)
   13036:	49 89 6c cc 08       	mov    %rbp,0x8(%r12,%rcx,8)
   1303b:	48 b8 00 00 00 00 00 	movabs $0x5003c0000000000,%rax
   13042:	3c 00 05 
   13045:	48 09 c8             	or     %rcx,%rax
   13048:	48 83 c4 60          	add    $0x60,%rsp
   1304c:	5d                   	pop    %rbp
   1304d:	c3                   	retq   
   1304e:	4c 89 e7             	mov    %r12,%rdi
   13051:	4c 89 cb             	mov    %r9,%rbx
   13054:	4d 89 c1             	mov    %r8,%r9
   13057:	49 89 f0             	mov    %rsi,%r8
   1305a:	4c 89 ee             	mov    %r13,%rsi
   1305d:	ba 01 00 00 00       	mov    $0x1,%edx
   13062:	e8 6e a6 00 00       	callq  1d6d5 <heap_hand>
   13067:	4c 89 c6             	mov    %r8,%rsi
   1306a:	4d 89 c8             	mov    %r9,%r8
   1306d:	49 89 d9             	mov    %rbx,%r9
   13070:	e9 ff f4 ff ff       	jmpq   12574 <WL_FID_MAP_GET_GO+0x824>
   13075:	4c 89 e7             	mov    %r12,%rdi
   13078:	49 89 f0             	mov    %rsi,%r8
   1307b:	4c 89 ee             	mov    %r13,%rsi
   1307e:	ba 02 00 00 00       	mov    $0x2,%edx
   13083:	e8 4d a6 00 00       	callq  1d6d5 <heap_hand>
   13088:	4c 89 c6             	mov    %r8,%rsi
   1308b:	49 8b 5d 10          	mov    0x10(%r13),%rbx
   1308f:	e9 86 f6 ff ff       	jmpq   1271a <WL_FID_MAP_GET_GO+0x9ca>

Disassembly of section .init:

Disassembly of section .fini:

Disassembly of section .plt:
