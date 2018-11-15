[TOC]

# Git学习笔记

## 1 常用命令

- `git init`  把当前目录变成Git可以管理的仓库。
- `git status` 查看状态。
- `git add` 把文件**添加**到仓库。
- `git commit -m "xxx"` 把文件**提交**到仓库，并添加注释“xxx”。
- `git push origin master` 将提交的文件push到远程库origin的master主分支上。
- `git log` 查看历史记录。
- `git checkout -- fileName` 可以丢弃工作区的修改。
- `git reset` 回退版本。
- `git rm fileName` 从版本库中删除文件。



## 2 不常用命令

- `git config --global user.name "Your Name" ` 给本地的Git取名字。
- `git config --global user.email "email@example.com"` 给本地Git绑定邮箱。
- `git clone git@server-name:path/repo-name.git` 把仓库文件**clone**到本地。
- `git remote add origin git@server-name:path/repo-name.git` 添加**远程库**。
- `git remote -v` 查看**远程地址**。



