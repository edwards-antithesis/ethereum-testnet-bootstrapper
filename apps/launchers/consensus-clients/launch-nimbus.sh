#!/bin/bash

env_vars=( "PRESET_BASE", "START_FORK_NAME", "END_FORK_NAME", "DEBUG_LEVEL", "TESTNET_DIR", "NODE_DIR", "HTTP_WEB3_IP_ADDR", "IP_ADDR", "CONSENSUS_P2P_PORT", "BEACON_METRIC_PORT", "BEACON_RPC_PORT", "BEACON_API_PORT", "VALIDATOR_METRIC_PORT", "GRAFFITI", "NETRESTRICT_RANGE" , "EXECUTION_HTTP_PORT", "TERMINAL_TOTAL_DIFFICULTY", "CONSENSUS_BOOTNODE_ENR_FILE" "CONSENSUS_CHECKPOINT_FILE", "BESU_GENESIS_FILE", "GETH_GENESIS_FILE", "NETHERMIND_GENESIS_FILE" )

for var in "${env_vars[@]}" ; do
    if [[ -z "$var" ]]; then
        echo "$var not set"
        exit 1
    fi
done

if [[ -n "$EXECUTION_LAUNCHER" ]]; then
    "$EXECUTION_LAUNCHER" &
fi

while [ ! -f "$CONSENSUS_CHECKPOINT_FILE" ]; do
    sleep 1
done

while [ ! -f "$CONSENSUS_BOOTNODE_ENR_FILE" ]; do
    echo "waiting on bootnode"
    sleep 1
done

bootnode_enr=`cat $CONSENSUS_BOOTNODE_ENR_FILE`

ADDITIONAL_BEACON_ARGS="--log-level=$NIMBUS_DEBUG_LEVEL"

if [[ $END_FORK_NAME == "bellatrix" ]]; then
    ADDITIONAL_BEACON_ARGS="$ADDITIONAL_BEACON_ARGS --terminal-total-difficulty-override=$TERMINAL_TOTAL_DIFFICULTY"
fi

if [ -n "$JWT_SECRET_FILE" ]; then
    echo "Nimbus using jwt-secret"
    ADDITIONAL_BEACON_ARGS="$ADDITIONAL_BEACON_ARGS --jwt-secret=$JWT_SECRET_FILE --web3-url=ws://$WS_WEB3_IP_ADDR:$EXECUTION_AUTH_WS_PORT"
else
    echo "Nimbus is not using jwt-secret"
    ADDITIONAL_BEACON_ARGS="$ADDITIONAL_BEACON_ARGS --web3-url=ws://$WS_WEB3_IP_ADDR:$EXECUTION_ENGINE_WS_PORT"
fi

echo "nimbus launching with additional beacon args: $ADDITIONAL_BEACON_ARGS"

sleep 20

nimbus_beacon_node \
    --non-interactive \
    --data-dir="$NODE_DIR" \
    --log-file="$NODE_DIR/beacon-log.txt" \
    --network="$TESTNET_DIR" \
    --secrets-dir="$NODE_DIR/secrets" \
    --validators-dir="$NODE_DIR/keys" \
    --rpc \
    --rpc-address="0.0.0.0" --rpc-port="$BEACON_RPC_PORT" \
    --rest \
    --rest-address="0.0.0.0" --rest-port="$BEACON_API_PORT" \
    --listen-address="$IP_ADDR" \
    --tcp-port="$CONSENSUS_P2P_PORT" \
    --udp-port="$CONSENSUS_P2P_PORT" \
    --nat="extip:$IP_ADDR" \
    --discv5=true \
    --subscribe-all-subnets \
    --insecure-netkey-password \
    --netkey-file="$NODE_DIR/netkey-file.txt" \
    --graffiti="nimbus-kilnv2:$IP_ADDR" \
    --in-process-validators=true \
    --doppelganger-detection=true $ADDITIONAL_BEACON_ARGS \
    --bootstrap-node="$bootnode_enr" 
