#!/bin/bash

# 启动 SSH 代理
eval "$(ssh-agent -s)"
sleep 1

# 添加 SSH 密钥
ssh-add ~/.ssh/id_ed25519
sleep 1

# 列出已添加的 SSH 密钥
ssh-add -l
sleep 1

# 测试与 GitHub 的连接
ssh -T git@github.com

