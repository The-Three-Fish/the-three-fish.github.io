---
title: "oTree 随机分组与 Treatment 设计：实验组、对照组和角色分配"
description: "介绍 oTree 中如何随机分组、固定角色、设置 treatment/control，并把处理条件保存到数据里。"
image: "/images/blog-4.jpg"
date: 2026-05-01T07:00:00Z
draft: false
categories: ["oTree 入门系列"]
tags: ["oTree", "入门", "随机分组", "Treatment"]
---

经济学实验里经常需要随机：随机分组、随机角色、随机进入实验组或对照组。oTree 可以做这些事，但最好一开始就想清楚：随机发生在 session 层、group 层，还是 player 层。

---

## 一、先区分三种随机

常见随机需求有三类：

- 随机分组：把参与者分成若干组。
- 随机角色：组内有人是买家，有人是卖家。
- 随机 treatment：有人看到高信息版本，有人看到低信息版本。

这三件事可以同时存在，但代码位置不一样。

---

## 二、随机分组

如果只需要 oTree 默认随机分组，可以在 `creating_session` 中使用：

```python
def creating_session(subsession: Subsession):
    subsession.group_randomly()
```

如果是多轮实验，并且希望每轮重新随机：

```python
def creating_session(subsession: Subsession):
    if subsession.round_number > 1:
        subsession.group_randomly()
```

如果希望第一轮随机，后面保持同组，通常只在第一轮分组，后续轮次复制第一轮结构：

```python
def creating_session(subsession: Subsession):
    if subsession.round_number == 1:
        subsession.group_randomly()
    else:
        subsession.group_like_round(1)
```

---

## 三、角色分配

角色可以用 `id_in_group` 判断：

```python
class Player(BasePlayer):
    role_name = models.StringField()

def creating_session(subsession: Subsession):
    for group in subsession.get_groups():
        for player in group.get_players():
            if player.id_in_group == 1:
                player.role_name = 'buyer'
            else:
                player.role_name = 'seller'
```

页面里可以根据角色显示不同内容：

```python
class BuyerDecision(Page):
    @staticmethod
    def is_displayed(player: Player):
        return player.role_name == 'buyer'
```

角色一定要存成字段，方便导出后分析。不要只在模板里临时判断。

---

## 四、Treatment 和 Control

treatment 最好在实验开始时就分配，并保存到 `Player` 字段或 `participant.vars`。

```python
import random

class Player(BasePlayer):
    treatment = models.StringField()

def creating_session(subsession: Subsession):
    for player in subsession.get_players():
        player.treatment = random.choice(['control', 'treatment'])
```

如果后续 app 也要使用同一个 treatment，可以同时写入 `participant.vars`：

```python
player.participant.vars['treatment'] = player.treatment
```

在另一个 app 中读取：

```python
def creating_session(subsession: Subsession):
    for player in subsession.get_players():
        player.treatment = player.participant.vars.get('treatment')
```

---

## 五、按组分配 Treatment

有些实验要求同一组内所有人属于同一个 treatment。这时应当在 group 层分配：

```python
class Group(BaseGroup):
    treatment = models.StringField()

def creating_session(subsession: Subsession):
    for group in subsession.get_groups():
        group.treatment = random.choice(['control', 'treatment'])
        for player in group.get_players():
            player.treatment = group.treatment
```

这样导出的玩家数据里也有 treatment 标签，后续分析更方便。

---

## 六、一个实用检查清单

上线前检查这些问题：

- treatment 是否写入了导出字段？
- 随机是在 player 层还是 group 层？
- 多轮实验是否保持同一 treatment？
- treatment/control 人数是否需要平衡？
- 不同 treatment 的页面是否都测试过？

随机不是越复杂越好。实验设计里最重要的是可解释、可复现、可导出。只要这三点做到了，后面的统计分析就会顺很多。
