/*我的作业*/
/*作业*/
pragma solidity ^0.4.14;

contract Payroll {
    
    address employer;
    address employee;
    uint salary;
    uint lastPayday;
    uint constant payDuration = 10 seconds;
    
    function setEmployer() {
        if(employer == 0x0) {
            employer = msg.sender;
        }
    }
    
    function updateEmployee(address add, uint s, uint startPayday) {
        if(employer == msg.sender) {
            employee = add;
            salary = s * 1 ether;
            lastPayday = startPayday;
        }
    }
    
    function addFund() payable returns (uint) {
        return this.balance;
    } 
    
    function calculateRunway() returns (uint) {
        return this.balance / salary;
    }
    
    function hasEnoughFund() returns (bool) {
        return this.balance >= salary;
    }
    
    function getPay() payable{
        if(msg.sender != employee) {
            revert();    
        }
        
        uint nextPayday = lastPayday + payDuration;
        if(nextPayday > now) {
            revert();
        }
        
        lastPayday = nextPayday;
        employee.transfer(salary);
    }
    
}
