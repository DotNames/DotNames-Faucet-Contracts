// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

/// @title A simple Ether faucet with maintenance controls
/** @notice This contract is designed to control the disbursement of Ether 
    to addresses for testing purposes with locked disbursements timespan.
    Only maintainers can disburse while only the owner can withdraw and manage maintainers. */

contract DotNamesFaucet is Ownable {
    /// Maximum amount of Ether (in wei) that can be disbursed at a time
    uint256 public maxDisperse;

    /// Tracks if an address is given maintainer privileges
    mapping(address => bool) public maintainers;

    /// Tracks the next eligible time for an address to receive a disbursement
    mapping(address => uint256) public lockTime;

    // Events
    event MaxDisperseAmountUpdated(uint256 newDisperseAmount);
    event MaintainerAdded(address maintainer);
    event MaintainerRemoved(address maintainer);
    event Dispensed(address recipient, uint256 amount);
    event Withdrawn(uint256 amount);

    /// @notice Deploys the DotNamesFaucet and sets initial disbursement amount and maintainer.
    /** @dev The contract deployer is automatically assigned as the initial maintainer.
        @param _maxDisperse The initial maximum amount of Ether (in wei) that can be disbursed */
    constructor(uint256 _maxDisperse) Ownable(msg.sender) {
        setMaxDisperse(_maxDisperse);
        setMaintainer(msg.sender);
    }

    /// @dev Modifier to only allow function execution by maintainers
    modifier onlyMaintainer() {
        require(
            maintainers[msg.sender],
            "Caller is not maintainer of contract"
        );
        _;
    }

    /// @notice Sets the maximum amount of Ether (in wei) that can be disbursed with each `drip` call.
    /** @dev Only the contract owner can call this function.
        @param _newDisperseAmount New maximum amount of Ether to set */
    function setMaxDisperse(uint256 _newDisperseAmount) public onlyOwner {
        require(
            _newDisperseAmount > 0,
            "Disperse amount should be greater than 0"
        );
        maxDisperse = _newDisperseAmount;

        emit MaxDisperseAmountUpdated(_newDisperseAmount);
    }

    /// @notice Adds a maintainer to the contract allowing them to disburse funds.
    /** @dev Only the contract owner can call this function to add maintainers.
        @param _maintainer Address to be added as a maintainer */
    function setMaintainer(address _maintainer) public onlyOwner {
        require(
            !maintainers[_maintainer],
            "Provided address is already a maintainer"
        );
        maintainers[_maintainer] = true;

        emit MaintainerAdded(_maintainer);
    }

    /// @notice Removes maintainer privileges from an address.
    /** @dev Only the contract owner can call this function to remove a maintainer.
        @param _maintainer Address to have its maintainer privileges removed */
    function removeMaintainer(address _maintainer) public onlyOwner {
        require(
            maintainers[_maintainer],
            "Provided address is not a maintainer"
        );
        maintainers[_maintainer] = false;

        emit MaintainerRemoved(_maintainer);
    }

    /// @notice Sends a disbursement of the preset Ether amount to a specified address.
    /** @dev Maintainers can call this function; ensures the recipient's lock time expired.
        @param _to Recipient's address of the Ether disbursement */
    function drip(address _to) public onlyMaintainer {
        require(
            block.timestamp > lockTime[_to],
            "Lock time has not expired. Please try again later"
        );
        require(
            address(this).balance >= maxDisperse,
            "Insufficient balance in the faucet"
        );
        lockTime[_to] = block.timestamp + 1 days;
        (bool sent, ) = payable(_to).call{value: maxDisperse}("");
        require(sent, "Failed to send Ether");

        emit Dispensed(_to, maxDisperse);
    }

    /// @notice Withdraws a specified amount of Ether from the faucet funds to the owner.
    /** @dev Only the contract owner can call this function and has to specify the amount.
        Checks for sufficient balance before transfer.
        @param _amount The amount of Ether (in wei) to withdraw */
    function withdrawETH(uint256 _amount) public onlyOwner {
        require(
            address(this).balance >= _amount,
            "Insufficient balance in the faucet"
        );
        (bool sent, ) = payable(msg.sender).call{value: _amount}("");
        require(sent, "Failed to send Ether");
        emit Withdrawn(_amount);
    }

    /// @notice Allows the contract to receive Ether directly without data and maintain a balance.
    receive() external payable {
        // Emit an event if needed or add logic for received funds.
    }
}
