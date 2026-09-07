---
title: "Hash Table 雜湊表"
date: 2026-09-08
draft: false
description: "以雜湊表解題,含 Two Sum、Contains Duplicate、Valid Anagram"
tags: ["leetcode", "hash-table"]
categories: ["演算法"]
---

## 1. Two Sum

- 給定array，以及一個target，要找出array中兩數字相加等於target，保證有解，回傳兩數字的index
- 這題暴力法的兩層迴圈可以解開，但時間複雜度很高
- 可以使用hash來解這題，一個迴圈，每次把target-nums[i]放進hash map中
- 每個迴圈的開始都檢查該數字有沒有在hash map中，有就代表找到解
- hash map: (key, value): (target-nums[i], index)
- time complexity: O(n)
  - hash map 的查詢時間平均起來是常數時間

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

- 輸入兩個字串，判斷兩者是否是「字母異序詞」
- 基本想法就是用一個map去紀錄字母個數
- 先把一個字串掃過一遍紀錄起來，第二個字母掃過，然後用扣的
    - 發現有負數就return false
- ~~這問題要綁定第一個字串比第二個字串長，所以function一開頭要判斷長度~~
    - 更新，如果不同長度就直接return false
    - 但是如果沒判斷，就有機會是「ab」「a」被這樣的測資搞爆
