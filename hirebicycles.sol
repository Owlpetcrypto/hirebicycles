//SPDX-License-Identifier: MIT

pragma solidity ^0.8.16; 


contract BicycleHire {
    
    //person a rents a bicycle for a period of time
    //person a returns bike
    //duration * rates = cost
    //check person a balance
    //deduct balance
    address owner;

    constructor() {
        owner = msg.sender;
    }

    //renter details
    struct Renter {
        address payable walletAddress;
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
    function checkOut(address _walletAddress) public {
        require(renters[_walletAddress].due == 0, "You have a pending balance");
        require(renters[_walletAddress].canRent == true, "You cannot rent at this time");
        renters[_walletAddress].active = true;
        //unix timestamp - epochconverter.com
        renters[_walletAddress].startTime = block.timestamp;
        renters[_walletAddress].canRent = false;
        
    }

    //return bicycle
    function checkIn(address _walletAddress) public {
        require(renters[_walletAddress].active == true, "Please checkout a bike first" );
        renters[_walletAddress].active == false;
        //unix timestamp - epochconverter.com
        renters[_walletAddress].endTime = block.timestamp;
        dueAmount(_walletAddress);
    }

    //function duration of hire
    function renterTimespan(uint startTime, uint endTime) internal pure returns(uint) {
        return endTime - startTime;
    }

    //function duration of hire in minutes
    function getTotalDuration(address _walletAddress) public view returns(uint) {
        require(renters[_walletAddress].active == true, "Bike is currently checked out" );
        // uint timespan = renterTimespan(renters[_walletAddress].startTime, renters[_walletAddress].endTime);
        // uint timespanMinutes = timespan/60;
        // return timespanMinutes;
        return 123;
    }

    //function get contract balance
    function getBalanceOf() public view returns(uint){
        return address(this).balance;
    }

    //function get renters balance
    function balanceOfRenter(address _walletAddress) public view returns(uint) {
        return renters[_walletAddress].balance;
    }

    //function due amount
    function dueAmount(address _walletAddress) internal {
        uint timespanMinutes = getTotalDuration(_walletAddress);
        uint thirtyMinuteIncrements = timespanMinutes/ 30;
        renters[_walletAddress].due = thirtyMinuteIncrements * 0.002 ether;
    }

    //function check if you can rent
    function canRentBike(address _walletAddress) public view returns(bool) {
        return renters[_walletAddress].canRent;
    }

    //function deposit
    function deposit(address _walletAddress) payable public {
        renters[_walletAddress].balance += msg.value;
    }

    //function make payment
    function makePayment(address _walletAddress) payable public {
        require(renters[_walletAddress].due > 0, "Nothing is due");
        require(renters[_walletAddress].balance > msg.value, "You do not have enough funds to cover payment. Please make a deposit");   
        renters[_walletAddress].balance -= msg.value;
        renters[_walletAddress].canRent = true;
        renters[_walletAddress].due = 0;
        renters[_walletAddress].startTime = 0;
        renters[_walletAddress].endTime = 0;


    }

}
