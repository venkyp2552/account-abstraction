// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "lib/forge-std/src/Script.sol";
import {EntryPoint} from "lib/account-abstraction/contracts/core/EntryPoint.sol";

// import {MinimalAccount} from "../src/ethereum/MinimalAccount.sol";

contract HelperConfig is Script{
    /*////////////////////////////////////////////
                    ERRORS
    ////////////////////////////////////////////*/
    error HelperConfig__InvalidChainId();
     /*////////////////////////////////////////////
                    TYPES
    ////////////////////////////////////////////*/
    struct NetworkConfig{
        address entryPoint;
        address account;
    }
    
    /*////////////////////////////////////////////
                    STATE VARIABLES
    ////////////////////////////////////////////*/

    uint256 constant ETH_SEPOLIA_CHAINID=1115111;
    uint256 constant ZKSYNC_SEPOLIA_CHAINID=300;
    uint256 constant LOCAL_CHAINID=31337;
    address constant BURNER_WALLET=0xFaF9931A1f6932aBcE97e97cd7d390734120FE84; //metamsk wallet address
    // address constant FOUNDRY_DEFAULT_ADDRESS=0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38; //this address default it willc ome from Base.sol
    address constant ANVIL_DEFAULT_ACCOUNT=0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266; // anvil first account address
    NetworkConfig public localNetworkConfig;

    mapping(uint256 chainId=>NetworkConfig) public netWorkConfigs;

    
    /*////////////////////////////////////////////
                    FUNCTIONS
    ////////////////////////////////////////////*/

    constructor() {
        netWorkConfigs[ETH_SEPOLIA_CHAINID]=getEthSepoliaConfig();
        netWorkConfigs[ZKSYNC_SEPOLIA_CHAINID]=getzkSyncSepoliaConfig();

    }

    /*////////////////////////////////////////////
                    EXTERNAL FUNCTIONS
    ////////////////////////////////////////////*/

    function getConfig() public returns(NetworkConfig memory){
        return getCofigByChainId(block.chainid);
    }

    function getCofigByChainId(uint256 chainId) public returns(NetworkConfig memory){
        if(chainId==LOCAL_CHAINID){
            return getOrCreateAnvilConfig();
        } else if(netWorkConfigs[chainId].account != address(0)){
            return netWorkConfigs[chainId];
        } else{
            revert HelperConfig__InvalidChainId();
        }
    }

    function getEthSepoliaConfig() public pure returns(NetworkConfig memory){
        return NetworkConfig({
            entryPoint:0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789, //entrypoint.sol address
            account:BURNER_WALLET

        });
    }
    
    function getzkSyncSepoliaConfig() public pure returns(NetworkConfig memory){
        return NetworkConfig({
            entryPoint:address(0), //its have native address
            account:BURNER_WALLET
        });
    }

    function getOrCreateAnvilConfig() public returns(NetworkConfig memory){
        if(localNetworkConfig.account !=address(0)){
            return localNetworkConfig;
        }

        vm.startBroadcast(ANVIL_DEFAULT_ACCOUNT);
        EntryPoint entryPoint=new EntryPoint();
        vm.stopBroadcast();
        localNetworkConfig=NetworkConfig({
            entryPoint:address(entryPoint),
            account:ANVIL_DEFAULT_ACCOUNT
        });
        return localNetworkConfig ;
        
    }
    
}