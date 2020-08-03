[TOC]

locate 让使用者可以很快速的搜寻档案系统内是否有指定的档案。其方法是先建立一个包括系统内所有档案名称及路径的数据库，之后当寻找时就只需查询这个数据库，而不必实际深入档案系统之中了。在一般的 distribution 之中，数据库的建立都被放在 crontab 中自动执行。

# 一 ．命令格式：

```
locate [-d ][--help][--version][范本样式...]
```

# 二．命令功能：

locate命令可以在搜寻数据库时快速找到档案，数据库由updatedb程序来更新，updatedb是由cron daemon周期性建立的，locate命令在搜寻数据库时比由整个由硬盘资料来搜寻资料来得快，但较差劲的是locate所找到的档案若是最近才建立或 刚更名的，可能会找不到，在内定值中，updatedb每天会跑一次，可以由修改crontab来更新设定值。(etc/crontab)

locate指定用在搜寻符合条件的档案，它会去储存档案与目录名称的数据库内，寻找合乎范本样式条件的档案或目录录，可以使用特殊字元（如”*” 或”?”等）来指定范本样式，如指定范本为kcpa*ner, locate会找出所有起始字串为kcpa且结尾为ner的档案或目录，如名称为kcpartner若目录录名称为kcpa_ner则会列出该目录下包括 子目录在内的所有档案。

locate指令和find找寻档案的功能类似，但locate是通过update程序将硬盘中的所有档案和目录资料先建立一个索引数据库（一般在/var/lib/slocate/slocate.db中），在执行loacte时直接找该索引，查询速度会较快，索引数据库一般是由操作系统管理，但也可以直接下达update强迫系统立即更新索引数据库。
命令为：

```
locate -u 
```

# 三．命令参数：

| 参数 | 描述                                                         |
| ---- | ------------------------------------------------------------ |
| -e   | 将排除在寻找的范围之外。                                     |
| -1   | 如果 是 1．则启动安全模式。在安全模式下，使用者不会看到权限无法看到 的档案。这会使速度减慢，因为 locate 必须至实际的档案系统中取得档案的权限资料。 |
| -f   | 将特定的档案系统排除在外，例如我们没有道理要把 proc 档案系统中的档案放在资料库中。 |
| -q   | 安静模式，不会显示任何错误讯息。                             |
| -n   | 至多显示 n个输出。                                           |
| -r   | 使用正规运算式 做寻找的条件。                                |
| -o   | 指定资料库存的名称。                                         |
| -d   | -d或--database= 配置locate指令使用的数据库。locate指令预设的数据库位于/var/lib/slocate目录里，文档名为slocate.db，您可使用 这个参数另行指定。 |
| -h   | 显示辅助讯息                                                 |
| -V   | 显示程式的版本讯息                                           |

# 四．使用实例

## 查询文件路径中含有/etc/sh的文件或目录

命令：

```
locate /etc/sh
```

输出：

```
hc@hc-virtual-machine:~$ locate /etc/sh
/etc/shadow
/etc/shadow-
/etc/shells
/snap/core/5548/etc/shadow
/snap/core/5548/etc/shells
/snap/core/5662/etc/shadow
/snap/core/5662/etc/shells
/snap/core/5742/etc/shadow
/snap/core/5742/etc/shells
```