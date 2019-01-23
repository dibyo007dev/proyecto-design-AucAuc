// BiddingContract: Takes care of all the bidding business logic and admin related permissions
 
pragma solidity >=0.4.21 <0.6.0;

// import the ASS token
import "./AucSters.sol";

// SafeMath for Ops Utils
import "../libraries/SafeMath.sol";

contract BiddingContract {

    using SafeMath for uint; 

    address admin;
    AucSters public tokenContract;
    uint256 public tokenPrice;
    uint256 public tokensSold;

    //structs
    struct Seller {
        uint256 sellerId;
        string sellerName;
        bool isValidSeller;
    }
    struct Bidder {
        address bidders_address;
        uint productId;
        uint bidValue;
    }
    struct Product {
        uint productId;
        uint bidStartPrice;
        uint32 bidStartTime;
        Bidder latestBid;
        string productName;
        bool isAvailable;
        uint32 bidSession;

    }



    //seller-mappings
    mapping(address => Seller) registeredSeller;

    // ** product-mappings : a registered seller has multiple products
    
    // for getting all the products of a perticular seller
    mapping(address => Product) public products;

    //lookup for the owner of product with productId
    mapping(uint => address) public productIdToOwner;

    //get product details with specific productId
    mapping(uint => Product) public product;

    //latest bid tracker
    mapping(address => mapping(uint => uint)) latestBidStore;


    //ARRAYS
    address[] public regSellers;
    Product[] public productsForSale;
    address[] public bidders;


    // modifiers
    modifier onlyOwner() {
        require(msg.sender == admin, "not an admin");
        _;
    }

    modifier isRegisteredSeller(address _seller) {
        require(registeredSeller[_seller].isValidSeller,"seller not registered");
        _;
    }

    modifier inSession(uint256 _productId){
        require(now < product[_productId].bidSession + product[_productId].bidStartTime, "Timeout occured for the product");
        _;
    }
    //events
    event TokenSold(address indexed _customer,
                    uint _numberOfTokens
    );

    event ProductSold(uint indexed _productId,
                address indexed _customer,
                uint _numberOfTokens
    );

    event Bidding(uint indexed _productId,
                address indexed _bidder,
                uint _numberOfTokens
    );

    event NewProductAdded( address indexed _sellerId,
                           uint _productId
    );



    constructor(AucSters _tokenContract, uint _tokenPrice) public {
        //Assign an admin
        admin = msg.sender;

        // token Contract 
        tokenContract = _tokenContract;
        
        //Token price
        tokenPrice = _tokenPrice;
    }

    function buyTokens(uint256 _numberOfTokens) public payable {
        uint price = _numberOfTokens.mul(tokenPrice);
        require(msg.value == price, "buyer doesn't sent sufficient funds");
        require(tokenContract.balanceOf(address(this)) >= _numberOfTokens, "contract dont have enough balance");
        require(tokenContract.transfer(msg.sender, _numberOfTokens), "cannot transfer the tokens");

        tokensSold = tokensSold.add(_numberOfTokens);

        emit TokenSold(msg.sender, _numberOfTokens);
    }

    function endSupply() public {
        require(msg.sender == admin,"only admin can end the token sale");
        require(tokenContract.transfer(admin, tokenContract.balanceOf(address(this))),"balance not transferring");

        selfdestruct(msg.sender);
    }

    // registration of seller from the admin
    function registerSeller(address _sellerAddress, string memory _sellerName, uint256 _sellerId) public onlyOwner isRegisteredSeller(_sellerAddress) returns(bool){
        registeredSeller[_sellerAddress].sellerName = _sellerName;
        registeredSeller[_sellerAddress].sellerId = _sellerId;
        registeredSeller[_sellerAddress].isValidSeller = true;

        regSellers.push(_sellerAddress) - 1;

        return true;
    }
    // get All sellers
    function getSellers() public view  returns(address[] memory) {
        return regSellers;
    }

    // get description of a registered seller
    function getSeller(address _address) public view returns(uint, string memory){
        return( registeredSeller[_address].sellerId, registeredSeller[_address].sellerName);
    }

    // registered sellers can add products for bidding
    function addProductForBid(uint _productId, string memory _productName, uint256 _bidStartPrice, uint32 _sessionValue) public isRegisteredSeller(msg.sender) returns(bool){
        //update the mapping
        products[msg.sender].productId = _productId;
        products[msg.sender].productName = _productName;
        products[msg.sender].bidStartPrice = _bidStartPrice;
        products[msg.sender].isAvailable = true;
        products[msg.sender].bidStartTime = uint32(now);
        products[msg.sender].bidSession = _sessionValue; // in seconds



        // update the product mapping
        product[_productId].productName = _productName;
        product[_productId].bidStartPrice = _bidStartPrice;
        product[_productId].isAvailable = true;

        // Update the all product array
        Product memory newProduct;
        newProduct.productId = _productId;
        newProduct.productName = _productName;
        newProduct.bidStartPrice = _bidStartPrice;
        newProduct.isAvailable = true;


        productsForSale.push(newProduct) - 1;

        productIdToOwner[_productId] = msg.sender;

        //Initial Bid price is set to the mapping
        latestBidStore[msg.sender][_productId] = _bidStartPrice;

        // emit an product added event
        emit NewProductAdded(msg.sender, _productId);

        return true;
    }

    // UPGRADE : function removeProduct();
    // UPGRADE : update productForSale array


    // bidding on a certain product

    function Bid(uint _productId, uint _bidValue) inSession(_productId) public returns(bool) { // modifier to check the session is still there
        // check if msg.sender has enough balance
        require(tokenContract.balanceOf(msg.sender) >= _bidValue, "not enough balance");
            // check if bid is higher than previous bid event 
        require(latestBidStore[msg.sender][_productId] > _bidValue, "must bid a larger amount");
            //  transfer the token for locking 
        tokenContract.approve(address(this), _bidValue);

        tokenContract.transferFrom(msg.sender, address(this), _bidValue);

            //  update the bid amount : latestBidPrice
        latestBidStore[msg.sender][_productId] = _bidValue;
            // update the bidding array
        bidders.push(msg.sender) - 1;
        product[_productId].latestBid.bidders_address = msg.sender;
        product[_productId].latestBid.bidValue = _bidValue;

            //  trigger event on every update 
        emit Bidding(_productId,msg.sender, _bidValue);
    }

    // on Session end called by the Seller

    function finalizeBid(uint _productId) public returns(bool) {
        // check if called by the product seller only 
        require(productIdToOwner[_productId] == msg.sender, "seller can only finalize the bid");
        // check if session is timed out or not 
        require(now > product[_productId].bidSession + product[_productId].bidStartTime, "cannot finalize");
        // finalize price of higest bid // last bidder

        //product no more available
        product[_productId].isAvailable = false;
        // return the rest of bidders' tokens locked 
        for(uint i = 0;i < bidders.length;i++) {
            // find and refund the bidders who have got their token locked for the auction and did not won the product
            if(latestBidStore[bidders[i]][_productId] != 0 && latestBidStore[bidders[i]][_productId] != product[_productId].latestBid.bidValue) {
                // process the return
                tokenContract.transfer(bidders[i], latestBidStore[bidders[i]][_productId]);          
            }
            else if(latestBidStore[bidders[i]][_productId] != 0 && latestBidStore[bidders[i]][_productId] == product[_productId].latestBid.bidValue) {
                // max bid is sent to the seller
                tokenContract.transfer(msg.sender, latestBidStore[bidders[i]][_productId]);
            }
        }
        
        // UPGRADE : supplychain triggered on Bid Finalization, 
        //           approve the supply chain to ... onSuccess() -> transfer money to the seller
        //           on failure -> refund back to buyer

    }

    // supply chain and locking 

}