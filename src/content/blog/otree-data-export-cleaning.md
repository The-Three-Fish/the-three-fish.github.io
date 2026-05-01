---
title: "oTree 数据导出与清洗：从后台 CSV 到 R、Python 和 Stata"
description: "介绍 oTree 数据导出的基本逻辑、变量命名、清洗步骤，以及如何为 R、Python 和 Stata 分析做准备。"
image: "/images/blog-4.jpg"
date: 2026-05-01T09:00:00Z
draft: false
categories: ["oTree 入门系列"]
tags: ["oTree", "入门", "数据导出"]
---

实验写完只是第一步，真正做研究还要把数据导出来分析。很多 oTree 初学者在这里会遇到两个问题：导出的列太多，不知道哪些能用；或者关键变量没有导出，回头才发现代码里没有存字段。

---

## 一、先理解 oTree 导出的数据

oTree 后台可以导出 session 数据。导出的 CSV 通常包含参与者信息、app、round、player 字段、group 字段等。

你在 `Player`、`Group`、`Subsession` 中定义的 `models.*Field()`，才会稳定进入数据表。

例如：

```python
class Player(BasePlayer):
    contribution = models.CurrencyField()
    treatment = models.StringField()
    age = models.IntegerField()
```

这些变量会比临时 Python 变量更适合后续分析。

---

## 二、写实验时就要想导出

不要等实验结束才想“我需要哪些变量”。建议开工前列一个分析变量表：

- participant code
- round number
- treatment
- group id
- role
- decision
- payoff
- reaction time 或 timeout
- demographic controls

只要统计分析需要，就应该存成字段。

---

## 三、变量命名要清楚

建议使用英文小写加下划线：

```python
risk_choice = models.IntegerField()
belief_estimate = models.FloatField()
treatment_group = models.StringField()
```

避免使用太短的名字，比如 `x`、`a1`。也不要频繁改变量名，否则旧数据和新数据很难合并。

---

## 四、清洗数据的基本步骤

拿到 CSV 后，通常先做这些事：

1. 删除测试 session 或 demo 数据。
2. 检查参与者是否完整完成实验。
3. 检查 treatment/control 人数。
4. 检查关键变量是否有缺失。
5. 检查每个参与者的轮数是否正确。
6. 生成分析需要的新变量。

不要直接把原始 CSV 改到看不出来源。更好的做法是保留 raw data，另存 cleaned data，并记录清洗脚本。

---

## 五、Python 清洗示例

```python
import pandas as pd

df = pd.read_csv('all_apps_wide.csv')

df = df[df['participant._is_bot'] == 0]
df = df.dropna(subset=['public_goods.1.player.contribution'])

df['is_treatment'] = df['public_goods.1.player.treatment'] == 'treatment'

df.to_csv('cleaned_otree_data.csv', index=False)
```

实际列名会根据 app 名、轮次和字段名变化。清洗时先打印 `df.columns`，确认列名再写脚本。

---

## 六、R 清洗示例

```r
library(readr)
library(dplyr)

df <- read_csv("all_apps_wide.csv")

cleaned <- df %>%
  filter(participant._is_bot == 0) %>%
  filter(!is.na(public_goods.1.player.contribution)) %>%
  mutate(is_treatment = public_goods.1.player.treatment == "treatment")

write_csv(cleaned, "cleaned_otree_data.csv")
```

如果列名里有点号，R 一般可以处理，但复杂时建议重命名成更短的分析变量。

---

## 七、Stata 使用建议

Stata 对变量名长度和特殊字符更敏感。导入后建议先重命名关键变量：

```stata
import delimited "all_apps_wide.csv", clear
rename public_goods_1_player_contribution contribution
rename public_goods_1_player_treatment treatment
save "cleaned_otree_data.dta", replace
```

如果导入后变量名被 Stata 自动改写，要以实际导入结果为准。

---

## 八、上线前的数据测试

正式收数据前，至少跑一次完整测试 session，然后导出数据检查：

- 每个关键变量是否存在？
- treatment 是否正确记录？
- 多轮数据是否每轮都有？
- 退出或超时参与者如何识别？
- payoff 是否和页面展示一致？

数据导出不是实验结束后的杂活，而是实验设计的一部分。能不能分析，往往取决于你写代码时有没有把该存的变量存下来。
