---
title: "Hash Table 雜湊表"
date: 2026-09-08
lastmod: 2026-10-23
draft: false
description: "以雜湊表解題,含 1、217、242、347"
tags: ["leetcode", "hash-table"]
categories: ["演算法"]
---

## map 和 unordered_map 的差別

- 這兩個名字很像，但底層完全不同，複雜度也不一樣，set 和 unordered_set 同理
    - std::map / std::set 是紅黑樹，key 是有序的，查詢和插入都是 O(log n)
    - std::unordered_map / std::unordered_set 是雜湊表，key 無序，查詢和插入平均是 O(1)，worst case 是 O(n)
- 這篇講「hash map」的時候指的都是 unordered_map，所有複雜度也是照它算的
- 這類題目幾乎都不需要 key 有序，所以預設就選 unordered 版本
    - 挑錯容器不會寫錯答案，但會讓原本 O(n)的解法變成 O(n log n)
- 不過有一點反過來對紅黑樹有利: std::map 的 O(log n)是保證，任何輸入都打不壞
    - unordered 版本的 O(1)是平均，代價是存在退化成 O(n)的可能
    - 這是除了需要 key 有序之外，唯一會想選紅黑樹的理由，一般題目遇不到

## 1. Two Sum

- 這題是給定一個 array 和一個 target，要找出 array 中相加等於 target 的兩個數字，回傳它們的 index，題目保證有解
- 暴力法用兩層迴圈可以解開，但時間複雜度是 O(n^2)
- 改用 unordered_map 只需要一個迴圈，map 記錄的是(key, value) = (target - nums[i], index)
- 每次迴圈先檢查 nums[i]有沒有在 map 裡面
    - 有的話就代表之前某個數字的補數正好是 nums[i]，該筆的 index 和 i 就是答案
    - 沒有的話就把(target - nums[i], i)放進 map，繼續往下找
- time complexity: O(n)
    - unordered_map 的查詢時間平均起來是常數時間

## 217. Contains Duplicate

- 這題是輸入一個沒有排序的 array，回傳裡面是否有重複值
- 第一個想法:
    - for 迴圈看每一個 element，如果在 unordered_set 裡面看過，就回傳 true
    - 否則把它放進 unordered_set 裡面
    - 迴圈結束後回傳 false
    - 這裡只需要判斷「看過沒有」，不需要存 value，所以選 unordered_set
        - 用 unordered_map 也是平均 O(n)，但每個節點多存一個用不到的 value，記憶體和常數項都略差
        - 用 std::set 就真的比較糟，紅黑樹插入 O(log n)，整體變成 O(n log n)
    - 時間複雜度平均是 O(n)，worst case 因為 hash 碰撞會退化成 O(n^2)
        - 退化的情況是「全部都不重複但 hash 到同一個 bucket」，這時提早 return 一次都不會觸發
        - 迴圈跑滿 n 次，第 i 次查詢要走完長度 i 的鏈才能確定沒看過，加起來是 O(n^2)
        - 實務上要湊出全碰撞需要對抗性的輸入，一般測資就是 O(n)
- 第二個想法:
    - 先排序，然後用 for 迴圈檢查前後兩個 element 的 value 是否相同
    - 時間複雜度是 O(n log n)，主要是因為 sort 的關係
    - 它的好處是額外空間只要 O(1)，代價是會改動到輸入的 array
- 第三個想法:
    - 把 vector 丟進 set 裡面，再判斷兩者的 size 是不是一樣，不一樣就代表有重複
    - 這裡就是前言講的容器選擇問題
        - 用 std::set 的話 n 次插入各 O(log n)，整體是 O(n log n)，跟第二個想法一樣沒佔到便宜
        - 要平均 O(n)的話得用 unordered_set

## 242. Valid Anagram

- 這題是輸入兩個字串，判斷兩者是否為「字母異序詞」
- 基本想法就是用一個 unordered_map 去記錄字母個數
- 先把第一個字串掃過一遍記錄起來，再掃第二個字串，這次改用扣的
    - 發現有負數就 return false
- 如果兩個字串長度不同，就必定不是異序詞，一開頭直接回傳 false 即可

## 347. Top K Frequent Elements

- 這題是給定一個 array，回傳出現頻率最高的 K 個數字
- 不管用哪個解法，都要先用一個 unordered_map 把每個數字的頻率記錄起來
- 最簡單的解法是使用 priority queue
    - 把 map 的每個 key value pair 放到 priority queue 裡面
    - 困難點是要知道 C++的 priority queue 怎麼寫
    - 最後從 priority queue 取出 K 個 item 就是答案
    - time complexity: O(n + m log m)，m 是不同數字的個數
        - 掃 array 建 map 是 O(n)，m 個 pair 進 priority queue 是 O(m log m)，取 K 個是 O(K log m)
        - 最差的情況每個數字都不一樣，m = n，就變成 O(n log n)
- 另一個解法是使用 bucket sort
    - 因為 array 總共就 nums.size()個數字，所以任何數字的頻率最大也就是 nums.size()
    - 宣告一個大小為 nums.size() + 1 的 vector，用頻率當 index
    - vector 的內容也是個 vector，裝的是頻率等於該 index 的數字
    - 把 map 掃過一遍，將每個數字填進「以它的頻率為 index」的那一格
    - 最後從 vector 的尾端往回走，收集到 K 個數字就是答案
    - time complexity: O(n)
        - 建 map、填 bucket、掃 bucket 都是線性，省掉了排序的 log
        - 但這個 O(n)的前提是建 map 用 unordered_map，換成 std::map 就變成 O(n log m)，線性就沒了
