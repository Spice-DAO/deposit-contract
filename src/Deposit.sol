pragma solidity ^0.8.13;

/// @title SpiceDAO Deposit
/// @author 0xNotes
/// @notice Only to be used for the Ancient Enemies Deposit List. Not a persistent solution
contract Deposit {
    bool internal locked;
    bool public active = true;
    address owner;
    mapping(address => uint256) public addressToMintCount;
    mapping(address => uint256) public addressToDeposit;
    address[] public refundlist;
    address[] public depositlist;

    address[] public whitelist = [
        address(1),
        address(2),
        address(3),
        address(4),
        address(5)
    ];

    uint256[] public claimedDeposit = [
        0.1 ether,
        0.2 ether,
        0.3 ether,
        0.4 ether,
        0.5 ether
    ];

    constructor() {
        owner = msg.sender;
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

    /// @notice Called when eth is provided.
    fallback() external payable {
        require(active, "Deposit Contract Inactive");
        require(!isRefundlisted(), "Already Refunded");
        require(isWhitelisted(), "Not On Whitelist");
        (bool valid, uint256 count) = getValidDeposit(msg.value);
        require(valid, "Invalid Contribution Amount");
        depositlist.push(msg.sender);
        addressToMintCount[msg.sender] = count;
        addressToDeposit[msg.sender] = msg.value;
        delete whitelist[getWhitelistIndex()];
    }

    /// @notice Users can get refunds from this contract
    function refund() public noReentrant {
        require(active, "Deposit Contract Inactive");
        require(isDepositlisted(), "Not On Deposit List");
        require(
            address(this).balance > 0,
            "Out Of Funding! Please Notify Team!"
        );
        (bool sent, bytes memory data) = address(msg.sender).call{
            value: addressToDeposit[msg.sender]
        }("");
        require(sent, "Failed to send Ether");
        delete depositlist[getDepositlistIndex()];
        refundlist.push(msg.sender);
    }

    /// @param to the address that will receive the balance
    /// @notice Used to transfer balance to another address
    function transferBalance(address to) public onlyOwner {
        (bool sent, ) = payable(to).call{value: address(this).balance}("");
        require(sent, "Failed to send Ether");
    }

    /// @notice Used to toggle a campaigns active state, will return false if true, true if false
    function activeToggle() public onlyOwner {
        active = !active;
    }

    /// @notice Used to return deposit list
    function getDepositList() public view onlyOwner returns (address[] memory) {
        return depositlist;
    }

    /// @notice Used to return whitelist
    function getWhitelist() public view returns (address[] memory) {
        return whitelist;
    }

    /// @notice Used to return claimed deposit list
    function getClaimedDepositList() public view returns (uint256[] memory) {
        return claimedDeposit;
    }

    /// @notice Used to return mint count for eth address
    /// @param a address to get mint count for
    function getCountMapping(address a) public view returns (uint256) {
        return addressToMintCount[a];
    }

    /// @notice Used to return deposit given an eth address
    /// @param a address to get mint count for
    function getDepositMapping(address a) public view returns (uint256) {
        require(isDepositlisted(), "Not A Depositor!");
        return addressToDeposit[a];
    }

    /// @notice Gets index of user in whitelist. Used also to verify claimedBurnAmount numbers.
    /// @return index The Index of Message Sender, reverts if not whitelisted
    function getWhitelistIndex() public view returns (uint256 index) {
        //require(isWhitelisted(), "Not On Whitelist");
        for (uint256 i = 0; i < whitelist.length; i++) {
            if (whitelist[i] == msg.sender) {
                return i;
            }
        }
    }

    /// @notice Gets index of user in whitelist. Used also to verify claimedBurnAmount numbers.
    /// @return index The Index of Message Sender, reverts if not whitelisted
    function getDepositlistIndex() public view returns (uint256 index) {
        //require(isW(), "Not On Whitelist");
        for (uint256 i = 0; i < depositlist.length; i++) {
            if (depositlist[i] == msg.sender) {
                return i;
            }
        }
    }

    /// @notice Gets message senders whitelist status.
    /// @return whitelisted True if on Deposit whitelist, False if not on Deposit whitelist
    function isWhitelisted() public view returns (bool whitelisted) {
        for (uint256 i = 0; i < whitelist.length; i++) {
            if (whitelist[i] == msg.sender) {
                return true;
            }
        }
        return false;
    }

    /// @notice Gets message senders whitelist status.
    /// @return funder True if on Deposit whitelist, False if not on Deposit whitelist
    function isDepositlisted() public view returns (bool funder) {
        for (uint256 i = 0; i < depositlist.length; i++) {
            if (depositlist[i] == msg.sender) {
                return true;
            }
        }
        return false;
    }

    /// @notice Gets message senders whitelist status.
    /// @return refunded True if on refundlistlist, False if not on Deposit whitelist
    function isRefundlisted() public view returns (bool refunded) {
        for (uint256 i = 0; i < refundlist.length; i++) {
            if (refundlist[i] == msg.sender) {
                return true;
            }
        }
        return false;
    }

    /// @return valid The boolean status of if the deposit is for a valid amount
    /// @return count The NFT Mint count for the user
    function getValidDeposit(uint256 val)
        public
        view
        returns (bool valid, uint256 count)
    {
        require(
            val <= claimedDeposit[getWhitelistIndex()],
            "Contribution greater than Claimed Deposit Amount!"
        );
        for (uint256 i = 0; i < 5; i++) {
            if (
                val ==
                [0.1 ether, 0.2 ether, 0.3 ether, 0.4 ether, 0.5 ether][i]
            ) {
                return (true, i + 1);
            }
        }
        return (false, 0);
    }

    /// @notice Updates whitelist and claimed deposit amount list
    /// @dev Ensure same order as newClaimedBurnAmount and same number of entries AND are in the same order
    /// @param newWhitelist The new whitelist for another campaign
    /// @param newClaimedDeposit The new Claimed Deposit Amount for another group of users
    function updateLists(
        address[] memory newWhitelist,
        uint256[] memory newClaimedDeposit
    ) public onlyOwner {
        require(
            newWhitelist.length == newClaimedDeposit.length,
            "Lists Not Same Length! PLEASE CHECK"
        );
        updateWhitelist(newWhitelist);
        updateClaimedDeposit(newClaimedDeposit);
    }

    /// @param newWhitelist The new whitelist for another campaign
    function updateWhitelist(address[] memory newWhitelist) internal {
        address[] memory returnArr = new address[](
            whitelist.length + newWhitelist.length
        );

        uint256 i = 0;
        for (i; i < whitelist.length; i++) {
            returnArr[i] = whitelist[i];
        }

        uint256 j = 0;
        while (j < newWhitelist.length) {
            returnArr[i++] = newWhitelist[j++];
        }

        whitelist = returnArr;
    }

    /// @param newClaimedDeposit The new Claimed Deposit Amount for another group of users
    function updateClaimedDeposit(uint256[] memory newClaimedDeposit) internal {
        uint256[] memory returnArr = new uint256[](
            claimedDeposit.length + newClaimedDeposit.length
        );

        uint256 i = 0;
        for (i; i < claimedDeposit.length; i++) {
            returnArr[i] = claimedDeposit[i];
        }

        uint256 j = 0;
        while (j < newClaimedDeposit.length) {
            returnArr[i++] = newClaimedDeposit[j++];
        }

        claimedDeposit = returnArr;
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
