// SPDX-License-Identifier: MIt
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";

contract DeployFundMe is Script
{
    function run() external returns (FundMe)
    {
        //before broadcast not a real transaction
        //after broadcast is a real transaction
        HelperConfig helperconfig = new HelperConfig();
        address EthUSDpricefeed = helperconfig.activeNetworkConfig();
        vm.startBroadcast();
        FundMe fundMe =new FundMe(EthUSDpricefeed);
        vm.stopBroadcast();
        return fundMe;
    }
}