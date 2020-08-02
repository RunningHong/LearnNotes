[toc]

# crontab相关

## 1 查看crontab

    [ crontab -l ] 查看root用户的crontab任务
    [ crontab -e ] 使用vim修改信息
## 2 语法&使用

    # Example of job definition:
    # .---------------- minute (0 - 59)
    # |  .------------- hour (0 - 23)
    # |  |  .---------- day of month (1 - 31)
    # |  |  |  .------- month (1 - 12) OR jan,feb,mar,apr ...
    # |  |  |  |  .---- day of week (0 - 6) (Sunday=0 or 7) OR sun,mon,tue,wed,thu,fri,sat
    # |  |  |  |  |
    # *  *  *  *  * user-name  command to be executed
    1.每分钟定时执行一次规则：
    每1分钟执行：*/1 * * * *（或者* * * * *）
    每5分钟执行：*/5 * * * *
    
    2.每小时定时执行一次规则：
    每小时执行： 0 * * * * (或者0 */1 * * *)
    
    3.每天定时执行一次规则：
    每天执行 0 0 * * *
    每天上午7点执行: 0 7 * * *
    每天上午7点10分执行: 10 7 * * *
    
    4.每周定时执行一次规则：
    每周执行 0 0 * * 0
    
    5.每月1号定时执行一次规则：
    每月执行 0 0 1 * *
    
    6.每年1月1号定时执行一次规则：
    每年执行 0 0 1 1 *
    
    45 4 1,10,22 * * /usr/local/etc/rc.d/lighttpd restart 表示每月1、10、22日的4 : 45重启apache
    0,30 18-23 * * * /usr/local/etc/rc.d/lighttpd restart 表示在每天18 : 00至23 : 00之间每隔30分钟重启apache
    30 21 * * * /usr/local/etc/rc.d/lighttpd restart 表示每晚的21:30重启lighttpd
    45 4 1,10,22 * * /usr/local/etc/rc.d/lighttpd restart 表示每月1、10、22日的4 : 45重启lighttpd
    10 1 * * 6,0 /usr/local/etc/rc.d/lighttpd restart 表示每周六、周日的1 : 10重启lighttpd
    0,30 18-23 * * * /usr/local/etc/rc.d/lighttpd restart 表示在每天18 : 00至23 : 00之间每隔30分钟重启lighttpd
    0 23 * * 6 /usr/local/etc/rc.d/lighttpd restart 表示每星期六的11 : 00 pm重启lighttpd
    * */1 * * * /usr/local/etc/rc.d/lighttpd restart 每一小时重启lighttpd
    * 23-7/1 * * * /usr/local/etc/rc.d/lighttpd restart 晚上11点到早上7点之间，每隔一小时重启lighttpd
    0 11 4 * mon-wed /usr/local/etc/rc.d/lighttpd restart 每月的4号与每周一到周三的11点重启lighttpd
    0 4 1 jan * /usr/local/etc/rc.d/lighttpd restart 一月一号的4点重启lighttpd
