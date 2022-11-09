#!/bin/bash

main() {
    set -e

    WALLET_NAME=$1

    nigiri rpc getblockchaininfo &>/dev/null
    if [ $? -ne 0 ]; then
        nigiri start
    fi

    BITCOIN_RPC_USERNAME=admin1
    BITCOIN_RPC_PASSWORD=123
    BITCOIN_RPC_HOST=localhost
    BITCOIN_RPC_PORT=18443

    wallet_info_res=$(curl -s --user $BITCOIN_RPC_USERNAME:$BITCOIN_RPC_PASSWORD --data-binary '{"jsonrpc": "1.0", "method": "getwalletinfo"}' -H 'content-type: text/plain;' http://127.0.0.1:18443/wallet/$WALLET_NAME | jq .error -r)
    if [[ $wallet_info_res != "null" ]]; then
        nigiri rpc createwallet $WALLET_NAME
    fi

    LDK_STORAGE_DIRECTORY_PATH=$PWD/storage/$WALLET_NAME
    ANNOUNCED_LISTEN_ADDR=127.0.0.1
    ANNOUNCED_NODE_NAME=${WALLET_NAME}_node

    ldk_peer_listening_port=$(__get_free_port $ANNOUNCED_LISTEN_ADDR)

    cargo run $BITCOIN_RPC_USERNAME:$BITCOIN_RPC_PASSWORD@$BITCOIN_RPC_HOST:$BITCOIN_RPC_PORT $WALLET_NAME $LDK_STORAGE_DIRECTORY_PATH $ldk_peer_listening_port "regtest" $ANNOUNCED_NODE_NAME $ANNOUNCED_LISTEN_ADDR
}

function __get_free_port {
    while
        port=$(shuf -n 1 -i 49152-65535)
        nc -vz $1 $port &>/dev/null
    do
        continue
    done

    echo "$port"
}

main "$@"
exit
