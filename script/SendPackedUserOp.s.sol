// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "lib/forge-std/src/Script.sol";
import {PackedUserOperation} from "lib/account-abstraction/contracts/interfaces/PackedUserOperation.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {IEntryPoint} from "lib/account-abstraction/contracts/interfaces/IEntryPoint.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {MinimalAccount} from "../src/ethereum/MinimalAccount.sol";
contract SendPackedUserOp is Script{
    using MessageHashUtils for bytes32;
    // MinimalAccount minimalAccount=new MinimalAccount();
    function run() public {}  //Here whatever we want to deploy like arbiturm or any main we can structure like that last testing function model
 
    function generatedSignedUserOperation(bytes memory callData,HelperConfig.NetworkConfig memory config,address minimalAccount) public view returns(PackedUserOperation memory){
        //1.Generate the un-signed data
 
        uint128 nonce=vm.getNonce(minimalAccount)-1;
        PackedUserOperation memory userOp=_generateUnsignedUserOperation(callData,minimalAccount,nonce);
        // to sign the data we need to getUserOpHash to get this in Entrypoint.sol we have function like getUserOpHash()
        //2.Get the userOphash
        bytes32 userOpHash=IEntryPoint(config.entryPoint).getUserOpHash(userOp);
        bytes32 digest=userOpHash.toEthSignedMessageHash();

        //3.Sign it and return it.
        uint8 v; 
        bytes32 r;
        bytes32 s;
        uint256 ANVIL_DEFAULT_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80; // frist privatekey
        if(block.chainid==31337){
            (v,r,s)=vm.sign(ANVIL_DEFAULT_KEY,digest);
        } else{
            (v,r,s)=vm.sign(config.account,digest);// here we should pass rivatekey instead if we pass accoutn autmatilaly it awil check the privatekey unlcked or not
        }
        userOp.signature=abi.encodePacked(r,s,v);
        return userOp;
    }

    //Generate UnsignedUserOpe function 
    // it will generate essentially struct for now
    function _generateUnsignedUserOperation(bytes memory callData, address sender, uint256 nonce)
        internal
        pure
        returns (PackedUserOperation memory)
    {
        uint128 verificationGasLimit = 16777216;
        uint128 callGasLimit = verificationGasLimit;
        uint128 maxPriorityFeePerGas = 256;
        uint128 maxFeePerGas = maxPriorityFeePerGas;
        return PackedUserOperation({
            sender: sender,
            nonce: nonce,
            initCode: hex"",
            callData: callData,
            accountGasLimits: bytes32(uint256(verificationGasLimit) << 128 | callGasLimit),
            preVerificationGas: verificationGasLimit,
            gasFees: bytes32(uint256(maxPriorityFeePerGas) << 128 | maxFeePerGas),
            paymasterAndData: hex"",
            signature: hex""
        });
    }
}