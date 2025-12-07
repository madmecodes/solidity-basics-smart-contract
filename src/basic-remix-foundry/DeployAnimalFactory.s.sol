// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {AnimalFactory} from "./AnimalFactory.sol";

contract DeployAnimalFactory is Script {
    function run() external returns (AnimalFactory) {
        vm.startBroadcast();

        AnimalFactory factory = new AnimalFactory();
        factory.createAnimals();

        vm.stopBroadcast();
        return factory;
    }
}
