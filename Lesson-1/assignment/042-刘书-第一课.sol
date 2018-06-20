pragma solidity ^0.4.24;
contract Payroll {
    //boss's address is constant
    address boss;
    uint constant payDuration = 10 seconds;
    
    address employeeAdress;
    uint salary;
    uint lastPayDay =now;
    
    function Payroll() {
        boss = msg.sender;
    }
    
    //private function
    function setArgs(address e, uint s) private{
        employeeAdress = e;
        salary = s * 1 ether;
        lastPayDay = now;
    }
    
     //only boss could set salary and salary shuold be > 0
    function updateEmployee(address e, uint s) {
        require(msg.sender == boss && s>=0);
        
        if (employeeAdress == 0x0) {
            setArgs(e,s);
        }else{
            uint payment = salary * (now - lastPayDay) / payDuration;
            address former = employeeAdress;
            setArgs(e,s);
            //finish all args change before transfer moeny
            former.transfer(payment);
        }
    }

    function addFund() payable returns (uint){
        return this.balance;    
    }
    
    function calculateRunway() returns (uint){
        return this.balance/salary;
    }
    
    function hasEnoughFund() returns (bool){
        return calculateRunway() > 0;
    }
    
    //makesure boss have enough fund beforePay
    function getPaid(){
        require(msg.sender == employeeAdress && hasEnoughFund());
        uint nextPayDay = lastPayDay + payDuration;
        assert(nextPayDay < now);
        uint payment = salary * (now - lastPayDay) / payDuration;
        lastPayDay = nextPayDay;
        employeeAdress.transfer(payment);
    }
    
}
