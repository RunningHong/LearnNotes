[TOC]

# Git学习笔记



工作区    (add操作) -->     暂存区   （commit操作）-->      本地仓库     (push操作) -->      远程仓库

![pIC](https://segmentfault.com/img/bVFcx8?w=800&h=227)



## 1 常用命令

### 1.1 基础

- `git status` 查看状态。
- `git add` 把文件**添加**到仓库。
- `git commit -m "xxx"` 把文件**提交**到仓库，并添加注释“xxx”。
- `git push origin master` 将提交的文件push到远程库origin的master主分支上。
- `git log` 查看当前版本库及其之前的所有commit 
- `git log --pretty=oneline` 作用同 `git log` 不过显示的东西更好看，更容易辨识。
- `git reflog` 查看从本地仓库创建之日起，本地所进行的与项目更改有关的操作！比如说commit，clone等操作。 
- `git checkout -- fileName` 可以丢弃工作区的修改。就是让这个文件回到最近一次`git commit`或`git add`时的状态。
- `git reset` 回退版本。
- `git rm fileName` 从版本库中删除文件。
- `git diff` 对比工作区(自己平时工作的地方)与暂存区(add后的地方)。
- `git diff --stage` 或者 `git diff --cached` 对比暂存区（add后的代码）与本地仓库（commit后的代码）。

### 1.2 分支相关

- `git branch dev` 创建dev分支。
- `git chechout dev` 切换到dev分支。
- `git checkout -b 分支名`  创建分支并切换到该分支。
- `git branch` 查看当前分支。
- `git merge f1` 将`f1`分支和合并到当前分支。
  `git merge f1 f2` 将`f1`分支合并到`f2`分支。
  (如： `git merge f1 master`：将`f1`分支合并到`master`分支 )
- `git branch -d 分支名` 删除该分支。
- `git log --graph` 查看分支合并图。
- `git branch -v` 查看分支的详细信息（分支名，最近一次提交的注释信息）



### 1.3 stash相关(类似栈结构)

- `git stash` 把当前工作现场“储藏”起来，等以后恢复现场后继续工作
- `git stash list` 查看已有的工作现场（包括隐藏的现场）
- `git stash apply` 恢复最近的现场，恢复后stash内容并不删除。
- `git stash drop` 删除最近的现场。
- `git stash pop` 恢复现场，并删除备份的现场。



### 1.4 拉取代码命令（fetch、merge、pull）

- `git fetch` 拉取远程仓库到本地仓库。
- `git merge f1` 将`f1`分支和合并到当前分支。
  `git merge f1 f2` 将`f1`分支合并到`f2`分支。
  (如： `git merge f1 master`：将`f1`分支合并到`master`分支 )
- `git pull` 拉取远程仓库到本地仓库并合并到本地分支（相当于：`git fetch + git merge`）

### 1.5 reset命令

- `git reset --mixed HEAD~` 与 `git reste HEAD~` 将本地仓库的上一个版本覆盖到暂存区
- `git reset --hard HEAD~` 将本地仓库的上一个版本覆盖到暂存区和工作区。（谨慎使用，不可逆）
- `git reset --soft HEAD~` 将HEAD的指针指向上一个版本。

### 1.6 revert命令

撤销这次提交。并且产生一个新的提交。

### 1.7 撤销修改

1. `git checkout -- <文件名>`：丢弃工作区的修改，就是让这个文件回到最近一次`git commit`或`git add`时的状态。
2. `git reset HEAD <文件名>`：把暂存区的修改撤销掉（unstage），重新放回工作区。
3. `git reset --hard commit_id`:git版本回退，回退到特定的commit_id版本
   - 流程：
   - `git log`查看提交历史，以便确定要回退到哪个版本(commit 之后的即为ID);

4.`git reflog`查看命令历史，以便确定要回到未来的哪个版本;

- 更新远程代码到本地
  `git fetch origin master(分支)`
  `git pull // 将fetch下来的代码pull到本地`
  `git diff master origin/master // 查看本地分支代码和远程仓库的差异`


## 2 不常用命令

- `git init`  把当前目录变成Git可以管理的仓库。
- `git config --global user.name "Your Name" ` 给本地的Git取名字。
- `git config --global user.email "email@example.com"` 给本地Git绑定邮箱。
- `git config --global core.quotepath off`  避免git status显示的中文文件名乱码
- `git clone git@server-name:path/repo-name.git` 把仓库文件**clone**到本地。
- `git remote add origin git@server-name:path/repo-name.git` 添加**远程库**。
- `git remote -v` 查看**远程地址**。
- `git remote rm origin` 删除已关联的名为origin的远程库（绑定错地址时使用）。
- `git config --global color.ui auto` 获得彩色输出。
- `ssh-keygen -t rsa -C "youremail"`  生成ssh key，后续直接回车，可以看见生成的路径（公钥为.pub文件）

## 3 忽略文件的使用（.gitignore）

------

### 3.1 .gitignore文件的使用

有些时候，你必须把某些文件放到Git工作目录中，但又不能提交它们，比如保存了数据库密码的配置文件。

这时我们就只需在Git工作区根目录下创建一个特殊的文件 `.gitignore` 文件，然后把要忽略的文件填进去，Git就会自动忽略这些文件，最后一步就是把 `.gitignore` 文件提交到Git就好了。

有些时候，你想**添加一个被忽略的文件到Git**，会出现该问题：

```
$ git add App.class
The following paths are ignored by one of your .gitignore files:
App.class
Use -f if you really want to add them.
```

如果你确实想添加该文件，可以用`-f`强制添加到Git：

```
$ git add -f App.class
```

或者你发现，可能是`.gitignore`写得有问题，需要找出来到底哪个规则写错了，可以用`git check-ignore`命令检查：

```
$ git check-ignore -v App.class
.gitignore:3:*.class    App.class
```

Git会告诉我们，`.gitignore`的第3行规则忽略了该文件，于是我们就可以知道应该修订哪个规则。

### 3.2 .gitignore文件无效的解决方法

`.gitignore`只能忽略那些原来没有被 track 的文件，如果某些文件已经被纳入了版本管理中，则修改 `.gitignore` 是无效的。解决方法是**先把本地缓存删除，然后再提交**。

```java
git rm -r --cached .     // 此处用的是【.】删除的是所有的缓存，如果不想删除所有的见后面的方法
git add .
git commit -m '修复追踪一些被忽略的文件的问题'
```

**如果缓存中有重要的数据更改，那么你只需要单独删除不要的缓存**：

```java
git rm --cached logs/xx.log // 指定清除某个文件的缓存
```









