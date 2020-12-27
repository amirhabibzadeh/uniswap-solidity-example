// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.7.1;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./interfaces/IUniswapV2Router02.sol";
import "./interfaces/IBoardroom.sol";

contract DoBasis is AccessControl {
    IUniswapV2Router02 public uniswapRouter;
    IERC20 public daiToken;
    IERC20 public basToken;
    IERC20 public bacToken;
    IBoardroom public boardRoom;

    address public daiAddress;
    address public basAddress;
    address public bacAddress;
    address public uniswapRouterAddress;
    address public boardroomAddress;

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    modifier onlyAdmin() {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Caller is not admin");
        _;
    }

    function setUniswapRouterAddress(address _uniswapRouterAddress)
        external
        onlyAdmin
    {
        uniswapRouter = IUniswapV2Router02(_uniswapRouterAddress);
        uniswapRouterAddress = _uniswapRouterAddress;
    }

    function setDaiAddress(address _daiAddress) external onlyAdmin {
        daiToken = IERC20(_daiAddress);
        daiAddress = _daiAddress;
    }

    function setBasAddress(address _basAddress) external onlyAdmin {
        basToken = IERC20(_basAddress);
        basAddress = _basAddress;
    }

    function setBacAddress(address _bacAddress) external onlyAdmin {
        bacToken = IERC20(_bacAddress);
        bacAddress = _bacAddress;
    }

    function setBoardroomAddress(address _boardroomAddress) external onlyAdmin {
        boardRoom = IBoardroom(_boardroomAddress);
        boardroomAddress = _boardroomAddress;
    }

    function setAllAdresses(
        address _uniswapRouterAddress,
        address _daiAddress,
        address _basAddress,
        address _bacAddress,
        address _boardroomAddress
    ) external onlyAdmin {
        uniswapRouter = IUniswapV2Router02(_uniswapRouterAddress);
        uniswapRouterAddress = _uniswapRouterAddress;

        daiToken = IERC20(_daiAddress);
        daiAddress = _daiAddress;

        basToken = IERC20(_basAddress);
        basAddress = _basAddress;

        bacToken = IERC20(_bacAddress);
        bacAddress = _bacAddress;

        boardRoom = IBoardroom(_boardroomAddress);
        boardroomAddress = _boardroomAddress;
    }

    function approveTokensForUniswap(uint256 amount) external onlyAdmin {
        daiToken.approve(uniswapRouterAddress, amount);
        basToken.approve(uniswapRouterAddress, amount);
        bacToken.approve(uniswapRouterAddress, amount);
    }

    function approveBacForUniswap(uint256 amount) external onlyAdmin {
        bacToken.approve(uniswapRouterAddress, amount);
    }

    function approveBasForBoardroom(uint256 amount) external onlyAdmin {
        basToken.approve(boardroomAddress, amount);
    }

    function stakeBas() external onlyAdmin {
        boardRoom.stake(basToken.balanceOf(address(this)));
    }

    function unstakeBas(uint256 _amount) external onlyAdmin {
        boardRoom.withdraw(_amount);
    }

    function exitBas() external onlyAdmin {
        boardRoom.exit();
    }

    function claimBasReward() external onlyAdmin {
        boardRoom.claimReward();
    }

    function exitBasAndCovertToDai() external onlyAdmin {
        boardRoom.exit();

        uint256 bacAmount = bacToken.balanceOf(address(this));

        require(bacAmount > 0, "Bac is zero");

        uniswapRouter.swapExactTokensForTokens(
            bacAmount,
            1000000,
            getPathForBACtoDAI(),
            address(this),
            block.timestamp + 15
        );
    }

    function withdrawEther(address payable _to, uint256 _amount)
        external
        onlyAdmin
    {
        uint256 totalAmount = 0;
        if (_amount == 0) {
            totalAmount = address(this).balance;
        } else {
            totalAmount = _amount;
        }

        require(totalAmount > 0, "totalAmount is zero");

        (bool success, ) = _to.call{value: totalAmount}("");
        require(success, "withdraw failed");
    }

    function withdrawDai(address _to, uint256 _amount) external onlyAdmin {
        uint256 totalAmount = 0;
        if (_amount == 0) {
            totalAmount = daiToken.balanceOf(address(this));
        } else {
            totalAmount = _amount;
        }

        require(totalAmount > 0, "totalAmount is zero");

        bool success = daiToken.transfer(_to, totalAmount);
        require(success, "withdraw failed");
    }

    function withdrawBas(address _to, uint256 _amount) external onlyAdmin {
        uint256 totalAmount = 0;
        if (_amount == 0) {
            totalAmount = basToken.balanceOf(address(this));
        } else {
            totalAmount = _amount;
        }

        require(totalAmount > 0, "totalAmount is zero");

        bool success = basToken.transfer(_to, totalAmount);
        require(success, "withdraw failed");
    }

    function withdrawBac(address _to, uint256 _amount) external onlyAdmin {
        uint256 totalAmount = 0;
        if (_amount == 0) {
            totalAmount = bacToken.balanceOf(address(this));
        } else {
            totalAmount = _amount;
        }

        require(totalAmount > 0, "totalAmount is zero");

        bool success = bacToken.transfer(_to, totalAmount);
        require(success, "withdraw failed");
    }

    function getEstimatedBACforDAI(uint256 _amount)
        public
        view
        returns (uint256[] memory)
    {
        return uniswapRouter.getAmountsIn(_amount, getPathForBACtoDAI());
    }

    function getEstimatedBASforDAI(uint256 _amount)
        public
        view
        returns (uint256[] memory)
    {
        return uniswapRouter.getAmountsIn(_amount, getPathForBAStoDAI());
    }

    function getPathForBACtoDAI() private view returns (address[] memory) {
        address[] memory path = new address[](2);
        path[0] = bacAddress;
        path[1] = daiAddress;

        return path;
    }

    function getPathForBAStoDAI() private view returns (address[] memory) {
        address[] memory path = new address[](2);
        path[0] = basAddress;
        path[1] = daiAddress;

        return path;
    }

    function getEstimatedDAIforBAC(uint256 _amount)
        public
        view
        returns (uint256[] memory)
    {
        return uniswapRouter.getAmountsIn(_amount, getPathForDaitoBac());
    }

    function getPathForDaitoBac() private view returns (address[] memory) {
        address[] memory path = new address[](2);
        path[0] = daiAddress;
        path[1] = bacAddress;

        return path;
    }

    function getEstimatedDAIforBAS(uint256 _amount)
        public
        view
        returns (uint256[] memory)
    {
        return uniswapRouter.getAmountsIn(_amount, getPathForDaitoBas());
    }

    function getPathForDaitoBas() private view returns (address[] memory) {
        address[] memory path = new address[](2);
        path[0] = daiAddress;
        path[1] = basAddress;

        return path;
    }

    function covertBasToDai(uint256 _amount) external onlyAdmin {
        uint256 basAmount = 0;
        if (_amount == 0) {
            basAmount = basToken.balanceOf(address(this));
        } else {
            basAmount = _amount;
        }

        require(basAmount > 0, "Bas amount is zero");

        uniswapRouter.swapExactTokensForTokens(
            basAmount,
            1000000,
            getPathForBAStoDAI(),
            address(this),
            block.timestamp + 15
        );
    }

    function covertBacToDai(uint256 _amount) external onlyAdmin {
        uint256 bacAmount = 0;

        if (_amount == 0) {
            bacAmount = bacToken.balanceOf(address(this));
        } else {
            bacAmount = _amount;
        }

        require(bacAmount > 0, "Bas amount is zero");

        uniswapRouter.swapExactTokensForTokens(
            bacAmount,
            1000000,
            getPathForBACtoDAI(),
            address(this),
            block.timestamp + 15
        );
    }

    function covertDaiToBas(uint256 _amount) external onlyAdmin {
        uint256 daiAmount = 0;

        if (_amount == 0) {
            daiAmount = daiToken.balanceOf(address(this));
        } else {
            daiAmount = _amount;
        }

        require(daiAmount > 0, "Dai amount is zero");

        uniswapRouter.swapExactTokensForTokens(
            daiAmount,
            1000000,
            getPathForDaitoBas(),
            address(this),
            block.timestamp + 15
        );
    }

    function covertDaiToBac(uint256 _amount) external onlyAdmin {
        uint256 daiAmount = 0;

        if (_amount == 0) {
            daiAmount = daiToken.balanceOf(address(this));
        } else {
            daiAmount = _amount;
        }

        require(daiAmount > 0, "Dai amount is zero");

        uniswapRouter.swapExactTokensForTokens(
            daiAmount,
            1000000,
            getPathForDaitoBac(),
            address(this),
            block.timestamp + 15
        );
    }

    // important to receive ETH
    receive() external payable {}
}
