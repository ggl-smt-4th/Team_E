pragma solidity ^0.4.14;

contract Payroll {

uint constant payDuration = 10 seconds;

    struct Employee {
        // TODO: your code here
        address addrOfEmployee;
        uint salary;
        uint lastPayday;
    }

    address addrOfowner;
    Employee[] employees;

    //构造函数
    function Payroll() payable public {
        addrOfowner = msg.sender;
    }

    function partialPaid(Employee employee) private {
         uint partialdPaid = employee.salary * (now - employee.lastPayday)/payDuration;
         employee.addrOfEmployee.transfer(partialdPaid);

    }

    function findEmployee(address addrOfEmployee) private returns (Employee,uint) {
        for(uint i=0; i<employees.length; i++) {
            if( employees[i].addrOfEmployee == addrOfEmployee) {
                return (employees[i],i);
            }
    }
    }

    function addEmployee(address employeeAddress, uint salary) public {
        require(msg.sender == addrOfowner);
        // TODO: your code here
        for(uint i=0; i<employees.length; i++) {
            if( employees[i].addrOfEmployee == employeeAddress) {
                revert();
            }
        }
        employees.push(employees(employeeAddress,salary * 1 ether,now));
    }

    function removeEmployee(address employeeId) public {
        require(msg.sender == addrOfowner);
        // TODO: your code here
        var (employee,index) = findEmployee(employeeId);
        assert(employee.addrOfEmployee != 0x0);

        partialPaid(employee);
        delete employees[index];
        employees[index] = employees[employees.length - 1] ;
        employees.length -= 1;
    }

    function updateEmployee(address employeeAddress, uint salary) public {
        require(msg.sender == addrOfowner);
        // TODO: your code here
        var (employee,index) = findEmployee(employeeAddress);
        partialPaid(employee);
        employee.salary = salary * 1 ether;
        employee.lastPayday = now;
    }

    //存入工资
    function addFund() payable public returns (uint) {
        return address(this).balance;
    }

    function calculateRunway() public view returns (uint) {
        // TODO: your code here
        uint totalSalary = 0;
        for(uint i=0;i<employees.length;i++) {
            totalSalary += employees[i].salary;
        }
        assert(totalSalary!=0);
        return this.balance/totalSalary;
    }

    function hasEnoughFund() public view returns (bool) {
        return calculateRunway() > 0;
    }

    function getPaid() public {
        // TODO: your code here
        var (employee,index) = findEmployee(msg.sender);
        assert(employee.addrOfEmployee != 0x0);

        uint nextPayday = employee.lastPayday + payDuration;
        if(nextPayday >now) revert();

        employee.lastPayday = nextPayday;
        employee.addrOfEmployee.transfer(employee.salary);
    }
}
