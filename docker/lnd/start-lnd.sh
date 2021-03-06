#!/usr/bin/env bash

# exit from script if error was raised.
set -e

# error function is used within a bash function in order to send the error
# message directly to the stderr output and exit.
error() {
    echo "$1" > /dev/stderr
    exit 0
}

# return is used within bash function in order to return the value.
return() {
    echo "$1"
}

# set_default function gives the ability to move the setting of default
# env variable from docker file to the script thereby giving the ability to the
# user override it durin container start.
set_default() {
    # docker initialized env variables with blank string and we can't just
    # use -z flag as usually.
    BLANK_STRING='""'

    VARIABLE="$1"
    DEFAULT="$2"

    if [[ -z "$VARIABLE" || "$VARIABLE" == "$BLANK_STRING" ]]; then

        if [ -z "$DEFAULT" ]; then
            error "You should specify default variable"
        else
            VARIABLE="$DEFAULT"
        fi
    fi

   return "$VARIABLE"
}

# Set default variables if needed.
RPCUSER=$(set_default "$RPCUSER" "devuser")
RPCPASS=$(set_default "$RPCPASS" "devpass")


# Remove TLS certificates (docker-compose does not re-assign the same IP address; therefore certificates might be wrong)
rm -f /root/.lnd/tls.cert
rm -f /root/.lnd/tls.key

echo "LND sleeping 5 minutes, to let BTCD generate certificates"
sleep 300 &
pid=$!
wait $pid
echo "LNS sleeping 5 minutes.. Done."

exec lnd \
    --debuglevel=info \
    --logdir="/data" \
    "--bitcoin.active" \
    "--bitcoin.mainnet" \
    "--bitcoin.node=bitcoind" \
    "--bitcoind.rpchost=bitcoind:8332" \
    "--bitcoind.rpcuser=$RPCUSER" \
    "--bitcoind.rpcpass=$RPCPASS" \
    "--bitcoind.zmqpubrawblock=tcp://bitcoind:28332" \
    "--bitcoind.zmqpubrawtx=tcp://bitcoind:28333" \
    "--rpclisten=localhost:10001" \
    "--rpclisten=lnd:10001" \
    "--restlisten=0.0.0.0:8089" \
    "--listen=0.0.0.0:10011" \
    "--externalip=51.143.175.11" \ 
    "$@"

# Valid levels are {trace, debug, info, warn, error, critical}

#    --noseedbackup \
#    "--restlisten=lnd:8089" \

# Neutrino is not yet valid for mainnet
#  "--bitcoin.node=neutrino" \
#  "--neutrino.connect=faucet.lightning.community" \

#"--bitcoin.node"="btcd" \
#    "--btcd.rpccert"="/rpc/rpc.cert" \
#    "--btcd.rpchost"="btcd" \
#    "--btcd.rpcuser"="$RPCUSER" \
#    "--btcd.rpcpass"="$RPCPASS" \






# Wallet Address:   39Shju5ZrxvrCJfvSecZm9EJiwHhjQY7rA
