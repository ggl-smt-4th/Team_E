pragma solidity ^0.4.14;

import "./SafeMath.sol";
import "./Ownable.sol";

contract Payroll is Ownable {

    using SafeMath for uint;

    struct Employee {
        address id;
        uint salary;
        uint lastPayDay;
    }

    uint constant PAY_DURATION = 30 days;
    mapping(address => Employee) public employees;
    address owner;
    uint public totalSalary = 0;

    function Payroll() payable public {
        owner = msg.sender;
    }

    modifier isValidAddr(address employeeId) {
        require(employeeId != address(0));
        _;
    }

    modifier isExist(address employeeId) {
        require(employeeId != address(0));
        assert(employees[employeeId].id != address(0));
        _;
    }

    modifier notExist(address employeeId) {
        require(employeeId != address(0));
        assert(employees[employeeId].id == address(0));
        _;
    }

    function _patialPaid(Employee e) private {
        uint payment = e.salary.mul(now - e.lastPayDay).div(PAY_DURATION);
        assert(payment <= address(this).balance);

        e.lastPayDay = now;
        e.id.transfer(payment);
    }

    function addEmployee(address employeeId, uint salary) public 
        onlyOwner 
        isValidAddr(employeeId)
        notExist(employeeId) {
        uint _salary = salary.mul(1 ether);

        employees[employeeId] = Employee(employeeId, _salary, now);
        totalSalary = totalSalary.add(_salary);
    }

    function removeEmployee(address employeeId) public 
        onlyOwner 
        isValidAddr(employeeId)
        isExist(employeeId) {
        var e = employees[employeeId];
        uint salary = e.salary;
        _patialPaid(e);
        totalSalary = totalSalary.sub(salary);
        delete employees[employeeId];
    }

    function changePaymentAddress(address oldAddress, address newAddress) public 
        onlyOwner
        isValidAddr(newAddress) 
        isExist(oldAddress)
        notExist(newAddress) {
        require(oldAddress != newAddress);
        var oldE = employees[oldAddress];

        employees[newAddress] = Employee(newAddress, oldE.salary, oldE.lastPayDay);
        delete employees[oldAddress];
    }

    function updateEmployee(address employeeId, uint salary) public 
        onlyOwner
        isValidAddr(employeeId) 
        isExist(employeeId) {
        var e = employees[employeeId];
        uint _salary = salary.mul(1 ether);

        _patialPaid(e);
        totalSalary = totalSalary.sub(e.salary);
        employees[employeeId].salary = _salary;
        totalSalary = totalSalary.add(_salary);
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

    function getPaid() public
        isValidAddr(msg.sender) 
        isExist(msg.sender) {
        var e = employees[msg.sender];

        uint nextPayDay = e.lastPayDay + PAY_DURATION;
        assert(nextPayDay <= now);
        e.lastPayDay = nextPayDay;
        e.id.transfer(e.salary);
    }
}