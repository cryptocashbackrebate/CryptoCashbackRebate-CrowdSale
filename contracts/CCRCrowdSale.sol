pragma solidity ^0.4.18;

/*
 * CCR Token Crowdsale Smart Contract.  @ 2018 by Kapsus Technoloies Limited (www.kapsustech.com).
 * Author: Susanta Saren <business@cryptocashbackrebate.com>
 */

import "../token/Ownable.sol";
import "./CCRToken.sol";

contract CCRCrowdsale is Ownable {

    using SafeMath for uint;

    event TokensPurchased(address indexed buyer, uint256 ether_amount);
    event CCRCrowdsaleClosed();

    CCRToken public token = new CCRToken();

    address public multisigVault = 0x4f39C2f050b07b3c11B08f2Ec452eD603a69839D;

    uint256 public totalReceived = 0;
    uint256 public hardcap = 416667 ether;
    uint256 public minimum = 0.10 ether;

    uint256 public altDeposits = 0;
    uint256 public start = 1521338401; // 18 March, 2018 02:00:01 GMT
    bool public saleOngoing = true;

    /**
    * @dev modifier to allow token creation only when the sale IS ON
    */
    modifier isSaleOn() {
    require(start <= now && saleOngoing);
    _;
    }

    /**
    * @dev modifier to prevent buying tokens below the minimum required
    */
    modifier isAtLeastMinimum() {
    require(msg.value >= minimum);
    _;
    }

    /**
    * @dev modifier to allow token creation only when the hardcap has not been reached
    */
    modifier isUnderHardcap() {
    require(totalReceived + altDeposits <= hardcap);
    _;
    }

    function CCRCrowdsale() public {
    token.pause();
    }

    /*
    * @dev Receive eth from the sender
    * @param sender the sender to receive tokens.
    */
    function acceptPayment(address sender) public isAtLeastMinimum isUnderHardcap isSaleOn payable {
    totalReceived = totalReceived.add(msg.value);
    multisigVault.transfer(this.balance);
    TokensPurchased(sender, msg.value);
  }

    /**
    * @dev Allows the owner to set the starting time.
    * @param _start the new _start
    */
    function setStart(uint256 _start) external onlyOwner {
    start = _start;
    }

    /**
    * @dev Allows the owner to set the minimum purchase.
    * @param _minimum the new _minimum
    */
    function setMinimum(uint256 _minimum) external onlyOwner {
    minimum = _minimum;
    }

    /**
    * @dev Allows the owner to set the hardcap.
    * @param _hardcap the new hardcap
    */
    function setHardcap(uint256 _hardcap) external onlyOwner {
    hardcap = _hardcap;
    }

    /**
    * @dev Allows to set the total alt deposit measured in ETH to make sure the hardcap includes other deposits
    * @param totalAltDeposits total amount ETH equivalent
    */
    function setAltDeposits(uint256 totalAltDeposits) external onlyOwner {
    altDeposits = totalAltDeposits;
    }

    /**
    * @dev Allows the owner to set the multisig contract.
    * @param _multisigVault the multisig contract address
    */
    function setMultisigVault(address _multisigVault) external onlyOwner {
    require(_multisigVault != address(0));
    multisigVault = _multisigVault;
    }

    /**
    * @dev Allows the owner to stop the sale
    * @param _saleOngoing whether the sale is ongoing or not
    */
    function setSaleOngoing(bool _saleOngoing) external onlyOwner {
    saleOngoing = _saleOngoing;
    }

    /**
    * @dev Allows the owner to close the sale and stop accepting ETH.
    * The ownership of the token contract is transfered to this owner.
    */
    function closeSale() external onlyOwner {
    token.transferOwnership(owner);
    CCRCrowdsaleClosed();
    }    

    /**
    * @dev Allows the owner to transfer ERC20 tokens to the multisig vault
    * @param _token the contract address of the ERC20 contract
    */
    function retrieveTokens(address _token) external onlyOwner {
    ERC20 foreignToken = ERC20(_token);
    foreignToken.transfer(multisigVault, foreignToken.balanceOf(this));
    }

    /**
    * @dev Fallback function which receives ether
    */
    function() external payable {
    acceptPayment(msg.sender);
    }
}