### 作业

* 完成第二课所讲智能合约，添加 100ETH 到合约中

* 加入十个员工，每个员工的薪水都是 1ETH

    每次加入一个员工后调用 `calculateRunway()` 这个函数，并且记录消耗的 gas。Gas 变化么？如果有，为什么？

* 如何优化 `calculateRunway()` 这个函数来减少 gas 的消耗？

* 提交
    1. 智能合约代码: 
        * **复制 `projects/lesson-2/contracts/Payroll.sol.sample` 到 `projects/lesson-2/contracts/Payroll.sol` 并实现相关 TODO 处的代码**
        * 提交时请修改为 `payDuration = 30 days` 
        * 保持各 public 的函数名不变。

    2. gas 变化的记录，放到 `projects/lesson-2/home-work.md` 中。

    3. `calculateRunway()` 函数的优化思路和过程, 放到 `projects/lesson-2/home-work.md` 中。




1)
transaction cost 	22974 gas (Cost only applies when called by a contract)
 execution cost 	1702 gas (Cost only applies when called by a contract)
2)
 transaction cost 	23755 gas (Cost only applies when called by a contract)
 execution cost 	2483 gas (Cost only applies when called by a contract)
3)
 transaction cost 	24536 gas (Cost only applies when called by a contract)
 execution cost 	3264 gas (Cost only applies when called by a contract)
 4)
  transaction cost 	25317 gas (Cost only applies when called by a contract)
 execution cost 	4045 gas (Cost only applies when called by a contract)
 5)
  transaction cost 	26098 gas (Cost only applies when called by a contract)
 execution cost 	4826 gas (Cost only applies when called by a contract)

6)
 transaction cost 	26879 gas (Cost only applies when called by a contract)
 execution cost 	5607 gas (Cost only applies when called by a contract)
 7)
  transaction cost 	27660 gas (Cost only applies when called by a contract)
 execution cost 	6388 gas (Cost only applies when called by a contract)
 8)
 transaction cost 	28441 gas (Cost only applies when called by a contract)
 execution cost 	7169 gas (Cost only applies when called by a contract)
 9)
  transaction cost 	29222 gas (Cost only applies when called by a contract)
 execution cost 	7950 gas (Cost only applies when called by a contract)
 10)
  transaction cost 	30003 gas (Cost only applies when called by a contract)
 execution cost 	8731 gas (Cost only applies when called by a contract)


 应为每次增加员工调用的时候，数组的长度会增加1，所以for循环的执行会增加一次，所以增加全局变量totalSalary，在执行添加删除的时候，就改变其值，这样就可以减少calculateRunway的消耗

