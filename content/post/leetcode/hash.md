---
title: "Hash Table 雜湊表"
date: 2026-08-15
draft: false
description: "以雜湊表解題,含 Contains Duplicate、Valid Anagram"
tags: ["leetcode", "hash-table"]
categories: ["演算法"]
---

## 217. Contains Duplicate

- 輸入一個array進來，無排序，回傳是否有重複值
- 第一個想法:
    - for迴圈看每一個element，如果在map有看過，回傳true
    - 否則放進map裡面
    - 最後回傳false
- 第二個想法:
    - 排序，然後for迴圈查看是否前後element value相同
- 第三個想法:
    - 把vector丟進去set裡面，判斷兩個size是不是一樣

## 242. Valid Anagram

- 輸入兩個字串，判斷兩者是否是”字母異序詞”
- 基本想法就是用一個map去紀錄字母個數
- 先把一個字串掃過一遍紀錄起來，第二個字母掃過，然後用扣的
    - 發現有負數就return false
- ~~這問題要綁定第一個字串比第二個字串長，所以function一開頭要判斷長度~~
    - 更新，如果不同長度就直接return false
    - 但是如果沒判斷，就有機會是”ab” “a”被這樣的測資搞爆