// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import "../src/MockERC777Token.sol";
import "../src/Attacker.sol";

contract CounterTest is Test {
    function setUp() public {

    }

    function testCreateAndDelegateCall() public {
        ERC777Token token01 = new ERC777Token("token01", "token01");
        console.log("total supply: ", token01.totalSupply());
        console.log("token01 owner: ", token01.owner());

        Attacker attacker = new Attacker();
        attacker.setVictimToken(address(token01));
        console.log("victim token address: ", attacker.getVictimToken());

        string memory denom = "token01";
        attacker.setVictimTokenDenom(denom);
        console.log("victim token: ", attacker.getVictimTokenDenom());

        token01.transfer(address(attacker), 100);
    }
}
