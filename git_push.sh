# @Author: Marte
# @Date:   2020-08-13 11:17:35
# @Last Modified by:   Marte
# @Last Modified time: 2020-08-14 10:26:01


if [[ $# -eq 1 ]]; then
    comment="$1"
else
    comment="update notes"
fi

echo "拉取远程分支"
git pull origin master

echo "推送提交任务到远程"
git status
git add .
git commit -m '${comment}'
git push origin master
