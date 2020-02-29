# 一、需求

## 1. 需求背景

> - **需求一：**统计当前及历史同期业务量并在一个字段内展示；
> - **需求二：**统计指定时间段内业务总量；

## 2. 最终效果展示

### 2.1 模拟表的表结构

本文以水果销量模拟真实的业务量

![图片.png](https://ask.qcloudimg.com/draft/6211241/qb8gf6mv2r.png)

### 2.2 当前及历史同期效果展示

统计近7天内和历史同期各水果销量

![图片.png](https://ask.qcloudimg.com/draft/6211241/t3todv6kgg.png)

### 2.3 某时间段内总计效果展示

统计2019年全年各水果销量总计

![图片.png](https://ask.qcloudimg.com/draft/6211241/w8ks2xnzje.png)

# 二.脚本

## 1. 当前及历史同期脚本

```bash
#!/usr/bin/ksh

#运行示例：sh fru_calc_day.sh

#本脚本用于统计每日及同期历史的水果销量

#统计时间从前D1天开始，默认为7，即统计从7天前开始
D1=7
#统计时间到前D2天，默认为1，即截止到前一天
D2=1
#历史数据，默认为12，即前12个月(去年)
M=12

#日志时间格式
filedate=`date +"%Y%m%d%H%M"`
#日志名
REPORT="/tmp/fru/report$filedate.log"

#数据库用户名/密码，根据实际情况填写
DBUSER=dbuser
DBPASSWD=password

#数据库环境变量，根据实际情况填写
export ORACLE_SID=mydb
export ORACLE_BASE=/oracle/app/10.2.0
export ORACLE_HOME=$ORACLE_BASE/db_1
export PATH=$ORACLE_HOME/bin:$ORACLE_HOME/OPatch:$PATH
export NLS_LANG="SIMPLIFIED Chinese_CHINA.ZHS16GBK"


FRU_CALC() {
echo "***************************每日水果销量统计***************************">> $REPORT
sqlplus -s /nolog << EOS | sed '1d' | sed '/rows selected/d'
conn $DBUSER/$DBPASSWD
set linesize 999
set pages 999
col 日期 format a30
col 苹果(历史同期) format a30
col 梨子(历史同期) format a30
col 香蕉(历史同期) format a30
col 橙子(历史同期) format a30
select f.day as "日期",
       f.app as "苹果(历史同期)",
       f.pea as "梨子(历史同期)",
       f.ban as "香蕉(历史同期)",
       f.ora as "橙子(历史同期)"
  from (select t.day,
               t.app || '(' || y.app || ')' as app,
               t.pea || '(' || y.pea || ')' as pea,
               t.ban || '(' || y.ban || ')' as ban,
               t.ora || '(' || y.ora || ')' as ora
          from (select a.day,
                       a.apple as app,
                       a.pear as pea,
                       a.banana as ban,
                       a.orange as ora
                  from fruits a
                 where a.day between TRUNC(sysdate - $D1, 'DD') and
                       TRUNC(sysdate - $D2, 'DD')) t,
               (select a.day,
                       a.apple as app,
                       a.pear as pea,
                       a.banana as ban,
                       a.orange as ora
                  from fruits a
                 where a.day between
                       TRUNC(ADD_MONTHS(sysdate, -$M) - $D1, 'DD') and
                       TRUNC(ADD_MONTHS(sysdate, -$M) - $D2, 'DD')) y
         where ADD_MONTHS(t.day, -$M) = y.day) f
order by f.day;
quit
EOS
}

FRU_CALC >>$REPORT 2>&1

echo "*****************************end*****************************">> $REPORT
```

本文脚本的执行shell为/usr/bin/ksh，可根据实际情况修改，运行命令echo $SHELL可查看当前用户的shell类型。

## 2. 某时间段内总计脚本

```bash
#!/usr/bin/ksh

#运行示例：sh  fru_calc_sum.sh 20190101 20191231
#本脚本用于统计月度、年度或任意时间段内水果销量汇总

#参数1，开始时间
startdate="$1"
#参数2，结束时间
enddate="$2"

#日志时间格式
filedate=`date +"%Y%m%d%H%M"`
#日志名
REPORT="/tmp/fru/report$filedate.log"

#数据库用户名/密码，根据实际情况填写
DBUSER=dbuser
DBPASSWD=password

#数据库环境变量，根据实际情况填写
export ORACLE_SID=mydb
export ORACLE_BASE=/oracle/app/10.2.0
export ORACLE_HOME=$ORACLE_BASE/db_1
export PATH=$ORACLE_HOME/bin:$ORACLE_HOME/OPatch:$PATH
export NLS_LANG="SIMPLIFIED Chinese_CHINA.ZHS16GBK"



FRU_CALC() {
echo "***********历史水果销量总计:'$startdate'至'$enddate'***********">> $REPORT
sqlplus -s /nolog << EOS | sed '1d' | sed '/rows selected/d'
conn $DBUSER/$DBPASSWD
set linesize 999
set pages 999
select sum(f.app) as "苹果",
       sum(f.pea) as "梨子",
       sum(f.ban) as "香蕉",
       sum(f.ora) as "橙子"
  from (select a.day,
               sum(a.apple) as app,
               sum(a.pear) as pea,
               sum(a.banana) as ban,
               sum(a.orange) as ora
          from fruits a
         where a.day between to_date('$startdate', 'yyyymmdd') and
               to_date('$enddate', 'yyyymmdd')
         group by a.day) f;
quit
EOS
}

FRU_CALC >>$REPORT 2>&1

echo "*****************************end*****************************">> $REPORT
```

# 三、运行效果

## 1. 当前及历史同期查询

![图片.png](https://ask.qcloudimg.com/draft/6211241/a0osdm0lj0.png)

## 2. 某时间段内总计查询

![图片.png](https://ask.qcloudimg.com/draft/6211241/mrckkway2z.png)





&nbsp;

&nbsp;



**原文地址：**https://blog.51cto.com/3241766/2474581

