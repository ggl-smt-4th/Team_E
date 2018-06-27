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
    
    mapping (address => Employee) public employees;
    
    uint constant payDuration = 30 days;
    //uint constant payDuration = 10 seconds;
    uint public totalSalary = 0;
    
    modifier checkInputAddressExist(address employeeId) {
        Employee employee = employees[employeeId];
        assert(employee.id != 0x0);
        _;
    }
    
    modifier checkInputAddressNoError(address employeeId){
        assert(employeeId != 0x0);
        _;
    }
    
    modifier checkSalary(uint s){
        assert(s > 0 && s < uint(-1));//learn from classmate
        _;
    }
    
    function _partialPaid(Employee employee) private {
        uint payment = employee.salary.mul(now.sub(employee.lastPayday)).div(payDuration);
        employee.id.transfer(payment);
    }
    
    function addEmployee(address employeeId, uint salary) onlyOwner checkInputAddressNoError(employeeId) checkSalary(salary) public {
        Employee employee = employees[employeeId];
        assert(employee.id == 0x0);
        
        uint s = salary.mul(1 ether);
        totalSalary = totalSalary.add(s);
        employees[employeeId] = Employee(employeeId, s, now);
    }

    function removeEmployee(address employeeId) onlyOwner checkInputAddressExist(employeeId) checkInputAddressNoError(employeeId) public {
        Employee employee = employees[employeeId];
        
        totalSalary = totalSalary.sub(employee.salary);
        _partialPaid(employee);
        delete employees[employeeId];
        
    }

    function changePaymentAddress(address oldAddress, address newAddress) onlyOwner checkInputAddressExist(oldAddress) checkInputAddressNoError(oldAddress) public {
        Employee employee = employees[oldAddress];
        //assert(newAddress != 0x0);
        
        //employees[newAddress] = Employee(newAddress,employee.salary,employee.lastPayday);
        //delete employees[oldAddress];
    }

    function updateEmployee(address employeeId, uint salary) onlyOwner checkInputAddressExist(employeeId) checkInputAddressNoError(employeeId) checkSalary(salary) public {
        Employee employee = employees[employeeId];
        
        totalSalary = totalSalary.sub(employee.salary).add(salary.mul(1 ether));
        _partialPaid(employee);
        employees[employeeId].salary = salary.mul(1 ether);
        employees[employeeId].lastPayday = now;
        
        
    }

    function addFund() payable public returns (uint) {
        return address(this).balance;
    }

    function calculateRunway() public view returns (uint) {
        assert(totalSalary>0);
        return address(this).balance.div(totalSalary);
    }

    function hasEnoughFund() public view returns (bool) {
        return calculateRunway() > 0;
    }

    function getPaid() checkInputAddressExist(msg.sender) public {
        Employee employee = employees[msg.sender];
        
        uint nextPayday = employee.lastPayday.add(payDuration);
        assert(nextPayday < now);
        assert(employee.salary < address(this).balance);
        
        employees[msg.sender].lastPayday = nextPayday;
        employee.id.transfer(employee.salary);
    }
    
}
