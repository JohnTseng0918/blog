---
title: "Operating system interfaces"
date: 2026-06-19T17:49:49+08:00
draft: false
description: "MIT 6.S081 / xv6-riscv Operating system interfaces"
tags: ["xv6", "riscv", "kernel"]
categories: ["作業系統"]
---

## Operating system interfaces

- OS Job:
  - 讓多個 program 可以共享電腦
  - provide service
- OS 要將 low-level hardware 抽象化
- OS 會透過 interface 提供服務給 user programs
  - 設計一個好的 interface 是困難的
    - 希望 interface 簡單易實作
    - 希望提供較複雜的 feature 給應用程式
    - 解法:設計依賴少數幾種機制的介面,這些機制可以組合起來提供很強的通用性
- Unix 提供了一個簡潔的 interface,其機制組合良好,又有高通用性
  - 這個 interface 非常成功,以至於 Modern OS 都擁有 Unix-like interfaces
  - xv6 是理解 Modern OS 的好起點
- kernel:
  - A special program that provides services to running programs.
  - 執行中的 program,稱之為 **process**
    - 它的記憶體包含:instructions, data, and a stack
    - instruction: program's computation
    - data: variables on which the computation acts
    - stack: organizes the program's procedure calls
  - 一台電腦通常會同時擁有許多 process,但只會有一個 kernel
- System call:
  - process 需要請求 kernel 的服務,就要透過呼叫 system call
  - 呼叫 system call 會進入 kernel,kernel 執行服務後會 return
  - process 會在 user space 和 kernel space 來回轉換
- kernel 利用 CPU 提供的硬體保護機制,確保在 user space 執行的每個 process 只能存取自己的記憶體。
- kernel 會以 hardware privilege 執行這些保護機制
  - user program 則不具備這些 privilege
  - 當 user program 呼叫 system call,hardware 會提升 privilege level,並執行 kernel 中預先設定的 function。

## Processes and memory

- 一個 xv6 process 由 user space 中的記憶體(包含 instruction, data, and stack)以及屬於該 process、只有 kernel 能存取的 state 所構成
- xv6 使用 time-sharing 機制
  - 它會在多個等待執行的 process 之間,切換可用的 CPU
  - 當某個 process 未執行時,xv6 會保存該 process 的 CPU register,並在下次執行該 process 時恢復這些 register。
  - kernel 會為每個 process 分配一個編號:process identifier, or PID

### System call introduction

#### fork
- fork 會為新產生的 child process 建立一份與 parent process 一模一樣的 memory copy,這包含了 parent process 的 instructions, data, stack
- return value:
  - Original process: return the new process's PID
  - New process: return zero
- The original and new processes 通常被稱為 parent and child。

#### exit
- exit 使呼叫的 process 停止執行並且釋放資源:
  - 例如釋放記憶體,或是開啟的檔案(open files)等資源
- return value:
  - conventionally 0 代表成功
  - 1 代表失敗

#### wait
- return 該 process 中已經離開或被殺掉的 child process 的 PID,並且 copy exit status 給傳入 wait 的 address
- 如果沒有 child process 已經 exit,就會等到有 child exit
- 如果沒有 children,wait 會 return -1
- 如果 parent 不在乎 child process 的 exit status,可以傳入位址 0 給 wait
- 儘管 child process 和 parent process 有一樣的記憶體內容,但它們在各自獨立的記憶體和 register 上執行
  - 所以改變 variable 內容是不會影響到彼此的

#### exec
- exec 會從檔案系統中的 file 載入 memory image 取代 calling process's memory
  - 這個 file 通常有特定格式
    - 會定義哪些區塊是 instruction,哪些是 data,還有從哪一個 instruction 開始執行
    - xv6 使用 ELF
    - 通常這個 file 就是從 program's source code compile 的結果
- exec 成功,它不會回到呼叫它的 process
  - 會從 ELF 的 entry point 開始執行
- exec 有兩個參數,一個是 executable name,另一個是 array of strings
- 多數程式會忽略 argv 陣列的第一個元素,它慣例上是程式名稱

#### read
- read(fd, buf, n)
  - fd: file descriptor
  - copy file 資料到 buf
  - 最多 n bytes
  - return 讀到的 bytes 數
- 每個 file descriptor 都有一個 offset,每次 read 都會從目前的 file offset 開始讀,read 完會把 offset 加上實際讀到的 byte 數,下次 read 就會從新的 offset 繼續讀
  - 沒有 byte 可以讀的就會 return 0,代表已到 end of the file

#### write
- write(fd, buf, n)
  - fd: file descriptor
  - copy buf 資料到 file
  - copy n bytes
  - return 寫的 bytes 數
- return 少於 n 就代表有 error 發生
- 就像是 read,write 也會從 current file offset 開始寫,write 之後 offset 也會加上實際寫入的 byte 數,每次 write 都從上次結束的地方繼續寫

