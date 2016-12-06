#!/bin/bash

# Reporter Settings
PROPERTIES=Reporter.properties

# iTunes Connect Settings

#---
# java -jar Reporter.jar p=Reporter.properties Sales.getVendors
#---
VENDOR_ID=
REPORT_TYPE=Sales
DATE_TYPE=Daily
REPORT_SUB_TYPE=Summary

# File Settings
HOME=`dirname $0`
OUTPUT_DIR=${HOME}/reports/
LOG_DIR=${HOME}/logs/
