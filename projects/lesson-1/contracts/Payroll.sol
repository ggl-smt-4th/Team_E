pragma solidity ^0.4.14;

// 实现课上所教的单员工智能合约系统，并且加入两个函数能够更改员工地址以及员工薪水。

contract Payroll {
    uint constant payDuration = 10 seconds;

    address owner;
    uint salary;
    address employee;
    uint lastPayday;

    //构造函数，函数名字跟合约名字一样，构造函数主要用于初始化
    function Payroll() payable public{
        owner = msg.sender;
        
        lastPayday = now;
    }
    
    function updateEmployee(address e, uint s) {
       
        //require(msg.sender == owner);
        
        if (employee != 0x0) {
            uint payment = salary * (now - lastPayday) / payDuration;
            employee.transfer(payment);
        }
        
        employee = e;
        salary = s;
        lastPayday = now;
    }
    
    function updateEmployeeAddress(address newAddress) public {
        require(msg.sender == owner);
        require(newAddress != employee);
        
        updateEmployee(newAddress,salary);
        
    }
    
    function updateEmployeeSalary(uint newSalary) public {
        require(msg.sender == owner);
        require(newSalary > 0);
        newSalary = newSalary * 1 ether;
        require(newSalary != salary);
        
        updateEmployee(employee,newSalary);
        
    }
    
    function getEmployee() view public returns (address) {
        return employee;
    }
    
    
    
    //boss在智能合约存钱
    function addFund() payable returns (uint) {
        return this.balance;
    }
    //计算boss存钱还能付几次工钱
    function calculateRunway() returns (uint) {
        return this.balance / salary;
    }
    //是否有足够的钱支付工资
    function hasEnoughFund() returns (bool) {
        return calculateRunway() > 0;
    }
    //员工拿到钱
    function getPaid() {
         //require检查程序输入的输入值是否满足要求，要求
        require(msg.sender == employee);
        
        uint nextPayday = lastPayday + payDuration;
        //assert程序运行的时候的时候，确认
        assert(nextPayday < now);

        lastPayday = nextPayday;
        employee.transfer(salary);
    }
}