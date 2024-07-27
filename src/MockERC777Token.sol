// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./IERC777.sol";
import {Test, console} from "forge-std/Test.sol";


contract ERC777Token {
    string public name;
    string public symbol;
    uint256 public totalSupply;
    uint8 public decimals;
    address public owner;
    
    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Minted(address indexed operator, address indexed to, uint256 amount, bytes data, bytes operatorData);
    event Burned(address indexed operator, address indexed from, uint256 amount, bytes data, bytes operatorData);

    constructor() {
        name = "token01";
        symbol = "token01";
        decimals = 18;
        totalSupply = 100_000_000 ether;
        balances[msg.sender] = totalSupply;
        owner = msg.sender;
    }

    modifier onlyOwner{
        require(msg.sender == owner, "ERC777: caller is not the owner");
        _;
    }

    function getowner() public returns (address) {
        return owner;
    }

    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _send(msg.sender, recipient, amount, "", "", true);
        return true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        uint256 currentAllowance = allowances[sender][msg.sender];
        require(currentAllowance >= amount, "ERC777: transfer amount exceeds allowance");
        allowances[sender][msg.sender] = currentAllowance - amount;
        _send(sender, recipient, amount, "", "", true);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return allowances[owner][spender];
    }

    function mint(address account, uint256 amount) onlyOwner public returns (bool) {
        totalSupply += amount;
        balances[account] += amount;
        emit Minted(msg.sender, account, amount, "", "");
        emit Transfer(address(0), account, amount);
        return true;
    }

    function burn(uint256 amount) public onlyOwner {
        require(balances[msg.sender] >= amount, "ERC777: burn amount exceeds balance");
        balances[msg.sender] -= amount;
        totalSupply -= amount;
        emit Burned(msg.sender, msg.sender, amount, "", "");
        emit Transfer(msg.sender, address(0), amount);
    }

    function _send(
        address from,
        address to,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData,
        bool requireReceptionAck
    ) internal {
        require(from != address(0), "ERC777: transfer from the zero address");
        require(to != address(0), "ERC777: transfer to the zero address");
        require(balances[from] >= amount, "ERC777: transfer amount exceeds balance");

        balances[from] -= amount;
        balances[to] += amount;

        if (requireReceptionAck) {
            require(
                _checkOnERC777Received(from, to, amount, userData, operatorData),
                "ERC777: transfer to non ERC777Recipient implementer"
            );
        }

        emit Transfer(from, to, amount);
    }

    function _checkOnERC777Received(
        address from,
        address to,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData
    ) private returns (bool) {
        // if (to.code.length > 0) {
        console.log("115");
            try IERC777Recipient(to).tokensReceived(msg.sender, from, to, amount, userData, operatorData) {
                return true;
            } catch {
                return false;
            }
        // }
        return true;
    }
}