#### close
- release a file descriptor
  - 使可以被之後的 open, pipe, dup 使用

#### open
- 有一系列參數可以控制 open 行為:
  - O_RDONLY (read), O_WRONLY (write), O_RDWR (read and write), O_CREATE (create file if not exist), O_TRUNC (truncate file to 0)
    - truncate 通常用於覆寫

#### dup
- duplicates an existing file descriptor
- return new one 指到同一個 I/O object
- shared offset

#### pipe
- create a new pipe
- 參數是一組 file descriptor
- 和 read 組合
  - 如果沒有 data,read 會等到 pipe 有資料被寫進來
  - 或是所有 file descriptor 都 closed
  - read 會一直 block 到確定沒有新資料進來
  - 這就是為什麼如果有 fork,需要先把 file descriptor 關閉的原因,不然就會看不到 end-of-file

## I/O and File descriptors
- file descriptor 是一個 small integer,代表的是 process 可以讀或是可以寫的一個 kernel 管理的物件
- Process 可以透過 open a file, directory, device 或是 create a pipe,又或者是 duplicate an existing descriptor 來獲得 file descriptor
- file descriptor interface 將這些不同的 file, pipe, device 都抽象化,讓它們看起來都是 streams of bytes
  - input, output: I/O
  - file: the object a file descriptor refers to
- By convention, file descriptor:
  - 0: standard input
  - 1: standard output
  - 2: standard error
- 新 alloc 的 file descriptor 都從該 process 最小且沒有使用的編號開始
- File descriptor 和 fork 就會讓 I/O redirection 變得很好實作
  - fork copy parent file descriptor table
  - child 就可以從同一個 file 開始
  - exec 可以把 memory 取代掉,但卻保留 file table
- 所以 fork and exec 之所以要分開實作,就是保留 I/O redirection 的彈性
- 儘管 fork 會 copy file descriptor,但是 file descriptor 的 offset 是共享的
  - 這樣才能做 sequential output
- 透過 fork 或是 dup,從同一個 file descriptor 生成的會共享 offset,其他的 file descriptor 不會,即使它們是對同一個 file 使用 open
```
ls existing-file non-existing-file > tmp1 2>&1
```
- 2>&1 的意思是要把 file descriptor 2 輸出的位置導到 file descriptor 1,也就是會一起寫到同個地方
  - xv6 沒有實作 error message 的 I/O redirection,但這樣應該也知道要怎麼實作了

## Pipes
- pipe 是 kernel 管理的一塊小 buffer,以 pair 的形式將 file descriptor 暴露給 process
  - 1 for reading
  - 1 for writing
  - 把資料寫到 pipe 的一端,可以讓資料從 pipe 的另一端讀出來
  - pipe 提供了一種方式讓 process 之間可以 communicate
- xv6 shell 有實作 pipe:
```
 grep fork sh.c | wc -l 
```
- pipe 看起來和暫存檔作法沒有差別
```
echo hello world | wc
echo hello world >/tmp/xyz; wc </tmp/xyz
```
- pipe 其實至少有三個優勢
  - pipe 會自動清除暫存檔
  - pipe 可以傳遞任意長度的 data stream
    - file redirection 方式需要系統上有足夠的硬碟空間
  - pipe 允許 pipeline parallel execution,file redirection 方式則不行

## File system
- xv6 file system 提供了
  - data files: uninterpreted byte arrays
  - directories: 其中包含了 data files 和其他的 directories
- directories 會形成一個 tree,開始的地方叫做 root
  - path: /a/b/c 表示 file or directory c 在 b 資料夾裡面,b 資料夾在 a 資料夾裡面,而 a 在 root 資料夾裡面
  - path 不是從 root 開始,就是相對於目前這個 calling process 的 current directory
- 可以用 system call chdir 來改變路徑
- mkdir: create a new directory
- open 使用 O_CREATE 就可以 create a new file
- mknod: create a new device file
  - 參數會有 major and minor device number
  - 如果 process open device file,會使用 kernel device 實作的 read/write,而不是 kernel 的 read/write system call
- file name 和 file 本身是不同的
  - 底層同樣的 file,稱之為 inode,可以有不同的 name,稱之為 links
  - 每個 link 對應著 directory 底下的一個 entry
  - entry 包含著 file name and a reference to an inode
- inode 有著 file 的 metadata
  - type (file or directory or device)
  - length
  - location of the file
  - number of links
- inode 由 unique inode number 識別
- fstat system call 可以取得 inode information,然後把資料裝到 struct stat
- link system call 可以對一個現存的 file create another file system name
  - 使用之後 struct stat 的 nlink 會 ++
- unlink system call 就是移除 file system 中的一個 name
  - 如果沒有 link,那該 inode 的內容就會被 free
- Unix 提供了一些從 shell 呼叫的 user level program,例如 ln, rm, mkdir,只有 cd 是例外,它實作在 shell 裡面,因為如果由 child 改變資料夾,並不會影響到 parent