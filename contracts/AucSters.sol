// AucSters : ERC20 token and a cryptoCurrency governing the money transfer in auction
 
pragma solidity >=0.4.21 <0.6.0;

contract AucSters {
    //  Constructor
    //  Set the total number of tokens
    //  read the total number of tokens
    uint256 public totalSupply;

    constructor() public {
        totalSupply = 10000000;
    }
}