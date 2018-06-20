/*我的作业*/
pragma solidity ^0.4.14;

contract Payroll {
    
    address employer;//can't be queried
    address public employee;//'public' can be queried
    uint public salary;
    uint lastPayday;
    uint constant payDuration = 10 seconds;
    
    //set owner address
    function setEmployer() {
        require(employer == 0x0);//check the employer address
        employer = msg.sender;
    }
    
    //update employee address, salary
    function updateEmployee(address add, uint s) {
        require(employer == msg.sender);//check the employer address
        
        if(employee != 0x0){
            uint payment = salary * (now - lastPayday)/payDuration;
            require(this.balance > payment);//check balance
            employee.transfer(payment);
        }
        
        employee = add;
        salary = s * 1 ether;
        lastPayday = now;
    }
    
    // update salary
    function updateSalary(uint s){
        require(employer == msg.sender);
        require(employee != 0x0);
        salary = s * 1 ether;
    }
    
    //deposit ether
    function addFund() payable returns (uint) {
        return this.balance;
    } 
    
    //calculate the contract can pay how many times for the employee
    function calculateRunway() view returns (uint) {
        return this.balance / salary;
    }
    
    //check the contract balance
    function hasEnoughFund() view returns (bool) {
        return this.balance >= salary;
    }
    
    //employee get salary by himself
    function getPaid() payable public{
        require(msg.sender == employee);
        require(this.balance >= salary);
        
        uint nextPayday = lastPayday + payDuration;
        if(nextPayday > now) {
            revert();
        }

        lastPayday = nextPayday;
        employee.transfer(salary);
    }
    
    //get all salary in one time
    function getAllPaid() payable{
        require(msg.sender == employee);
        uint time = now;//keey the time
        uint times = (time - lastPayday)/payDuration;
        uint payment = salary * times;
        
        require(this.balance > payment);//check balance
        
        lastPayday = time - times * payDuration;
        employee.transfer(payment);
    }
    
}
