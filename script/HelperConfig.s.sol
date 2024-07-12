// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18 ;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script
{
    uint8 public constant DECIMALS=8;
    int256 public constant INITIAL_PRICE = 2000e8;

    struct NetworkConfig {
        address PriceFeed;
        }
    
    NetworkConfig public activeNetworkConfig;

    constructor ()
    {
        if(block.chainid==11155111)
        {
            activeNetworkConfig= getSepoliaEthConfig();
        }
        else if (block.chainid==1)
        {
            activeNetworkConfig = getEthMainnetConfig();
        }
        
        else {
            activeNetworkConfig = getOrcreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory)
    {
        NetworkConfig memory SepoliaEthConfig = NetworkConfig ({
            PriceFeed : 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return SepoliaEthConfig;
    }

     function getEthMainnetConfig() public pure returns (NetworkConfig memory)
    {
        NetworkConfig memory EthMainnetConfig = NetworkConfig ({
            PriceFeed : 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        return EthMainnetConfig;
    }

    
    function getOrcreateAnvilEthConfig() public  returns(NetworkConfig memory)
    {
        if (activeNetworkConfig.PriceFeed != address(0)) 
        {
            return activeNetworkConfig;
        }
        //price feed address
        // 1.Deploy the mocks
        // 2.Return the mock address
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS,INITIAL_PRICE);
        vm.stopBroadcast();
        NetworkConfig memory anvilConfig = NetworkConfig ({
            PriceFeed : address(mockPriceFeed)
        });
        return anvilConfig ;
    }


}