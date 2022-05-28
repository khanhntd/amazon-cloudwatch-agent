#!/bin/sh

CTL_PATH=/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl

assertStatus() {
  sleep 3
  keyToCheck="${1:-}"
  expectedVal="${2:-}"

  grepKey='unknown'
  case "${keyToCheck}" in
    cwa_running_status)
        grepKey="\"status\""
        ;;
    cwa_config_status)
        grepKey="\"configstatus\""
        ;;
    *)  echo "Invalid Key To Check: ${keyToCheck}" >&2
        exit 1
        ;;
  esac

  result=$(${CTL_PATH} -a status | grep "${grepKey}" | awk -F: '{print $2}' | sed 's/ "//; s/",//')

  if [ "${result}" = "${expectedVal}" ]; then
      echo "In step ${step}, ${keyToCheck} is expected"
  else
      echo "In step ${step}, ${keyToCheck} is NOT expected. (actual="${result}"; expected="${expectedVal}")"
      exit 1
  fi
}

# init
step=0
echo "`date` step: $step"
${CTL_PATH} -a remove-config -c all
${CTL_PATH} -a stop

step=1
echo "`date` step: $step"
${CTL_PATH} -a status
assertStatus "cwa_running_status" "stopped"
assertStatus "cwa_config_status" "not configured"

step=2
echo "`date` step: $step"
${CTL_PATH} -a start
assertStatus "cwa_running_status" "running"
assertStatus "cwa_config_status" "configured"

step=3
echo "`date` step: $step"
${CTL_PATH} -a remove-config -c default -s
assertStatus "cwa_running_status" "running"
assertStatus "cwa_config_status" "configured"

step=4
echo "`date` step: $step"
${CTL_PATH} -a prep-restart
${CTL_PATH} -a stop
assertStatus "cwa_running_status" "stopped"
assertStatus "cwa_config_status" "configured"

step=5
echo "`date` step: $step"
${CTL_PATH} -a cond-restart
assertStatus "cwa_running_status" "running"
assertStatus "cwa_config_status" "configured"

step=6
echo "`date` step: $step"
${CTL_PATH} -a remove-config -c default -s
assertStatus "cwa_running_status" "running"
assertStatus "cwa_config_status" "configured"

step=7
echo "`date` step: $step"
${CTL_PATH} -a remove-config -c all
assertStatus "cwa_running_status" "running"
assertStatus "cwa_config_status" "not configured"

step=8
echo "`date` step: $step"
${CTL_PATH} -a stop
assertStatus "cwa_running_status" "stopped"
assertStatus "cwa_config_status" "not configured"
