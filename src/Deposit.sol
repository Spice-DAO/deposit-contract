pragma solidity ^0.8.13;

contract Deposit {
    bool internal locked;
    bool public active = true;
    address owner;

    mapping(address => uint256) public addressToMintCount;
    mapping(address => uint256) public addressToDeposit;

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


    fallback() external payable {
        require(active, "Deposit Contract Inactive!");
        require(isWhitelisted(), "Not on whitelist!");
        (bool valid, uint256 count) = getValidDeposit(msg.value);
        require(valid, "Invalid contribution amount!");
        depositlist.push(msg.sender);
        addressToMintCount[msg.sender] = count;
        addressToDeposit[msg.sender] = msg.value;
        delete whitelist[getIndex()];
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
        require(active, "Deposit Contract Inactive!");
        require(isWhitelisted(), "Not Whitelisted!");
        require(isDepositlisted(), "Not On Deposit List!");
        require(
            address(this).balance > 0,
            "Out of Funding! Please Notify Team!"
        );
        (bool sent, bytes memory data) = address(msg.sender).call{value: addressToDeposit[msg.sender]}("");
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


    /// @notice Updates whitelist and claimed deposit amount list
    /// @dev Ensure same order as newClaimedBurnAmount and same number of entries AND are in the same order
    /// @param newWhitelist The new whitelist for another campaign
    /// @param newclaimedDeposit The new Claimed Deposit Amount for another group of users
    function updateLists(address[] memory newWhitelist, uint[] memory newclaimedDeposit) public onlyOwner{
        require(newWhitelist.length == newclaimedDeposit.length, "Lists Not Same Length! PLEASE CHECK");
        updateWhitelist(newWhitelist);
        updateclaimedDeposit(newclaimedDeposit);
    }


    /// @notice Updates whitelist for future campaigns
    /// @param newWhitelist The new whitelist for another campaign
    function updateWhitelist(address[] memory newWhitelist) internal onlyOwner{
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

    /// @notice Updates Claimed Deposit Amount for new whitelisted users.
    /// @param newclaimedDeposit The new Claimed Deposit Amount for another group of users
    function updateclaimedDeposit(uint[] memory newclaimedDeposit) internal onlyOwner {
        uint[] memory returnArr = new uint[](
            claimedDeposit.length + newclaimedDeposit.length
        );

        uint256 i = 0;
        for (i; i < claimedDeposit.length; i++) {
            returnArr[i] = claimedDeposit[i];
        }

        uint256 j = 0;
        while (j < newclaimedDeposit.length) {
            returnArr[i++] = newclaimedDeposit[j++];
        }

        claimedDeposit = returnArr;
    }



    function getWhitelist() public view returns (address[] memory a) {
        return whitelist;
    }

    function getClaimedDepositList() public view returns (uint[] memory a) {
        return claimedDeposit;
    }

    function getCountMapping(address a) public view returns (uint256) {
        return addressToMintCount[a];
    }

    function getDepositMapping(address a) public view returns (uint256) {
        require(isDepositlisted(), "Not A Depositor!");
        return addressToDeposit[a];
    }



    /// @notice Used to toggle a campaigns active state, will return false if true, true if false
    function activeToggle() public onlyOwner {
        active = !active;
    }

    /// @notice Gets index of user in whitelist. Used also to verify claimedBurnAmount numbers.
    /// @return index The Index of Message Sender, reverts if not whitelisted
    function getIndex() public view returns (uint256 index) {
        require(isWhitelisted(), "Not On Whitelist");
        for (uint256 i = 0; i < whitelist.length; i++) {
            if (whitelist[i] == msg.sender) {
                return i;
            }
        }
    }


    function transferBalance() public onlyOwner {
        (bool sent, ) = payable(owner).call{value: address(this).balance}("");
        require(sent, "Failed to send Ether");
    }

    function getValidDeposit(uint256 val)
        public
        view
        returns (bool valid, uint256 count)
    {
        require(
            val <= claimedDeposit[getIndex()],
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
