// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ReferralToken {
    // Token details
    string public name = "ReferralToken";
    string public symbol = "RTK";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    // Mapping for balances and allowances
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    // Events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event ReferralReward(address indexed referrer, address indexed learner, uint256 reward);

    // Owner of the contract
    address public owner;

    // Referral bonus configuration
    uint256 public referralBonus = 10 * (10 ** uint256(decimals)); // 10 RTK

    constructor(uint256 _initialSupply) {
        owner = msg.sender;
        totalSupply = _initialSupply * (10 ** uint256(decimals));
        balanceOf[owner] = totalSupply;
        emit Transfer(address(0), owner, totalSupply);
    }

    // Modifier to restrict actions to the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    // Transfer tokens
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    // Approve tokens for spending
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    // Transfer tokens on behalf of the owner
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value, "Insufficient balance");
        require(allowance[_from][msg.sender] >= _value, "Allowance exceeded");
        balanceOf[_from] -= _value;
        allowance[_from][msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    // Reward referrer with tokens
    function rewardReferrer(address _referrer, address _learner) public onlyOwner {
        require(balanceOf[owner] >= referralBonus, "Insufficient tokens in the contract");
        balanceOf[owner] -= referralBonus;
        balanceOf[_referrer] += referralBonus;
        emit ReferralReward(_referrer, _learner, referralBonus);
    }

    // Update referral bonus
    function setReferralBonus(uint256 _bonus) public onlyOwner {
        referralBonus = _bonus * (10 ** uint256(decimals));
    }
}
