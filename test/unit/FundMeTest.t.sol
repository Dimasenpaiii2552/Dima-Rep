// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundme;

    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;

    address USER = makeAddr("USER");
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        // fundme = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployfundme = new DeployFundMe();
        fundme = deployfundme.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinumumDollar_is_5Demo() public view {
        assertEq(fundme.MINIMUM_USD(), 5e18);
    }

    function testownerismsgsender() public view {
        assertEq(fundme.getowner(), msg.sender);
    }

    function testPriceFeeVersionIsAccurate() public view {
        uint256 version = fundme.getVersion();
        assertEq(version, 4);
    }

    function testFundFailwithoutenoughEth() public {
        vm.expectRevert();
        fundme.fund();
    }

    function testFundUpdatesFundedDataStructures() public {
        vm.prank(USER);
        fundme.fund{value: SEND_VALUE}();

        uint256 amountFunded = fundme.getAddresstoAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddFunderstoArrayofFunders() public {
        // check if funder is added to array of funder
        // Needs
        //1. Get funder
        //2. check if funder is added to array of funder
        vm.prank(USER);
        fundme.fund{value: SEND_VALUE}();
        address theFunder = fundme.getfunders(0);
        assertEq(theFunder, USER);
    }

    modifier m_funded() {
        vm.prank(USER);
        fundme.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public m_funded {
        // check if only owner can call withdraw function
        // get address to sender
        // check if msg.sender = owner

        vm.prank(USER);
        vm.expectRevert();
        fundme.withdraw();
    }

    function testWithdraWithASngleSender() public m_funded {
        //Arrange
        uint256 startingOwnerBalance = fundme.getowner().balance;
        uint256 StartingFundMebalance = address(fundme).balance;

        //Act
        uint256 gasStart = gasleft();
        vm.txGasPrice(GAS_PRICE);
        vm.prank(fundme.getowner());
        fundme.withdraw();
        uint256 gasEnd = gasleft();
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        console.log(gasStart);
        console.log(gasEnd);
        console.log(gasUsed);

        //Assert
        uint256 endingOwnerBalance = fundme.getowner().balance;
        uint256 endingFundMeBalance = address(fundme).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            StartingFundMebalance + startingOwnerBalance,
            endingOwnerBalance
        );
    }

    function testWithdrawFromMultipleFunders() public m_funded {
        // Arrange
        uint160 numberofFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberofFunders; i++) {
            //vm.prank
            //vm.deal
            hoax(address(i), SEND_VALUE);
            fundme.fund{value: SEND_VALUE}();
            //fund the fundme
        }

        uint256 startingOwnerBalance = fundme.getowner().balance;
        uint256 StartingFundMebalance = address(fundme).balance;

        //Act

        vm.startPrank(fundme.getowner());
        fundme.withdraw();
        vm.stopPrank();

        //Assert

        assertEq(address(fundme).balance, 0);
        assertEq(
            StartingFundMebalance + startingOwnerBalance,
            fundme.getowner().balance
        );
    }

    function testWithdrawFromMultipleFunderscheaper() public m_funded {
        // Arrange

        uint160 numberofFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberofFunders; i++) {
            //vm.prank
            //vm.deal
            hoax(address(i), SEND_VALUE);
            fundme.fund{value: SEND_VALUE}();
            //fund the fundme
        }

        uint256 startingOwnerBalance = fundme.getowner().balance;
        uint256 StartingFundMebalance = address(fundme).balance;

        //Act

        vm.startPrank(fundme.getowner());
        fundme.cheaperWithdraw();
        vm.stopPrank();

        //Assert

        assertEq(address(fundme).balance, 0);
        assertEq(
            StartingFundMebalance + startingOwnerBalance,
            fundme.getowner().balance
        );
    }
}
