---
title: "Two Pointers 雙指標"
date: 2026-09-08
draft: false
description: "雙指標/對撞指標解題,含 Container With Most Water、3Sum、Remove Duplicates、Valid Palindrome"
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

## 26. Remove Duplicates from Sorted Array

- 給定一個array，這是非嚴格遞增的array，要把重複的元素移除，最後回傳有k個不同的元素，並且這題需要in-place操作
- 這題用two-pointer角度出發解題最美，想像一個指標指著已經整理好的array，另一個隨著迴圈，掃過所有數字
- 我們先需要一個左指標記錄index，然後迴圈內部，直接比較nums[i]和nums[left_index]有沒有相同，當然我們不能比較同個index，所以迴圈要從第二個開始
- 如果nums[i]和nums[left_index]相同，那就是沒事，然後i就會往前一格
- 如果nums[i]和nums[left_index]不同，就要把nums[left_index] = nums[i]，然後left_index++，這樣就達到了把不同的元素放到array前面的作法
- 最後回傳left_index + 1，因為這個指標是指著result array的尾巴，然後0-index，所以會少1
- 時間複雜度 O(n)，很單純就是一個迴圈
- 進階題: 80

## 42. Trapping Rain Water

- 給定一個vector<int>，代表的意義是牆壁高度，目標是要回傳可以裝多少水
- 例如[3,0,1]就代表可以裝1的水
- 這題可以用兩個指標來解，先記錄左邊高，和右邊高
- 使用一個while loop，如果左右index還沒碰在一起，就執行
- 如果現在這個位置的高度，比左高低，那答案就可以加上兩個的差
- 如果比左高高，那就可以更新新的左高到現在的位置
- 右高亦然
- 然後每次判斷左高和右高誰高，就移動低的那個index

## 80. Remove Duplicates from Sorted Array II

- 這題和26相似，差別就是可以允許有兩個相同元素，多的都要移除
- 兩個pointer思維是相近的，一個是整理好的array的下一個index，另一個就是迴圈index
- 注意left_index和迴圈index都要從2開始，所以開頭要先判斷，如果array長度小於等於2就直接回傳長度，不然nums[left_index - 2]會存取越界
- 同樣是一個迴圈，只是裡面的判斷不同，是判斷nums[i]和nums[left_index - 2]
- 如果nums[i]和nums[left_index - 2]相同，代表nums[i]和nums[left_index - 1]也相同，這樣就會有三個同樣元素了，所以這情況下，就不能把nums[i]取進去，不做事讓i自然++
- 如果nums[i]和nums[left_index - 2]不同，就代表可能有一個nums[i]這個元素，或者是兩個，這樣合法
- 最後回傳left_index，因為一開始的指標就是指向整理好的array的下一個index
- 時間複雜度 O(n)，很單純就是一個迴圈

## 125. Valid Palindrome

- 這題目標就是判斷一個字串扣除空白及符號後是否回文，並且忽略大小寫
- 首先要先知道幾個function
    - isalnum: 這是用來知道是否是字母或是數字
    - tolower: 這是轉成小寫
- 想法其實很簡單，使用左右指標，指向字串頭和字串尾
- 使用while迴圈判斷是否左<右
    - 如果不是字母數字就移動並且continue
    - 如果不一樣就return false
    - 一樣就left++, right--
