
user/_stress:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "user/user.h"
#include "kernel/fcntl.h"

int
main(int argc, char *argv[])
{
   0:	7139                	addi	sp,sp,-64
   2:	fc06                	sd	ra,56(sp)
   4:	f822                	sd	s0,48(sp)
   6:	f426                	sd	s1,40(sp)
   8:	f04a                	sd	s2,32(sp)
   a:	0080                	addi	s0,sp,64
  int i;
  int n = 3; 
  int pid;
  int priorities[3] = {5, 10, 1}; 
   c:	4795                	li	a5,5
   e:	fcf42823          	sw	a5,-48(s0)
  12:	47a9                	li	a5,10
  14:	fcf42a23          	sw	a5,-44(s0)
  18:	4785                	li	a5,1
  1a:	fcf42c23          	sw	a5,-40(s0)

  printf("\n--- Stress test: Launching %d instances of spin ---\n", n);
  1e:	458d                	li	a1,3
  20:	00001517          	auipc	a0,0x1
  24:	8f050513          	addi	a0,a0,-1808 # 910 <malloc+0xfe>
  28:	00000097          	auipc	ra,0x0
  2c:	72e080e7          	jalr	1838(ra) # 756 <printf>

  for(i = 0; i < n; i++){
  30:	4481                	li	s1,0
  32:	490d                	li	s2,3
    pid = fork();
  34:	00000097          	auipc	ra,0x0
  38:	3ac080e7          	jalr	940(ra) # 3e0 <fork>
    
    if(pid < 0){
  3c:	02054463          	bltz	a0,64 <main+0x64>
      printf("fork failed\n");
      exit(1);
    }
    
    if(pid == 0){
  40:	cd1d                	beqz	a0,7e <main+0x7e>
  for(i = 0; i < n; i++){
  42:	2485                	addiw	s1,s1,1
  44:	ff2498e3          	bne	s1,s2,34 <main+0x34>
      
      printf("exec failed\n");
      exit(1);
    }
  }
  printf("Parent: Waiting for children to finish...\n\n");
  48:	00001517          	auipc	a0,0x1
  4c:	9a050513          	addi	a0,a0,-1632 # 9e8 <malloc+0x1d6>
  50:	00000097          	auipc	ra,0x0
  54:	706080e7          	jalr	1798(ra) # 756 <printf>
  58:	448d                	li	s1,3
  int finished_pid;
  for(i = 0; i < n; i++){
    finished_pid = wait(0);
    
    if(finished_pid > 0){
        printf(">>> Child with PID %d has finished.\n", finished_pid);
  5a:	00001917          	auipc	s2,0x1
  5e:	9be90913          	addi	s2,s2,-1602 # a18 <malloc+0x206>
  62:	a855                	j	116 <main+0x116>
      printf("fork failed\n");
  64:	00001517          	auipc	a0,0x1
  68:	8ec50513          	addi	a0,a0,-1812 # 950 <malloc+0x13e>
  6c:	00000097          	auipc	ra,0x0
  70:	6ea080e7          	jalr	1770(ra) # 756 <printf>
      exit(1);
  74:	4505                	li	a0,1
  76:	00000097          	auipc	ra,0x0
  7a:	372080e7          	jalr	882(ra) # 3e8 <exit>
      if(set_ps_priority(priorities[i]) != 0){
  7e:	048a                	slli	s1,s1,0x2
  80:	fe048793          	addi	a5,s1,-32
  84:	008784b3          	add	s1,a5,s0
  88:	ff04a483          	lw	s1,-16(s1)
  8c:	8526                	mv	a0,s1
  8e:	00000097          	auipc	ra,0x0
  92:	3fa080e7          	jalr	1018(ra) # 488 <set_ps_priority>
  96:	cd11                	beqz	a0,b2 <main+0xb2>
        printf("Error, priority is larger than 10 or less than 1");
  98:	00001517          	auipc	a0,0x1
  9c:	8c850513          	addi	a0,a0,-1848 # 960 <malloc+0x14e>
  a0:	00000097          	auipc	ra,0x0
  a4:	6b6080e7          	jalr	1718(ra) # 756 <printf>
        exit(-1);
  a8:	557d                	li	a0,-1
  aa:	00000097          	auipc	ra,0x0
  ae:	33e080e7          	jalr	830(ra) # 3e8 <exit>
      printf("Debug: Child (PID %d) launched with priority %d\n", getpid(), priorities[i]);
  b2:	00000097          	auipc	ra,0x0
  b6:	3b6080e7          	jalr	950(ra) # 468 <getpid>
  ba:	85aa                	mv	a1,a0
  bc:	8626                	mv	a2,s1
  be:	00001517          	auipc	a0,0x1
  c2:	8da50513          	addi	a0,a0,-1830 # 998 <malloc+0x186>
  c6:	00000097          	auipc	ra,0x0
  ca:	690080e7          	jalr	1680(ra) # 756 <printf>
      char *args[] = { "spin", 0 };
  ce:	00001797          	auipc	a5,0x1
  d2:	90278793          	addi	a5,a5,-1790 # 9d0 <malloc+0x1be>
  d6:	fcf43023          	sd	a5,-64(s0)
  da:	fc043423          	sd	zero,-56(s0)
      exec("spin", args);
  de:	fc040593          	addi	a1,s0,-64
  e2:	853e                	mv	a0,a5
  e4:	00000097          	auipc	ra,0x0
  e8:	33c080e7          	jalr	828(ra) # 420 <exec>
      printf("exec failed\n");
  ec:	00001517          	auipc	a0,0x1
  f0:	8ec50513          	addi	a0,a0,-1812 # 9d8 <malloc+0x1c6>
  f4:	00000097          	auipc	ra,0x0
  f8:	662080e7          	jalr	1634(ra) # 756 <printf>
      exit(1);
  fc:	4505                	li	a0,1
  fe:	00000097          	auipc	ra,0x0
 102:	2ea080e7          	jalr	746(ra) # 3e8 <exit>
        printf(">>> Child with PID %d has finished.\n", finished_pid);
 106:	85aa                	mv	a1,a0
 108:	854a                	mv	a0,s2
 10a:	00000097          	auipc	ra,0x0
 10e:	64c080e7          	jalr	1612(ra) # 756 <printf>
  for(i = 0; i < n; i++){
 112:	34fd                	addiw	s1,s1,-1
 114:	c889                	beqz	s1,126 <main+0x126>
    finished_pid = wait(0);
 116:	4501                	li	a0,0
 118:	00000097          	auipc	ra,0x0
 11c:	2d8080e7          	jalr	728(ra) # 3f0 <wait>
    if(finished_pid > 0){
 120:	fea059e3          	blez	a0,112 <main+0x112>
 124:	b7cd                	j	106 <main+0x106>
    }
  }

  printf("\nStress test finished.\n");
 126:	00001517          	auipc	a0,0x1
 12a:	91a50513          	addi	a0,a0,-1766 # a40 <malloc+0x22e>
 12e:	00000097          	auipc	ra,0x0
 132:	628080e7          	jalr	1576(ra) # 756 <printf>
  exit(0);
 136:	4501                	li	a0,0
 138:	00000097          	auipc	ra,0x0
 13c:	2b0080e7          	jalr	688(ra) # 3e8 <exit>

0000000000000140 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 140:	1141                	addi	sp,sp,-16
 142:	e406                	sd	ra,8(sp)
 144:	e022                	sd	s0,0(sp)
 146:	0800                	addi	s0,sp,16
  extern int main();
  main();
 148:	00000097          	auipc	ra,0x0
 14c:	eb8080e7          	jalr	-328(ra) # 0 <main>
  exit(0);
 150:	4501                	li	a0,0
 152:	00000097          	auipc	ra,0x0
 156:	296080e7          	jalr	662(ra) # 3e8 <exit>

000000000000015a <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 15a:	1141                	addi	sp,sp,-16
 15c:	e406                	sd	ra,8(sp)
 15e:	e022                	sd	s0,0(sp)
 160:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 162:	87aa                	mv	a5,a0
 164:	0585                	addi	a1,a1,1
 166:	0785                	addi	a5,a5,1
 168:	fff5c703          	lbu	a4,-1(a1)
 16c:	fee78fa3          	sb	a4,-1(a5)
 170:	fb75                	bnez	a4,164 <strcpy+0xa>
    ;
  return os;
}
 172:	60a2                	ld	ra,8(sp)
 174:	6402                	ld	s0,0(sp)
 176:	0141                	addi	sp,sp,16
 178:	8082                	ret

000000000000017a <strcmp>:

int
strcmp(const char *p, const char *q)
{
 17a:	1141                	addi	sp,sp,-16
 17c:	e406                	sd	ra,8(sp)
 17e:	e022                	sd	s0,0(sp)
 180:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 182:	00054783          	lbu	a5,0(a0)
 186:	cb91                	beqz	a5,19a <strcmp+0x20>
 188:	0005c703          	lbu	a4,0(a1)
 18c:	00f71763          	bne	a4,a5,19a <strcmp+0x20>
    p++, q++;
 190:	0505                	addi	a0,a0,1
 192:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 194:	00054783          	lbu	a5,0(a0)
 198:	fbe5                	bnez	a5,188 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 19a:	0005c503          	lbu	a0,0(a1)
}
 19e:	40a7853b          	subw	a0,a5,a0
 1a2:	60a2                	ld	ra,8(sp)
 1a4:	6402                	ld	s0,0(sp)
 1a6:	0141                	addi	sp,sp,16
 1a8:	8082                	ret

00000000000001aa <strlen>:

uint
strlen(const char *s)
{
 1aa:	1141                	addi	sp,sp,-16
 1ac:	e406                	sd	ra,8(sp)
 1ae:	e022                	sd	s0,0(sp)
 1b0:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1b2:	00054783          	lbu	a5,0(a0)
 1b6:	cf91                	beqz	a5,1d2 <strlen+0x28>
 1b8:	00150793          	addi	a5,a0,1
 1bc:	86be                	mv	a3,a5
 1be:	0785                	addi	a5,a5,1
 1c0:	fff7c703          	lbu	a4,-1(a5)
 1c4:	ff65                	bnez	a4,1bc <strlen+0x12>
 1c6:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 1ca:	60a2                	ld	ra,8(sp)
 1cc:	6402                	ld	s0,0(sp)
 1ce:	0141                	addi	sp,sp,16
 1d0:	8082                	ret
  for(n = 0; s[n]; n++)
 1d2:	4501                	li	a0,0
 1d4:	bfdd                	j	1ca <strlen+0x20>

00000000000001d6 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1d6:	1141                	addi	sp,sp,-16
 1d8:	e406                	sd	ra,8(sp)
 1da:	e022                	sd	s0,0(sp)
 1dc:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1de:	ca19                	beqz	a2,1f4 <memset+0x1e>
 1e0:	87aa                	mv	a5,a0
 1e2:	1602                	slli	a2,a2,0x20
 1e4:	9201                	srli	a2,a2,0x20
 1e6:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1ea:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1ee:	0785                	addi	a5,a5,1
 1f0:	fee79de3          	bne	a5,a4,1ea <memset+0x14>
  }
  return dst;
}
 1f4:	60a2                	ld	ra,8(sp)
 1f6:	6402                	ld	s0,0(sp)
 1f8:	0141                	addi	sp,sp,16
 1fa:	8082                	ret

00000000000001fc <strchr>:

char*
strchr(const char *s, char c)
{
 1fc:	1141                	addi	sp,sp,-16
 1fe:	e406                	sd	ra,8(sp)
 200:	e022                	sd	s0,0(sp)
 202:	0800                	addi	s0,sp,16
  for(; *s; s++)
 204:	00054783          	lbu	a5,0(a0)
 208:	cf81                	beqz	a5,220 <strchr+0x24>
    if(*s == c)
 20a:	00f58763          	beq	a1,a5,218 <strchr+0x1c>
  for(; *s; s++)
 20e:	0505                	addi	a0,a0,1
 210:	00054783          	lbu	a5,0(a0)
 214:	fbfd                	bnez	a5,20a <strchr+0xe>
      return (char*)s;
  return 0;
 216:	4501                	li	a0,0
}
 218:	60a2                	ld	ra,8(sp)
 21a:	6402                	ld	s0,0(sp)
 21c:	0141                	addi	sp,sp,16
 21e:	8082                	ret
  return 0;
 220:	4501                	li	a0,0
 222:	bfdd                	j	218 <strchr+0x1c>

0000000000000224 <gets>:

char*
gets(char *buf, int max)
{
 224:	711d                	addi	sp,sp,-96
 226:	ec86                	sd	ra,88(sp)
 228:	e8a2                	sd	s0,80(sp)
 22a:	e4a6                	sd	s1,72(sp)
 22c:	e0ca                	sd	s2,64(sp)
 22e:	fc4e                	sd	s3,56(sp)
 230:	f852                	sd	s4,48(sp)
 232:	f456                	sd	s5,40(sp)
 234:	f05a                	sd	s6,32(sp)
 236:	ec5e                	sd	s7,24(sp)
 238:	e862                	sd	s8,16(sp)
 23a:	1080                	addi	s0,sp,96
 23c:	8baa                	mv	s7,a0
 23e:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 240:	892a                	mv	s2,a0
 242:	4481                	li	s1,0
    cc = read(0, &c, 1);
 244:	faf40b13          	addi	s6,s0,-81
 248:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 24a:	8c26                	mv	s8,s1
 24c:	0014899b          	addiw	s3,s1,1
 250:	84ce                	mv	s1,s3
 252:	0349d663          	bge	s3,s4,27e <gets+0x5a>
    cc = read(0, &c, 1);
 256:	8656                	mv	a2,s5
 258:	85da                	mv	a1,s6
 25a:	4501                	li	a0,0
 25c:	00000097          	auipc	ra,0x0
 260:	1a4080e7          	jalr	420(ra) # 400 <read>
    if(cc < 1)
 264:	00a05d63          	blez	a0,27e <gets+0x5a>
      break;
    buf[i++] = c;
 268:	faf44783          	lbu	a5,-81(s0)
 26c:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 270:	0905                	addi	s2,s2,1
 272:	ff678713          	addi	a4,a5,-10
 276:	c319                	beqz	a4,27c <gets+0x58>
 278:	17cd                	addi	a5,a5,-13
 27a:	fbe1                	bnez	a5,24a <gets+0x26>
    buf[i++] = c;
 27c:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 27e:	9c5e                	add	s8,s8,s7
 280:	000c0023          	sb	zero,0(s8)
  return buf;
}
 284:	855e                	mv	a0,s7
 286:	60e6                	ld	ra,88(sp)
 288:	6446                	ld	s0,80(sp)
 28a:	64a6                	ld	s1,72(sp)
 28c:	6906                	ld	s2,64(sp)
 28e:	79e2                	ld	s3,56(sp)
 290:	7a42                	ld	s4,48(sp)
 292:	7aa2                	ld	s5,40(sp)
 294:	7b02                	ld	s6,32(sp)
 296:	6be2                	ld	s7,24(sp)
 298:	6c42                	ld	s8,16(sp)
 29a:	6125                	addi	sp,sp,96
 29c:	8082                	ret

000000000000029e <stat>:

int
stat(const char *n, struct stat *st)
{
 29e:	1101                	addi	sp,sp,-32
 2a0:	ec06                	sd	ra,24(sp)
 2a2:	e822                	sd	s0,16(sp)
 2a4:	e04a                	sd	s2,0(sp)
 2a6:	1000                	addi	s0,sp,32
 2a8:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2aa:	4581                	li	a1,0
 2ac:	00000097          	auipc	ra,0x0
 2b0:	17c080e7          	jalr	380(ra) # 428 <open>
  if(fd < 0)
 2b4:	02054663          	bltz	a0,2e0 <stat+0x42>
 2b8:	e426                	sd	s1,8(sp)
 2ba:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2bc:	85ca                	mv	a1,s2
 2be:	00000097          	auipc	ra,0x0
 2c2:	182080e7          	jalr	386(ra) # 440 <fstat>
 2c6:	892a                	mv	s2,a0
  close(fd);
 2c8:	8526                	mv	a0,s1
 2ca:	00000097          	auipc	ra,0x0
 2ce:	146080e7          	jalr	326(ra) # 410 <close>
  return r;
 2d2:	64a2                	ld	s1,8(sp)
}
 2d4:	854a                	mv	a0,s2
 2d6:	60e2                	ld	ra,24(sp)
 2d8:	6442                	ld	s0,16(sp)
 2da:	6902                	ld	s2,0(sp)
 2dc:	6105                	addi	sp,sp,32
 2de:	8082                	ret
    return -1;
 2e0:	57fd                	li	a5,-1
 2e2:	893e                	mv	s2,a5
 2e4:	bfc5                	j	2d4 <stat+0x36>

00000000000002e6 <atoi>:

int
atoi(const char *s)
{
 2e6:	1141                	addi	sp,sp,-16
 2e8:	e406                	sd	ra,8(sp)
 2ea:	e022                	sd	s0,0(sp)
 2ec:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2ee:	00054683          	lbu	a3,0(a0)
 2f2:	fd06879b          	addiw	a5,a3,-48
 2f6:	0ff7f793          	zext.b	a5,a5
 2fa:	4625                	li	a2,9
 2fc:	02f66963          	bltu	a2,a5,32e <atoi+0x48>
 300:	872a                	mv	a4,a0
  n = 0;
 302:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 304:	0705                	addi	a4,a4,1
 306:	0025179b          	slliw	a5,a0,0x2
 30a:	9fa9                	addw	a5,a5,a0
 30c:	0017979b          	slliw	a5,a5,0x1
 310:	9fb5                	addw	a5,a5,a3
 312:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 316:	00074683          	lbu	a3,0(a4)
 31a:	fd06879b          	addiw	a5,a3,-48
 31e:	0ff7f793          	zext.b	a5,a5
 322:	fef671e3          	bgeu	a2,a5,304 <atoi+0x1e>
  return n;
}
 326:	60a2                	ld	ra,8(sp)
 328:	6402                	ld	s0,0(sp)
 32a:	0141                	addi	sp,sp,16
 32c:	8082                	ret
  n = 0;
 32e:	4501                	li	a0,0
 330:	bfdd                	j	326 <atoi+0x40>

0000000000000332 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 332:	1141                	addi	sp,sp,-16
 334:	e406                	sd	ra,8(sp)
 336:	e022                	sd	s0,0(sp)
 338:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 33a:	02b57563          	bgeu	a0,a1,364 <memmove+0x32>
    while(n-- > 0)
 33e:	00c05f63          	blez	a2,35c <memmove+0x2a>
 342:	1602                	slli	a2,a2,0x20
 344:	9201                	srli	a2,a2,0x20
 346:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 34a:	872a                	mv	a4,a0
      *dst++ = *src++;
 34c:	0585                	addi	a1,a1,1
 34e:	0705                	addi	a4,a4,1
 350:	fff5c683          	lbu	a3,-1(a1)
 354:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 358:	fee79ae3          	bne	a5,a4,34c <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 35c:	60a2                	ld	ra,8(sp)
 35e:	6402                	ld	s0,0(sp)
 360:	0141                	addi	sp,sp,16
 362:	8082                	ret
    while(n-- > 0)
 364:	fec05ce3          	blez	a2,35c <memmove+0x2a>
    dst += n;
 368:	00c50733          	add	a4,a0,a2
    src += n;
 36c:	95b2                	add	a1,a1,a2
 36e:	fff6079b          	addiw	a5,a2,-1
 372:	1782                	slli	a5,a5,0x20
 374:	9381                	srli	a5,a5,0x20
 376:	fff7c793          	not	a5,a5
 37a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 37c:	15fd                	addi	a1,a1,-1
 37e:	177d                	addi	a4,a4,-1
 380:	0005c683          	lbu	a3,0(a1)
 384:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 388:	fef71ae3          	bne	a4,a5,37c <memmove+0x4a>
 38c:	bfc1                	j	35c <memmove+0x2a>

000000000000038e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 38e:	1141                	addi	sp,sp,-16
 390:	e406                	sd	ra,8(sp)
 392:	e022                	sd	s0,0(sp)
 394:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 396:	c61d                	beqz	a2,3c4 <memcmp+0x36>
 398:	1602                	slli	a2,a2,0x20
 39a:	9201                	srli	a2,a2,0x20
 39c:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 3a0:	00054783          	lbu	a5,0(a0)
 3a4:	0005c703          	lbu	a4,0(a1)
 3a8:	00e79863          	bne	a5,a4,3b8 <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 3ac:	0505                	addi	a0,a0,1
    p2++;
 3ae:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3b0:	fed518e3          	bne	a0,a3,3a0 <memcmp+0x12>
  }
  return 0;
 3b4:	4501                	li	a0,0
 3b6:	a019                	j	3bc <memcmp+0x2e>
      return *p1 - *p2;
 3b8:	40e7853b          	subw	a0,a5,a4
}
 3bc:	60a2                	ld	ra,8(sp)
 3be:	6402                	ld	s0,0(sp)
 3c0:	0141                	addi	sp,sp,16
 3c2:	8082                	ret
  return 0;
 3c4:	4501                	li	a0,0
 3c6:	bfdd                	j	3bc <memcmp+0x2e>

00000000000003c8 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3c8:	1141                	addi	sp,sp,-16
 3ca:	e406                	sd	ra,8(sp)
 3cc:	e022                	sd	s0,0(sp)
 3ce:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3d0:	00000097          	auipc	ra,0x0
 3d4:	f62080e7          	jalr	-158(ra) # 332 <memmove>
}
 3d8:	60a2                	ld	ra,8(sp)
 3da:	6402                	ld	s0,0(sp)
 3dc:	0141                	addi	sp,sp,16
 3de:	8082                	ret

