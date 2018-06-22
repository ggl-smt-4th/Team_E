# �Ż�ǰ
* ��ʼʹ�úͿγ���һ���ķ�ʽ��������Ա���Ĺ������
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
## gasʹ�����
* ��Ա�� 485gas
* addEmployee 81962 gas��1Ա�� 1266 gas
* addEmployee 67803 gas��2Ա�� 2047 gas
* addEmployee 68644 gas��3Ա�� 2828 gas
* addEmployee 69485 gas��4Ա�� 3609 gas

# �޸�1����employee.length���forѭ��
## gasʹ�����
* ��Ա�� 485gas
* addEmployee 81962 gas��1Ա�� 1071 gas
* addEmployee 67803 gas��2Ա�� 1644 gas
* addEmployee 68644 gas��3Ա�� 2217 gas
* addEmployee 54485 gas��4Ա�� 2790 gas
## ����
* ����forѭ���У�ÿ��ѭ������ִ���ж����������¶��ִ��employees.length���ݴ��ƶϣ�ÿ�ζ�ȡstorage������������gas�����Ҫ�����ܼ���storage��������Ҫ�Ķ�ȡ
# ��һ��̽��
* ʹ��һ��uint������͵�Сdemo�����м򵥲��ԣ���ʼ��������
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
## gasʹ�����
* ������ 542 gas
* addNnumber 40632 gas��1���� 1098 gas
* addNnumber 25632 gas��2���� 1654 gas
* addNnumber 25632 gas��3���� 2210 gas
* addNnumber 25632 gas��4���� 2766 gas
## i++ ��Ϊ++i gasʹ�����
* ������ 542 gas
* addNnumber 40632 gas��1���� 1093 gas
* addNnumber 25632 gas��2���� 1644 gas
* addNnumber 25632 gas��3���� 2195 gas
* addNnumber 25632 gas��4���� 2746 gas
* ÿ�ε��ü���5gas�������EVM�ײ㣬�²�����C++
```
// ǰ׺��ʽ��
int& int::operator++() {
    *this += 1;  
    return *this;  
}

//��׺��ʽ:
const int int::operator++(int){
    //�������Σ�˵��������Ŀռ俪��
    int oldValue = *this; 
    ++(*this);
    return oldValue; 
}
```
## uint i��Ϊuint8 i gasʹ�����
* ����Ա��ֻ��10�ˣ�����uintΪuint8�����ٴ洢����
* gas���ķ������󡣡���ΪEVMΪ32�ֽ� 256λϵͳ��ʹ�ø���λ�������֣��ᵼ�´洢ʱ��Ҫ���⴦��

# ����
* ��forѭ�������У����������в���Ҫ�Ķ�д�������
* ����ʹ��++i
* �Ե���������ԣ�uint�����Լgas����������