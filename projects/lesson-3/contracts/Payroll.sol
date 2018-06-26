pragma solidity ^0.4.14;

import './SafeMath.sol';
import './Ownable.sol';

contract Payroll is Ownable {
    
    using SafeMath for uint;
    
    struct Employee{
        address id;
        uint salary;
        uint lastPayday;
    }
    
    mapping (address => Employee) employees;
    
    //uint constant payDuration = 30 days;
    uint constant payDuration = 10 seconds;
    uint public totalSalary = 0;
    
    function _partialPaid(Employee employee) private {
        uint payment = employee.salary.mul(now.sub(employee.lastPayday)).div(payDuration);
        employee.id.transfer(payment);
    }
    
    function addEmployee(address employeeId, uint salary) onlyOwner public {
        var employee = employees[employeeId];
        assert(employee.id == 0x0);
        
        uint s = salary.mul(1 ether);
        totalSalary = totalSalary.add(s);
        employees[employeeId]=Employee(employeeId, s, now);
    }

    function removeEmployee(address employeeId) onlyOwner public {
        require(msg.sender == owner);
        var employee = employees[employeeId];
        assert(employee.id != 0x0);
        
        totalSalary = totalSalary.sub(employee.salary);
        Employee tmpEmployee = Employee(employee.id,employee.salary,employee.lastPayday);
        delete employees[employeeId];
        _partialPaid(tmpEmployee);//delete the employee first, and then paid for the employee
    }

    function changePaymentAddress(address oldAddress, address newAddress) onlyOwner public {
        // TODO: your code here
    }

    function updateEmployee(address employeeId, uint salary) onlyOwner public {
        require(msg.sender == owner);
        var employee = employees[employeeId];
        assert(employee.id != 0x0);
        
        totalSalary = totalSalary.sub(employee.salary).add(salary.mul(1 ether));
        Employee tmpEmployee = Employee(employee.id,employee.salary,employee.lastPayday);
        employees[employeeId].salary = salary.mul(1 ether);
        employees[employeeId].lastPayday = now;
        
        _partialPaid(tmpEmployee);//update the employee first, and then paid for the employee
    }

    function addFund() payable public returns (uint) {
        return address(this).balance;
    }

    function calculateRunway() public view returns (uint) {
        return this.balance.div(totalSalary);
    }

    function hasEnoughFund() public view returns (bool) {
        return calculateRunway() > 0;
    }

    function getPaid() public {
        var employee = employees[msg.sender];
        assert(employee.id != 0x0);
        
        uint nextPayday = employee.lastPayday.add(payDuration);
        assert(nextPayday < now);
        
        employees[msg.sender].lastPayday = nextPayday;
        employee.id.transfer(employee.salary);
    }
}
