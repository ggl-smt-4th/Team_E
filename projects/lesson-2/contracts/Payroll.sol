pragma solidity ^0.4.14;

contract Payroll {

    struct Employee {
        address id;
        uint salary;
        uint lastPayDay;
    }

    uint constant payDuration = 30 days;
    address owner;
    Employee[] employees;
    uint totalSalary = 0;
    

    function Payroll() payable public {
        owner = msg.sender;
    }

    function addFund() payable public returns (uint) {
        require(msg.sender == owner);
        return this.balance;
    }
    
    function getUnpaidSalary(Employee employee) private returns (uint){
        return employee.salary * (now - employee.lastPayDay) / payDuration;
    }
    
    function findEmployee(address employeeId) private returns (Employee, uint) {
        for(uint i=0; i<employees.length; i++) {
            if(employees[i].id == employeeId) {
                return (employees[i], i);
            }
        }
    }
    
    function addEmployee(address employeeAddress, uint salary) public {
        require(msg.sender == owner);
        
        salary = salary* 1 ether;
        var (employee,index) = findEmployee(employeeAddress);
        assert(employee.id==0x0);
        employees.push(Employee(employeeAddress,salary,now));
        totalSalary += salary;
    }

    function removeEmployee(address employeeAddress) public {
        require(msg.sender == owner);
        
        var (employee,index) = findEmployee(employeeAddress);
        assert(employee.id != 0x0);
        
        Employee former = employees[index];
        totalSalary -= former.salary;
        delete employees[index];
        employees[index] = employees[employees.length-1];
        employees.length-=1;
        
        former.id.transfer(getUnpaidSalary(former));
    }

    function updateEmployee(address employeeAddress, uint salary) public {
        require(msg.sender == owner);
        
        salary = salary * 1 ether;
        var (employee,index) = findEmployee(employeeAddress);
        assert(employee.id != 0x0);
        Employee former = employees[index];
        totalSalary -= former.salary;
        totalSalary += salary;
        employees[index].salary = salary;
        employees[index].lastPayDay = now;
        former.id.transfer(getUnpaidSalary(former));
    }



    function calculateRunway() public view returns (uint) {
        return this.balance/totalSalary;
    }

    function hasEnoughFund() public view returns (bool) {
        return calculateRunway() > 0;
    }

    function getPaid() public {
        var (employee,index) = findEmployee(msg.sender);
        assert(employee.id != 0x0 && hasEnoughFund());
        
        uint nextPayDay = employees[index].lastPayDay + payDuration;
        assert(nextPayDay < now);
        employees[index].lastPayDay = nextPayDay;
        
        employees[index].id.transfer(getUnpaidSalary(employees[index]));
    }
}
