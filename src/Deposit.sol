pragma solidity ^0.8.13;

contract Deposit {
    bool internal locked;
    bool public active = true;
    address owner;

    address[] public depositList;
    address[] public whitelist = [address(1)];
    uint256[] public claimedDepositAmount = [0.5 ether];

    constructor() {
        owner = msg.sender;
    }

    receive() external payable {
        require(isWhitelisted(), "Not on whitelist!");
    }

    fallback() external payable {
        require(isWhitelisted(), "Not on whitelist!");
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }

    function redeem() public noReentrant {
        require(isWhitelisted(), "Not whitelisted!");
        require(
            address(this).balance > 0,
            "Out of Funding! Please Notify Team!"
        );
        require(active, "Redemption is not currently available!");
    }

    /// @notice Gets message senders whitelist status.
    /// @return funder True if on Deposit whitelist, False if not on Deposit whitelist
    function isWhitelisted() public view returns (bool funder) {
        for (uint256 i = 0; i < whitelist.length; i++) {
            if (whitelist[i] == msg.sender) {
                return true;
            }
        }
        return false;
    }

    /// @notice Updates whitelist for future campaigns
    /// @dev Ensure same order as newClaimedBurnAmount and same number of entries
    /// @param newWhitelist The new whitelist for another campaign
    function updatewhitelist(address[] memory newWhitelist) public onlyOwner {
        address[] memory temp;

        for (uint256 i = 0; i < whitelist.length; i++) {
            temp[i] = whitelist[i];
        }

        for (uint256 i = whitelist.length; i < newWhitelist.length; i++) {
            temp[i] = (newWhitelist[i]);
        }
        whitelist = temp;
    }

    /// @notice Used to toggle a campaigns active state, will return false if true, true if false
    function activeToggle() public onlyOwner {
        active = !active;
    }


    function transferBalance() public onlyOwner{
        (bool sent, bytes memory data) = payable(owner).call{
            value: address(this).balance
        }("");
    }
 
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  $$$$$$\            $$\                     $$$$$$$\   $$$$$$\   $$$$$$\
// $$  __$$\           \__|                    $$  __$$\ $$  __$$\ $$  __$$\
// $$ /  \__| $$$$$$\  $$\  $$$$$$$\  $$$$$$\  $$ |  $$ |$$ /  $$ |$$ /  $$ |
// \$$$$$$\  $$  __$$\ $$ |$$  _____|$$  __$$\ $$ |  $$ |$$$$$$$$ |$$ |  $$ |
//  \____$$\ $$ /  $$ |$$ |$$ /      $$$$$$$$ |$$ |  $$ |$$  __$$ |$$ |  $$ |
// $$\   $$ |$$ |  $$ |$$ |$$ |      $$   ____|$$ |  $$ |$$ |  $$ |$$ |  $$ |
// \$$$$$$  |$$$$$$$  |$$ |\$$$$$$$\ \$$$$$$$\ $$$$$$$  |$$ |  $$ | $$$$$$  |
//  \______/ $$  ____/ \__| \_______| \_______|\_______/ \__|  \__| \______/
//           $$ |
//           $$ |                                            DEPOSIT
//           \__|                                            -0xNotes
//
////////////////////////////////////////////////////////////////////////////////////////////////////
