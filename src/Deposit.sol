pragma solidity ^0.8.13;

contract Deposit {
    bool internal locked;
    bool public active = true;
    address owner;

    address[] public depositList;
    mapping(address => uint) public addressToMintCount;
    address[] public whitelist = [address(1)];
    uint256[] public claimedDepositAmount = [0.3 ether];

    constructor() {
        owner = msg.sender;
    }

    //Might be able to remove, Should make cheaper to run
    // receive() external payable {
    //     require(isWhitelisted(), "Not on whitelist!");
    //     (bool valid, uint count) = getValidDeposit(msg.value);
    //     require(valid, "Invalid contribution amount!");
    //     depositList.push(msg.sender);
    //     addressToMintCount[msg.sender] = count;
        
    // }

    fallback() external payable {
        require(isWhitelisted(), "Not on whitelist!");
        (bool valid, uint count) = getValidDeposit(msg.value);
        require(valid, "Invalid contribution amount!");
        depositList.push(msg.sender);
        addressToMintCount[msg.sender] = count;

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



    function transferBalance() public onlyOwner{
        (bool sent, ) = payable(owner).call{
            value: address(this).balance
        }("");
        require(sent, "Failed to send Ether");
    }

    function getValidDeposit(uint val) public view returns(bool valid, uint count) {
        require(val <= claimedDepositAmount[getIndex()], "Contribution greater than Claimed Deposit Amount!");
        for(uint i = 0; i < 5; i++){
        if(val == [0.1 ether, 0.2 ether, 0.3 ether, 0.4 ether, 0.5 ether][i]){
            return(true, i+1);
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
