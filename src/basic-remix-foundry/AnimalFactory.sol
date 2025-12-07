// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Cows} from "./Cows.sol";
import {Birds} from "./Birds.sol";

contract AnimalFactory {
    Cows public cow;
    Birds public bird;

    function createAnimals() public {
        cow = new Cows();
        bird = new Birds();
    }
}
