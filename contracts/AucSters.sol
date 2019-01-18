// AucSters : ERC20 token and a cryptoCurrency governing the money transfer in auction
 
pragma solidity >=0.4.21 <0.6.0;

contract AucSters {
    // State varables
    uint256 public totalSupply;
    string public name;
    string public symbol;
    string public standard;

    // Mapping
    mapping(address => uint256) public balanceOf;

    // Events
    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 _value
    );

    // Modifiers
    modifier hasEnoughBalance(uint _value) {
            // exception if account doesn't have enough balance
        require(balanceOf[msg.sender] >= _value, "Not enough balance for the transaction");
        _;
    }


    constructor(uint256 _initialSupply) public {
        // Allocate the initial supply to the deployer
        balanceOf[msg.sender] = _initialSupply;
        totalSupply = _initialSupply;   

        name = "AucSters";
        symbol = "ASS";
        standard = "AucSters v0.1";        
    }

    // Transfer
    function transfer(address _to, uint _value) public hasEnoughBalance(_value) returns(bool) {
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;

        // Trigger a transfer event
        emit Transfer(msg.sender, _to, _value);
        
        // return a boolean
        return true;
    }
}