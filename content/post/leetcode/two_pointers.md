---
title: "Two Pointers 雙指標"
date: 2026-08-15
draft: false
description: "雙指標/對撞指標解題,含 Container With Most Water、3Sum、Valid Palindrome"
tags: ["leetcode", "two-pointers"]
categories: ["演算法"]
---

## 11. Container With Most Water

- 給定一個array，value是高度的意思，找出兩個包起來可以裝最多水的
- 這題的想法很簡單，就是2個pointer指到最左和最右，計算並比較水量
- 直接使用greedy方式，比較左右的高度，誰比較矮就移動一個

## 15. 3Sum

- 給定一個array，找出三個元素相加等於0，並且答案不能有重複
- 這題如果不排序，就只能暴力搜尋，所以要先排序過
- 排序之後，就使用一個for loop，到了特定的index後，[index + 1, last]，就可以用2 pointer的手法來找出兩者相加等於0-nums[i]
- 這題比較麻煩的事情是不能重複，所以第一個for，就要和array前位比較，相同就continue
- 2 pointer的時候也是，如果找到正解，位移一個也是需要比較有沒有相同，相同就有可能重複

## 42. Trapping Rain Water

- 給定一個vector<int>，代表的意義是牆壁高度，目標是要回傳可以裝多少水
- 例如[3,0,1]就代表可以裝1的水
- 這題可以用兩個指標來解，先記錄左邊高，和右邊高
- 使用一個while loop，如果左右index還沒碰在一起，就執行
- 如果現在這個位置的高度，比左高低，那答案就可以加上兩個的差
- 如果比左高高，那就可以更新新的左高到現在的位置
- 右高亦然
- 然後每次判斷左高和右高誰高，就移動低的那個index

## 125. Valid Palindrome

- 這題目標就是判斷一個字串扣除空白及符號後是否回文，並且忽略大小寫
- 首先要先知道幾個function
    - isalnum: 這是用來知道是否是字母或是數字
    - tolower: 這是轉成小寫
- 想法其實很簡單，使用左右指標，指向字串頭和字串尾
- 使用while迴圈判斷使否左<右
    - 如果不是字母數字就移動並且continue
    - 如果不一樣就return false
    - 一樣就left++, right—