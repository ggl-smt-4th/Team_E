# 优化前
* 初始使用和课程用一样的方式进行所有员工的工资求和
```
    function addEmployee(address employeeId, uint salary) public onlyOwner {
        var (employee, index) = _findEmployee(employeeId);
        if(employee.id == 0x0){
            employees.push(Employee(employeeId, salary, now));
        } else {
            if(salary != employee.salary){
                _partialPaid(employee);
                employee.lastPayday = now;
                employee.salary = salary;
            }
        }
    }
    
    function calculateRunway() public view returns (uint) {
        uint sum = 0;
        for(uint i = 0; i < employees.length; i++){
            sum += employees[i].salary;
        }
        return sum;
    }

```
## gas使用情况
* 无员工 485gas
* addEmployee 81962 gas，1员工 1266 gas
* addEmployee 67803 gas，2员工 2047 gas
* addEmployee 68644 gas，3员工 2828 gas
* addEmployee 69485 gas，4员工 3609 gas

# 修改1：将employee.length提出for循环
## gas使用情况
* 无员工 485gas
* addEmployee 81962 gas，1员工 1071 gas
* addEmployee 67803 gas，2员工 1644 gas
* addEmployee 68644 gas，3员工 2217 gas
* addEmployee 54485 gas，4员工 2790 gas
## 结论
* 由于for循环中，每次循环都会执行判断条件，导致多次执行employees.length。据此推断，每次读取storage变量都会消耗gas，因此要尽可能减少storage变量不必要的读取
# 进一步探索
* 使用一个uint数组求和的小demo来进行简单测试，初始代码如下
```
    uint[] testArray;
    function addNnumber(uint number){
        testArray.push(number);
    }
    function sumArray() returns (uint){
        uint count = testArray.length;
        uint sum = 0;
        for(uint i = 0; i < count; i++){
            sum += testArray[i];
        }
        return sum;
    }
```
## gas使用情况
* 无数字 542 gas
* addNnumber 40632 gas，1数字 1098 gas
* addNnumber 25632 gas，2数字 1654 gas
* addNnumber 25632 gas，3数字 2210 gas
* addNnumber 25632 gas，4数字 2766 gas
## i++ 换为++i gas使用情况
* 无数字 542 gas
* addNnumber 40632 gas，1数字 1093 gas
* addNnumber 25632 gas，2数字 1644 gas
* addNnumber 25632 gas，3数字 2195 gas
* addNnumber 25632 gas，4数字 2746 gas
* 每次调用减少5gas，不清楚EVM底层，猜测类似C++
```
// 前缀形式：
int& int::operator++() {
    *this += 1;  
    return *this;  
}

//后缀形式:
const int int::operator++(int){
    //函数带参，说明有另外的空间开辟
    int oldValue = *this; 
    ++(*this);
    return oldValue; 
}
```
## uint i换为uint8 i gas使用情况
* 由于员工只有10人，降低uint为uint8，减少存储开销
* gas消耗反而增大。。因为EVM为32字节 256位系统，使用更少位数的数字，会导致存储时需要特殊处理

# 结论
* 在for循环条件中，尽量不进行不必要的读写和运算等
* 尽量使用++i
* 对单纯计算而言，uint是最节约gas的数字类型