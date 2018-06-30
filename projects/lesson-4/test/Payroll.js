var Payroll = artifacts.require("./Payroll.sol");

contract('Payroll',function(accounts) {
    const owner = accounts[0];
    const employee = accounts[1];
    const salary = 1;
    const other = accounts[2];



    it("...test addEmployee function by other",function() {
        return Payroll.deployed().then(function(instance) {
            payrollInstance = instance;
            return payrollInstance.addEmployee(employee,salary,{from:other});
        }).then(()=>{assert(false,"other can not call this function,only owner");
        }).catch(err => {console.log(err.message);});
    });

    it("...test addEmployee function normally",function() {
        return Payroll.deployed().then(function(instance) {
            payrollInstance = instance;
            return payrollInstance.addEmployee(employee,salary,{from:owner});
        });
    });

    it("...test addEmployee function second time",function() {
        return Payroll.deployed().then(function(instance) {
            payrollInstance = instance;
            return payrollInstance.addEmployee(employee,salary,{from:owner});
        }).then(()=>{assert(false,"second time can not run,employee is exist");
        }).catch(err => {console.log(err.message);});
    });

    it("...test removeEmployee function normally",function() {
        return Payroll.deployed().then(function(instance) {
            payrollInstance = instance;

            return payrollInstance.removeEmployee(employee,{from:owner});
        });
    });

    it("...test removeEmployee function by other",function() {
        return Payroll.deployed().then(function(instance) {
            payrollInstance = instance;
            return payrollInstance.addEmployee(employee,salary,{from:owner});
        }).then(function() {
            return payrollInstance.removeEmployee(employee,{from:other});
        }).then(()=>{assert(false,"other can not call this function,only owner");
        }).catch(err=>{console.log(err.message);});
    });

    it("...test removeEmployee function by unexist employee",function() {
        return Payroll.deployed().then(function(instance) {
            payrollInstance = instance;
            
            return payrollInstance.removeEmployee(employee,{from:owner});
            
        }).then(()=>{assert(false,"the employee is not exist");})
        .catch(err=>{console.log(err.message);});
    });

    //1.how to send ether to the contract?
    //2.how to change timestamp?






});
