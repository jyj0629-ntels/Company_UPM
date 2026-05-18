# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
        . ~/.bashrc
fi

# User specific environment and startup programs

stty -istrip -parenb
stty erase ^H

#set vi tty
set -o vi

################################################################################
# MYSQL Environment
################################################################################
export MYSQL_HOME=/MYSQL

alias sql='/MYSQL/mysql/bin/mysql -uupm -pntels1234'
alias sqlroot='$MYSQL_HOME/bin/mysql -uroot -pntels1234 mysql'
alias mysql_start='cd /MYSQL/mysql ; /MYSQL/mysql/bin/mysqld_safe &'
alias mysql_stop='/MYSQL/mysql/bin/mysqladmin -uroot -pntels1234 shutdown'
alias bsql='$MYSQL_HOME/bin/mysql -uupm_ems -pupm?4321? upm_ems_biz -h 192.168.10.151'
alias sqlpm='$MYSQL_HOME/bin/mysql -uupm -pupm?4321? pm'


PATH=$PATH:$HOME/bin

export PATH

export LD_LIBRARY_PATH=/usr/local/openssl/lib:$MYSQL_HOME/mysql/libmysql:/usr/local/apr/lib
export DEV_PFM_HOME=/APPDATA/NPFM/PFMV4.4E
export RD_HOME=/APPDATA/NPFM/RDLIB

#JAVA SETTING
export JAVA_HOME=/pm/java/jdk1.8.0_151
export CATALINA_HOME=/pm/was/apache-tomcat-8.0.50 
PATH=$PATH:$JAVA_HOME/bin
export CLASSPATH=$JAVA_HOME/jre/ext:$JAVA_HOME/lib/tools.jar

###############################################################################
# PFM Environment
###############################################################################
export PFM_HOME=/APPDATA/NPFM/PFMV4.4E
export TMPDIR=/APPDATA/TMP
alias cdpfm='cd /APPDATA/NPFM/PFMV4.4E'
export PKGID=73
PATH=$PFM_HOME/BIN:$PATH
PATH=$PFM_HOME/SCRIPT:$PATH


###############################################################################
# PM Environment
###############################################################################
export PM_HOME=/APPDATA/PM
export PM_PKG_HOME=$PM_HOME/SRC/R220
export PM_HM_CFG=$PM_HOME/CFG/hm.cfg

alias cdpm='cd '$PM_HOME
alias cdpmlog='cd '$PM_HOME'/LOG'
alias cdperm='cd /APPDATA/PM/SIM/PERM'
alias cdpermres='cd /APPDATA/PM/SIM/PERM/TOOLS/PKG_R120/RESULT'
alias cdpermtool='cd /APPDATA/PM/SIM/PERM/TOOLS/PKG_R120'
alias clilog='cd /APPDATA/PM/SRC/upmcli/LOG'

###############################################################################
# NCN Environment
################################################################################
alias sqlncn='$MYSQL_HOME/bin/mysql -uupm -pupm?4321? ncn'
export NCN_HOME=/APPDATA/NCN
export NCN_DEV_HOME=/APPDATA/NCN
export NC_CFG=$NCN_HOME/CFG/nc.cfg
export AI_CFG=$NCN_HOME/CFG/ai.cfg
export NCN_PI_CFG=$NCN_HOME/CFG/pi.cfg
export FI_CFG=$NCN_HOME/CFG/fi.cfg
export NCN_HM_CFG=$NCN_HOME/CFG/hm.cfg

alias cdncn='cd '$NCN_HOME
alias cdncnlog='cd '$NCN_HOME'/LOG'

export TERM=xterm

###############################################################################
# PM WAS Environment
################################################################################
#alias cdweb='cd /pm/web/apache-2.2.27'
alias cdapp='cd /pm/app/odapm'
alias cdapplog='cd /pm/app/odapm/logs'
alias tailapplog='tail -f /pm/app/odapm/logs/odapm_was.out' 
alias tailnotilog='tail -f /pm/app/odapm/logs/catalina.out'
# PKG R210 추가
alias cdmdms='cd /pm/app/mdms'
alias cdmapplog='cd /pm/app/odapm/logs'
alias tailmnotilog='tail -f /pm/app/odapm/logs/catalina.out'
# PKG R210에서 변경
alias hwas_start='/pm/app/odapm/bin/startup_odapm.sh'
alias hwas_stop='/pm/app/odapm/bin/shutdown_odapm.sh'
alias mwas_start='/pm/app/mdms/bin/startup_mdms.sh'
alias mwas_stop='/pm/app/mdms/bin/shutdown_mdms.sh'

