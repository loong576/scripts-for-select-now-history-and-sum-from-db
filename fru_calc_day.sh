#!/usr/bin/ksh

#����ʾ����sh fru_calc_day.sh

#���ű�����ͳ��ÿ�ռ�ͬ����ʷ��ˮ������

#ͳ��ʱ���ǰD1�쿪ʼ��Ĭ��Ϊ7����ͳ�ƴ�7��ǰ��ʼ
D1=7
#ͳ��ʱ�䵽ǰD2�죬Ĭ��Ϊ1������ֹ��ǰһ��
D2=1
#��ʷ���ݣ�Ĭ��Ϊ12����ǰ12����(ȥ��)
M=12

#��־ʱ���ʽ
filedate=`date +"%Y%m%d%H%M"`
#��־��
REPORT="/tmp/fru/report$filedate.log"

#���ݿ��û���/���룬����ʵ�������д
DBUSER=dbuser
DBPASSWD=password

#���ݿ⻷������������ʵ�������д
export ORACLE_SID=mydb
export ORACLE_BASE=/oracle/app/10.2.0
export ORACLE_HOME=$ORACLE_BASE/db_1
export PATH=$ORACLE_HOME/bin:$ORACLE_HOME/OPatch:$PATH
export NLS_LANG="SIMPLIFIED Chinese_CHINA.ZHS16GBK"


FRU_CALC() {
echo "***************************ÿ��ˮ������ͳ��***************************">> $REPORT
sqlplus -s /nolog << EOS | sed '1d' | sed '/rows selected/d'
conn $DBUSER/$DBPASSWD
set linesize 999
set pages 999
col ���� format a30
col ƻ��(��ʷͬ��) format a30
col ����(��ʷͬ��) format a30
col �㽶(��ʷͬ��) format a30
col ����(��ʷͬ��) format a30
select f.day as "����",
       f.app as "ƻ��(��ʷͬ��)",
       f.pea as "����(��ʷͬ��)",
       f.ban as "�㽶(��ʷͬ��)",
       f.ora as "����(��ʷͬ��)"
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