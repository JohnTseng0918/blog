---
title: "Hash Table 雜湊表"
date: 2026-09-08
draft: false
description: "以雜湊表解題,含 1、217、242、347"
tags: ["leetcode", "hash-table"]
categories: ["演算法"]
---

## map 和 unordered_map 的差別

- 這兩個名字很像，但底層完全不同，複雜度也不一樣，set和unordered_set同理
    - std::map / std::set 是紅黑樹，key是有序的，查詢和插入都是O(log n)
    - std::unordered_map / std::unordered_set 是雜湊表，key無序，查詢和插入平均是O(1)，worst case是O(n)
- 這篇講「hash map」的時候指的都是unordered_map，所有複雜度也是照它算的
- 這類題目幾乎都不需要key有序，所以預設就選unordered版本
    - 挑錯容器不會寫錯答案，但會讓原本O(n)的解法變成O(n log n)
- 不過有一點反過來對紅黑樹有利: std::map的O(log n)是保證，任何輸入都打不壞
    - unordered版本的O(1)是平均，代價是存在退化成O(n)的可能
    - 這是除了需要key有序之外，唯一會想選紅黑樹的理由，一般題目遇不到

## 1. Two Sum

- 這題是給定一個array和一個target，要找出array中相加等於target的兩個數字，回傳它們的index，題目保證有解
- 暴力法用兩層迴圈可以解開，但時間複雜度是O(n^2)
- 改用unordered_map只需要一個迴圈，map記錄的是(key, value) = (target - nums[i], index)
- 每次迴圈先檢查nums[i]有沒有在map裡面
    - 有的話就代表之前某個數字的補數正好是nums[i]，該筆的index和i就是答案
    - 沒有的話就把(target - nums[i], i)放進map，繼續往下找
- time complexity: O(n)
    - unordered_map的查詢時間平均起來是常數時間

## 217. Contains Duplicate

- 這題是輸入一個沒有排序的array，回傳裡面是否有重複值
- 第一個想法:
    - for迴圈看每一個element，如果在unordered_set裡面看過，就回傳true
    - 否則把它放進unordered_set裡面
    - 迴圈結束後回傳false
    - 這裡只需要判斷「看過沒有」，不需要存value，所以選unordered_set
        - 用unordered_map也是平均O(n)，但每個節點多存一個用不到的value，記憶體和常數項都略差
        - 用std::set就真的比較糟，紅黑樹插入O(log n)，整體變成O(n log n)
    - 時間複雜度平均是O(n)，worst case因為hash碰撞會退化成O(n^2)
        - 退化的情況是「全部都不重複但hash到同一個bucket」，這時提早return一次都不會觸發
        - 迴圈跑滿n次，第i次查詢要走完長度i的鏈才能確定沒看過，加起來是O(n^2)
        - 實務上要湊出全碰撞需要對抗性的輸入，一般測資就是O(n)
- 第二個想法:
    - 先排序，然後用for迴圈檢查前後兩個element的value是否相同
    - 時間複雜度是O(n log n)，主要是因為sort的關係
    - 它的好處是額外空間只要O(1)，代價是會改動到輸入的array
- 第三個想法:
    - 把vector丟進set裡面，再判斷兩者的size是不是一樣，不一樣就代表有重複
    - 這裡就是前言講的容器選擇問題
        - 用std::set的話n次插入各O(log n)，整體是O(n log n)，跟第二個想法一樣沒佔到便宜
        - 要平均O(n)的話得用unordered_set

## 242. Valid Anagram

- 這題是輸入兩個字串，判斷兩者是否為「字母異序詞」
- 基本想法就是用一個unordered_map去記錄字母個數
- 先把第一個字串掃過一遍記錄起來，再掃第二個字串，這次改用扣的
    - 發現有負數就return false
- 如果兩個字串長度不同，就必定不是異序詞，一開頭直接回傳false即可

## 347. Top K Frequent Elements

- 這題是給定一個array，回傳出現頻率最高的K個數字
- 不管用哪個解法，都要先用一個unordered_map把每個數字的頻率記錄起來
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
        - 但這個O(n)的前提是建map用unordered_map，換成std::map就變成O(n log m)，線性就沒了
