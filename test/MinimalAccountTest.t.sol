// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test,console} from "lib/forge-std/src/Test.sol";
import {DeployMinimal} from "../script/DeployMinimal.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {MinimalAccount} from "../src/ethereum/MinimalAccount.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import {SendPackedUserOp} from "../script/SendPackedUserOp.s.sol";
import {PackedUserOperation} from "lib/account-abstraction/contracts/interfaces/PackedUserOperation.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {IEntryPoint} from "lib/account-abstraction/contracts/interfaces/IEntryPoint.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
contract MinimalAccountTest is Test{
    using MessageHashUtils for bytes32;
    HelperConfig helperConfig;
    MinimalAccount minimalAccount;
    SendPackedUserOp sendPackedUserOp;
    ERC20Mock usdc;
    uint256 AMOUNT=1e18;
    address romdomuser=makeAddr('randomUser');
    function setUp() public{
        DeployMinimal deployer=new DeployMinimal();
        (helperConfig,minimalAccount)=deployer.deployMinimalAccount();
        usdc=new ERC20Mock();
        sendPackedUserOp=new SendPackedUserOp();
    }

    function testOwnerCanExecuteCommands() public {
    //Arrange 
    assertEq(usdc.balanceOf(address(minimalAccount)),0);
    address dest=address(usdc);
    uint256 value=0;
    bytes memory functionData=abi.encodeWithSelector(ERC20Mock.mint.selector,address(minimalAccount),AMOUNT);
    
    //Act
    vm.prank(minimalAccount.owner());
    minimalAccount.execute(dest,value,functionData);

    //Assert

    assertEq(usdc.balanceOf(address(minimalAccount)),AMOUNT);
    }

    function testNonOwnerCannotExcuteTheCommands() public{
        // romdomuser
        address dest=address(usdc);
        uint256 value=0;
        bytes memory functionData=abi.encodeWithSelector(ERC20Mock.mint.selector,address(minimalAccount),AMOUNT);

        vm.prank(romdomuser);
        vm.expectRevert(MinimalAccount.MinimalAccount__NotFromEntryPointOrOwner.selector);
        minimalAccount.execute(dest,value,functionData);
    }

    function testRecoverSignedOp() public {
        address dest=address(usdc);
        uint256 value=0;
        bytes memory functionData=abi.encodeWithSelector(ERC20Mock.mint.selector,address(minimalAccount),AMOUNT);

        bytes memory executeCallData=abi.encodeWithSelector(MinimalAccount.execute.selector,dest,value,functionData);

        PackedUserOperation memory packedUserOp=sendPackedUserOp.generatedSignedUserOperation(executeCallData,helperConfig.getConfig(),address(minimalAccount));

        bytes32 userOperationHash=IEntryPoint(helperConfig.getConfig().entryPoint).getUserOpHash(packedUserOp);
        address actualSigner=ECDSA.recover(userOperationHash.toEthSignedMessageHash(), packedUserOp.signature);

        //assert
        assertEq(actualSigner,minimalAccount.owner());

    }


    //1.sign users ops
    //2.Call validate userOps
    //3.Assert the return is correct
    function testValidationOfUserOps() public{
         address dest=address(usdc);
        uint256 value=0;
        bytes memory functionData=abi.encodeWithSelector(ERC20Mock.mint.selector,address(minimalAccount),AMOUNT);

        bytes memory executeCallData=abi.encodeWithSelector(MinimalAccount.execute.selector,dest,value,functionData);

        PackedUserOperation memory packedUserOp=sendPackedUserOp.generatedSignedUserOperation(executeCallData,helperConfig.getConfig(),address(minimalAccount));

        bytes32 userOperationHash=IEntryPoint(helperConfig.getConfig().entryPoint).getUserOpHash(packedUserOp);
        uint256 missingAccountFunds = 1e18;
         vm.prank(helperConfig.getConfig().entryPoint); // bcz we have a modifier
        uint256 validationData=minimalAccount.validateUserOp(packedUserOp,userOperationHash,missingAccountFunds);
         assertEq(validationData,0);
    }

    function testEntryPointCanExecuteCommands() public{
        address dest=address(usdc);
        uint256 value=0;
        bytes memory functionData=abi.encodeWithSelector(ERC20Mock.mint.selector,address(minimalAccount),AMOUNT);

        bytes memory executeCallData=abi.encodeWithSelector(MinimalAccount.execute.selector,dest,value,functionData);

        PackedUserOperation memory packedUserOp=sendPackedUserOp.generatedSignedUserOperation(executeCallData,helperConfig.getConfig(),address(minimalAccount));

        // bytes32 userOperationHash=IEntryPoint(helperConfig.getConfig().entryPoint).getUserOpHash(packedUserOp);

        vm.deal(address(minimalAccount),1e18);
        PackedUserOperation[] memory ops=new PackedUserOperation[](1);
        ops[0]=packedUserOp;

        //Act
        vm.prank(romdomuser);
        IEntryPoint(helperConfig.getConfig().entryPoint).handleOps(ops,payable(romdomuser));
        assertEq(usdc.balanceOf(address(minimalAccount)),AMOUNT);
    }
}



/*
1.USDC Mint Approval we want  our destination is USDC account (addres)
2.msg.sender is our =>minimalAccount contract
3.approve some amount
4.USDC contract 
5.come from entrypoint 

*/

