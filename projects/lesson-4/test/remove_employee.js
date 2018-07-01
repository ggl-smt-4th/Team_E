const Payroll = artifacts.require('Payroll');

contract('Payroll', function (accounts) {
    const owner = accounts[0];
    const employee = accounts[1];
    const employee2 = accounts[2];
    const guest = accounts[5];
    const salary = 1;
    
    it('owner remove employee Test', function () {
        let payroll;
        return Payroll.new().then(function (instance) {
            payroll = instance;
            return instance.addFund({from: owner, value: web3.toWei(2, 'ether')});
        })
            .then(function () {
            return payroll.addEmployee(employee, salary, {from: owner});
        })
            .then(function () {
            return payroll.removeEmployee(employee, {from: owner});
        })
            .then(function () {
            assert(true, 'removeEmployee should succeeded');
        }).catch(error => {
                assert.include(error.toString(), "Error: VM Exception", "Cannot call removeEmployee() by guest");
            });
    });

    it('non owner remove employee test', function () {
        let payroll;
        return Payroll.new().then(function (instance) {
            payroll = instance;
            return instance.addFund({from: owner, value: web3.toWei(2, 'ether')});
        })
            .then(function () {
                return payroll.addEmployee(employee, salary, {from: owner});
            })
            .then(function () {
                return payroll.removeEmployee(employee, {from: guest});
            })
            .then(function () {
                assert(false, 'remove employee by non owner should fail');
            }).catch(error => {
                assert.include(error.toString(), "Error: VM Exception", "Cannot call removeEmployee() by guest");
            });
    });

    it('remove non-exist employee Test', function () {
        let payroll;
        return Payroll.new().then(function (instance) {
            payroll = instance;
            return instance.addFund({from: owner, value: web3.toWei(2, 'ether')});
        })
            .then(function () {
                return payroll.addEmployee(employee, salary, {from: owner});
            })
            .then(function () {
                return payroll.removeEmployee(employee2, {from: owner});
            })
            .then(function () {
                assert(false, 'remove non-exist employee should fail');
            }).catch(error => {
                assert.include(error.toString(), "Error: VM Exception", "Cannot call removeEmployee() by guest");
            });
    });
});
