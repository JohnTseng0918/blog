---
title: "Sliding Window 滑動視窗"
date: 2026-08-15
lastmod: 2026-10-23
draft: false
description: "滑動視窗解連續子陣列/子字串,含 Longest Substring、Reduce X to Zero"
tags: ["leetcode", "sliding-window", "two-pointers"]
categories: ["演算法"]
---

## 3. Longest Substring Without Repeating Characters

- 給定一個字串，找出最長的子字串長度，並且子字串沒有重複的字元，回傳子字串長度
- 這題的思維是，應該會需要一個 for 迴圈從左掃到右，並且與此同時，也要把左邊的 index 記錄起來
    - 這樣右-左+1 就是一個沒有重複的子字串
- 所以需要一個 map 去記錄遇到的字元，它最後出現的位置
- 每一次掃過去的時候，先檢查 map，沒有查找到就是沒有 repeat
    - 如果有找到，就要把左邊 index 移到該字串上一次出現的位置的右邊一個

## 1658. Minimum Operations to Reduce X to Zero

- 給定一個 `vector<int>`，以及一個 x，可以從最左邊或最右邊選擇數字來做減法，使 X 等於 0
- 找出最少要選出幾個元素
- 這題有兩種解，可以用 sliding window，也可以使用 prefix sum，這裡使用 sliding window 來解
- 一樣想法是把題目換一個角度看，就是找出最大的 subarray 總和是 sum - x
- 用兩個 index 指標，left and right，先令 left = 0
- right 放在 for loop 裡面 iterate，每次都先把 nums[right]加到暫時的總和裡面
- 然後判斷這個暫時總和有沒有超過 sum - x
- 超過就用一個 for loop 去判斷，每次右移一個 left，新的總和是多少
- 然後判斷一下暫時總和有沒有相等 sum - x，有的話就取一下 max