pragma solidity ^0.4.14;

contract Payroll {

    struct Employee {
        address id;
        uint salary;
        uint lastPayday;
    }

    uint constant payDuration = 30 days;
    
    address owner;
    Employee[] employees;

    function Payroll() payable public {
        owner = msg.sender;
    }

    function _partialPaid(Employee employee) private {
        uint payment = employee.salary * (now - employee.lastPayday)/payDuration;
        employee.id.transfer(payment);
    }
    
    function _findEmployee(address employeeAddress) private returns(Employee, uint){
        for(uint i = 0; i < employees.length; i++){
            if(employees[i].id==employeeAddress){
                return (employees[i],i);   
            }
        }
    }

    function addEmployee(address employeeAddress, uint salary) public {
        require(msg.sender == owner);
        var (employee,index) = _findEmployee(employeeAddress);
        assert(employee.id == 0x0);
        
        uint s = salary * 1 ether;
        employees.push(Employee(employeeAddress,s,now));
    }

    function removeEmployee(address employeeAddress) public {
        require(msg.sender == owner);
        var (employee,index) = _findEmployee(employeeAddress);
        assert(employee.id != 0x0);
        
        Employee tmpEmployee = employees[index];
        delete employees[index];
        employees[index] = employees[employees.length - 1];
        employees.length -= 1;
        _partialPaid(tmpEmployee);//delete the employee first, and then paid for the employee
    }

    function updateEmployee(address employeeAddress, uint salary) public {
        require(msg.sender == owner);
        var (employee,index) = _findEmployee(employeeAddress);
        assert(employee.id != 0x0);
        
        Employee tmpEmployee = employees[index];
        employees[index].salary = salary * 1 ether;
        employees[index].lastPayday = now;
        _partialPaid(tmpEmployee);//update the employee first, and then paid for the employee
    }

    function addFund() payable public returns (uint) {
        return address(this).balance;
    }

    function calculateRunway() public view returns (uint) {
        uint totalSalary = 0;
        for(uint i = 0;i < employees.length;i++){
            totalSalary += employees[i].salary;
        }
        return this.balance/totalSalary;
    }

    function hasEnoughFund() public view returns (bool) {
        return calculateRunway() > 0;
    }

    function getPaid() public {
        // TODO: your code here
        var (employee,index) = _findEmployee(msg.sender);
        assert(employee.id != 0x0);
        
        uint nextPayday = employee.lastPayday + payDuration;
        assert(nextPayday < now);
        employees[index].lastPayday = nextPayday;
        employee.id.transfer(employee.salary);
    }
}
