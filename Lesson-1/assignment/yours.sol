pragma solidity ^0.4.14;
contract Payroll{
    address owner;
    uint salary;
    address employee;
    uint constant payDuartion = 10 seconds;
    uint lastPayday = now;
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    function Payroll() payable {
        owner = msg.sender;
    }
    
    function updateEmployee(address wal, uint money) onlyOwner{
        if(employee != 0x0){
            uint payment = salary * (now - lastPayday) / payDuartion;
            employee.transfer(payment);
        }
        employee = wal;
        salary = money * 1 ether;
        lastPayday = now;
    }

    
    function addFund() payable returns(uint){
        return this.balance;
    }
    function calculateRunway() returns (uint){
        return this.balance / salary;
    }
    function hasEnoughFund() returns (bool){
        return this.balance >= salary;
    }
    function getPaid(){
        require(msg.sender == employee);
        uint nextPayday = lastPayday + payDuartion;
        if(nextPayday > now){
            revert();
        }
        lastPayday = nextPayday;
        employee.transfer(salary);
    }
    
}