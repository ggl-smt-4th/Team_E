
1)10次调用calculateRunway 时 Gas的消耗情况:

序号	execution cost		transaction cost	
1	    1702		          22974	
2	    2483		          23755	
3	    3264		          24536	
4	    4045		          25317	
5	    4826		          26098	
6	    5607		          26879	
7	    6388		          27660	
8	    7169		          28441	
9	    7950		          29222	
10	  8731		          30003	

2)calculateRunway() 函数的优化思路和过程
原函数
function calculateRunway() public view returns (uint) {
        uint totalSalary = 0;
        for(uint i = 0;i < employees.length;i++){
            totalSalary += employees[i].salary;
        }
        return this.balance/totalSalary;
    }
    
分析 ：
    原函数每次计算都需要把所有员工工资累加，然后余额再除以总工资。
其中，员工工资累加这一操作多次重复，但是原始数据变动情况很少，
所以应该定义一个totalSalary的状态变量（storage），
同时增加一个员工数据是否变动的状态SalaryHasChanged。
SalaryHasChanged 初始默认为false，
每次调用addEmployee\updateEmployee\removeEmployee时都把SalaryHasChanged设成true.
运行 calculateRunway前检查SalaryHasChanged，如果为false，则使用当前totalSalary的值；
如果为true，则重新计算totalSalary，然后把SalaryHasChanged设成false。

contract Payroll{
    ......
    bool SalaryHasChanged = false;
    uint totalSalary = 0;
    
    function addEmployee(address employeeAddress, uint salary) public {
      ......
      SalaryHasChanged = true;
    }
    
    function removeEmployee(address employeeAddress) public {
      ......
      SalaryHasChanged = true;
    }
    
    function updateEmployee(address employeeAddress, uint salary) public {
      ......
      SalaryHasChanged = true;
    }
    
    function calculateRunway() public view returns (uint) {
        if(SalaryHasChanged){
          totalSalary = 0;
          for(uint i = 0;i < employees.length;i++){
              totalSalary += employees[i].salary;
          }
          SalaryHasChanged = false;
        }
        return this.balance/totalSalary;
    }
}
