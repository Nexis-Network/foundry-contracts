// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

contract Foundry {
    address public owner;
    uint256 public xpConversionRate = 20;

    /*
    User Interface
    - xpPoints : records the xp points of user
    - registeredOn : records the timestamp of when the user registered
    - checkInDetails : stores the details related to daily check-ins
    - booster : stores the details related to the booster plan
    */

    struct CheckInDetails {
        uint256 lastCheckedIn;
        uint256 lastCheckInReward;
    }

    struct Booster {
        uint256 multiplier;
        uint256 purchasedOn;
    }

    struct User {
        uint256 xpPoints;
        uint256 registeredOn;
        CheckInDetails checkInDetails;
        Booster booster;
    }

    /*
    BOOSTER_DURATION: a cron script will check the validity of booster and expire it if 28 days are reached
    */
    uint256 public constant BOOSTER_DURATION = 28 days;

    /*
    users: a mapping consisting of key as address of registered user and value as User struct
    */
    mapping(address => User) public users;

    /*
    Booster prices in ethers for different plans
    */
    uint256[5] public boosterPrices = [1 ether, 2 ether, 3 ether, 4 ether, 5 ether];
    uint256[5] public boosterMultipliers = [125, 150, 175, 200, 250]; // representing 1.25x, 1.5x, etc. as percentages

    /*
    Constructor to set the owner
    */
    constructor() {
        owner = msg.sender;
    }

    /*
    Modifier to restrict access to owner only
    */
    modifier onlyOwner {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    /*
    registerUser: only callable if user doesn't exist otherwise inits the new user
    */
    function registerUser() public {
        // revert if user already exists/registered
        require(users[msg.sender].registeredOn == 0, "User already registered");

        users[msg.sender] = User({
            xpPoints: 0,
            registeredOn: block.timestamp,
            checkInDetails: CheckInDetails({
                lastCheckedIn: 0,
                lastCheckInReward: 0
            }),
            booster: Booster({
                multiplier: 100, // Stone booster (1x)
                purchasedOn: block.timestamp
            })
        });
    }

    function fetchUserInfo(address _address) public view returns(User memory){
        return users[_address];
    }

    /*
    Modifier to check and apply the booster
    */
    modifier applyBooster {
        User storage user = users[msg.sender];
        if (block.timestamp > user.booster.purchasedOn + BOOSTER_DURATION) {
            user.booster.multiplier = 100; // Stone booster (1x)
        }
        _;
    }

    /*
    dailyCheckIn: allows user to check in daily and earn XP points based on the time since the last check-in
    */
    function dailyCheckIn() public applyBooster {
        User storage user = users[msg.sender];
        uint256 currentTime = block.timestamp;
        uint256 timeSinceLastCheckIn = currentTime - user.checkInDetails.lastCheckedIn;

        require(user.registeredOn != 0, "User not registered");

        if (timeSinceLastCheckIn < 24 hours) {
            revert("You can only check in once every 24 hours");
        } else if (timeSinceLastCheckIn < 48 hours) {
            user.xpPoints += (user.checkInDetails.lastCheckInReward + 1) * user.booster.multiplier / 100; // reset high count for rewards on 8th day of streak
            user.checkInDetails.lastCheckInReward += 1;
        } else {
            user.xpPoints += 1 * user.booster.multiplier / 100;
            user.checkInDetails.lastCheckInReward = 1;
        }

        user.checkInDetails.lastCheckedIn = currentTime;
    }

    /*
    purchaseBooster: allows user to purchase a booster if they don't have an active one
    */
    function purchaseBooster(uint256 plan) public payable {
        require(plan >= 0 && plan < 5, "Invalid booster plan");
        require(users[msg.sender].booster.purchasedOn + BOOSTER_DURATION <= block.timestamp, "Active booster plan exists");
        require(msg.value == boosterPrices[plan], "Incorrect ETH value sent");

        users[msg.sender].booster = Booster({
            multiplier: boosterMultipliers[plan],
            purchasedOn: block.timestamp
        });
    }

    /*
    changeBoosterPrices: allows owner to change the prices of booster plans
    */
    function changeBoosterPrices(uint256[5] memory newPrices) public onlyOwner {
        boosterPrices = newPrices;
    }

    /*
    changeXpConversionRate: allows owner to change the conversion rate of XP to ETH
    */
    function changeXpConversionRate(uint256 newRate) public onlyOwner {
        xpConversionRate = newRate;
    }

    /*
    withdrawXP: allows user to withdraw their XP points for ETH
    */
    function withdrawXP() public {
        User storage user = users[msg.sender];
        require(user.xpPoints > 0, "No XP points to withdraw");

        uint256 nztAmount = user.xpPoints / xpConversionRate;
        user.xpPoints = 0;

        (bool success, ) = msg.sender.call{value: nztAmount}("");
        require(success, "Transfer failed");
    }

    /*
    depositETH: allows owner to deposit ETH into the contract
    */
    function depositNZT() public payable onlyOwner {}

    /*
    withdrawNZT: allows owner to withdraw NZT from the contract
    */
    function withdrawNZT(uint256 amount) public onlyOwner {
        require(amount <= address(this).balance, "Insufficient balance");

        (bool success, ) = owner.call{value: amount}("");
        require(success, "Transfer failed");
    }

    /*
    Fallback function to accept NZT
    */
    receive() external payable {}
}
