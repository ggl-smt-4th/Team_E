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
    uint public totalSalary = 0;
    mapping(address => Employee) public employees;
    address owner;
    uint public total_salary = 0;

    modifier notNoneAddress(address employeeId) {
       require(employeeId != 0x0);
        _;
    }


    function Payroll() payable public {
        owner = msg.sender;
    }

    function _settlement(address employeeId) payable{
        Employee e = employees[employeeId];
        uint money = e.salary*(now-e.lastPayDay)/payDuration;
        assert(money<=this.balance);
        e.lastPayDay = now;
        e.id.transfer(money);
    }

    function addEmployee(address employeeId, uint salary) public onlyOwner notNoneAddress(employeeId){
        assert(salary>=0);
        assert(employees[employeeId].id == 0x0);
        employees[employeeId] = Employee(employeeId, salary * 1 ether, now);
        total_salary += salary * 1 ether;
    }

    function removeEmployee(address employeeId) public onlyOwner notNoneAddress(employeeId){
        assert(employees[employeeId].id == employeeId);
        total_salary -= employees[employeeId].salary;
        _settlement(employeeId);
        delete employees[employeeId];
    }

    function changePaymentAddress(address oldAddress, address newAddress) public onlyOwner{
        assert(employees[newAddress].id == 0x0);
        assert(employees[oldAddress].id == oldAddress);
        employees[newAddress] = employees[oldAddress];
        delete employees[oldAddress];
    }

    function updateEmployee(address employeeId, uint salary) public onlyOwner notNoneAddress(employeeId){
        assert(employees[employeeId].id == employeeId);
        assert(salary>=0);
        _settlement(employeeId);
        total_salary = total_salary - employees[employeeId].salary + salary;
        employees[employeeId].salary = salary * 1 ether;
    }

    function addFund() payable public returns (uint) {
        return address(this).balance;
    }

    function calculateRunway() public view returns (uint) {
        return address(this).balance / total_salary;
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
