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