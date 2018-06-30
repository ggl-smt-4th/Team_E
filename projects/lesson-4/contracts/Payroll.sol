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

    uint constant payDuration = 10 seconds;
    mapping(address => Employee) public employees;
    address owner;
    uint public totalSalary = 0;

    modifier notNoneAddress(address employeeId) {
       require(employeeId != 0x0);
        _;
    }


    function Payroll() payable public {
        owner = msg.sender;
    }

    function _settlement(address employeeId) payable{
        assert(employees[employeeId].id == employeeId);
        var e = employees[employeeId];
        uint money = e.salary.mul(now-e.lastPayDay)/payDuration;
        assert(money<=this.balance);
        e.lastPayDay = now;
        e.id.transfer(money);
    }

    function addEmployee(address employeeId, uint salary) public onlyOwner notNoneAddress(employeeId){
        assert(salary < uint(-300000));
        assert(employees[employeeId].id == 0x0);
        employees[employeeId] = Employee(employeeId, salary.mul(1 ether), now);
        totalSalary = totalSalary.add( salary * 1 ether);
    }

    function removeEmployee(address employeeId) public onlyOwner notNoneAddress(employeeId){
        assert(employees[employeeId].id == employeeId);
        totalSalary = totalSalary.sub(employees[employeeId].salary);
        _settlement(employeeId);
        delete employees[employeeId];
    }

    function changePaymentAddress(address oldAddress, address newAddress) public onlyOwner{
        require(oldAddress != newAddress);
        assert(employees[newAddress].id == 0x0);
        assert(employees[oldAddress].id == oldAddress);
        employees[newAddress] = Employee(newAddress, employees[oldAddress].salary, employees[oldAddress].lastPayDay);//employees[oldAddress];
        delete employees[oldAddress];
    }

    function updateEmployee(address employeeId, uint salary) public onlyOwner notNoneAddress(employeeId){
        assert(employees[employeeId].id == employeeId);
        _settlement(employeeId);
        totalSalary = totalSalary.sub(employees[employeeId].salary);
        employees[employeeId].salary = salary.mul(1 ether);
        totalSalary = totalSalary.add( employees[employeeId].salary);
    }

    function addFund() payable public returns (uint) {
        return address(this).balance;
    }

    function calculateRunway() public view returns (uint) {
        return address(this).balance / totalSalary;
    }

    function hasEnoughFund() public view returns (bool) {
        return calculateRunway() > 0;
    }

    function getPaid() public {
        require(msg.sender != 0x0);
        assert(employees[msg.sender].id == msg.sender);
        Employee e = employees[msg.sender];
        uint nextPayDay = e.lastPayDay + payDuration;
        assert(nextPayDay<now);
        e.lastPayDay = nextPayDay;
        e.id.transfer(e.salary);
    }
}
