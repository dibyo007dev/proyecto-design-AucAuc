// AucSters : ERC20 token and a cryptoCurrency governing the money transfer in auction
 
pragma solidity >=0.4.21 <0.6.0;

contract AucSters {
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    constructor(uint256 _initialSupply) public {
        balanceOf[msg.sender] = _initialSupply;
        totalSupply = _initialSupply;
        // Allocate the initial supply to the deployer
    }
}