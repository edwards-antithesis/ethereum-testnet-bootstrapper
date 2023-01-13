# built CL images
FROM lighthouse:capella as lh_builder
FROM lodestar:capella as ls_builder
FROM nimbus:capella as nimbus_builder
FROM teku:capella as teku_builder
FROM prysm:capella as prysm_builder
# built EL images
FROM besu:capella as besu_builder
FROM geth:capella as geth_builder
FROM nethermind:capella as nethermind_builder

FROM etb-client-runner:latest

COPY --from=nethermind_builder /nethermind/ /nethermind/
COPY --from=nethermind_builder /nethermind.version /nethermind.version
RUN ln -s /nethermind/Nethermind.Runner /usr/local/bin/nethermind

COPY --from=geth_builder /usr/local/bin/geth /usr/local/bin/geth
COPY --from=geth_builder /usr/local/bin/bootnode /usr/local/bin/bootnode
COPY --from=geth_builder /geth.version /geth.version
COPY --from=besu_builder /opt/besu /opt/besu
COPY --from=besu_builder /besu.version /besu.version
RUN ln -s /opt/besu/bin/besu /usr/local/bin/besu


# COPY --from=txfuzzer_builder /run/tx-fuzz.bin /usr/local/bin/tx-fuzz
#COPY --from=geth_bad_block_builder /usr/local/bin/geth-bad-block /usr/local/bin/geth-bad-block-creator
#COPY --from=erigon_builder /usr/local/bin/erigon /usr/local/bin/erigon
##COPY --from=erigon_builder /erigon.version /erigon.version

# copy in all of the consensus clients
COPY --from=lh_builder /usr/local/bin/lighthouse /usr/local/bin/lighthouse
COPY --from=lh_builder /lighthouse.version /lighthouse.version
COPY --from=nimbus_builder /usr/local/bin/nimbus_beacon_node /usr/local/bin/nimbus_beacon_node
COPY --from=nimbus_builder /usr/local/bin/nimbus_validator_client /usr/local/bin/nimbus_validator_client
COPY --from=nimbus_builder /nimbus.version /nimbus.version
COPY --from=prysm_builder /usr/local/bin/beacon-chain /usr/local/bin/beacon-chain
COPY --from=prysm_builder /usr/local/bin/validator /usr/local/bin/validator
COPY --from=prysm_builder /prysm.version /prysm.version
COPY --from=teku_builder /opt/teku /opt/teku
COPY --from=teku_builder /teku.version /teku.version
RUN ln -s /opt/teku/bin/teku /usr/local/bin/teku
COPY --from=ls_builder /usr/app/ /usr/app/
RUN ln -s /usr/app/node_modules/.bin/lodestar /usr/local/bin/lodestar

ENTRYPOINT ["/bin/bash"]