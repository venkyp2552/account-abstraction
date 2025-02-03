// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IAccount} from "lib/foundry-era-contracts/src/system-contracts/contracts/interfaces/IAccount.sol";
import {Transaction} from "lib/foundry-era-contracts/src/system-contracts/contracts/libraries/MemoryTransactionHelper.sol";


/**
 * lifeCycle of type 113(0x71) Transaction
 * msg.sender is the bootloader system contract(This contract will take care the ownership of the transactio)
 * Phase 1 Validation:
 * 1.The user send transaction to the zksync api client(Sort of light node)
 * 2.The zksync api client checks to see the nonce is unique by quering the nonce
 * holder system contract
 * 3.The zkSync API client call validateTransaction,which must update the nonce.
 * Note Here bootloader system contractor is the msg.sender(is nothing but super admin of all the system contracts)
 * 4.The zkSync API client checks if the nonce updated or not if not it will revert the call.
 * 5.If its true then zkSync API client calls payForTransaction, or prepareForPaymaster & validateAndPayForPaymasterTransction
 * 6.The zkSync API client verifies that the bootloader gets paid.
 * 
 * Phase 2 Execution:
 * 7.The zkSync Client passes the validation to the main node / sequencer (as of today, they are the same)
 * 8.main node calls the executeTransaction function
 * 9.If a paymaster was used, the postTransaction is called.
 */

contract ZkMinimalAccount is IAccount {

     /*////////////////////////////////////////////
                    ERRORS
    ////////////////////////////////////////////*/


    /*////////////////////////////////////////////
                    EXTERNAL FUNCTIONS
    ////////////////////////////////////////////*/

    function validateTransaction(bytes32 _txHash, bytes32 _suggestedSignedHash, Transaction calldata _transaction)
        external
        payable
        returns (bytes4 magic){

        }

    function executeTransaction(bytes32 _txHash, bytes32 _suggestedSignedHash, Transaction calldata _transaction)
        external
        payable{

        }

    // There is no point in providing possible signed hash in the `executeTransactionFromOutside` method,
    // since it typically should not be trusted.
    function executeTransactionFromOutside(Transaction calldata _transaction) external payable{

    }

    function payForTransaction(bytes32 _txHash, bytes32 _suggestedSignedHash, Transaction calldata _transaction)
        external
        payable{

    }

    function prepareForPaymaster(bytes32 _txHash, bytes32 _possibleSignedHash, Transaction calldata _transaction)
        external
        payable{

    }

    
    /*////////////////////////////////////////////
                    INTERNAL FUNCTIONS
    ////////////////////////////////////////////*/

    

}