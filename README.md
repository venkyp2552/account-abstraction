# About

1.Create a basic AA on Ethereum 
2.Create a basic AA on zkSync 
3.Deploy and send a userOption / transaction through them.

    1.Nothing to send an AA on ethereum
    2.But will send AA tx to  zkSync


 this function is nothing but entrypoint.sol we are using this one from IAccount.sol interface
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