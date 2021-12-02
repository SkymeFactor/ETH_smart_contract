// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

contract MyWallet_v1_0_0 {
    // Contract owner, comission usage, commission size in per cents
    address payable private owner;
    bool using_fee;
    uint private fee_size;

    // Clients' balances
    mapping (address => uint) balances;
    // Clients' allowance
    mapping(address => mapping (address => uint256)) allowance;

    // Transfer coins event will reflect on blockchain
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed loaner, address indexed delegate, uint tokens);

    // Set default values in constructor
    constructor() {
        owner = payable(msg.sender);    // Might be hardcoded though
        using_fee = true;
        fee_size = 2;
    }

    // Transfer wei from your account to other ethereum acount
    function withdraw(address payable receiver, uint amount) public payable {
        if (balances[msg.sender] < amount) return;
        if (using_fee) {
            uint fee = amount / 100 * fee_size;
            balances[msg.sender] -= fee;
            balances[owner] += fee;
            amount -= fee;
        }
        balances[msg.sender] -= amount;
        receiver.transfer(amount);
    }

    // Receive wei from anywhere else
    receive() external payable {
        balances[msg.sender] += msg.value;
    }

    // Transfer tokens between the contract accounts
    function transferTokens(address receiver, uint amount) public {
        if (balances[msg.sender] < amount) return;
        balances[msg.sender] -= amount;
        balances[receiver] += amount;
        emit Transfer(msg.sender, receiver, amount);
    }

    // Transfer allowed tokens from given loaner
    function transferTokensFromTo(address loaner, address receiver, uint amount) public {
        if (amount > balances[loaner]) return;
        if (amount > allowance[loaner][msg.sender]) return;

        balances[loaner] -= amount;
        allowance[loaner][msg.sender] -= amount;
        balances[receiver] += amount;
        emit Transfer(loaner, receiver, amount);
    }

    // Approve the allowance to somebody
    function setAllowance(address delegate, uint amount) public {
        allowance[msg.sender][delegate] = amount;
        emit Approval(msg.sender, delegate, amount);
    }

    // Receive your allowance from a loaner
    function getAllowance(address loaner) view public returns (uint) {
        return allowance[loaner][msg.sender];
    }

    // Set commission usage
    function setFee(bool use_fee) public {
        if (msg.sender != owner) return;
        using_fee = use_fee;
    }

    // Comission size change
    function setFeeSize(uint fee) public {
        if (msg.sender != owner || fee > 100) return;
        fee_size = fee;
    }

    // Receive your balance value
    function getBalance(address account) view public returns (uint) {
        return balances[account];
    }
}