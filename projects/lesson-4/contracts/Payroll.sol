pragma solidity ^0.4.14;

import './SafeMath.sol';
import './Ownable.sol';

contract Payroll is Ownable {

    using SafeMath for uint;

    struct Employee {
        address id;
        uint salary;
        uint lastPayday;
    }

    uint constant payDuration = 30 days;
    // uint constant payDuration = 30 seconds;
    uint public totalSalary = 0;
    mapping(address => Employee) public employees;

    function Payroll() payable public {
    }
    
    modifier deleteEmployee(address employeeId) {
        _;
        delete employees[employeeId];
    }

    
    function _partialPaid(Employee employee) internal {
        assert(employee.id != 0x0);
        uint payment = employee.salary.mul(now.sub(employee.lastPayday)).div(payDuration);
        employee.id.transfer(payment);
        
    }

    function addEmployee(address employeeId, uint salary) public onlyOwner {
        require(int(salary) >= 0);
        var employee = employees[employeeId];
        assert(employee.id == 0x0);
        totalSalary = totalSalary.add(salary.mul(1 ether));
        employees[employeeId] = Employee(employeeId, salary.mul(1 ether), now);
    }

    function removeEmployee(address employeeId) public onlyOwner deleteEmployee(employeeId) {
        var employee = employees[employeeId];
        assert(employee.id != 0x0);
        _partialPaid(employee);
        totalSalary = totalSalary.sub(employee.salary);
    }

    function changePaymentAddress(address oldAddress, address newAddress) public onlyOwner deleteEmployee(oldAddress){
        assert(oldAddress != newAddress);
        var employee = employees[oldAddress];
        assert(employee.id != 0x0);
        _partialPaid(employee);
        employees[newAddress] = Employee(newAddress, employee.salary, now);
    }

    function updateEmployee(address employeeId, uint salary) public onlyOwner {
        require(int(salary) >= 0);
        var employee = employees[employeeId];
        assert(employee.id != 0x0);
        assert(employee.salary != salary);
        _partialPaid(employee);
        totalSalary = totalSalary.sub(employee.salary);
        employee.lastPayday = now;
        employee.salary = salary * 1 ether;
        totalSalary = totalSalary.add(employee.salary);
    }

    function addFund() payable public returns (uint) {
    }

    function calculateRunway() public view returns (uint) {
        return address(this).balance.div(totalSalary);
    }

    function hasEnoughFund() public view returns (bool) {
        return calculateRunway() > 0;
    }

    function getPaid() public {
        // TODO: your code here
        var employee = employees[msg.sender];
        assert(employee.id != 0x0);
        uint nextPayday = employee.lastPayday.add(payDuration);
        assert(nextPayday < now);
        employee.lastPayday = nextPayday;
        employee.id.transfer(employee.salary);
    }
}
