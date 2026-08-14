---
title: "Backtracking 回溯法"
date: 2026-08-15
draft: false
description: "回溯法列舉所有組合/路徑,含 Combination Sum、Word Search"
tags: ["leetcode", "backtracking"]
categories: ["演算法"]
---

## 39. Combination Sum

- 這題是給定一個數字array，以及一個target，要回傳所有組合總和是target
- 要列出所有組合得很明顯就是backtracking的題目
- 所以先寫一個backtracking的function，參數除了原先的input以外，也要紀錄path，以及走到第幾個array index，還有數字總和
- 判斷基本上就是如果總和和target相同就加入result並return
- 超出target or index超出範圍也return
- Solution 1:
    - 加入path
    - backtracking同個index
    - pop path
    - backtracking下一個index
- Solution 2:
    - for loop
        - 加入path
        - backtracking i
        - pop path

## 79. Word Search

- 這題是給一個2D地圖，裡面有英文字母，並且給定一個英文單字，要找出地圖中是否有這個英文單字(必須相鄰，垂直相鄰或是水平相鄰)
- 這個就標準的backtracking題目
- 每一個點都要call一次backtracking function
- backtracking function的參數要有地圖，英文單字，座標，單字的index
    - 因為C++ string不容易取substring，因此使用index比較方便
    - function內部就先檢查座標不要出界，index不要超出單字長度
    - 還有字母和預期的單字[index]就 return false
    - 字母和單字的最後一個字(前面都檢查一樣了)相同就return true
    - function本體需要先把地圖的字母變成不存在的字元，避免重複被走過
    - 接下來就if ( backtring 1 || backtring 2 || backtring 3 || backtring 4) return true
    - 最後把地圖復原
    - 都沒有找到就return false