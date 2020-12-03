#!/bin/bash

# rpm -q bugfix
export LANG=en_US.UTF-8

# Simple input to skip slow tests
if [[ "$1" == "--skip-slow" ]]; then
  export BENCH_SKIP_SLOW=1
fi

. includes/log_utils.sh
. includes/test_utils.sh

func_wrapper() {
  local func=$1
  shift
  local args=$@
  ${func} ${args} 
  #2>/dev/null
  if [[ "$?" -eq 127 ]]; then
    warn "${func} not implemented"
  fi
}

# CentOS Bench for Security 
# 
# Based on 'CIS_CentOS_Linux_7_Benchmark_v2.2.0 (12-27-2017)'
# https://www.cisecurity.org/cis-benchmarks/
#
# Björn Oscarsson (c) 2017-
#
# Inspired by the Docker Bench for Security.
# 
# Forked from https://github.com/hzde0128/centos-bench-security
# Modified by kaleyroy@gmail.com for private environment (CentOS7.x ONLY)

main () {  
  yell "# ------------------------------------------------------------------------------
#
# Ubuntu Bench for Security (v1.0)
# provided by aZaaS <https://www.azaas.com>
# 
# ------------------------------------------------------------------------------"
  logit "Initializing $(date)"

  ID=$(id -u)
  if [[ "x$ID" != "x0" ]]; then
    logit ""
    warn "Tests requires root to run"
    logit ""
    exit 1
  fi
  
  # Basic tools
  [[ $(rpm -q net-tools >/dev/null) ]] || yum -y -q install net-tools

  for test in tests/*.sh
  do
    logit ""
    . ./"$test"
    func_wrapper check_$(echo "$test" | awk -F_ '{print $1}' | cut -d/ -f2)
  done

  logit ""  
}

main "$@"