# by kwlee
alias lupm='tail -F /pm/app/odapm/logs/catalina.out'
alias hupm='cd /pm/app/odapm/webapp'
alias rupm='/pm/app/odapm/bin/startup_odapm.sh'
alias kupm="ps aux | grep 'app/odapm' | grep -v grep | awk '{print $2}' | xargs kill -9 $pid > /dev/null"
alias tupm="tail -F /pm/app/odapm/logs/catalina.out"
alias hpg='cd /pm/app/odapm/pgsimulator'
alias lcfg='curl http://127.0.0.1/ems/loadConfig'
alias supm='/APPDATA/PM/SCRIPT/upm_select.sh'
alias pgchk='/APPDATA/PM/SCRIPT/checkPgStatus.sh'
alias stmpchk='/APPDATA/PM/SCRIPT/checkMdmsStatus.sh'
alias bpgchk='/APPDATA/PM/SCRIPT/checkBarodStatus.sh'
alias cdsim='cd /APPDATA/PM/SIM/HFC_PG'

# by kilgun
alias lmdms='tail -F /pm/app/mdms/logs/catalina.out'
alias hmdms='cd /pm/app/mdms/webapp'
alias rmdms='/pm/app/mdms/bin/startup_mdms.sh'
alias kmdms="ps aux | grep 'app/mdms' | grep -v grep | awk '{print $2}' | xargs kill -9 $pid > /dev/null"
alias tmdms="tail -F /pm/app/mdms/logs/catalina.out"
alias lzcfg='curl http://127.0.0.1/ems/loadCellRadius'

################################################################################
# ORACLE Environment
################################################################################

export ORACLE_HOME=/ORACLE/product
export PATH=$PATH:$ORACLE_HOME/bin:$ORACLE_HOME/lib
export LD_LIBRARY_PATH=/usr/local/openssl/lib:$MYSQL_HOME/mysql/libmysql:$ORACLE_HOME/lib:/usr/local/apr/lib
export NLS_LANG=American_America.AL32UTF8
export LANG=ko_KR.UTF-8
export ORACLE_SID=PCISTEST

alias osql='sqlplus pcrf/pcrf1234@PCISTEST'
alias syssql='sqlplus sys/oracle@PCISTEST as sysdba'

###############################################################################
# RBUS Environment
###############################################################################
export RBUS_HOME=/APPDATA/RBUS
alias cdrb='cd '$RBUS_HOME

#################SCRIPT##################
alias startPFM='/home/upm/script/startPFM'
alias stopPFM='/home/upm/script/stopPFM'
alias disVER='/home/upm/script/verget'
alias disHA='/home/upm/script/disHA'
alias shmDel='/home/upm/script/shmDel.sh'
alias cdsc='cd /home/upm/WORK/UTIL'


###############################################################################
# R120 Environment
################################################################################
export EMS_HOME=/APPDATA/PM
export LM_CFG=/APPDATA/PM/CFG/lm.cfg
export ST_CFG=/APPDATA/PM/CFG/st.cfg
export ZC_CFG=/APPDATA/PM/CFG/zc.cfg
export HM_CFG=/APPDATA/PM/CFG/hm.cfg
export CC_CFG=/APPDATA/PM/CFG/cc.cfg
export CLI_SCRIPTS=/APPDATA/PM/UPMCLI/SCRIPTS
export HIST_PATH=/APPDATA/PM/HIST

alias cdcli='cd /APPDATA/PM/SRC/upmcli'
export CLI_LIB=$EMS_HOME/SRC/upmcli/LIB
PATH=$CLI_LIB:$PATH

SVN_EDITOR=/usr/bin/vim
export SVN_EDITOR
EDITOR=vim

##############################################################################
# R260 For Test alias (Add by jyj)
##############################################################################
alias cdsyncfile='cd /pm/app/odapm/webapp/upm_file/upm_sync_data/'
alias readmetest='cat /home/upm/readmetest.txt'
alias cdtest='cd /APPDATA/PM/PKG_TEST'
alias hfcmsgtail='tail -f /pm/app/odapm/logs/catalina.out | grep -E "messageType|Exception"'
alias pgmsgtail='tail -f /APPDATA/PM/SIM/HFC_PG/PGSim.log | grep -E "tid==|msgType=="' 

export LS_COLORS='di=00;36:ex=00;33'

if [ -f ~/.01.bashrc ]; then
        . ~/.01.bashrc
fi