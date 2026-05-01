---
title: "oTree 项目结构完全指南：每个文件到底负责什么"
description: "安装完 oTree 之后，先看懂 settings.py、app、模板、静态文件和数据导出的关系，再开始写实验会顺很多。"
image: "/images/blog-4.jpg"
date: 2026-05-01T05:00:00Z
draft: false
categories: ["oTree 入门系列"]
tags: ["oTree", "入门", "项目结构"]
---

很多同学安装好 oTree 之后，第一反应不是“我要怎么写实验”，而是“这些文件到底谁管谁”。如果项目结构没看懂，后面写 `Page`、`WaitPage`、表单、分组、数据导出时都会很容易迷路。

这篇先不讲复杂实验逻辑，只讲一个 oTree 项目的基本地图。你可以把它当成开工前的导航图：知道代码放哪里、页面放哪里、配置改哪里、数据从哪里来。

---

## 一、一个 oTree 项目通常长什么样

一个简化后的项目大概是这样：

```text
my_otree_project/
├── settings.py
├── requirements.txt
├── public_goods/
│   ├── __init__.py
│   └── templates/
│       └── public_goods/
│           ├── Introduction.html
│           ├── Contribute.html
│           └── Results.html
├── survey/
│   ├── __init__.py
│   └── templates/
│       └── survey/
│           └── Questionnaire.html
├── _static/
└── _templates/
```

你可以先记住一句话：`settings.py` 管整个项目，一个 app 管一个实验模块，`__init__.py` 写实验逻辑，`templates` 写参与者看到的页面。

---

## 二、settings.py：整个项目的总开关

`settings.py` 是项目级配置文件，最常改的是 `SESSION_CONFIGS`。它决定后台能创建哪些实验 session，每个 session 包含哪些 app、多少人、多少轮。

例如：

```python
SESSION_CONFIGS = [
    dict(
        name='public_goods_demo',
        display_name='公共品博弈 Demo',
        app_sequence=['public_goods', 'survey'],
        num_demo_participants=4,
    ),
]
```

这里的 `app_sequence` 很关键。它告诉 oTree：参与者先进入 `public_goods`，再进入 `survey`。所以，当你新建了一个 app，但后台看不到它，第一步就该检查 `settings.py` 里有没有把它加入 session config。

---

## 三、app 文件夹：一个实验模块

在 oTree 里，一个 app 通常对应实验中的一个模块，比如公共品博弈、独裁者博弈、风险偏好问卷、人口统计问卷。

以 `public_goods` 为例，核心逻辑写在：

```text
public_goods/__init__.py
```

在新写法里，一个 app 的模型、页面、分组和顺序通常都放在这个文件中：

```python
from otree.api import *

class C(BaseConstants):
    NAME_IN_URL = 'public_goods'
    PLAYERS_PER_GROUP = 4
    NUM_ROUNDS = 1
    ENDOWMENT = cu(100)

class Subsession(BaseSubsession):
    pass

class Group(BaseGroup):
    total_contribution = models.CurrencyField()

class Player(BasePlayer):
    contribution = models.CurrencyField(min=0, max=C.ENDOWMENT)

class Contribute(Page):
    form_model = 'player'
    form_fields = ['contribution']

class Results(Page):
    pass

page_sequence = [Contribute, Results]
```

初学时不用急着理解所有类。先抓住三层数据结构：`Subsession` 管一场实验的某一轮，`Group` 管一组人，`Player` 管单个参与者。

---

## 四、templates：参与者看到的页面

`Page` 类只定义页面逻辑，真正显示给参与者的 HTML 放在 `templates` 目录。

如果 app 叫 `public_goods`，页面类叫 `Contribute`，模板路径通常是：

```text
public_goods/templates/public_goods/Contribute.html
```

最小模板可以这样写：

```html
{{ block title }}
  贡献决策
{{ endblock }}

{{ block content }}
  {{ formfields }}
  {{ next_button }}
{{ endblock }}
```

文件名要和页面类名对上。`Contribute` 对 `Contribute.html`，`Results` 对 `Results.html`。如果页面报模板找不到，优先检查 app 名、文件夹名、页面类名和模板文件名是否一致。

---

## 五、_static 和 _templates：公共资源

`_static` 适合放多个 app 共用的 CSS、JavaScript、图片等静态资源。比如你想让所有页面使用同一份样式，可以放在这里。

`_templates` 适合放全局模板，例如统一的页面外壳、说明页片段、页脚等。简单实验一开始可以先不用动这两个目录，等多个 app 出现重复页面或重复样式时再整理。

---

## 六、数据在哪里定义，在哪里导出

你希望最后导出的变量，通常应该定义在 `Player`、`Group` 或 `Subsession` 里。

例如：

```python
class Player(BasePlayer):
    age = models.IntegerField()
    risk_choice = models.IntegerField()
    contribution = models.CurrencyField()
```

这些字段会进入 oTree 的数据表，并能在后台导出。临时计算、只用于页面显示的变量，不一定要存成字段；可以在 `vars_for_template` 里计算。

一个实用原则是：如果后续统计分析需要它，就定义成字段；如果只是页面展示用，就尽量不要污染数据表。

---

## 七、新手最常见的三个迷路点

第一，改了 app 但后台没有出现。通常是忘了在 `settings.py` 的 `SESSION_CONFIGS` 里加入 app。

第二，页面打不开，提示找不到模板。通常是模板路径或文件名没有和 `Page` 类名对应。

第三，导出的数据没有某个变量。通常是变量只写成了普通 Python 变量，没有定义为 `models.*Field()`。

---

## 下一步可以学什么

看懂项目结构之后，下一步建议按这个顺序学：

1. `is_displayed`、`before_next_page` 和 `WaitPage` 控制页面流程。
2. 随机分组、角色分配和 treatment/control 设计。
3. 多轮实验中的 `round_number`、`in_rounds()` 和跨轮数据读取。
4. 实验上线前测试、数据导出和常见报错排查。

oTree 的难点不在某一个语法，而在“项目配置、实验逻辑、页面模板、数据导出”四件事同时发生。先把文件结构看懂，后面写实验会轻松很多。
