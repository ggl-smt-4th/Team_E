var Payroll = artifacts.require("./Payroll.sol");


contract('Payroll', function (accounts) {
    const owner = accounts[0];
    const employee = accounts[1];
    const guest = accounts[5];
    const salary = 1;


    //Caller: Owner
    it("Test call addEmployee() by owner", function () {
    var payroll;
    return Payroll.new().then(instance => {
        payroll = instance;
        return payroll.addEmployee(employee, salary, {from: owner});
    });
    });


    // Caller: Employee:
    it("Test addEmployee() by guest", function () {
    var payroll;
    return Payroll.new().then(function (instance) {
        payroll = instance;
        return payroll.addEmployee(employee, salary, {from: guest});
    }).then(() => {
        assert(false, "Should not be successful");
    }).catch(error => {
        assert.include(error.toString(), "Error: VM Exception", "Can not call addEmployee() by guest");
    });
    });



    //Salary: Negative salary
    it("Test call addEmployee() with negative salary", function () {
        var payroll;
        return Payroll.new().then(instance => {
            payroll = instance;
            return payroll.addEmployee(employee, -salary, {from: owner});
        }).then(assert.fail).catch(error => {
            assert.include(error.toString(), "Error: VM Exception", "Negative salary can not be accepted!");
        });
        });
    
    it("Test call addEmployee() with null employee address", function(){
        var payroll;
        return Payroll.new().then(instance => {
            payroll = instance;
            return payroll.addEmployee(0x0, salary, {from: owner});
        }).then(assert.fail).catch(error => {
            assert.include(error.toString(), "Error: VM Exception", "Input Employee could not be null.");
        });
    });

    it("Test total_salary change correctly.", function(){
        var payroll;
        var totalSalary;
        return Payroll.new().then(instance => {
            payroll = instance;
            totalSalary = payroll.totalSalary;
            return payroll.addEmployee(employee, salary, {from: owner});
        })
        .then(() => {payroll.totalSalary == totalSalary+salary;});
    });
});