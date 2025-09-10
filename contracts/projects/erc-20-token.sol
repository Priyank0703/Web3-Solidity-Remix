// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

contract ERC20 is IERC20 {
    uint256 public override totalSupply = 1000;
    uint8 public decimals = 0;
    string public name = "TestToken";
    string public symbol = "TTK";mapping(address => uint256) public balanceOf;
mapping(address => mapping(address => uint256)) public allowances;

constructor() {
    balanceOf[msg.sender] = totalSupply;
}

function transfer(address to, uint256 value) external override returns (bool) {
    require(balanceOf[msg.sender] >= value, "Insufficient balance");
    require(to != address(0), "Invalid address");

    balanceOf[msg.sender] -= value;
    balanceOf[to] += value;

    emit Transfer(msg.sender, to, value);
    return true;
}

function allowance(address owner, address spender) external view override returns (uint256) {
    return allowances[owner][spender];
}

function approve(address spender, uint256 value) external override returns (bool) {
    require(spender != address(0), "Invalid address");

    allowances[msg.sender][spender] = value;

    emit Approval(msg.sender, spender, value);
    return true;
}

function transferFrom(address from, address to, uint256 value) external override returns (bool) {
    require(allowances[from][msg.sender] >= value, "Allowance exceeded");
    require(balanceOf[from] >= value, "Insufficient balance");
    require(to != address(0), "Invalid address");

    allowances[from][msg.sender] -= value;
    balanceOf[from] -= value;
    balanceOf[to] += value;

    emit Transfer(from, to, value);
    return true;
}
}