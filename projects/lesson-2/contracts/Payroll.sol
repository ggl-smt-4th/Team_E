pragma solidity ^0.4.14;

contract PayRoll {
    struct Employee {
        address id;
        uint salary;
        uint lastPayDay;
    }
    
    address owner;
    uint public totalSalary;
    Employee[] public employees;
    
    uint constant PAY_DURATION = 30 days;
    
    function PayRoll() payable public {
        owner = msg.sender;
        totalSalary = 0;
    }
    
    function _patialPaid(Employee employee) private {
        uint payment = employee.salary * (now - employee.lastPayDay) / PAY_DURATION;
        employee.id.transfer(payment);
    }
    
    function _findEmployee(address employeeId) private returns (uint) {
        for (uint i = 0; i < employees.length; i++) {
            if (employees[i].id == employeeId) {
                return i;
            }
        }
    }
    
    function addEmployee(address employeeId, uint salary) public {
        require(msg.sender == owner);
        uint index = _findEmployee(employeeId);
        assert(index == 0);
        
        totalSalary += salary * 1 ether;
        employees.push(Employee(employeeId, salary * 1 ether, now));
    }
    
    function removeEmployee(address employeeId) public {
        require(msg.sender == owner);
        uint index = _findEmployee(employeeId);
        assert(index != 0);
        
        _patialPaid(employees[index]);
        totalSalary -= employees[index].salary * 1 ether;
        delete employees[index];
        employees[index] = employees[employees.length-1];
        employees.length -= 1;
    }
    
    function updateEmployee(address employeeId, uint salary) public {
        require(msg.sender == owner);
        uint index = _findEmployee(employeeId);
        assert(index != 0);
        
        _patialPaid(employees[index]);
        totalSalary += salary * 1 ether - employees[index].salary * 1 ether;
        employees[index].salary = salary * 1 ether;
        employees[index].lastPayDay = now;
    }  

    function addFund() payable public returns (uint) {
        return this.balance;
    }

    function calculateRunWay() public constant returns (uint) {
        return this.balance/totalSalary;
    }
    
    function hasEnoughFund() public constant returns (bool) {
        return calculateRunWay() > 0;
    }
    
    function getPaid() public {
        uint index = _findEmployee(msg.sender);
        assert(index != 0);
        
        uint nextPayDay = employees[index].lastPayDay + PAY_DURATION;
        assert(nextPayDay < now);
        
        employees[index].lastPayDay = nextPayDay;
        employees[index].id.transfer(employees[index].salary);
    }
}
