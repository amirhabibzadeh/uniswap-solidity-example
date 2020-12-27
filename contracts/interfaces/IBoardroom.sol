// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.6.2;

interface IBoardroom {
    function allocateSeigniorage(uint256 amount) external;
    
    function exit() external;
    function stake(uint256 amount) external;
    function claimReward() external;
    function withdraw(uint256 amount) external;
}
