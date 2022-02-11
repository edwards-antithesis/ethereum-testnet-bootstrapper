#!/bin/bash 
  
TESTNET_DIR=$1
NODE_DATADIR=$2
WEB3_PROVIDER=$3
IP_ADDR=$4
P2P_PORT=$5
METRICS_PORT=$6
RPC_PORT=$7
GRPC_PORT=$8
VALIDATOR_METRICS_PORT=${9}
GRAFFITI=${10}
NETRESTRICT_RANGE=${11}
DEPOSIT_CONTRACT_ADDR=${12}
DEPOSIT_CONTRACT_BLK=${13}
# TODO: check if deposit_contract args are empty or not that way we can use
# the same script for delayed deployment and genesis

while [ ! -f "/data/consensus-clients-ready" ]; do
    sleep 1
done

while [ ! -f "/data/local_testnet/bootnode/enr.dat" ]; do
    echo "waiting on bootnode"
    sleep 1
done

beacon-chain \
  --accept-terms-of-use=true \
  --subscribe-all-subnets \
  --datadir="$NODE_DATADIR" \
  --genesis-state="$TESTNET_DIR/genesis.ssz" \
  --chain-config-file="$TESTNET_DIR/config.yaml" \
  --http-web3provider="$WEB3_PROVIDER" \
  --bootstrap-node="$(< /data/local_testnet/bootnode/enr.dat)" \
  --p2p-max-peers=10 \
  --p2p-host-ip="$IP_ADDR" \
  --p2p-udp-port="$P2P_PORT" --p2p-tcp-port="$P2P_PORT" \
  --grpc-gateway-host=0.0.0.0 \
  --grpc-gateway-port="$GRPC_PORT" \
  --verbosity="debug" \
  --enable-debug-rpc-endpoints \
  --p2p-allowlist="$NETRESTRICT_RANGE" \
  --enable-debug-rpc-endpoints \
  --deposit-contract "0x8c594691c0e592ffa21f153a16ae41db5befcaaa" \
  --contract-deployment-block 0 \
  --min-sync-peers 1 &

  # --monitoring-host=0.0.0.0 --monitoring-port="$METRICS_PORT" \
  # --rpc-host=0.0.0.0 --rpc-port="$RPC_PORT" \
sleep 20

validator \
  --accept-terms-of-use=true \
  --datadir="$NODE_DATADIR" \
  --chain-config-file="$TESTNET_DIR/config.yaml" \
  --graffiti="$GRAFFITI" \
  --wallet-dir="$NODE_DATADIR" \
  --wallet-password-file "$TESTNET_DIR/wallet-password.txt" \
  --verbosity=debug
  # --beacon-rpc-provider="127.0.0.1:$GRPC_PORT" \
  # --monitoring-host=0.0.0.0 --monitoring-port="$VALIDATOR_METRICS_PORT" \
