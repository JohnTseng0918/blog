---
title: "RISC-V CLIC (Core-Local Interrupt Controller)"
date: 2026-10-03
draft: false
description: "CLIC 規格閱讀筆記"
tags: ["riscv", "clic", "interrupt"]
categories: ["riscv"]
---

## CLIC

> The Core-Local Interrupt Controller (CLIC) Privileged Architecture Extensions are designed to provide low-latency, vectored, pre-emptive interrupts for RISC-V systems. When activated the CLIC subsumes and replaces the original RISC-V basic local interrupt scheme (known as the CLINT in this document). The CLIC has a base design that requires minimal hardware, but supports additional extensions to provide hardware acceleration. The goal of the CLIC is to provide support for a variety of software ABI and interrupt models, without complex hardware that can impact high-performance implementations.

- CLIC 目標是low-latency, vectored, pre-emptive的中斷處理機制
- 啟用CLIC後，會接管並取代RISC-V 基本的local中斷系統 (CLINT)
  - exception 的行為不會改變
- CLIC的基礎設計只需要很小的硬體資源，有保留擴充去提供硬體加速

> The CLIC also supports a Selective Hardware Vectoring extension that allow users to optimize each interrupt for either faster response or smaller code size.

- 支援 Selective Hardware Vectoring 擴充，每個interrupt可以各自選擇要更快的回應還是更小的code size

### CLINT
- xie, xip
- CLINT mode: `xtvec.mode` = `00` (direct) 或 `01` (vectored)
- CLIC mode: `xtvec.mode` = `11` 且 `xtvec.submode` = `0000`

### CLIC compared to CLINT
- wip

### CLIC compared to PLIC
- wip

### CLIC compared to Advanced Interrupt Architecture
- wip

## Overview

- CLIC supports up to 4096 interrupt inputs per hart.
- 每個interrupt input i 有4個control registers
  - interrupt-pending bit (`clicintip[i]`)
  - interrupt-enable bit (`clicintie[i]`)
  - interrupt attribute (`clicintattr[i]`): privilege mode, trigger type
  - interrupt control bits (`clicintctl[i]`, 8-bit): level and priority
- 如果要和CLINT mode相容，前16個interrupt input 保留給CLINT mode interrupt (對應 `xip`/`xie` 的低16 bits，保留原本的cause值)，剩下4080個是用來擴充的

### interrupt preemption
- CLIC 對每個privilege mode 支援256個interrupt level
  - 數字大的interrupt level可以搶數字比較小的interrupt level
  - Level 0 代表是一般程式執行
  - Level 1 - 255 對應的是interrupt handler level
  - 要配置多少個level是平台決定的
- 同個privilege底下，high interrupt level 可以搶奪 active low interrupt level
  - 前提是這個privilege mode的global interrupt enable (`xstatus.xie`) 有開
- 沿用原本RISC-V的行為：higher privilege mode interrupt 可以搶奪 lower privilege mode interrupt
  - 不管lower privilege mode的 `xstatus.xie` 有沒有開
- level 和 priority 的差別 (§3.1.2)
  - level 決定能不能搶占 (preemption)
  - priority 不影響搶占，只是同一個level有多個pending interrupt時的tie-breaker
  - privilege mode, level, priority 都一樣時，編號大的interrupt先處理 (跟CLINT一樣，跟PLIC相反)

### CLIC interaction with other local interrupts
- CLIC 會把basic local interrupt整合進來
  - 原本在 `xip`/`xie` bits 16 以上的local interrupt 就不再可見 (§2.2)
  - 在CLIC mode 下整個 `mie`/`mip` 讀起來都是0，寫入會被忽略 (§3.8.3)
- timer, software, external interrupt 都會被當作additional local interrupt source
  - privilege mode, interrupt level, priority 就會被描述在 `clicintattr[i]`, `clicintctl[i]` 這些register裡
  - delegation 不再由 `mideleg` 控制，改由 `clicintattr[i].mode` 決定interrupt在哪個privilege mode處理

### CLIC extension summary
- smclic: clic support for m-mode
- ssclic: clic support for s-mode
- smclicshv: selective hardware vectoring for m-mode
- smclicconfig: allows implementations to support different parameterizations of CLIC extensions
