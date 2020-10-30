自己写的快速add&commit&push的脚本

```shell
alias ll='ls -l'
git_notes_path="/d/我的/LearnNotes"
alias cd_git_notes="cd ${git_notes_path}"

# 推送
# $1: 目录名
# $2(可选):注释[默认：update]
# $3(可选)：推送分支[默认：master]
function gitpush() {
    now_path=`pwd` # 记录当前的目录
    if [[ $# -eq 1 ]]; then
        cd ${1}  # 切换到指定目录
        comment="update"
        branch="master"
    elif [[ $# -eq 2 ]]; then
        cd ${1}  # 切换到指定目录
        comment="${2}" # 添加注释
        branch="master"
    elif [[ $# -eq 3 ]]; then
        cd ${1}  # 切换到指定目录
        comment="${2}" # 添加注释
        branch="${3}"
    fi
    echo "推送目录： "`pwd`
    echo "拉取远程master分支"
    git pull origin master

    echo "改动部分"
    git status

    echo "推送提交任务到远程${branch}分支"
    git add ./
    git commit -m "${comment}"
    git push origin "${branch}"
    echo "推送到${branch}分支完毕"
    cd $now_path # 恢复目录
}

# 推送git笔记
# $1(可选): 注释[默认：update]
# $2(可选): 推送分支[默认：master]
function mypush_git_notes() {
    if [[ $# -eq 0 ]]; then
        gitpush "${git_notes_path}"
    elif [[ $# -eq 1 ]]; then
        gitpush "${git_notes_path}" ${1}
    elif [[ $# -eq 2 ]]; then
        gitpush "${git_notes_path}" ${1} ${2}
    else
        echo "参数个数错误"
    fi
}

# 推送当前
# $1(可选): 注释[默认：update]
# $2(可选): 推送分支[默认：master]
function mypush_now() {
    now_path=`pwd`
    if [[ $# -eq 0 ]]; then
        gitpush "${now_path}"
    elif [[ $# -eq 1 ]]; then
        gitpush "${now_path}" ${1}
    elif [[ $# -eq 2 ]]; then
        gitpush ${now_path} ${1} ${2}
    else
        echo "参数个数错误"
    fi
}

echo "脚本位置： Git的安装目录/etc/bash.bashrc"
echo "快捷命令："
echo "    mypush_git_notes   : 推送git笔记"
echo "    mypush_now         : 推送当前目录"
echo "参数说明："
echo '    $1(可选): 注释    [默认：update]'
echo '    $2(可选): 推送分支[默认：master]'
```

