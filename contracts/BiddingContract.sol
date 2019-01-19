// BiddingContract: Takes care of all the bidding business logic and admin related permissions
 
pragma solidity >=0.4.21 <0.6.0;

// import the ASS token
import "./AucSters.sol";

// SafeMath for Ops Utils
import "../libraries/SafeMath.sol";

contract BiddingContract {

    address admin;
    AucSters public tokenContract;
    uint256 tokenPrice;

    constructor(AucSters _tokenContract, uint _tokenPrice) public {
        //Assign an admin
        admin = msg.sender;

        // token Contract 
        tokenContract = _tokenContract;
        
        //Token price
        tokenPrice = _tokenPrice;
    }
}