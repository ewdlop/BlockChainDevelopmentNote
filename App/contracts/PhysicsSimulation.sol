// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PhysicsSimulation {
    struct ObjectState {
        int256 x;
        int256 y;
        int256 vx;
        int256 vy;
    }

    mapping(uint256 => ObjectState) public objects;
    uint256 public objectCount;

    event ObjectUpdated(uint256 objectId, int256 x, int256 y, int256 vx, int256 vy);

    function addObject(int256 x, int256 y, int256 vx, int256 vy) public returns (uint256) {
        objectCount++;
        objects[objectCount] = ObjectState(x, y, vx, vy);
        emit ObjectUpdated(objectCount, x, y, vx, vy);
        return objectCount;
    }

    function updateObject(uint256 objectId, int256 x, int256 y, int256 vx, int256 vy) public {
        require(objectId <= objectCount, "Invalid object ID");
        objects[objectId] = ObjectState(x, y, vx, vy);
        emit ObjectUpdated(objectId, x, y, vx, vy);
    }

    function getObject(uint256 objectId) public view returns (int256, int256, int256, int256) {
        require(objectId <= objectCount, "Invalid object ID");
        ObjectState memory state = objects[objectId];
        return (state.x, state.y, state.vx, state.vy);
    }
}
