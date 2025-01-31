// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IAccount} from "lib/account-abstraction/contracts/interfaces/IAccount.sol";
import {PackedUserOperation} from "lib/account-abstraction/contracts/interfaces/PackedUserOperation.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {SIG_VALIDATION_FAILED,SIG_VALIDATION_SUCCESS} from "lib/account-abstraction/contracts/core/Helpers.sol";

 
contract MinimalAccount is Ownable(msg.sender),IAccount{

    //this function is nothing but entrypoint.sol we are using this one from IAccount.sol interface
    // PackedUserOperation one is nothing kind of struct as follow below 
    //     struct PackedUserOperation {
    //     address sender; --> Our minimal account which means wallet
    //     uint256 nonce; -->kind of sequencec and noo only repeat once
    //     bytes initCode; -->igonre
    //     bytes callData; --> this where we put good stuff
    //     bytes32 accountGasLimits; 
    //     uint256 preVerificationGas;
    //     bytes32 gasFees;
    //     bytes paymasterAndData; --> minimal coount holder should pay the gas fee instead on behahlf us third part can pay
    //     bytes signature;
    // signature is nothing but combination of above all data expect bytes signature;, 
    // userOp is notihng above data , userOpHash is signed hash
    // }
    function validateUserOp(
            PackedUserOperation calldata userOp,
            bytes32 userOpHash,
            uint256 missingAccountFunds
        ) external returns (uint256 validationData){
            validationData=_validateSignature(userOp,userOpHash);
            _payPrefund(missingAccountFunds) //
        }

        //validate signature is correct or not
    function _validateSignature(PackedUserOperation calldata userOp,bytes32 userOpHash) internal view returns(uint256 validationData){
        // we need to convert this userOpHash into normal hash for this we use MessageHashUtils
        bytes32 ethSignedMsgHash=MessageHashUtils.toEthSignedMessageHash(userOpHash);
        address singer=ECDSA.recover(ethSignedMsgHash,userOp.signature);
        if(singer !=owner()){
            return SIG_VALIDATION_FAILED;
        }
        return SIG_VALIDATION_SUCCESS;

    }
}