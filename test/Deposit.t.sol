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
        uint i = deposit.accessMapping(address(1));
        assertEq(i, 1);
    }

    function testValid2() public {
        cheats.deal(address(2), 5 ether);
        cheats.prank(address(2));
        (bool sent, bytes memory data) = address(deposit).call{value: 0.2 ether}("");
        uint i = deposit.accessMapping(address(2));
        assertEq(i, 2);
        //assertEq(deposit == msg.sender);
    }

    function testValid3() public {
        cheats.deal(address(3), 5 ether);
        cheats.prank(address(3));
        (bool sent, bytes memory data) = address(deposit).call{value: 0.3 ether}("");
        assertEq(sent, true);
    }

    function testValid4() public {
        cheats.deal(address(1), 5 ether);
        cheats.prank(address(1));
        (bool sent, bytes memory data) = address(deposit).call{value: 0.4 ether}("");
        //assertEq(deposit == msg.sender);
    }

    function testValid5() public {
        cheats.deal(address(1), 5 ether);
        cheats.prank(address(1));
        (bool sent, bytes memory data) = address(deposit).call{value: 0.5 ether}("");
        //assertEq(deposit == msg.sender);
    }

    function testFail1() public {
        cheats.deal(address(1), 5 ether);
        cheats.prank(address(1));
        (bool sent, bytes memory data) = address(deposit).call{value: 0.12 ether}("");
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
        (bool sent, bytes memory data) = address(deposit).call{value: 0.2 ether}("");

        cheats.prank(address(777));
        deposit.transferBalance();
        assertEq(address(777).balance, 0.2 ether);
    }


}