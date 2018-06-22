pragma solidity ^0.4.14;

contract Payroll {

    struct Employee {
        address id;
        uint salary;
        uint lastPayday;
    }

    uint constant payDuration = 30 days;
    // uint constant payDuration = 10 seconds;

    address owner;
    Employee[] employees;
    uint[] testArray;
    function addNnumber(uint number){
        assert(number > 0);
        testArray.push(number);
    }
    function sumArray() returns (uint){
        uint count = testArray.length;
        uint sum = 0;
        for(uint i = 0; i < count; ++i){
            sum += testArray[i];
        }
        return sum;
    }

    function Payroll() payable public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    function _findEmployee(address employeeId) internal returns (Employee, uint){
        for(uint i = 0; i < employees.length; i++){
            if(employees[i].id == employeeId){
                return (employees[i], i);
            }
        }
    }
    
    function _deleteEmployee(uint index) internal {
        delete employees[index];
        employees[index] = employees[employees.length - 1];
        employees.length -= 1;
    }
    
    function _partialPaid(Employee employee) internal {
        assert(employee.id != 0x0);
        uint payment = employee.salary * (now - employee.lastPayday) / payDuration;
        employee.id.transfer(payment);
        
    }
        
    function addEmployee(address employeeId, uint salary) public onlyOwner {
        require(int(salary) >= 0);
        var (employee, index) = _findEmployee(employeeId);
        if(employee.id == 0x0){
            employees.push(Employee(employeeId, salary * 1 ether, now));
        } else {
            if(salary != employee.salary){
                _partialPaid(employee);
                employees[index].lastPayday = now;
                employees[index].salary = salary * 1 ether;
            }
        }
    }

    function removeEmployee(address employeeId) public onlyOwner {
        var (employee, index) = _findEmployee(employeeId);
        assert(employee.id != 0x0);
        _partialPaid(employee);
        _deleteEmployee(index);
    }

    function updateEmployee(address employeeId, uint salary) public onlyOwner {
        require(int(salary) >= 0);
        var (employee, index) = _findEmployee(employeeId);
        assert(employee.id != 0x0);
        _partialPaid(employee);
        employees[index].lastPayday = now;
        employees[index].salary = salary * 1 ether;
    }

    function addFund() payable public returns (uint) {
        return address(this).balance;
    }

    function calculateRunway() public view returns (uint) {
        uint sum = 0;
        uint employeeCount = employees.length;
        for(uint i = 0; i < employeeCount; ++i){
            sum += employees[i].salary;
        }
        return this.balance/sum;
    }

    function hasEnoughFund() public view returns (bool) {
        return calculateRunway() > 0;
    }

    function getPaid() public {
        var (employee, index) = _findEmployee(msg.sender);
        assert(employee.id != 0x0);
        uint nextPayday = employee.lastPayday + payDuration;
        assert(nextPayday < now);
        employees[index].lastPayday = nextPayday;
        employee.id.transfer(employee.salary);
    }
    
    function getEmployeeCount() public view returns (uint){
        return employees.length;
    }
    function getEmployeeSalary() public view returns (uint){
        var (employee, index) = _findEmployee(msg.sender);
        assert(employee.id != 0x0);
        return employee.salary;
    }
}
