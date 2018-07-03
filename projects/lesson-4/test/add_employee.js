var Payroll = artifacts.require("Payroll");

contract('Payroll', function (accounts) {

    const owner = accounts[0];
    const employee = accounts[1];
    const guest = accounts[2];
    const salary = 1;

    it('run test', function () {
        let payroll;
        return Payroll.new().then(function (instance) {
            payroll = instance;
            payroll.addEmployee(employee, salary);
        }).then(function () {
            payroll.addFund({from: owner, value: web3.toWei(2, 'ether')});
        }).then(() => {
            return payroll.calculateRunway();
        }).then(runway => {
            assert.equal(runway, 2, "runway should be 2");
        }).catch(error => {
            assert.include(error.toString(), "Error: VM Exception", "Cannot call addEmployee() by guest");
        });;
    });
    
    it('illegal salary test', function () {
        let payroll;
        return Payroll.new().then(function (instance) {
            payroll = instance;
        }).then(function(){
            return payroll.addEmployee(employee, -1);
        }).then(() => {
            assert(false, "adding employee with illegal salary should fail!");
        }).catch(error => {
            assert.include(error.toString(), "Error: VM Exception", "Cannot call addEmployee() by guest");
        });
    });

    it("guest call addEmployee test", function () {
        let payroll;
        return Payroll.new().then(function (instance) {
            payroll = instance;
        }).then(function(){
            return payroll.addEmployee(employee, 1, {from: guest});
        }).then(() => {
            assert(false, "adding employee with guest should fail!");
        }).catch(error => {
            assert.include(error.toString(), "Error: VM Exception", "Cannot call addEmployee() by guest");
        });
    });

    it("employee call addEmployee test", function () {
        let payroll;
        return Payroll.new().then(function (instance) {
            payroll = instance;
        }).then(function(){
            return payroll.addEmployee(employee, 1, {from: employee});
        }).then(() => {
            assert(false, "adding employee with employee should fail!");
        }).catch(error => {
            assert.include(error.toString(), "Error: VM Exception", "Cannot call addEmployee() by employee");
        });
    });
});
