// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
> Objectives:
1. To reach the top of the buiding (bool top = true);

*/

interface Building {
    function isLastFloor(uint256) external returns (bool);
}

contract Elevator {
    bool public top;
    uint256 public floor;

    function goTo(uint256 _floor) public {
        Building building = Building(msg.sender);

        if (!building.isLastFloor(_floor)) {
            floor = _floor;
            top = building.isLastFloor(floor);
        }
    }
}
