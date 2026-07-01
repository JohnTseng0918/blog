---
title: "Trace xv6 source code note"
date: 2026-06-30
draft: false
description: "MIT 6.S081 / trace xv6-riscv source code 的隨意筆記"
tags: ["xv6", "riscv", "kernel"]
categories: ["作業系統"]
---

## Trace Note

### Homework 1 due: file descriptors

#### cat.c

這個作業要 trace cat 的實作方式,並且要 track argv[i] 是如何 pass 給 open(),
以及 file descriptor 的 result 是什麼、file descriptor 這個 integer 是指向什麼?

首先 cat.c 是個 user program,很輕鬆就可以看到 main 入口

一開始先有一個判斷,如果 argc <= 1,代表只有 argv[0](按照慣例是執行檔的名稱)、沒有輸入任何檔名
所以就呼叫了 cat(0),參數是 file descriptor,0 也就是 standard input

```
void cat(int fd){
  int n;

  while ((n = read(fd, buf, sizeof(buf))) > 0) {
    if (write(1, buf, n) != n) {
      fprintf(2, "cat: write error\n");
      exit(1);
    }
  }
  if (n < 0) {
    fprintf(2, "cat: read error\n");
    exit(1);
  }
}
```

實作可以清楚看到用一個 while 去做 read,並且把 read 到的 byte 數 assign 給 n
如果 n > 0,代表有讀到 data,接下來就會進入裡面執行 write

回到 main function,如果 argc > 1
就會去 open argv[i],然後將 file descriptor 傳入 cat

#### system call flow

有一個很有趣的問題,是 user program 呼叫 system call open(),但是 kernel code 只有找到 sys_open,中間是發生什麼事情?

首先,open 不是一個真正的 function,它是由 usys.pl 產生的一段 assembly

```
.global open
open:
    li a7, SYS_open   # 把系統呼叫編號 15 放進 a7 暫存器
    ecall             # 觸發 trap 進入 kernel
    ret               # 回到 cat,回傳值已經在 a0
```

參數的傳遞方式: 就是依照 RISC-V calling convention,進到 open 的時候 path 在 a0,mode 在 a1
a7 是系統呼叫編號,kernel 會依據此數值來查表

ecall 完會跳轉到 stvec 暫存器的 address,也就是 uservec,這邊的 value 是上次從 kernel 切換到 user 的時候、在 prepare_return() 裡用 w_stvec(uservec) 設定的

進入 uservec,也就是 assembly,會把暫存器(除了 x0/zero 共 31 個)都存進 trapframe,最後呼叫 C function usertrap
其中 a0 比較特別,不是直接存:會先 `csrw sscratch, a0` 把它暫存到 sscratch,因為需要用 a0 載入 TRAPFRAME 位址當基底,最後才把 sscratch(原本的 a0)寫回 trapframe

usertrap 裡頭會判斷是不是 system call,然後就跳進去 syscall()

syscalls 是個 function pointer array,最後進入 sys_open

做完 system call 會把 return value 放到 p->trapframe->a0

這時候就會回到 usertrap() 繼續執行 prepare_return()

prepare_return() 會先把 interrupt disable,接著用 w_stvec 把 stvec 設回 uservec(下次 ecall 的入口),這個上面有提過

會設定 trapframe values

接著把 sstatus 讀出來,privilege mode bit 改成 user mode,也把 interrupt bit 打開

接著把這個值寫回 sstatus,接著設定 sepc,把 p->trapframe->epc 寫進去

當初在 uservec 是使用 jalr 跳進去 usertrap,所以 usertrap 做完就會回到 uservec 的最後,asm 往下繼續執行就會碰到 userret
(另外 usertrap 的 return value 是 user 頁表的 satp,會透過 a0 傳給 userret 用)

這裡做的事情是:先用 usertrap 回傳的 satp 換回 user page table(csrw satp, a0),再把 trapframe 存的暫存器都 restore 回來,最後執行 sret,剛好跟去程 uservec「換 kernel 頁表 + 存暫存器」對稱

要特別注意 a0 是最後才 restore 的(因為前面一直用 a0 當 TRAPFRAME 的基底位址),而還原進 a0 的值,正是前面 sys_open 回傳、被存進 trapframe->a0 的那個 fd
所以 fd 一路藏在 trapframe->a0,到這裡才被載回真正的 a0 暫存器

sret 跳轉回到 ecall 結束的地方,下一步的 ret 就會依 calling convention 從 a0 把 fd 交回 cat 的 open()

#### sys_open()

sys_open 取得 file name 和 open mode 的方式是使用 argint 和 argstr function

內部都會有 argraw,會從 process 的 trapframe 取值,因為 uservec 已經把暫存器的值存進 trapframe,這時候就取出來用

進入 open 實際處理的功能以前會有 begin_op(),結束會有 end_op(),這是檔案系統的 logging / transaction,保證一組磁碟寫入的原子性(當機也不會只做一半),對應 kernel/log.c,細節等以後 trace 後再補充

之後會判斷是不是 O_CREATE,因為 trace 的是 O_RDONLY,所以就進去 namei(path)

然後會發現 access inode 之前,都要做 ilock()。要注意結束時分兩種情況:
- 成功路徑用的是 iunlock(),只解鎖但保留 inode 的引用,因為引用被接下來的 f->ip 接手持有,要等以後 close(fd) → fileclose 才會真正 iput 釋放
- 錯誤路徑才用 iunlockput()(= iunlock + iput,解鎖並釋放引用)
ilock/iput 的細節等以後 trace 後再補充

接著會進行 filealloc(),在 ftable 中找到一個可用的 (ref==0),找到後會馬上設 f->ref = 1 才 release 鎖(避免競爭),然後 return

ftable 的用意也是以後探討,access ftable 的時候要進行 acquire(),結束要 release(),可以猜測這是希望做到 atomic 的行為

如果 filealloc() 成功,接下來就會進行 fdalloc,這個就是在 myproc()->ofile(也就是 p->ofile,per-process 的 array)中找到最小可用的 file descriptor index return

如果 fdalloc() 成功,就會往下檢查 file type,以此設定 ftable entry 的 type,以及其 read/write 屬性,以及指向的 inode,最後 return file descriptor