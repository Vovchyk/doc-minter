// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Import this file to use console.log
import "hardhat/console.sol";

contract RDocMinter {

    event Received(uint256 value);
    event Minting(uint256 value);
    event Minted(uint256 value);
    event Refunded(uint256 value);

    address payable private rskSwapAddr;
    address private rifAddr;
    address private rocAddr;
    address private rdocAddr;
    address private rocExchangeAddr;
    address private rocInrateAddr;
    address private rocVendorAddr;

    constructor(address payable _rskSwapAddr, address _rifAddr, address _rocAddr, address _rdocAddr, address _rocExchangeAddr, address _rocInrateAddr, address _rocVendorAddr) {
        rskSwapAddr = _rskSwapAddr;
        rifAddr = _rifAddr;
        rocAddr = _rocAddr;
        rdocAddr = _rdocAddr;
        rocExchangeAddr = _rocExchangeAddr;
        rocInrateAddr = _rocInrateAddr;
        rocVendorAddr = _rocVendorAddr;
    }

    receive() external payable {
        emit Received(msg.value);
    }

    function mintRDoc(address payable receiverAddr, address payable refundAddr) payable external returns (uint256) {
        emit Minting(msg.value);

        bool success;
        bytes memory _returnData;

        uint256 oldBalance = address(this).balance - msg.value;

        (success, _returnData) = rdocAddr.call(abi.encodeWithSignature("balanceOf(address)", address(this)));
        if (!success) {
            string memory _revertMsg = _getRevertMsg(_returnData);
            revert(_revertMsg);
        }
        (uint256 oldDocBalance) = abi.decode(_returnData, (uint256));

        uint256 rifBalance = _swapRbtcToRifWithRskSwap();

        uint256 fee = _calcCommission(rifBalance);

        console.log("Calculated fee: %s", fee);

        (success, _returnData) = rifAddr.call(abi.encodeWithSignature("approve(address,uint256)", address(rocAddr), rifBalance));
        if (!success) {
            string memory _revertMsg = _getRevertMsg(_returnData);
            revert(_revertMsg);
        }
        (bool ok) = abi.decode(_returnData, (bool));
        require(ok, "RIF approve failed");

        console.log("Approved RIF balance transfer for %s", address(rocAddr));

        (success, _returnData) = rocAddr.call(abi.encodeWithSignature("mintStableTokenVendors(uint256,address)", rifBalance - fee, rocVendorAddr));
        if (!success) {
            string memory _revertMsg = _getRevertMsg(_returnData);
            revert(_revertMsg);
        }

        (success, _returnData) = rdocAddr.call(abi.encodeWithSignature("balanceOf(address)", address(this)));
        if (!success) {
            string memory _revertMsg = _getRevertMsg(_returnData);
            revert(_revertMsg);
        }
        (uint256 docBalance) = abi.decode(_returnData, (uint256));

        uint256 mintedDoc = docBalance - oldDocBalance;
        emit Minted(mintedDoc);

        (success, _returnData) = rdocAddr.call(abi.encodeWithSignature("transfer(address,uint256)", receiverAddr, mintedDoc));
        if (!success) {
            string memory _revertMsg = _getRevertMsg(_returnData);
            revert(_revertMsg);
        }

        uint256 reminder = address(this).balance - oldBalance;
        if (reminder > 0) {
            (success, ) = refundAddr.call{value: reminder}("");
            require(success, "Failed to send reminder to refundAddr");

            emit Refunded(reminder);
        }

        return mintedDoc;
    }

    function _swapRbtcToRifWithRskSwap() internal returns (uint256) {
        bool success;
        bytes memory _returnData;

        (success, _returnData) = rskSwapAddr.call(abi.encodeWithSignature("WETH()"));
        if (!success) {
            string memory _revertMsg = _getRevertMsg(_returnData);
            revert(_revertMsg);
        }
        (address wrbtcAddr) = abi.decode(_returnData, (address));

        address[] memory path = new address[](2);
        path[0] = wrbtcAddr;
        path[1] = rifAddr;
        (success, _returnData) = rskSwapAddr.call(abi.encodeWithSignature("getAmountsOut(uint256,address[])", msg.value, path));
        if (!success) {
            string memory _revertMsg = _getRevertMsg(_returnData);
            revert(_revertMsg);
        }
        (uint256[] memory amounts) = abi.decode(_returnData, (uint256[]));

        uint256 deadline = block.timestamp + 60 * 60;
        (success, _returnData) = rskSwapAddr.call{value: msg.value}(abi.encodeWithSignature("swapExactETHForTokens(uint256,address[],address,uint256)", amounts[1], path, address(this), deadline));
        if (!success) {
            string memory _revertMsg = _getRevertMsg(_returnData);
            revert(_revertMsg);
        }

        (success, _returnData) = rifAddr.call(abi.encodeWithSignature("balanceOf(address)", address(this)));
        if (!success) {
            string memory _revertMsg = _getRevertMsg(_returnData);
            revert(_revertMsg);
        }
        (uint256 rifBalance) = abi.decode(_returnData, (uint256));

        return rifBalance;
    }

    function _calcCommission(uint256 amount) internal returns (uint256) {
        bool success;
        bytes memory _returnData;

        (success, _returnData) = rocInrateAddr.call(abi.encodeWithSignature("MINT_STABLETOKEN_FEES_MOC()"));
        require(success, "MINT_STABLETOKEN_FEES_MOC() failed");
        (uint8 txTypeFeesMOC) = abi.decode(_returnData, (uint8));

        (success, _returnData) = rocInrateAddr.call(abi.encodeWithSignature("MINT_STABLETOKEN_FEES_RESERVE()"));
        require(success, "MINT_STABLETOKEN_FEES_RESERVE() failed");
        (uint8 txTypeFeesReserveToken) = abi.decode(_returnData, (uint8));

        (success, _returnData) = rocExchangeAddr.call(abi.encodeWithSignature("calculateCommissionsWithPrices((address,uint256,uint8,uint8,address))",
            address(this), amount, txTypeFeesMOC, txTypeFeesReserveToken, rocVendorAddr));
        if (!success) {
            string memory _revertMsg = _getRevertMsg(_returnData);
            revert(_revertMsg);
        }

        // (uint256 btcCommission, uint256 mocCommission, uint256 btcPrice, uint256 mocPrice, uint256 btcMarkup, uint256 mocMarkup)
        (uint256 btcCommission, , , , uint256 btcMarkup, uint256 mocMarkup) = abi.decode(_returnData, (uint256, uint256, uint256, uint256, uint256, uint256));

        if (mocMarkup > 0) {
            return 0;
        }

        return btcCommission + btcMarkup;
    }

    function _getRevertMsg(bytes memory _returnData) internal pure returns (string memory) {
        // If the _res length is less than 68, then the transaction failed silently (without a revert message)
        if (_returnData.length < 68) return 'Transaction reverted silently';

        assembly {
        // Slice the sighash.
            _returnData := add(_returnData, 0x04)
        }
        return abi.decode(_returnData, (string)); // All that remains is the revert string
    }

}
