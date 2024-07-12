// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test
{
    FundMe fundMe; 
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 20 ether;
    uint256 constant GAS_PRICE=1;
    function setUp() external 
    {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe= deployFundMe.run();
        vm.deal(USER,STARTING_BALANCE);
    }

    function testminimumdollaris5 () public view
    {
        assertEq(fundMe.MINIMUM_USD() , 5e18);
    }

    function testOwnerIsMsgSender() public view
    {
      assertEq(fundMe.getOwner(), msg.sender);  
    }

    
    function testPriceFeedIsAccurate () public view
    {
       uint256 version = fundMe.getVersion();
       assertEq(version , 4);
    
    }

    function testFundFailsWithoutEnoughEth  () public
    {
        vm.expectRevert(); // the line after should revert , if it doesnt then the test fails 
        //uint256 cat =1 ;this has no reverting and all , so this fails expectRevert 
        fundMe.fund(); // no value , so default 0 eth , 0eth < 5eth (min eth func in fundme.sol) fails and reverts and hence expectRevert passes
    }

    function testFundUpdatesFundsDataStructures () public
    {
        vm.prank(USER); // the next Tx will be send by USER
        fundMe.fund{value:SEND_VALUE}();
        uint256 amountfunded= fundMe.getAddressToAmountFunded(USER);
        assertEq(amountfunded,SEND_VALUE);
    }

    function testAddFunderToFundersArray () public 
    {
        vm.prank(USER);
        fundMe.fund{value:SEND_VALUE}();//everytime we run test the setup function gets executed and whatever data we saved on the last test gets reset 
        
        address funder = fundMe.getfunder(0);
        assertEq(funder , USER);
    } 

    modifier funded() 
    {
        vm.prank(USER);
        fundMe.fund{value:SEND_VALUE}();  
        _;
    }

    function testOnlyOwnerCanWithdraw  () funded public
    {
        vm.prank(USER);
        fundMe.fund{value:SEND_VALUE}();

        vm.expectRevert();// this vm ignores other vm statements , it will check next statement
        vm.prank(USER);
        fundMe.withdraw();// two lines make USER to withdraw funds , for which the modifier onlyOwner will revert hence test shall pass
    
    }

    function testWithdrawWithASingleFunder() public funded
    {
        //arrange
        uint256 startingownerbalance = fundMe.getOwner().balance;
        uint256 startingFundmeBalance= address(fundMe).balance;

        //Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        //assert
        uint256 endingownerbalance = fundMe.getOwner().balance;
        uint256 endingFundmebalance = address(fundMe).balance;
        assertEq(endingFundmebalance,0);
        assertEq(startingFundmeBalance+startingownerbalance , endingownerbalance);
    }

    function testWithdrawWithAMultipleFunder () public funded
    {
        //arrange
        uint160 numberOfFunders =10;
        uint160 startingfunderindex =2;
        //vm prank new address
        //vm deal new address
        //address()
        for(uint160 i=startingfunderindex ; i<numberOfFunders ; i++)
        {
        
        hoax(address(i), SEND_VALUE);
        fundMe.fund{value :SEND_VALUE}();
        }

        uint256 startingownerbalance = fundMe.getOwner().balance;
        uint256 startingFundmeBalance= address(fundMe).balance;
        //act
    
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();
        //assert
        
        assert(address(fundMe).balance==0);
        assert(startingFundmeBalance+startingownerbalance==fundMe.getOwner().balance);
        

    }

    function testWithdrawWithAMultipleFunderCheaper () public funded
    {
        //arrange
        uint160 numberOfFunders =10;
        uint160 startingfunderindex =2;
        //vm prank new address
        //vm deal new address
        //address()
        for(uint160 i=startingfunderindex ; i<numberOfFunders ; i++)
        {
        
        hoax(address(i), SEND_VALUE);
        fundMe.fund{value :SEND_VALUE}();
        }

        uint256 startingownerbalance = fundMe.getOwner().balance;
        uint256 startingFundmeBalance= address(fundMe).balance;
        //act
    
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperwithdraw();
        vm.stopPrank();
        //assert
        
        assert(address(fundMe).balance==0);
        assert(startingFundmeBalance+startingownerbalance==fundMe.getOwner().balance);
        

    }
}