00000000000003e0 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3e0:	4885                	li	a7,1
 ecall
 3e2:	00000073          	ecall
 ret
 3e6:	8082                	ret

00000000000003e8 <exit>:
.global exit
exit:
 li a7, SYS_exit
 3e8:	4889                	li	a7,2
 ecall
 3ea:	00000073          	ecall
 ret
 3ee:	8082                	ret

00000000000003f0 <wait>:
.global wait
wait:
 li a7, SYS_wait
 3f0:	488d                	li	a7,3
 ecall
 3f2:	00000073          	ecall
 ret
 3f6:	8082                	ret

00000000000003f8 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3f8:	4891                	li	a7,4
 ecall
 3fa:	00000073          	ecall
 ret
 3fe:	8082                	ret

0000000000000400 <read>:
.global read
read:
 li a7, SYS_read
 400:	4895                	li	a7,5
 ecall
 402:	00000073          	ecall
 ret
 406:	8082                	ret

0000000000000408 <write>:
.global write
write:
 li a7, SYS_write
 408:	48c1                	li	a7,16
 ecall
 40a:	00000073          	ecall
 ret
 40e:	8082                	ret

0000000000000410 <close>:
.global close
close:
 li a7, SYS_close
 410:	48d5                	li	a7,21
 ecall
 412:	00000073          	ecall
 ret
 416:	8082                	ret

