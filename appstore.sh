#!/bin/bash

OS=`uname`
DIR=`dirname $0`
PROGNAME=$(basename $0)
VERSION="1.0"
HELP_MSG="'$PROGNAME -h'と指定することでヘルプを見ることができます"

# Command
JAVA=java
GREP=grep

# ヘルプメッセージ
usage() {
  echo "Usage: $PROGNAME [-d yyyymmdd]"
  echo
  echo "オプション:"
  echo "  -h, --help"
  echo "  -v, --version"
  echo "  -d, --date <yyyymmdd>  [Optional] *default is yesterday"
  echo
  exit 1
}

# --共通関数定義--
################
# ログ出力関数 #
################
LOG()
{
  # ログファイル
  LOG_DATE=`date '+%Y-%m-%d'`
  LOG_TIME=`date '+%H:%M:%S'`
  LOGFILE="${LOG_DIR}${LOG_DATE}.log"

  # Make output directory
  if [ ! -d $LOG_DIR ]; then
    mkdir $LOG_DIR
  fi

  # 引数展開
  FILENM=`basename $0`
  TITLE=$1
  MSG=$2

  # ログ出力実行
  printf "%-10s %-8s %-14s %-50s\n" \
  "${TITLE} ${LOG_DATE}" "${LOG_TIME}" "${FILENM}" "${MSG}" >>${LOGFILE}
}

# オプション解析
for OPT in "$@"
do
  case "$OPT" in
    # ヘルプメッセージ
    '-h'|'--help' )
      usage
      exit 1
      ;;
    # バージョンメッセージ
    '-v'|'--version' )
      echo $VERSION
      exit 1
      ;;
    # オプション-d、--date
    '-d'|'--date' )
      TARGET_DATE=$2
      # オプションに引数がなかった場合
      if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
        shift
      else
        # オプションの引数設定
        TARGET_DATE="$2"
        shift 2
      fi
      ;;
  esac
done

# 日付の指定がない場合は[昨日]を指定
if [ -z $TARGET_DATE ]; then
  if [ $OS = 'Darwin' ]; then
    TARGET_DATE=`date -v-1d +'%Y%m%d'`
  elif [ $OS = 'Linux' ]; then
    TARGET_DATE=`date -d "1 days ago" + '%Y%m%d'`
  fi
fi

# Load Settings
source ${DIR}/settings.sh

if [ -z $PROPERTIES ]; then
  echo '$PROPERTIES is not set.'
  exit 1
fi

if [ ! $VENDOR_ID -gt 0 ]; then
  echo '$VENDOR_ID is not set.'
  exit 1
fi

if [ $REPORT_TYPE = 'Sales' ]; then
  FILE_PRE_R='S_'
else
  echo 'Only sales report is supported.'
  exit 1
fi

if [ $REPORT_SUB_TYPE != 'Summary' ]; then
  echo 'Only summary report is supported.'
  exit 1
fi

if [ $DATE_TYPE = 'Daily' ]; then
  FILE_PRE_D='D_'
else
  echo 'Only daily report is supported.'
  exit 1
fi

FILE_PRE=${FILE_PRE_R}${FILE_PRE_D}

cd $DIR

# Make output directory
if [ ! -d $OUTPUT_DIR ]; then
  mkdir $OUTPUT_DIR
fi

LOG [INFO] "download ${TARGET_DATE}"

# Download with Autoingestion
RESULT=`$JAVA -jar Reporter.jar p=$PROPERTIES Sales.getReport $VENDOR_ID, $REPORT_TYPE, $REPORT_SUB_TYPE, $DATE_TYPE, $TARGET_DATE`

FILE=${FILE_PRE}${VENDOR_ID}_${TARGET_DATE}.txt

# If succeeded
if echo $RESULT | $GREP $FILE > /dev/null; then
  gzip -d -f ${FILE}.gz
  mv ${FILE} ${OUTPUT_DIR}${FILE}
  LOG [INFO] "save to ${OUTPUT_DIR}${FILE}"
else
  LOG [ERROR] $RESULT
fi

exit 0
