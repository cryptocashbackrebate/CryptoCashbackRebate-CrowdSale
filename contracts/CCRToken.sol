pragma solidity ^0.4.18;

/*
 * CCR Token Smart Contract.  @ 2018 by Kapsus Technoloies Limited (www.kapsustech.com).
 * Author: Susanta Saren <business@cryptocashbackrebate.com>
 */

import "../token/MintableToken.sol";
import "../token/PausableToken.sol";

contract CCRToken is MintableToken, PausableToken {
    using SafeMath for uint256;

    string public constant name = "CryptoCashbackRebate Token";
    string public constant symbol = "CCR";
    uint32 public constant decimals = 18;
}