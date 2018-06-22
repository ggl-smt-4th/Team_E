Gas变化记录:
用一个单独的_totalSalary()函数来计算total_salary(通过循环)
| Employee No.| Transaction cost(gas)           | Execution cost(gas)  |
| ------------- |:-------------:| -----:|
| 1 | 23031 | 1759| 
| 2 | 23812 | 2540   |
| 3 | 24593 | 3321   |
| 4 | 25374 | 4102 |
| 5 | 26155 | 4883 |
| 6 | 26936 | 5664 |
| 7 | 27717 | 6445 |
| 8 | 28498 | 7226 |
| 9 | 29279 | 8007 |
|10 | 30060 | 8788 |

如果想要减少calculateRunway的gas消耗，一个naive的改法是在创建一个total_salary全局变量并在add,delete,update操作时维护这个变量，
这么做的话第一次的execution cost可以降到882， transaction cost可以降到22154 gas.