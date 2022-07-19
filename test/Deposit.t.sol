// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../src/Deposit.sol";
import "forge-std/Test.sol";


interface CheatCodes {
    function prank(address, address) external;

    // Sets the *next* call's msg.sender to be the input address, and the tx.origin to be the second input
    function prank(address) external;

    // Sets the *next* call's msg.sender to be the input address
    function assume(bool) external;

    // When fuzzing, generate new inputs if conditional not met
    function deal(address who, uint256 newBalance) external;
    // Sets an address' balance
}


contract DepositTest is Test {
    CheatCodes cheats = CheatCodes(HEVM_ADDRESS);

    Deposit deposit;

    function setUp() public {
        cheats.prank(address(777));
        deposit = new Deposit();
    }

    function testValid1() public {
        cheats.deal(address(1), 5 ether);
        cheats.prank(address(1));
        (bool sent, bytes memory data) = address(deposit).call{value: 0.1 ether}("");
        assertTrue((sent));
        assertEq(deposit.accessMapping(address(1)), 1);
                assertFalse(deposit.isWhitelisted());

    }

    function testValid2() public {
        cheats.deal(address(2), 5 ether);
        cheats.prank(address(2));
        (bool sent, bytes memory data) = address(deposit).call{value: 0.2 ether}("");
        assertTrue((sent));
        assertEq(deposit.accessMapping(address(2)), 2);
        assertFalse(deposit.isWhitelisted());
        //assertEq(deposit == msg.sender);
    }

    function testValid3() public {
        cheats.deal(address(3), 5 ether);
        cheats.prank(address(3));
        (bool sent, bytes memory data) = address(deposit).call{value: 0.3 ether}("");
        assertTrue(sent);
        assertEq(deposit.accessMapping(address(3)), 3);
        assertFalse(deposit.isWhitelisted());

    }

    function testValid4() public {
        cheats.deal(address(4), 5 ether);
        cheats.prank(address(4));
        (bool sent, bytes memory data) = address(deposit).call{value: 0.4 ether}("");
        assertTrue(sent);
        assertEq(deposit.accessMapping(address(4)), 4);
        assertFalse(deposit.isWhitelisted());

    }

    function testValid5() public {
        cheats.deal(address(5), 5 ether);
        cheats.prank(address(5));
        (bool sent, bytes memory data) = address(deposit).call{value: 0.5 ether}("");
        assertTrue(sent);
        assertEq(deposit.accessMapping(address(5)), 5);
        assertFalse(deposit.isWhitelisted());

        //assertEq(deposit == msg.sender);
    }

    function testValid6() public {
        cheats.deal(address(5), 5 ether);
        cheats.prank(address(5));
        (bool sent, bytes memory data) = address(deposit).call{value: 0.3 ether}("");
        assertTrue(sent);
        assertEq(deposit.accessMapping(address(5)), 3);
        assertFalse(deposit.isWhitelisted());

        //assertEq(deposit == msg.sender);
    }

    function testFail1() public {
        cheats.deal(address(1), 5 ether);
        cheats.prank(address(1));
        (bool sent, bytes memory data) = address(deposit).call{value: 0.9 ether}("");
        require(sent, "Failed to send Ether");
    }

    function testFail2() public {
        cheats.deal(address(2), 5 ether);
        cheats.prank(address(2));
        (bool sent, bytes memory data) = address(deposit).call{value: 0.5 ether}("");
        require(sent, "Failed to send Ether");
    }

    function testFailToggle() public {
        cheats.prank(address(1));
        deposit.activeToggle();
    }

    function testFailCashOut() public {
        cheats.prank(address(1));
        deposit.transferBalance();
    }


    function testCashOut() public {
        cheats.deal(address(1), 5 ether);
        cheats.prank(address(1));
        address(deposit).call{value: 0.1 ether}("");

        cheats.deal(address(2), 5 ether);
        cheats.prank(address(2));
        address(deposit).call{value: 0.2 ether}("");

        cheats.deal(address(3), 5 ether);
        cheats.prank(address(3));
        address(deposit).call{value: 0.3 ether}("");

        cheats.prank(address(777));
        deposit.transferBalance();
        assertEq(address(777).balance, 0.6 ether);
    }


}