0000000000000418 <kill>:
.global kill
kill:
 li a7, SYS_kill
 418:	4899                	li	a7,6
 ecall
 41a:	00000073          	ecall
 ret
 41e:	8082                	ret

0000000000000420 <exec>:
.global exec
exec:
 li a7, SYS_exec
 420:	489d                	li	a7,7
 ecall
 422:	00000073          	ecall
 ret
 426:	8082                	ret

0000000000000428 <open>:
.global open
open:
 li a7, SYS_open
 428:	48bd                	li	a7,15
 ecall
 42a:	00000073          	ecall
 ret
 42e:	8082                	ret

0000000000000430 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 430:	48c5                	li	a7,17
 ecall
 432:	00000073          	ecall
 ret
 436:	8082                	ret

0000000000000438 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 438:	48c9                	li	a7,18
 ecall
 43a:	00000073          	ecall
 ret
 43e:	8082                	ret

0000000000000440 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 440:	48a1                	li	a7,8
 ecall
 442:	00000073          	ecall
 ret
 446:	8082                	ret

0000000000000448 <link>:
.global link
link:
 li a7, SYS_link
 448:	48cd                	li	a7,19
 ecall
 44a:	00000073          	ecall
 ret
 44e:	8082                	ret

0000000000000450 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 450:	48d1                	li	a7,20
 ecall
 452:	00000073          	ecall
 ret
 456:	8082                	ret

