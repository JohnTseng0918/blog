---
title: "Hash Table 雜湊表"
date: 2026-09-08
draft: false
description: "以雜湊表解題,含 1、217、242、347"
tags: ["leetcode", "hash-table"]
categories: ["演算法"]
---

## 1. Two Sum

- 這題是給定一個array和一個target，要找出array中相加等於target的兩個數字，回傳它們的index，題目保證有解
- 暴力法用兩層迴圈可以解開，但時間複雜度是O(n^2)
- 改用hash map只需要一個迴圈，map記錄的是(key, value) = (target - nums[i], index)
- 每次迴圈先檢查nums[i]有沒有在map裡面
    - 有的話就代表之前某個數字的補數正好是nums[i]，該筆的index和i就是答案
    - 沒有的話就把(target - nums[i], i)放進map，繼續往下找
- time complexity: O(n)
    - hash map的查詢時間平均起來是常數時間

## 217. Contains Duplicate

- 這題是輸入一個沒有排序的array，回傳裡面是否有重複值
- 第一個想法:
    - for迴圈看每一個element，如果在map裡面看過，就回傳true
    - 否則把它放進map裡面
    - 迴圈結束後回傳false
- 第二個想法:
    - 先排序，然後用for迴圈檢查前後兩個element的value是否相同
- 第三個想法:
    - 把vector丟進set裡面，再判斷兩者的size是不是一樣

## 242. Valid Anagram

- 這題是輸入兩個字串，判斷兩者是否為「字母異序詞」
- 基本想法就是用一個map去記錄字母個數
- 先把第一個字串掃過一遍記錄起來，再掃第二個字串，這次改用扣的
    - 發現有負數就return false
- 如果兩個字串長度不同，就必定不是異序詞，一開頭直接回傳false即可

## 347. Top K Frequent Elements

- 這題是給定一個array，回傳出現頻率最高的K個數字
- 不管用哪個解法，都要先用一個map把每個數字的頻率記錄起來
- 最簡單的解法是使用priority queue
    - 把map的每個key value pair放到priority queue裡面
    - 困難點是要知道C++的priority queue怎麼寫
    - 最後從priority queue取出K個item就是答案
    - time complexity: O(n + m log m)，m是不同數字的個數
        - 掃array建map是O(n)，m個pair進priority queue是O(m log m)，取K個是O(K log m)
        - 最差的情況每個數字都不一樣，m = n，就變成O(n log n)
- 另一個解法是使用bucket sort
    - 因為array總共就nums.size()個數字，所以任何數字的頻率最大也就是nums.size()
    - 宣告一個大小為nums.size() + 1的vector，用頻率當index
    - vector的內容也是個vector，裝的是頻率等於該index的數字
    - 把map掃過一遍，將每個數字填進「以它的頻率為index」的那一格
    - 最後從vector的尾端往回走，收集到K個數字就是答案
    - time complexity: O(n)
        - 建map、填bucket、掃bucket都是線性，省掉了排序的log
