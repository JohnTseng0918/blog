---
title: "Bit Manipulation 位元運算"
date: 2026-08-15
draft: false
description: "位元運算技巧,含 Reverse Bits、Number of 1 Bits、Missing Number 等"
tags: ["leetcode", "bit-manipulation"]
categories: ["演算法"]
---

## 190. Reverse Bits

- Input是一個32bit int，return 頭尾反轉的32bit int
- 想法很簡單，就是先宣告一個return_val = 0
- input n & 1 == 1 → return_val | = 1
- 然後 n = n >> 1，下一輪return_val = return_val << 1;
- 就會得到:
    - return_val = return_val << 1;
    - return_val |= (n&1)
    - n = n >> 1
- 第一行要先位移，是因為第一輪左移沒差，0還是0，但下一輪開始會需要先空出空間來放

## 191. Number of 1 Bits

- 這題要回傳int中用二進位表示法有多少個1
- 使用到的技巧是n = n & (n - 1)
    - 想像n-1就是把n最小的1刪掉，然後往右放成一堆11111….
    - 兩者and完後，就是刪掉一個1
    - 0110 0100 → n
    - 0110 0011 → n - 1
    - 0110 0000 → new n
    - 這樣就可以知道有多少個1了

## 268. Missing Number

- 給定一個array，找出[0, n]中少的那個數字
- 例如[3,0,1] → 2
- XOR solution:
    - 利用兩個相同數字XOR，會變成0的特色
    - 所以0~n都要XOR過
    - array也要XOR過，這樣就會得到答案
- 數學解:
    - n (n + 1) / 2就是總和
    - 然後for迴圈也可以得到總和，相減就是答案

## 371. Sum of Two Integers

- 這題要做事情是兩個int不使用+來做加法
- 用bit的觀點來看 0, 0 → 0
- 0, 1 → 1
- 1, 0→ 1
- 1, 1→1
- 所以是使用exclusive or來做，但是還有carry要處理
- carry只有在兩者都是1才有carry
- 所以一開始就先做and存到carry並左移
- 然後做XOR
- 直到沒有任何的carry即完成