0000000000000458 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 458:	48a5                	li	a7,9
 ecall
 45a:	00000073          	ecall
 ret
 45e:	8082                	ret

0000000000000460 <dup>:
.global dup
dup:
 li a7, SYS_dup
 460:	48a9                	li	a7,10
 ecall
 462:	00000073          	ecall
 ret
 466:	8082                	ret

0000000000000468 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 468:	48ad                	li	a7,11
 ecall
 46a:	00000073          	ecall
 ret
 46e:	8082                	ret

0000000000000470 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 470:	48b1                	li	a7,12
 ecall
 472:	00000073          	ecall
 ret
 476:	8082                	ret

0000000000000478 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 478:	48b5                	li	a7,13
 ecall
 47a:	00000073          	ecall
 ret
 47e:	8082                	ret

0000000000000480 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 480:	48b9                	li	a7,14
 ecall
 482:	00000073          	ecall
 ret
 486:	8082                	ret

0000000000000488 <set_ps_priority>:
.global set_ps_priority
set_ps_priority:
 li a7, SYS_set_ps_priority
 488:	48d9                	li	a7,22
 ecall
 48a:	00000073          	ecall
 ret
 48e:	8082                	ret

0000000000000490 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 490:	1101                	addi	sp,sp,-32
 492:	ec06                	sd	ra,24(sp)
 494:	e822                	sd	s0,16(sp)
 496:	1000                	addi	s0,sp,32
 498:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 49c:	4605                	li	a2,1
 49e:	fef40593          	addi	a1,s0,-17
 4a2:	00000097          	auipc	ra,0x0
 4a6:	f66080e7          	jalr	-154(ra) # 408 <write>
}
 4aa:	60e2                	ld	ra,24(sp)
 4ac:	6442                	ld	s0,16(sp)
 4ae:	6105                	addi	sp,sp,32
 4b0:	8082                	ret

