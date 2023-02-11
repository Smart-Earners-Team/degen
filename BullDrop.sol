// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;
    mapping (address => bool) internal authorizations;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        authorizations[_owner] = true;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * Function modifier to require caller to be authorized
     */
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    /**
     * Return address' authorization status
     */
    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    /**
     * Authorize address. Owner only
     */
    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    /**
     * Remove address' authorization. Owner only
     */
    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }


    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address payable newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        authorizations[newOwner] = true;
        _owner = newOwner;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

contract BullDrop is Ownable {

    using SafeMath for uint256;
    
    // stores the total number of users
    uint public totalBULLs;
    uint public totalRefBonus;
    uint public maxBULLs = 10000;
    uint public dropAmount = 1000000000000;
    uint256[2] public refPercents = [1000, 500];


    bool public bullDropStarted = false;

    address public coreBull = 0x5d5f095Da71F2169A4154C4e9540f13ec3fC2E12;

    struct User {
        uint checkpoint;
        uint bullDrop;
        address referrer;
        uint bonus;
        uint[2] refs;
        address[] children;
        uint redeemed;
    }

    event RefBonus(
        address indexed referrer,
        address indexed user,
        uint256 indexed level,
        uint256 amount
    );

    mapping (address => User) public users;

    constructor () {
    }

    function userInfo(address _user) public view returns(User memory) {
        return users[_user];
    }

    function claimBULL(address ref) public payable {
        User storage user = users[msg.sender];

        require(bullDropStarted == true, 'BullDrop: Airdrop not active.');
        require(totalBULLs <= maxBULLs, "All $BULL's have been claimed");
        require(user.bullDrop == 0, "This user already claimed $BULL's");

        IERC20(coreBull).transfer(address(msg.sender), dropAmount);
        user.bullDrop = dropAmount;

        if(ref == msg.sender) {
            ref = address(owner());
        }

        if(user.referrer == address(0) && user.referrer != msg.sender) {
            user.referrer = ref;
        }

        address upline = user.referrer;
        for (uint256 i = 0; i < 2; i++) {
            if (upline != address(0)) {
                uint256 bonusAmount = dropAmount.mul(refPercents[i]).div(10000);
                if (bonusAmount > 0) {
                    users[upline].bonus += bonusAmount;
                    totalRefBonus += bonusAmount;
                    emit RefBonus(upline, msg.sender, i, bonusAmount);
                }
                upline = users[upline].referrer;
            } else break;
        }

        addChild(msg.sender);

        address uplineX = user.referrer;
        for (uint i = 0; i < user.children.length; i++) {
                if (uplineX != address(0)) {
                    users[uplineX].refs[i]++;
                    uplineX = users[uplineX].referrer;
                } else break;
        }

        user.checkpoint = block.timestamp;
        totalBULLs++;
    }

    function redeemBUULs() public payable {
        require(bullDropStarted == true, 'BullDrop: Airdrop not active.');
        uint256 quota = IERC20(coreBull).balanceOf(address(this));
        uint redeemableAmount = users[msg.sender].bonus;
        require(redeemableAmount <= quota, "$BULL DROP: Quota not enough.");

        IERC20(coreBull).transfer(msg.sender, redeemableAmount);
        users[msg.sender].bonus -= redeemableAmount;
        users[msg.sender].redeemed += redeemableAmount;

    }

    function addChild(address _user) internal {
        address upline = users[_user].referrer;

        for (uint256 i = 0; i < users[upline].children.length; i++) {
            if (users[upline].children[i] == _user) {
                // Child address is already in the array, return
                return;
            }

        }
        users[upline].children.push(_user);   
    }

    function setBullDropStarted(bool _status) external onlyOwner {
        require(bullDropStarted != _status, "Not changed");
        bullDropStarted = _status;
    }

    function setDropAmount(uint256 newRate) external onlyOwner {
        dropAmount = newRate;
    }

    function setTokens(address _tokenOut) external onlyOwner {
        coreBull = _tokenOut;
    }

    function recoverWrongTokens(address _tokenAddress, uint256 _tokenAmount) external onlyOwner {
        IERC20(_tokenAddress).transfer(address(msg.sender), _tokenAmount);
        emit AdminTokenRecovery(_tokenAddress, _tokenAmount);
    }
	
	function withdraw() public payable onlyOwner {
        (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(success);
    }	

    event AdminTokenRecovery(address tokenRecovered, uint256 amount);

}
