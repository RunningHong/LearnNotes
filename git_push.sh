# @Author: Marte
# @Date:   2020-08-13 11:17:35
# @Last Modified by:   Marte
# @Last Modified time: 2020-08-13 11:19:53


if [[ $# -eq 1 ]]; then
    comment="$1"
else
    comment="update notes"
fi


git add .
git commit -m "${comment}"
git push origin master