00000000000004b2 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4b2:	7139                	addi	sp,sp,-64
 4b4:	fc06                	sd	ra,56(sp)
 4b6:	f822                	sd	s0,48(sp)
 4b8:	f04a                	sd	s2,32(sp)
 4ba:	ec4e                	sd	s3,24(sp)
 4bc:	0080                	addi	s0,sp,64
 4be:	892a                	mv	s2,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4c0:	cad9                	beqz	a3,556 <printint+0xa4>
 4c2:	01f5d79b          	srliw	a5,a1,0x1f
 4c6:	cbc1                	beqz	a5,556 <printint+0xa4>
    neg = 1;
    x = -xx;
 4c8:	40b005bb          	negw	a1,a1
    neg = 1;
 4cc:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 4ce:	fc040993          	addi	s3,s0,-64
  neg = 0;
 4d2:	86ce                	mv	a3,s3
  i = 0;
 4d4:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4d6:	00000817          	auipc	a6,0x0
 4da:	5e280813          	addi	a6,a6,1506 # ab8 <digits>
 4de:	88ba                	mv	a7,a4
 4e0:	0017051b          	addiw	a0,a4,1
 4e4:	872a                	mv	a4,a0
 4e6:	02c5f7bb          	remuw	a5,a1,a2
 4ea:	1782                	slli	a5,a5,0x20
 4ec:	9381                	srli	a5,a5,0x20
 4ee:	97c2                	add	a5,a5,a6
 4f0:	0007c783          	lbu	a5,0(a5)
 4f4:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4f8:	87ae                	mv	a5,a1
 4fa:	02c5d5bb          	divuw	a1,a1,a2
 4fe:	0685                	addi	a3,a3,1
 500:	fcc7ffe3          	bgeu	a5,a2,4de <printint+0x2c>
  if(neg)
 504:	00030c63          	beqz	t1,51c <printint+0x6a>
    buf[i++] = '-';
 508:	fd050793          	addi	a5,a0,-48
 50c:	00878533          	add	a0,a5,s0
 510:	02d00793          	li	a5,45
 514:	fef50823          	sb	a5,-16(a0)
 518:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 51c:	02e05763          	blez	a4,54a <printint+0x98>
 520:	f426                	sd	s1,40(sp)
 522:	377d                	addiw	a4,a4,-1
 524:	00e984b3          	add	s1,s3,a4
 528:	19fd                	addi	s3,s3,-1
 52a:	99ba                	add	s3,s3,a4
 52c:	1702                	slli	a4,a4,0x20
 52e:	9301                	srli	a4,a4,0x20
 530:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 534:	0004c583          	lbu	a1,0(s1)
 538:	854a                	mv	a0,s2
 53a:	00000097          	auipc	ra,0x0
 53e:	f56080e7          	jalr	-170(ra) # 490 <putc>
  while(--i >= 0)
 542:	14fd                	addi	s1,s1,-1
 544:	ff3498e3          	bne	s1,s3,534 <printint+0x82>
 548:	74a2                	ld	s1,40(sp)
}
 54a:	70e2                	ld	ra,56(sp)
 54c:	7442                	ld	s0,48(sp)
 54e:	7902                	ld	s2,32(sp)
 550:	69e2                	ld	s3,24(sp)
 552:	6121                	addi	sp,sp,64
 554:	8082                	ret
  neg = 0;
 556:	4301                	li	t1,0
 558:	bf9d                	j	4ce <printint+0x1c>

