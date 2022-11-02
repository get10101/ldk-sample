# ldk-sample
Sample node implementation using LDK.

## Installation
```
git clone https://github.com/lightningdevkit/ldk-sample
```

## Usage

You will need a local bitcoind node. We recommend to use nigiri which also includes the blockexplorer esplora.

```bash
 curl https://getnigiri.vulpem.com | bash
```

Then start the bitcoin node: 

```bash
 nigiri start
 ```

Once done we need to set up a few things and define variables


```bash
# After start, make sure to create a wallet. We don't want to use the default wallet so that we can run multiple nodes on the same machine:
WALLET_NAME=alice
nigiri rpc createwallet $WALLET_NAME 
# The rpc username and password for nigir are hardcoded, you can find it in the bitcoin config in here:
#Linux: ~/.nigiri/docker-compose.yml
#macOS: $HOME/Library/Application Support/Nigiri/docker-compose.yml

# You can check if the wallet exists and has balance with
curl --user admin1:123  --data-binary '{"jsonrpc": "1.0", "id": "curltest", "method": "getbalance", "params": ["*", 6]}' -H 'content-type: text/plain;' http://127.0.0.1:18443/wallet/$WALLET_NAME


#The default password is 
BITCOIN_RPC_USERNAME=admin1
BITCOIN_RPC_PASSWORD=123

#Unless you started the bitcoin node on a different machine, it will be accesible under: 
BITCOIN_RPC_HOST=localhost
BITCOIN_RPC_PORT=18443

#Since we potentially want to create multiple nodes it is worth storing the data in subdirectories
LDK_STORAGE_DIRECTORY_PATH=$PWD/storage/$WALLET_NAME

# increment this counter per node you want to start
PORT_INDEX=0
#Next we define the port your node will be listening on
LDK_PEER_LISTENING_PORT=$((9735+$PORT_INDEX))
ANNOUNCED_LISTEN_ADDR=127.0.0.1
ANNOUNCED_NODE_NAME=$WALLET_NAME_node_1
```

With this you can start your node

```bash
cd ldk-sample
cargo run $BITCOIN_RPC_USERNAME:$BITCOIN_RPC_PASSWORD@$BITCOIN_RPC_HOST:$BITCOIN_RPC_PORT $WALLET_NAME $LDK_STORAGE_DIRECTORY_PATH $LDK_PEER_LISTENING_PORT "regtest" $ANNOUNCED_NODE_NAME $ANNOUNCED_LISTEN_ADDR
```
On success, your node will print your listening address and node id. 
Use it to connect from another node, e.g. using

```bash
connectpeer 0380b953338331a23be199d5ca70ca3f6b5f0638aaff046a370c4618e75e5aa692@127.0.0.1:9735 
```

Make sure to fund your wallet. If you use nigiri you can run this command: 

```bash
ADDRESS=$(curl --user $BITCOIN_RPC_USERNAME:$BITCOIN_RPC_PASSWORD --data-binary '{"jsonrpc": "1.0", "id": "curltest", "method": "getnewaddress", "params": []}' -H 'content-type: text/plain
;' http://127.0.0.1:18443/wallet/$WALLET_NAME)
nigiri faucet $ADDRESS
```

Once you have funds, you an open a channel with 
```bash
openchannel $NODE_ID@127.0.0.1:$LDK_PEER_LISTENING_PORT 1000000
```

## License

Licensed under either:

 * Apache License, Version 2.0 ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
 * MIT License ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)

at your option.
