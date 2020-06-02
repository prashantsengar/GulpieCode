pragma solidity ^0.6.8;
pragma experimental ABIEncoderV2;


import "github.com/OpenZeppelin/openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "github.com/OpenZeppelin/openzeppelin-solidity/contracts/math/SafeMath.sol";
import "github.com/OpenZeppelin/openzeppelin-solidity/contracts/access/Ownable.sol";

abstract contract StakingToken is ERC20, Ownable {
    using SafeMath for uint256;
    
    
    address public contract_owner;
    uint supply = 1000000000;
    constructor(address __owner) 
        public
    { 
        contract_owner = msg.sender;
        _mint(__owner, supply);
    }
    
    function burn(address reviewer, uint stakes) public{
        _burn(reviewer, stakes);
    }
    
    function return_owner() public returns(address){
        return contract_owner;
    }
    
    function reward(address person, uint reward_amount) public{
        _mint(person, reward_amount);
    }
}
    
contract Staking{

    StakingToken stakingToken = StakingToken(msg.sender);

    uint internal reviewCount;
    constructor() public{
        reviewCount = 0;
    }
    
    
    
struct Review{
        uint _id;
        uint rest_id;
        // string rest_namt;
        string text;
        uint rating;
        address reviewer;
        uint128 reviewer_stakes;
        int votes;
        uint128 stakes;
        mapping (address => int) validators;
        address payable[] allValidators;
        uint totalReviews;
        uint creationTime;
    }
    
    Review emptyReview;

struct PrintReview{
        uint _id;
        string text;
        uint rating;
    }
    
// mapping (uint => Review[]) private allReviews;
Review[] allReviews;

function getID() internal returns(uint){
    return ++reviewCount;
}

function createAccount(address person) public{
    stakingToken.reward(person, 50);
}

function writeReview(uint rest_id, uint _rating, string memory _text, uint128 _stakes, address reviewer) public {
    
    stakingToken.burn(reviewer, _stakes);
    
    emptyReview.validators[msg.sender]=0;
    address payable[] memory v;
    // allReviews.push(Review(allReviews.length+1, _text, _rating, msg.sender, int(_stakes), v, 0, now));
    uint review_id = getID();
    
    // allReviews[review_id] = Review(review_id, _text, _rating, msg.sender, int(_stakes), v, 0, now);
    allReviews.push(Review(review_id, rest_id, _text, _rating, reviewer, _stakes, int(_stakes), _stakes, v, 0, now));
}

function getReview(uint review_id) public view returns(PrintReview memory){
    PrintReview memory showreview;
    for (uint i = 0; i < allReviews.length; i++) {
            Review memory review = allReviews[i];
            if(review._id==review_id){
            showreview = PrintReview(review._id, review.text, review.rating);
                return showreview;
            }
        }
}

function getReviewIDs() public view returns(uint[] memory){
    uint len = allReviews.length;
    uint[] memory ids = new uint[](len);
    for (uint i = 0; i < len; i++) {
            Review memory review = allReviews[i];
            ids[i] = review._id;
        }
    return ids;
}


function AddVote(uint review_id, address payable validator, int votes, uint128 stakes) internal {
    Review storage review = allReviews[review_id-1];
    review.validators[validator] = votes;
    review.votes += votes;
    review.stakes += stakes;
    review.totalReviews+=1;
}


function Vote(uint review_id, address payable validator, bool up, uint128 tokens) public {
    // require(validator.tokens >= tokens, "Insufficient balance");
    int votes = 0;
    if (up){
        votes+=tokens;
    } 
    else{
        votes-=tokens;
    }
    stakingToken.burn(validator, tokens);
    AddVote(review_id, validator, votes, tokens);
}

modifier OwnerOnly{
    (address(msg.sender) != stakingToken.return_owner());
    _;
}

function giveReward(address payable person, uint reward_amount) internal{
    stakingToken.reward(person, reward_amount);
}

function Reward(uint review_id) OwnerOnly public{
    require(orderStatus(review_id), "Not yet");
    Review storage review = allReviews[review_id];
    uint total = review.stakes;
    


    if (total>0){
        giveReward(payable(review.reviewer), total/2); // pay half to the reviewer
        
        total = total - total/2;
        
        uint positive_reviewers = 0;
        
        for( uint i=0; i<review.allValidators.length; i++){
            if ( review.validators[review.allValidators[i]] > 0){
                positive_reviewers++;
            }
        }
        
        for( uint i=0; i<review.allValidators.length; i++){
            if ( review.validators[review.allValidators[i]] > 0){
                giveReward(review.allValidators[i], total/positive_reviewers);
            }
        }
    }
    
    // if invalidated review
    else if (total<0){
        
        uint negative_reviewers = 0;
        
        for( uint i=0; i<review.allValidators.length; i++){
            if ( review.validators[review.allValidators[i]] < 0){
                negative_reviewers++;
            }
        }
        
        for( uint i=0; i<review.allValidators.length; i++){
            if ( review.validators[review.allValidators[i]] < 0){
                giveReward(review.allValidators[i], total/negative_reviewers);
            }
        }
    }
    
    else if (total==0){
        
        
        for( uint i=0; i<review.allValidators.length; i++){
            uint reward = 0;
            
            if (review.validators[review.allValidators[i]]<0){
                reward = uint(-1*review.validators[review.allValidators[i]]);
            }
            else{
                reward = uint(review.validators[review.allValidators[i]]);   
            }
            giveReward(review.allValidators[i], reward);
        }
    }
}

function orderStatus(uint review_id) internal view returns (bool) {
    Review memory review = allReviews[review_id-1];
    if (now < review.creationTime + 5 seconds) {
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