000000000000055a <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 55a:	715d                	addi	sp,sp,-80
 55c:	e486                	sd	ra,72(sp)
 55e:	e0a2                	sd	s0,64(sp)
 560:	f84a                	sd	s2,48(sp)
 562:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 564:	0005c903          	lbu	s2,0(a1)
 568:	1a090b63          	beqz	s2,71e <vprintf+0x1c4>
 56c:	fc26                	sd	s1,56(sp)
 56e:	f44e                	sd	s3,40(sp)
 570:	f052                	sd	s4,32(sp)
 572:	ec56                	sd	s5,24(sp)
 574:	e85a                	sd	s6,16(sp)
 576:	e45e                	sd	s7,8(sp)
 578:	8aaa                	mv	s5,a0
 57a:	8bb2                	mv	s7,a2
 57c:	00158493          	addi	s1,a1,1
  state = 0;
 580:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 582:	02500a13          	li	s4,37
 586:	4b55                	li	s6,21
 588:	a839                	j	5a6 <vprintf+0x4c>
        putc(fd, c);
 58a:	85ca                	mv	a1,s2
 58c:	8556                	mv	a0,s5
 58e:	00000097          	auipc	ra,0x0
 592:	f02080e7          	jalr	-254(ra) # 490 <putc>
 596:	a019                	j	59c <vprintf+0x42>
    } else if(state == '%'){
 598:	01498d63          	beq	s3,s4,5b2 <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 59c:	0485                	addi	s1,s1,1
 59e:	fff4c903          	lbu	s2,-1(s1)
 5a2:	16090863          	beqz	s2,712 <vprintf+0x1b8>
    if(state == 0){
 5a6:	fe0999e3          	bnez	s3,598 <vprintf+0x3e>
      if(c == '%'){
 5aa:	ff4910e3          	bne	s2,s4,58a <vprintf+0x30>
        state = '%';
 5ae:	89d2                	mv	s3,s4
 5b0:	b7f5                	j	59c <vprintf+0x42>
      if(c == 'd'){
 5b2:	13490563          	beq	s2,s4,6dc <vprintf+0x182>
 5b6:	f9d9079b          	addiw	a5,s2,-99
 5ba:	0ff7f793          	zext.b	a5,a5
 5be:	12fb6863          	bltu	s6,a5,6ee <vprintf+0x194>
 5c2:	f9d9079b          	addiw	a5,s2,-99
 5c6:	0ff7f713          	zext.b	a4,a5
 5ca:	12eb6263          	bltu	s6,a4,6ee <vprintf+0x194>
 5ce:	00271793          	slli	a5,a4,0x2
 5d2:	00000717          	auipc	a4,0x0
 5d6:	48e70713          	addi	a4,a4,1166 # a60 <malloc+0x24e>
 5da:	97ba                	add	a5,a5,a4
 5dc:	439c                	lw	a5,0(a5)
 5de:	97ba                	add	a5,a5,a4
 5e0:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 5e2:	008b8913          	addi	s2,s7,8
 5e6:	4685                	li	a3,1
 5e8:	4629                	li	a2,10
 5ea:	000ba583          	lw	a1,0(s7)
 5ee:	8556                	mv	a0,s5
 5f0:	00000097          	auipc	ra,0x0
 5f4:	ec2080e7          	jalr	-318(ra) # 4b2 <printint>
 5f8:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 5fa:	4981                	li	s3,0
 5fc:	b745                	j	59c <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5fe:	008b8913          	addi	s2,s7,8
 602:	4681                	li	a3,0
 604:	4629                	li	a2,10
 606:	000ba583          	lw	a1,0(s7)
 60a:	8556                	mv	a0,s5
 60c:	00000097          	auipc	ra,0x0
 610:	ea6080e7          	jalr	-346(ra) # 4b2 <printint>
 614:	8bca                	mv	s7,s2
      state = 0;
 616:	4981                	li	s3,0
 618:	b751                	j	59c <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 61a:	008b8913          	addi	s2,s7,8
 61e:	4681                	li	a3,0
 620:	4641                	li	a2,16
 622:	000ba583          	lw	a1,0(s7)
 626:	8556                	mv	a0,s5
 628:	00000097          	auipc	ra,0x0
 62c:	e8a080e7          	jalr	-374(ra) # 4b2 <printint>
 630:	8bca                	mv	s7,s2
      state = 0;
 632:	4981                	li	s3,0
 634:	b7a5                	j	59c <vprintf+0x42>
 636:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 638:	008b8793          	addi	a5,s7,8
 63c:	8c3e                	mv	s8,a5
 63e:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 642:	03000593          	li	a1,48
 646:	8556                	mv	a0,s5
 648:	00000097          	auipc	ra,0x0
 64c:	e48080e7          	jalr	-440(ra) # 490 <putc>
  putc(fd, 'x');
 650:	07800593          	li	a1,120
 654:	8556                	mv	a0,s5
 656:	00000097          	auipc	ra,0x0
 65a:	e3a080e7          	jalr	-454(ra) # 490 <putc>
 65e:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 660:	00000b97          	auipc	s7,0x0
 664:	458b8b93          	addi	s7,s7,1112 # ab8 <digits>
 668:	03c9d793          	srli	a5,s3,0x3c
 66c:	97de                	add	a5,a5,s7
 66e:	0007c583          	lbu	a1,0(a5)
 672:	8556                	mv	a0,s5
 674:	00000097          	auipc	ra,0x0
 678:	e1c080e7          	jalr	-484(ra) # 490 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 67c:	0992                	slli	s3,s3,0x4
 67e:	397d                	addiw	s2,s2,-1
 680:	fe0914e3          	bnez	s2,668 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
 684:	8be2                	mv	s7,s8
      state = 0;
 686:	4981                	li	s3,0
 688:	6c02                	ld	s8,0(sp)
 68a:	bf09                	j	59c <vprintf+0x42>
        s = va_arg(ap, char*);
 68c:	008b8993          	addi	s3,s7,8
 690:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 694:	02090163          	beqz	s2,6b6 <vprintf+0x15c>
        while(*s != 0){
 698:	00094583          	lbu	a1,0(s2)
 69c:	c9a5                	beqz	a1,70c <vprintf+0x1b2>
          putc(fd, *s);
 69e:	8556                	mv	a0,s5
 6a0:	00000097          	auipc	ra,0x0
 6a4:	df0080e7          	jalr	-528(ra) # 490 <putc>
          s++;
 6a8:	0905                	addi	s2,s2,1
        while(*s != 0){
 6aa:	00094583          	lbu	a1,0(s2)
 6ae:	f9e5                	bnez	a1,69e <vprintf+0x144>
        s = va_arg(ap, char*);
 6b0:	8bce                	mv	s7,s3
      state = 0;
 6b2:	4981                	li	s3,0
 6b4:	b5e5                	j	59c <vprintf+0x42>
          s = "(null)";
 6b6:	00000917          	auipc	s2,0x0
 6ba:	3a290913          	addi	s2,s2,930 # a58 <malloc+0x246>
        while(*s != 0){
 6be:	02800593          	li	a1,40
 6c2:	bff1                	j	69e <vprintf+0x144>
        putc(fd, va_arg(ap, uint));
 6c4:	008b8913          	addi	s2,s7,8
 6c8:	000bc583          	lbu	a1,0(s7)
 6cc:	8556                	mv	a0,s5
 6ce:	00000097          	auipc	ra,0x0
 6d2:	dc2080e7          	jalr	-574(ra) # 490 <putc>
 6d6:	8bca                	mv	s7,s2
      state = 0;
 6d8:	4981                	li	s3,0
 6da:	b5c9                	j	59c <vprintf+0x42>
        putc(fd, c);
 6dc:	02500593          	li	a1,37
 6e0:	8556                	mv	a0,s5
 6e2:	00000097          	auipc	ra,0x0
 6e6:	dae080e7          	jalr	-594(ra) # 490 <putc>
      state = 0;
 6ea:	4981                	li	s3,0
 6ec:	bd45                	j	59c <vprintf+0x42>
        putc(fd, '%');
 6ee:	02500593          	li	a1,37
 6f2:	8556                	mv	a0,s5
 6f4:	00000097          	auipc	ra,0x0
 6f8:	d9c080e7          	jalr	-612(ra) # 490 <putc>
        putc(fd, c);
 6fc:	85ca                	mv	a1,s2
 6fe:	8556                	mv	a0,s5
 700:	00000097          	auipc	ra,0x0
 704:	d90080e7          	jalr	-624(ra) # 490 <putc>
      state = 0;
 708:	4981                	li	s3,0
 70a:	bd49                	j	59c <vprintf+0x42>
        s = va_arg(ap, char*);
 70c:	8bce                	mv	s7,s3
      state = 0;
 70e:	4981                	li	s3,0
 710:	b571                	j	59c <vprintf+0x42>
 712:	74e2                	ld	s1,56(sp)
 714:	79a2                	ld	s3,40(sp)
 716:	7a02                	ld	s4,32(sp)
 718:	6ae2                	ld	s5,24(sp)
 71a:	6b42                	ld	s6,16(sp)
 71c:	6ba2                	ld	s7,8(sp)
    }
  }
}
 71e:	60a6                	ld	ra,72(sp)
 720:	6406                	ld	s0,64(sp)
 722:	7942                	ld	s2,48(sp)
 724:	6161                	addi	sp,sp,80
 726:	8082                	ret

0000000000000728 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 728:	715d                	addi	sp,sp,-80
 72a:	ec06                	sd	ra,24(sp)
 72c:	e822                	sd	s0,16(sp)
 72e:	1000                	addi	s0,sp,32
 730:	e010                	sd	a2,0(s0)
 732:	e414                	sd	a3,8(s0)
 734:	e818                	sd	a4,16(s0)
 736:	ec1c                	sd	a5,24(s0)
 738:	03043023          	sd	a6,32(s0)
 73c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 740:	8622                	mv	a2,s0
 742:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 746:	00000097          	auipc	ra,0x0
 74a:	e14080e7          	jalr	-492(ra) # 55a <vprintf>
}
 74e:	60e2                	ld	ra,24(sp)
 750:	6442                	ld	s0,16(sp)
 752:	6161                	addi	sp,sp,80
 754:	8082                	ret

0000000000000756 <printf>:

void
printf(const char *fmt, ...)
{
 756:	711d                	addi	sp,sp,-96
 758:	ec06                	sd	ra,24(sp)
 75a:	e822                	sd	s0,16(sp)
 75c:	1000                	addi	s0,sp,32
 75e:	e40c                	sd	a1,8(s0)
 760:	e810                	sd	a2,16(s0)
 762:	ec14                	sd	a3,24(s0)
 764:	f018                	sd	a4,32(s0)
 766:	f41c                	sd	a5,40(s0)
 768:	03043823          	sd	a6,48(s0)
 76c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 770:	00840613          	addi	a2,s0,8
 774:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 778:	85aa                	mv	a1,a0
 77a:	4505                	li	a0,1
 77c:	00000097          	auipc	ra,0x0
 780:	dde080e7          	jalr	-546(ra) # 55a <vprintf>
}
 784:	60e2                	ld	ra,24(sp)
 786:	6442                	ld	s0,16(sp)
 788:	6125                	addi	sp,sp,96
 78a:	8082                	ret

000000000000078c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 78c:	1141                	addi	sp,sp,-16
 78e:	e406                	sd	ra,8(sp)
 790:	e022                	sd	s0,0(sp)
 792:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 794:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 798:	00001797          	auipc	a5,0x1
 79c:	8687b783          	ld	a5,-1944(a5) # 1000 <freep>
 7a0:	a039                	j	7ae <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7a2:	6398                	ld	a4,0(a5)
 7a4:	00e7e463          	bltu	a5,a4,7ac <free+0x20>
 7a8:	00e6ea63          	bltu	a3,a4,7bc <free+0x30>
{
 7ac:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7ae:	fed7fae3          	bgeu	a5,a3,7a2 <free+0x16>
 7b2:	6398                	ld	a4,0(a5)
 7b4:	00e6e463          	bltu	a3,a4,7bc <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7b8:	fee7eae3          	bltu	a5,a4,7ac <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 7bc:	ff852583          	lw	a1,-8(a0)
 7c0:	6390                	ld	a2,0(a5)
 7c2:	02059813          	slli	a6,a1,0x20
 7c6:	01c85713          	srli	a4,a6,0x1c
 7ca:	9736                	add	a4,a4,a3
 7cc:	02e60563          	beq	a2,a4,7f6 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 7d0:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 7d4:	4790                	lw	a2,8(a5)
 7d6:	02061593          	slli	a1,a2,0x20
 7da:	01c5d713          	srli	a4,a1,0x1c
 7de:	973e                	add	a4,a4,a5
 7e0:	02e68263          	beq	a3,a4,804 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 7e4:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 7e6:	00001717          	auipc	a4,0x1
 7ea:	80f73d23          	sd	a5,-2022(a4) # 1000 <freep>
}
 7ee:	60a2                	ld	ra,8(sp)
 7f0:	6402                	ld	s0,0(sp)
 7f2:	0141                	addi	sp,sp,16
 7f4:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 7f6:	4618                	lw	a4,8(a2)
 7f8:	9f2d                	addw	a4,a4,a1
 7fa:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7fe:	6398                	ld	a4,0(a5)
 800:	6310                	ld	a2,0(a4)
 802:	b7f9                	j	7d0 <free+0x44>
    p->s.size += bp->s.size;
 804:	ff852703          	lw	a4,-8(a0)
 808:	9f31                	addw	a4,a4,a2
 80a:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 80c:	ff053683          	ld	a3,-16(a0)
 810:	bfd1                	j	7e4 <free+0x58>

0000000000000812 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 812:	7139                	addi	sp,sp,-64
 814:	fc06                	sd	ra,56(sp)
 816:	f822                	sd	s0,48(sp)
 818:	f04a                	sd	s2,32(sp)
 81a:	ec4e                	sd	s3,24(sp)
 81c:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 81e:	02051993          	slli	s3,a0,0x20
 822:	0209d993          	srli	s3,s3,0x20
 826:	09bd                	addi	s3,s3,15
 828:	0049d993          	srli	s3,s3,0x4
 82c:	2985                	addiw	s3,s3,1
 82e:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 830:	00000517          	auipc	a0,0x0
 834:	7d053503          	ld	a0,2000(a0) # 1000 <freep>
 838:	c905                	beqz	a0,868 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 83a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 83c:	4798                	lw	a4,8(a5)
 83e:	09377a63          	bgeu	a4,s3,8d2 <malloc+0xc0>
 842:	f426                	sd	s1,40(sp)
 844:	e852                	sd	s4,16(sp)
 846:	e456                	sd	s5,8(sp)
 848:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 84a:	8a4e                	mv	s4,s3
 84c:	6705                	lui	a4,0x1
 84e:	00e9f363          	bgeu	s3,a4,854 <malloc+0x42>
 852:	6a05                	lui	s4,0x1
 854:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 858:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 85c:	00000497          	auipc	s1,0x0
 860:	7a448493          	addi	s1,s1,1956 # 1000 <freep>
  if(p == (char*)-1)
 864:	5afd                	li	s5,-1
 866:	a089                	j	8a8 <malloc+0x96>
 868:	f426                	sd	s1,40(sp)
 86a:	e852                	sd	s4,16(sp)
 86c:	e456                	sd	s5,8(sp)
 86e:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 870:	00000797          	auipc	a5,0x0
 874:	7a078793          	addi	a5,a5,1952 # 1010 <base>
 878:	00000717          	auipc	a4,0x0
 87c:	78f73423          	sd	a5,1928(a4) # 1000 <freep>
 880:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 882:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 886:	b7d1                	j	84a <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 888:	6398                	ld	a4,0(a5)
 88a:	e118                	sd	a4,0(a0)
 88c:	a8b9                	j	8ea <malloc+0xd8>
  hp->s.size = nu;
 88e:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 892:	0541                	addi	a0,a0,16
 894:	00000097          	auipc	ra,0x0
 898:	ef8080e7          	jalr	-264(ra) # 78c <free>
  return freep;
 89c:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 89e:	c135                	beqz	a0,902 <malloc+0xf0>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8a0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8a2:	4798                	lw	a4,8(a5)
 8a4:	03277363          	bgeu	a4,s2,8ca <malloc+0xb8>
    if(p == freep)
 8a8:	6098                	ld	a4,0(s1)
 8aa:	853e                	mv	a0,a5
 8ac:	fef71ae3          	bne	a4,a5,8a0 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 8b0:	8552                	mv	a0,s4
 8b2:	00000097          	auipc	ra,0x0
 8b6:	bbe080e7          	jalr	-1090(ra) # 470 <sbrk>
  if(p == (char*)-1)
 8ba:	fd551ae3          	bne	a0,s5,88e <malloc+0x7c>
        return 0;
 8be:	4501                	li	a0,0
 8c0:	74a2                	ld	s1,40(sp)
 8c2:	6a42                	ld	s4,16(sp)
 8c4:	6aa2                	ld	s5,8(sp)
 8c6:	6b02                	ld	s6,0(sp)
 8c8:	a03d                	j	8f6 <malloc+0xe4>
 8ca:	74a2                	ld	s1,40(sp)
 8cc:	6a42                	ld	s4,16(sp)
 8ce:	6aa2                	ld	s5,8(sp)
 8d0:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 8d2:	fae90be3          	beq	s2,a4,888 <malloc+0x76>
        p->s.size -= nunits;
 8d6:	4137073b          	subw	a4,a4,s3
 8da:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8dc:	02071693          	slli	a3,a4,0x20
 8e0:	01c6d713          	srli	a4,a3,0x1c
 8e4:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8e6:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8ea:	00000717          	auipc	a4,0x0
 8ee:	70a73b23          	sd	a0,1814(a4) # 1000 <freep>
      return (void*)(p + 1);
 8f2:	01078513          	addi	a0,a5,16
  }
}
 8f6:	70e2                	ld	ra,56(sp)
 8f8:	7442                	ld	s0,48(sp)
 8fa:	7902                	ld	s2,32(sp)
 8fc:	69e2                	ld	s3,24(sp)
 8fe:	6121                	addi	sp,sp,64
 900:	8082                	ret
 902:	74a2                	ld	s1,40(sp)
 904:	6a42                	ld	s4,16(sp)
 906:	6aa2                	ld	s5,8(sp)
 908:	6b02                	ld	s6,0(sp)
 90a:	b7f5                	j	8f6 <malloc+0xe4>
