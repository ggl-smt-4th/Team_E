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

    function Payroll() payable public {
        owner = msg.sender;
    }

    function _totalSalary() returns (uint) {
        uint total_salary = 0;
        for(uint idx=0; idx<employees.length; idx++)
        {
            total_salary += employees[idx].salary;
        }
        return total_salary;
    }

    function _findEmployee(address employeeAddress) returns (uint){

        for(uint idx=0; idx<employees.length; idx++)
        {
            if(employees[idx].id == employeeAddress)
            {
                break;
            }
        }
        return idx;

    }

    function _settlement(Employee e) payable{
        uint money = salary*(lastPayDay-now)/payDuration;
        assert(money<=this.balance);
        e.lastPayDay = now;
        e.id.transfer(money);
    }


    function addEmployee(address employeeAddress, uint salary) public {
        require(msg.sender == owner);
        // TODO: your code here
        require(employeeAddress != 0x0);

        idx = _findEmloyee(employeeAddress);
        if (idx < employees.length)
        {
            revert();
        }

        employee = Employee(employeeAddress, salary, now);
        employees.push(employee);
    }




    function removeEmployee(address employeeId) public {
        require(msg.sender == owner);
        // TODO: your code here
        assert(employeeAddress != 0x0);
        idx = _findEmloyee(employeeAddress);
        if(idx == employees.length)
        {
            revert();
        }
        // 把array理解成linked list?
        // send salary befor update
        _settlement(employees[idx]);
        employees[idx] = employees[employees.length - 1];
        delete employees[employees.length-1]; //是像Python一样删除引用，还是像C一样释放空间
    }

    function updateEmployee(address employeeAddress, uint salary) public {
        require(msg.sender == owner);
        // TODO: your code here
        idx = _findEmloyee(employeeAddress);
        if(idx == employees.length)
        {
            revert();
        }
        // send salary befor update
        _settlement(employees[idx]);
        employees[idx].salary = salary;
        employees[idx].lastPayDay = now;
    }

    function addFund() payable public returns (uint) {
        return address(this).balance;
    }

    function calculateRunway() public view returns (uint) {
        // TODO: your code here
        return this.balance / _totalSalary();
    }

    function hasEnoughFund() public view returns (bool) {
        return calculateRunway() > 0;
    }

    function getPaid() public {
        // TODO: your code here
        require(msg.sender == owner);
        for(uint idx=0; idx<employees.length; idx++)
        {
            _getPaidEmployeei(employees[idx]);
        }

    }

    function _getPaidEmployeei(Employee e) payable
    {
        uint nextPayDay = e.lastPayDay + e.payDuration;
        if (nextPayDay>now)
        {
            revert();
        }
        e.lastPayDay = nextPayDay;
        e.transfer(e.salary);
    }

}

