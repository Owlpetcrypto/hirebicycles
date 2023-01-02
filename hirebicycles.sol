//SPDX-License-Identifier: MIT

pragma solidity ^0.8.16; 


contract BicycleHire {
    
    //person a rents a bicycle for a period of time
    //person a returns bike
    //duration * rates = cost
    //check person a balance
    //deduct balance

    address owner;
    uint ownerBalance;

    constructor() {
        owner = msg.sender;
    }
    //only owner permission
    modifier onlyOwner() {
        require(msg.sender == owner, "You do not have permission");
        _;
    }
    //only renter permission
    modifier isRenter(address _walletAddress) {
        require(msg.sender == _walletAddress, "You can only manage your account");
        _;
    }

    //renter details
    struct Renter {
        address payable _walletAddress;
        string firstName;
        string lastName;
        bool canRent;
        bool active;
        uint256 balance;
        uint256 due;
        uint256 startTime;
        uint256 endTime;
    }

    //map out all renters
    mapping (address => Renter) public renters;

    //add renter details
    function addRenter(address payable _walletAddress, string memory _firstName, string memory _lastName, bool _canRent, bool _active, uint256 _balance, uint256 _due, uint256 _startTime, uint256 _endTime) public {
        renters[_walletAddress] = Renter(_walletAddress, _firstName, _lastName, _canRent, _active, _balance, _due, _startTime, _endTime);
    }

    //rent bicycle
    function checkOut(address _walletAddress) public isRenter(_walletAddress){
        require(renters[_walletAddress].due == 0, "You have a pending balance");
        require(renters[_walletAddress].canRent == true, "You cannot rent at this time");
        renters[_walletAddress].active = true;
        //unix timestamp - epochconverter.com
        renters[_walletAddress].startTime = block.timestamp;
        renters[_walletAddress].canRent = false;
        
    }

    //return bicycle
    function checkIn(address _walletAddress) public isRenter(_walletAddress){
        require(renters[_walletAddress].active == true, "Please checkout a bike first" );
        renters[_walletAddress].active == false;
        renters[_walletAddress].endTime = block.timestamp;
        dueAmount(_walletAddress);
    }

    //duration of hire
    function renterTimespan(uint startTime, uint endTime) internal pure returns(uint) {
        return endTime - startTime;
    }

    //duration of hire in minutes
    function getTotalDuration(address _walletAddress) public isRenter(_walletAddress) view returns(uint) {
        if (renters[_walletAddress].startTime == 0 || renters[_walletAddress].endTime == 0) {
            return 0;
        } else {
            uint timespan = renterTimespan(renters[_walletAddress].startTime, renters[_walletAddress].endTime);
            uint timespanInMinutes = timespan / 60;
            return timespanInMinutes;
        }

    }

    //get contract balance
    function getBalanceOf() onlyOwner() public view returns(uint){
        return address(this).balance;
    }

    //get owners balance
    function getOwnerBalance() view public onlyOwner() returns(uint) {
        return ownerBalance;
    }

    //withdraw balance
    function withdrawOwnerBalance() payable public {
        payable(owner).transfer(ownerBalance);
    }

    //get renters balance
    function balanceOfRenter(address _walletAddress) public isRenter(_walletAddress) view returns(uint) {
        return renters[_walletAddress].balance;
    }

    //due amount
    function dueAmount(address _walletAddress) internal {
        uint timespanMinutes = getTotalDuration(_walletAddress);
        uint thirtyMinuteIncrements = timespanMinutes/ 30;
        renters[_walletAddress].due = thirtyMinuteIncrements * 2000000000000000;
    }

    //check if you can rent
    function canRentBike(address _walletAddress) public isRenter(_walletAddress) view returns(bool) {
        return renters[_walletAddress].canRent;
    }

    //deposit money
    function deposit(address _walletAddress) payable isRenter(_walletAddress) public {
        renters[_walletAddress].balance += msg.value;
    }
    
    //make payment
    function makePayment(address _walletAddress, uint _amount) public isRenter(_walletAddress) {
        require(renters[_walletAddress].due > 0, "Nothing is due");
        require(renters[_walletAddress].due == _amount, "Please input the correct amount");
        require(renters[_walletAddress].balance >= _amount, "You do not have enough funds to cover payment. Please make a deposit");   
        renters[_walletAddress].balance -= _amount;
        renters[_walletAddress].canRent = true;
        renters[_walletAddress].active = false;
        renters[_walletAddress].due = 0;
        renters[_walletAddress].startTime = 0;
        renters[_walletAddress].endTime = 0;

    }

//For front end

    //get amount due
    function getDue(address _walletAddress) public isRenter(_walletAddress) view returns(uint) {
        return renters[_walletAddress].due;
    }

    //get basic details for front end
    function getRenter(address _walletAddress) public isRenter(_walletAddress) view returns(string memory firstName, string memory lastName, bool canRent, bool active) {
        firstName = renters[_walletAddress].firstName;
        lastName = renters[_walletAddress].lastName;
        canRent = renters[_walletAddress].canRent;
        active = renters[_walletAddress].active;
    }

    //see if the renter already exist on the app
    function renterExists(address _walletAddress) public isRenter(_walletAddress) view returns(bool) {
        if (renters[_walletAddress]._walletAddress != address(0)) {
            return true;
        }
        return false;
    }

}
