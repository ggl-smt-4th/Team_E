pragma solidity ^0.4.24;

contract PayRoll {
    uint public salary = 1 ether;
    address public employee = 0xca35b7d915458ef540ade6068dfe2f44e8fa733c;
    uint payDuration = 10 seconds;
    uint lastPayDay = now;
    
    function addFund() payable returns (uint) {
        return this.balance;
    }
    
    function setEmployee(address _employee) payable {
        employee = _employee;
        
    }
    
    function setSalary(uint _salary) payable {
        salary = _salary;
        
    }

    function calculateRunWay() returns (uint) {
        return this.balance / salary;
    }
    
    function hasEnoughFund() returns (bool) {
        return calculateRunWay() > 1;
    }
    
    function getPaid() payable {
        require(msg.sender == employee);
        require(hasEnoughFund());
        
        uint nextPayDay = lastPayDay + payDuration;
        require(nextPayDay <= now);
        
        lastPayDay = nextPayDay;
        employee.transfer(salary);
    }
}
