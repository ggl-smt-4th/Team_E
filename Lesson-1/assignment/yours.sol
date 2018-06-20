
/*作业请提交在这个目录下＊/
/*今天要解决的是可以调整员工的薪水和地址
只有owner可以更新employee的地址
只有employee可以加钱
getpaid转账前，增加balance余额校验，如果余额不足，则报错。
增加updateEmployee地址和金额的变化校验，如果没有变化，就不执行。


*/


pragma solidity ^0.4.14;

contract Payroll {
    uint constant payDuration = 10 seconds;
    uint lastPayday=now;
    uint salary;
    address owner;
    address employee;
    uint old_s; //s的上一次值


    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    modifier onlyEmployee() {
        require(msg.sender == employee);
        _;
    }


    function Payroll() {//初始化执行赋值执行程序的人
        owner = msg.sender;
    }

    function updateEmployee(address e, uint s) onlyOwner returns(uint){	//更新员工的地址和每月薪水额度
      //  require(msg.sender == owner);			 只允许owner调用,用modifier代替
        
        if(e==employee && s==old_s){ //如果数值没有改变，则不执行
            revert();
        }
        
        if (employee != 0x0) {				//为空表示是第一次初始化，不为空，表示执行过，如果执行过，就把2次调用间隔的薪水给他
            uint payment = salary * (now - lastPayday) / payDuration;
            employee.transfer(payment);
        }

        employee = e;
        salary = s * 1 ether;
        old_s=s;
        lastPayday = now;
        return(employee.balance);
    }

    function addFund() payable returns (uint) {//老板建立工资池，便于员工从池中自动付薪水
        return this.balance;
    }

    function calculateRunway() returns (uint) {//剩下的钱，够付几次
        return this.balance / salary;
    }

    function hasEnoughFund() returns (bool) {//是否够付
        return calculateRunway() > 0;
    }
    


    function getPaid() onlyEmployee {
       // require(msg.sender == employee); 用modifier代替

        uint nextPayday = lastPayday + payDuration;
        if(nextPayday > now) {
            revert();
        }
	if(hasEnoughFund()==false){//钱不够了，报错
		revert();

	}

        lastPayday = nextPayday;
        employee.transfer(salary);
        

    }
}

