pragma solidity ^0.6.8;
pragma experimental ABIEncoderV2;

// import "./erc20.sol";
// import "./SafeMath.sol";
// import "./Ownable.sol";

/**
* @title Staking Token (STK)
* @author Alberto Cuesta Canada
* @notice Implements a basic ERC20 staking token with incentive distribution.
*/
// contract StakingToken is ERC20, Ownable {
contract Staking{
//    using SafeMath for uint256;

//    /**
//     * @notice The constructor for the Staking Token.
//     * @param _owner The address to receive all tokens on construction.
//     * @param _supply The amount of tokens to mint on construction.
//     */
//    constructor(address _owner, uint256 _supply)
//        public
//    {
//        _mint(_owner, _supply);
//    }

    address owner;
    constructor() public{
        owner = msg.sender;
    }

struct Review{
        uint _id;
        string text;
        uint rating;
        address reviewer;
        int votes;
        mapping (address => int) validators;
        address[] allValidators;
        uint totalReviews;
        uint creationTime;
    }
    
    Review emptyReview;

struct PrintReview{
        uint _id;
        string text;
        uint rating;
    }

Review[] private allReviews;

function writeReview(uint _rating, string memory _text) public {
    emptyReview.validators[msg.sender]=0;
    address[] memory v;
    allReviews.push(Review(allReviews.length+1, _text, _rating, msg.sender, 0, v, 0, now));
}

function getReview(uint index) public view returns(PrintReview memory){
    PrintReview[20] memory reviews;
    for (uint i = 0; i < allReviews.length; i++) {
            Review memory review = allReviews[i];
            reviews[i] = PrintReview(review._id, review.text, review.rating);
        }
    return reviews[index];
}

function getReviewsLength() public view returns(uint){
    return allReviews.length;
}


function AddVote(uint review_id, address validator, int tokens) internal {
    Review storage review = allReviews[review_id-1];
    review.validators[validator] = tokens;
    review.votes += tokens;
    review.totalReviews+=1;
}


function Vote(uint review_id, address validator, bool up, uint128 tokens) public {
    // require(validator.tokens >= tokens, "Insufficient balance");
    int stakes = 0;
    if (up){
        stakes+=tokens;
    } 
    else{
        stakes-=tokens;
    }
    AddVote(review_id, validator, stakes);
}

modifier OwnerOnly{
    (msg.sender != owner);
    _;
}

function giveReward(address person) internal{
    // reward user
}

function Reward(uint review_id) OwnerOnly public{
    require(orderStatus(review_id), "Not yet");
    Review storage review = allReviews[review_id];
    int total = review.votes;

    if (total>0){
        giveReward(review.reviewer);
        for( uint i=0; i<review.allValidators.length; i++){
            if ( review.validators[review.allValidators[i]] > 0){
                giveReward(review.allValidators[i]);
            }
        }
    }
}

function orderStatus(uint review_id) public view returns (bool) {
    Review memory review = allReviews[review_id-1];
    if (now < review.creationTime + 2 days) {
        return false;
    } else {
        return true;
    }
}







}



    
    // function setname(string memory n) public returns(address){
    //     name = n;
    //     return msg.sender;
    // }
// }