---
title: "Two Pointers 雙指標"
date: 2026-09-09
lastmod: 2026-10-23
draft: false
description: "雙指標/對撞指標解題,含 Container With Most Water、3Sum、Remove Duplicates、Valid Palindrome"
tags: ["leetcode", "two-pointers"]
categories: ["演算法"]
---

## 11. Container With Most Water

- 給定一個 array，value 是高度的意思，找出兩個包起來可以裝最多水的
- 這題的想法很簡單，就是 2 個 pointer 指到最左和最右，計算並比較水量
- 直接使用 greedy 方式，比較左右的高度，誰比較矮就移動一個

## 15. 3Sum

- 給定一個 array，找出三個元素相加等於 0，並且答案不能有重複
- 這題如果不排序，就只能暴力搜尋，所以要先排序過
- 排序之後，就使用一個 for loop，到了特定的 index 後，[index + 1, last]，就可以用 2 pointer 的手法來找出兩者相加等於 0-nums[i]
- 這題比較麻煩的事情是不能重複，所以第一個 for，就要和 array 前位比較，相同就 continue
- 2 pointer 的時候也是，如果找到正解，位移一個也是需要比較有沒有相同，相同就有可能重複

## 26. Remove Duplicates from Sorted Array

- 給定一個 array，這是非嚴格遞增的 array，要把重複的元素移除，最後回傳有 k 個不同的元素，並且這題需要 in-place 操作
- 這題用 two-pointer 角度出發解題最美，想像一個指標指著已經整理好的 array，另一個隨著迴圈，掃過所有數字
- 我們先需要一個左指標記錄 index，然後迴圈內部，直接比較 nums[i]和 nums[left_index]有沒有相同，當然我們不能比較同個 index，所以迴圈要從第二個開始
- 如果 nums[i]和 nums[left_index]相同，那就是沒事，然後 i 就會往前一格
- 如果 nums[i]和 nums[left_index]不同，就要把 nums[left_index] = nums[i]，然後 left_index++，這樣就達到了把不同的元素放到 array 前面的作法
- 最後回傳 left_index + 1，因為這個指標是指著 result array 的尾巴，然後 0-index，所以會少 1
- 時間複雜度 O(n)，很單純就是一個迴圈
- 進階題: 80

## 42. Trapping Rain Water

- 給定一個 `vector<int>`，代表的意義是牆壁高度，目標是要回傳可以裝多少水
- 例如[3,0,1]就代表可以裝 1 的水
- 這題可以用兩個指標來解，先記錄左邊高，和右邊高
- 使用一個 while loop，如果左右 index 還沒碰在一起，就執行
- 如果現在這個位置的高度，比左高低，那答案就可以加上兩個的差
- 如果比左高高，那就可以更新新的左高到現在的位置
- 右高亦然
- 然後每次判斷左高和右高誰高，就移動低的那個 index

## 80. Remove Duplicates from Sorted Array II

- 這題和 26 相似，差別就是可以允許有兩個相同元素，多的都要移除
- 兩個 pointer 思維是相近的，一個是整理好的 array 的下一個 index，另一個就是迴圈 index
- 注意 left_index 和迴圈 index 都要從 2 開始，所以開頭要先判斷，如果 array 長度小於等於 2 就直接回傳長度，不然 nums[left_index - 2]會存取越界
- 同樣是一個迴圈，只是裡面的判斷不同，是判斷 nums[i]和 nums[left_index - 2]
- 如果 nums[i]和 nums[left_index - 2]相同，代表 nums[i]和 nums[left_index - 1]也相同，這樣就會有三個同樣元素了，所以這情況下，就不能把 nums[i]取進去，不做事讓 i 自然++
- 如果 nums[i]和 nums[left_index - 2]不同，就代表可能有一個 nums[i]這個元素，或者是兩個，這樣合法
- 最後回傳 left_index，因為一開始的指標就是指向整理好的 array 的下一個 index
- 時間複雜度 O(n)，很單純就是一個迴圈

## 88. Merge Sorted Array

- 這題給定兩個已排序過非遞減的 array，然後要 merge 成一個 array，合併到 array1
- array1 後面已經預留了 array2 長度的空位，這是這題可以從後面往前填的前提
- 這類題目最簡單的想法就是 2-pointer，然後元素被選擇之後就會移動一格 pointer
- 思維被僵化住的話，就會想著要從第一個 element 開始:
  - 這樣有個問題，array1 如果要有元素放進來，就要全部搬動嗎?
  - 換個方向，如果 pointer 指向最後一個元素，大排到小
  - 那選到的最大的值，我就從 array1 的最後擺回來，就不會強碰原本 array1 的內容
- 使用一個迴圈，外層判斷我們使用 index2 >= 0
  - 理由是如果 index2 排完了，那剩下 array1 的東西當然也不用排
- 內層就是單純的比較元素大小，大的就放到 array1[index]的位置
- 每次迴圈都會放元素，所以每次 index 都會--
- 記得也要判斷 index1，不然 array 會越界
- 這題觀念簡單，但其實細節還滿多的，值得多想一下
- 時間複雜度是單純的 O(m + n)

## 125. Valid Palindrome

- 這題目標就是判斷一個字串扣除空白及符號後是否回文，並且忽略大小寫
- 首先要先知道幾個 function
    - isalnum: 這是用來知道是否是字母或是數字
    - tolower: 這是轉成小寫
- 想法其實很簡單，使用左右指標，指向字串頭和字串尾
- 使用 while 迴圈判斷是否左<右
    - 如果不是字母數字就移動並且 continue
    - 如果不一樣就 return false
    - 一樣就 left++, right--
