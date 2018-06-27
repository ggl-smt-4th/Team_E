// software version
pragma solidity ^0.4.14;

// new contract
contract Payroll {
    // new struct employee
    struct Employee {
        address id;
        uint salary;
        uint lastPayday;
    }
    
    uint constant payDuration = 10 seconds;
    // uint constant payDuration = 30 days;

    address owner;
    Employee[] employees;

    function Payroll() payable public {
        owner = msg.sender;
    }
    
   function _partialPaid(Employee employee) private {
        uint payment = employee.salary * (now - employee.lastPayday)/payDuration;
        employee.id.transfer(payment);
    }
    
    function _findEmployee(address employeeAd) private returns(Employee, uint){
        for(uint i = 0; i < employees.length; i++){
            if(employees[i].id==employeeAd){
                return (employees[i],i);   
            }
        }
    }

    function addEmployee(address employeeAd, uint salary) public {
        require(msg.sender == owner);
        
        var (employee,index) = _findEmployee(employeeAd);
        assert(employee.id == 0x0);
        
        uint s = salary * 1 ether;
        employees.push(Employee(employeeAd, s, now));
    }

    function removeEmployee(address employeeAd) public {
        require(msg.sender == owner);
        var (employee,index) = _findEmployee(employeeAd);
        assert(employee.id != 0x0);
        
        Employee tmpEmployee = employees[index];
        delete employees[index];
        employees[index] = employees[employees.length - 1];
        employees.length -= 1;
        _partialPaid(tmpEmployee);
    }

    function updateEmployee(address employeeAd, uint salary) public {
        require(msg.sender == owner);
        var (employee,index) = _findEmployee(employeeAd);
        assert(employee.id != 0x0);
        
        Employee tmpEmployee = employees[index];
        employees[index].salary = salary * 1 ether;
        employees[index].lastPayday = now;
        _partialPaid(tmpEmployee);
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
        var (employee,index) = _findEmployee(msg.sender);
        assert(employee.id != 0x0);
        
        uint nextPayday = employee.lastPayday + payDuration;
        assert(nextPayday < now);
        employees[index].lastPayday = nextPayday;
        employee.id.transfer(employee.salary);
    }
}
