[TOC]

# wait命令

## 1 wait命令的使用小结

wait是用来阻塞当前进程的执行，直至指定的子进程执行结束后，才继续执行。使用wait可以在bash脚本“多进程”执行模式下，起到一些特殊控制的作用。

使用格式
wait [进程号 或 作业号]
如：wait 23   or  wait %1

备注：如果wait后面不带任何的进程号或作业号，那么wait会阻塞当前进程的执行，直至当前进程的所有子进程都执行结束后，才继续执行。

使用范例

```bash
#！/bin/sh
echo "1"
sleep 5s &
echo "3"
echo "4"
wait  #会等待wait所在bash上的所有子进程的执行结束，本例中就是sleep 5这句
echo "5"
```

## 2 wait控制子进程并发个数

demo1

```shell
# 后台运行个数
back_num=5
# 计数index
index=0
for i in $(seq 1 15); do

    # 此处子进程后台执行任务
    # sh xxxx.sh &
    # 举例：每个子进程睡眠指定的秒数
    echo "this will sleep ${i}s" && sleep ${i}s &

    #=======是否停止增加后台任务======
    value=$(($index % ${back_num}))
    let index++
    if [ $value -eq $((${back_num} - 1)) ]; then
        echo "后台执行任务达到${back_num}，等待所有子进行执行完成，wait..."
        wait
    fi

done
```

```shell

# 后台运行指定时间段范围的数据
begin_day='2020-12-25'
end_day='2021-01-05'

# 后台运行个数
back_num=3
# 计数index
index=0
while [ "${begin_day}" \< "${end_day}" -o "${begin_day}" = "${end_day}" ]; do
    compute_date=`date -d "${begin_day}" +"%Y-%m-%d"`

    nohup sh dws_abtest_xinrenzhuanqu1_di.sh ${begin_day} ${compute_date} > ab_${begin_day}_${compute_date}.log 2>&1 &

    value=$(($index % ${back_num}))
    let index++
    if [ $value -eq $((${back_num} - 1)) ]; then
        echo "后台执行任务达到${back_num}，等待所有子进行执行完成，wait..."
        wait
    fi

    begin_day=`date -d "${begin_day} 1 day" +"%Y-%m-%d"`
done

```

