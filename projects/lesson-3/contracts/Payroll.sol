/*
合约编写思路： 
1）只有合约创建者可以添加资金 
2）使用getUnpaidSalary函数进行未付工资的计算，减少重复代码 
3）增加、更新、删除员工函数中对totalSalary进行相应删减。 
4）更新、删除员工最后一步再进行转账操作。 
5）只有员工本人可以调用getPaid方法，并且校验是否有足够的钱可以支付。 
6）getPaid方法一次性把员工全部工资付清，避免员工3个月内只调用了一次getPaid方法，却只能获得一个月工资的情况发送。
7)在增加、修改员工时要求工资必须大于0
8）增加modifier employeeUnexist用于新增和修改员工地址时判断
9）只有员工本人能够changePaymentAddress，且在函数中要确保新的地址没被使用过，防止其他员工薪水被恶意修改，同时修改完之后要删除旧地址，防止一个员工出现2个地址。
*/
pragma solidity ^0.4.14;

import './SafeMath.sol';
import './Ownable.sol';

contract Payroll is Ownable {
    
    using SafeMath for uint;
    
    struct Employee {
        address id;
        uint salary;
        uint lastPayDay;
    }

    uint constant payDuration = 30 days;
    uint totalSalary = 0;
    mapping(address => Employee) public employees;
    
    modifier employeeExist(address employeeAddress){
        assert(employees[employeeAddress].id != 0x0);
        _;
    }
    
    modifier employeeUnexist(address employeeAddress){
        assert(employees[employeeAddress].id == 0x0);
        _;
    }
    
    function addFund() payable public onlyOwner returns (uint) {
        return this.balance;
    }
    
    function getUnpaidSalary(uint salary,uint lastPayDay) private returns (uint){
        return (salary.mul(now.sub(lastPayDay))).div(payDuration);
    }
    
    function addEmployee(address employeeAddress, uint salary) onlyOwner employeeUnexist(employeeAddress) public {
        require(salary > 0x0);
        salary = salary.mul(1 ether);
        employees[employeeAddress] = Employee(employeeAddress,salary,now);
        totalSalary = totalSalary.add(salary);
    }

    function removeEmployee(address employeeAddress) onlyOwner employeeExist(employeeAddress) public {
        uint formerSalary = employees[employeeAddress].salary;
        uint formerLastpayday = employees[employeeAddress].lastPayDay;
        Employee former = employees[employeeAddress];
        totalSalary = totalSalary.sub(former.salary);
        delete employees[employeeAddress];
        employeeAddress.transfer(getUnpaidSalary(formerSalary,formerLastpayday));
    }

    function updateEmployee(address employeeAddress, uint salary) onlyOwner employeeExist(employeeAddress) public {
        require(salary > 0x0);
        salary = salary.mul(1 ether);
        uint formerSalary = employees[employeeAddress].salary;
        uint formerLastpayday = employees[employeeAddress].lastPayDay;
        totalSalary = totalSalary.sub(formerSalary).add(salary);
        employees[employeeAddress].salary = salary;
        employees[employeeAddress].lastPayDay = now;
        employees[employeeAddress].id.transfer(getUnpaidSalary(formerSalary,formerLastpayday));
    }

    function calculateRunway() public view returns (uint) {
        return this.balance.div(totalSalary);
    }

    function hasEnoughFund() public view returns (bool) {
        return calculateRunway() > 0;
    }

    function getPaid() employeeExist(msg.sender) public returns(uint){
        assert(hasEnoughFund());
        uint nextPayDay = employees[msg.sender].lastPayDay.add(payDuration);
        assert(nextPayDay < now);
        employees[msg.sender].lastPayDay = nextPayDay;
        uint unpaidSalary = getUnpaidSalary(employees[msg.sender].salary,employees[msg.sender].lastPayDay);
        employees[msg.sender].id.transfer(unpaidSalary);
        return unpaidSalary;
    }
    
    function changePaymentAddress(address newAddress) employeeExist(msg.sender) employeeUnexist(newAddress) public{
        var salary = employees[msg.sender].salary;
        var lastPayDay = employees[msg.sender].lastPayDay;
        delete employees[msg.sender];
        employees[newAddress] = Employee(newAddress,salary,lastPayDay);
    }
}
