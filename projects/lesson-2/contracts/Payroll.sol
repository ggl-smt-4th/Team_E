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
    uint total_salary = 0;

    function Payroll() payable public {
        owner = msg.sender;
    }

    function getInfo() returns (address) {
        return owner;
    }

    // function _totalSalary() returns (uint) {
    //     uint total_salary = 0;
    //     for(uint idx=0; idx<employees.length; idx++)
    //     {
    //         total_salary += employees[idx].salary;
    //     }
    //     return total_salary;
    // }

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

    function _settlement(uint idx) payable{
        Employee storage e = employees[idx];
        uint money = e.salary*(now-e.lastPayDay)/payDuration;
        assert(money<=this.balance);
        e.lastPayDay = now;
        e.id.transfer(money);
    }


    function addEmployee(address employeeAddress, uint salary) public returns (address){
        require(msg.sender == owner);
        // TODO: your code here
        require(employeeAddress != 0x0);

        uint idx = _findEmployee(employeeAddress);
        if (idx < employees.length)
        {
            revert();
        }
        total_salary += salary * 1 ether;
        Employee memory employee = Employee(employeeAddress, salary * 1 ether, now);
        employees.push(employee);
    }




    function removeEmployee(address employeeId) public {
        require(msg.sender == owner);
        // TODO: your code here
        assert(employeeId != 0x0);
        uint idx = _findEmployee(employeeId);
        if(idx == employees.length)
        {
            revert();
        }
        // send salary befor update
        total_salary -= employees[idx].salary;
        _settlement(idx);
        employees[idx] = employees[employees.length - 1];
        delete employees[employees.length-1]; //是像Python一样删除引用，还是像C一样释放空间
    }

    function updateEmployee(address employeeAddress, uint salary) public {
        require(msg.sender == owner);
        // TODO: your code here
        uint idx = _findEmployee(employeeAddress);
        if(idx == employees.length)
        {
            revert();
        }
        // send salary befor update
        _settlement(idx);
        total_salary = total_salary - employees[idx].salary + salary;
        employees[idx].salary = salary;
    }

    function addFund() payable public returns (uint) {
        return address(this).balance;
    }

    function calculateRunway() public view returns (uint) {
        // TODO: your code here
        return this.balance / total_salary;//_totalSalary();
    }

    function hasEnoughFund() public view returns (bool) {
        return calculateRunway() > 0;
    }

    function getPaid() payable public {
        // TODO: your code here
        require(msg.sender != 0x0);
        uint idx = _findEmployee(msg.sender);
        assert(idx!=employees.length);

        Employee e = employees[idx];
        uint nextPayDay = e.lastPayDay + payDuration;
        assert(nextPayDay<now);
        e.lastPayDay = nextPayDay;
        e.id.transfer(e.salary);
//        for(uint idx=0; idx<employees.length; idx++)
//        {
//            _getPaidEmployeei(idx);
//        }


    }

//    function _getPaidEmployeei(uint idx) payable
//    {
//        Employee e = employees[idx];
//        uint nextPayDay = e.lastPayDay + payDuration;
//        assert(nextPayDay<now);
//        e.lastPayDay = nextPayDay;
//        e.id.transfer(e.salary);
//    }

}

