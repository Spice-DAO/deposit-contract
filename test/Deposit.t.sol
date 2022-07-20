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
        (bool sent, bytes memory data) = address(deposit).call{
            value: 0.1 ether
        }("");
        assertTrue((sent));
        assertEq(deposit.getCountMapping(address(1)), 1);
        cheats.prank(address(1));
        assertEq(deposit.getDepositMapping(address(1)), 0.1 ether);
        assertFalse(deposit.isWhitelisted());
    }

    function testValid2() public {
        cheats.deal(address(2), 5 ether);
        cheats.prank(address(2));
        (bool sent, bytes memory data) = address(deposit).call{
            value: 0.2 ether
        }("");
        assertTrue((sent));
        assertEq(deposit.getCountMapping(address(2)), 2);
        cheats.prank(address(2));
        assertEq(deposit.getDepositMapping(address(2)), 0.2 ether);
        assertFalse(deposit.isWhitelisted());
        //assertEq(deposit == msg.sender);
    }

    function testValid3() public {
        cheats.deal(address(3), 5 ether);
        cheats.prank(address(3));
        (bool sent, bytes memory data) = address(deposit).call{
            value: 0.3 ether
        }("");
        assertTrue((sent));
        assertEq(deposit.getCountMapping(address(3)), 3);
        cheats.prank(address(3));
        assertEq(deposit.getDepositMapping(address(3)), 0.3 ether);
        assertFalse(deposit.isWhitelisted());
    }

    function testValid4() public {
        cheats.deal(address(4), 5 ether);
        cheats.prank(address(4));
        (bool sent, bytes memory data) = address(deposit).call{
            value: 0.4 ether
        }("");
        assertTrue((sent));
        assertEq(deposit.getCountMapping(address(4)), 4);
        cheats.prank(address(4));
        assertEq(deposit.getDepositMapping(address(4)), 0.4 ether);
        assertFalse(deposit.isWhitelisted());
    }

    function testValid5() public {
        cheats.deal(address(5), 5 ether);
        cheats.prank(address(5));
        (bool sent, bytes memory data) = address(deposit).call{
            value: 0.5 ether
        }("");
        assertTrue((sent));
        assertEq(deposit.getCountMapping(address(5)), 5);
        cheats.prank(address(5));
        assertEq(deposit.getDepositMapping(address(5)), 0.5 ether);
        assertFalse(deposit.isWhitelisted());
        //assertEq(deposit == msg.sender);
    }

    function testValid6() public {
        cheats.deal(address(5), 5 ether);
        cheats.prank(address(5));
        (bool sent, bytes memory data) = address(deposit).call{
            value: 0.3 ether
        }("");
        assertTrue((sent));
        assertEq(deposit.getCountMapping(address(5)), 3);
        cheats.prank(address(5));
        assertEq(deposit.getDepositMapping(address(5)), 0.3 ether);
        assertFalse(deposit.isWhitelisted());
    }

    function testFail1() public {
        cheats.deal(address(1), 5 ether);
        cheats.prank(address(1));
        (bool sent, bytes memory data) = address(deposit).call{
            value: 0.9 ether
        }("");
        require(sent, "Failed to send Ether");
    }

    function testFail2() public {
        cheats.deal(address(2), 5 ether);
        cheats.prank(address(2));
        (bool sent, bytes memory data) = address(deposit).call{
            value: 0.5 ether
        }("");
        require(sent, "Failed to send Ether");
    }

    function testFail3() public {
        cheats.deal(address(3), 5 ether);
        cheats.prank(address(3));
        (bool sent, bytes memory data) = address(deposit).call{
            value: 0.3 ether
        }("");
        //assertTrue((sent));
        //assertEq(deposit.getCountMapping(address(3)), 3);
        //assertEq(deposit.getDepositMapping(address(3)), 0.3 ether);
        //assertFalse(deposit.isWhitelisted());

        cheats.deal(address(3), 5 ether);
        cheats.prank(address(3));
        address(deposit).call{value: 0.3 ether}("");
        vm.expectRevert("Not on whitelist!");
    }

    function testFailToggle() public {
        cheats.prank(address(1));
        deposit.activeToggle();
    }

    function testFailCashOut() public {
        cheats.prank(address(1));
        deposit.transferBalance(address(1));
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
        deposit.transferBalance(address(777));
        assertEq(address(777).balance, 0.6 ether);
    }

    // function testFailNewWhitelist() public {
    //     address[] memory a = new address[](2);
    //     a[0] = address(6);
    //     a[1] = address(7);

    //     deposit.updateWhitelist(a);
    //     assertEq(
    //         deposit.getWhitelist()[deposit.getWhitelist().length],
    //         address(7)
    //     );
    // }

    // function testNewWhitelist() public {
    //     address[] memory a = new address[](2);
    //     a[0] = address(6);
    //     a[1] = address(7);

    //     cheats.prank(address(777));
    //     deposit.updateWhitelist(a);
    //     //emit log_uint(deposit.getWhitelist().length);
    //     assertEq(deposit.getWhitelist()[6], address(7));
    // }

    // function testNewClaimedDepositAmount() public {
    //     uint256[] memory b = new uint256[](2);
    //     b[0] = 0.4 ether;
    //     b[1] = 0.5 ether;

    //     cheats.prank(address(777));
    //     deposit.updateClaimedDepositAmount(b);
    //     //emit log_uint(deposit.getClaimedDepositList().length);
    //     assertEq(deposit.getClaimedDepositList()[6], 0.5 ether);
    // }

    function testListUpdater() public {
        address[] memory a = new address[](2);
        a[0] = address(6);
        a[1] = address(7);

        uint256[] memory b = new uint256[](2);
        b[0] = 0.4 ether;
        b[1] = 0.5 ether;

        cheats.prank(address(777));
        deposit.updateLists(a, b);
        assertEq(deposit.getWhitelist()[6], address(7));
        assertEq(deposit.getClaimedDepositList()[6], 0.5 ether);

        //emit log_uint(deposit);
    }

    function testFailListUpdater() public {
        address[] memory a = new address[](1);
        a[0] = address(6);

        uint256[] memory b = new uint256[](2);
        b[0] = 0.4 ether;
        b[1] = 0.5 ether;

        cheats.prank(address(777));
        deposit.updateLists(a, b);
        //assertEq(deposit.getWhitelist()[6], address(7));
        //assertEq(deposit.getClaimedDepositList()[6], 0.5 ether);

        //emit log_uint(deposit);
    }
}
