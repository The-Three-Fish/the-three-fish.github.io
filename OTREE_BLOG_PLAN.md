# oTree Blog Series Plan

This plan continues the practical oTree learning path after `otree-project-structure.md`.

| Status | Slug | Working Title | Purpose |
| --- | --- | --- | --- |
| DONE | `otree-page-flow-control` | oTree 页面流程控制：is_displayed、before_next_page 和 WaitPage | Teach how pages appear, skip, save state, and synchronize groups. |
| DONE | `otree-random-grouping-treatment` | oTree 随机分组与 Treatment 设计：实验组、对照组和角色分配 | Explain grouping, roles, and treatment assignment for experiments. |
| DONE | `otree-multi-round-data` | oTree 多轮实验设计：round_number、in_rounds 和跨轮数据读取 | Show how repeated games and cross-round history work. |
| DONE | `otree-data-export-cleaning` | oTree 数据导出与清洗：从后台 CSV 到 R、Python 和 Stata | Help researchers prepare exported data for analysis. |
| DONE | `otree-prelaunch-checklist` | oTree 实验上线前测试清单：从本地预演到正式运行 | Provide a practical QA checklist before collecting real data. |
| DONE | `otree-common-errors` | oTree 常见报错合集：TemplateDoesNotExist、KeyError、NoReverseMatch | Give quick diagnosis and fixes for common beginner errors. |

## Completion Criteria

- Each article has valid frontmatter matching `src/content/config.ts`.
- Each article links conceptually to the existing beginner oTree posts.
- `pnpm build` succeeds after adding the posts.
- All rows above are changed from `TODO` to `DONE` after verification. Completed after `pnpm build` succeeded.

## Category Plan

Keep the oTree content taxonomy to three categories:

| Category | Articles | Notes |
| --- | --- | --- |
| `oTree 入门系列` | `video-1-install-otree`, `questions-round-one`, `new-format`, `otree-project-structure`, `otree-page-flow-control`, `otree-random-grouping-treatment`, `otree-multi-round-data`, `otree-data-export-cleaning`, `otree-prelaunch-checklist`, `otree-common-errors` | Beginner learning path from installation to first reliable experiment. |
| `oTree 实战进阶` | `risk-preferences`, `x-source-analysis-1` | Full experiment examples, source analysis, and deeper implementation notes. |
| `oTree 工具与动态` | `otree-launcher`, `otree-6.0` | Tool introductions, release updates, and ecosystem news. |

Do not create additional oTree categories unless the site grows beyond these editorial lanes. Use `tags` for narrower topics such as `安装`, `Treatment`, `数据导出`, or `版本更新`.
