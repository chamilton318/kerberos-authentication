#!/bin/bash

# TODO: get user from secret.json
# Check that variables are set
if [[ -z "$USER" ]]; then
    echo "Need to set USER as Docker Env Var" 1>&2
    exit 1
fi

# TODO: get password from secret.json
if [[ -z "$PASSWORD" ]]; then
    echo "Need to set PASSWORD as Docker Env Var" 1>&2
    exit 1
fi

# Get the Ticket-Granting-Ticket for Kerberos
kinit "$USER" <<< "$PASSWORD" || exit 1

# Create key tab
ktutil < <(echo -e "addent -password -p $USER -k 1 -e aes256-cts-hmac-sha1-96\n$PASSWORD\nwkt /opt/app-root/krb5/krb5.keytab \nquit")

# report the valid tokens
klist -c /dev/shm/ccache

## Retry logic

[[ "$PERIOD_SECONDS" == "" ]] && PERIOD_SECONDS=3600


echo "*** Waiting for $PERIOD_SECONDS seconds"
sleep $PERIOD_SECONDS

while true

do

  # report to stdout the time the kinit was being run

  echo "*** kinit at "+$(date)

  kinit $USER -kt /opt/app-root/krb5/krb5.keytab

  RESULT=$?
  if [ $RESULT -eq 0 ]; then
    # sleep for the defined period, then repeat
    echo "*** Waiting for $PERIOD_SECONDS seconds"
    # report the valid tokens
    klist -c /dev/shm/ccache
    sleep $PERIOD_SECONDS
  else
    echo "Refresh failed"
    exit 1
  fi

  
 done
