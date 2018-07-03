var Payroll = artifacts.require("./Payroll.sol");

contract('Payroll', function (accounts) {
  const owner = accounts[0];
  const employee = accounts[1];
  const guest = accounts[5];
  const salary = 1;

  let payroll;

   beforeEach("Setup contract for each test cases", () => {
    return Payroll.new().then(instance => {
      payroll = instance;
    });
  });

   it("Test call addEmployee() in right way", () => {
    return payroll.addEmployee(employee, salary, {from: owner})
  });

   it("Test call addEmployee() with negative salary", () => {
    return payroll.addEmployee(employee, -salary, {from: owner})
    .then(assert.fail)
    .catch(error => {
      assert.include(error.toString(), "Error: VM Exception", "Negative salary can not be accepted!");
    });
  });

   it("Test call addEmployee() by guest", () => {
    return payroll.addEmployee(employee, salary, {from: guest})
    .then(assert.fail)
    .catch(error => {
      assert.include(error.toString(), "Error: VM Exception", "Can not call addEmployee() by guest");
    });
  });

   it("Test call addEmployee() with exist employee", () => {
    return payroll.addEmployee(employee, salary, {from: owner})
    .then(() => payroll.addEmployee(employee, salary, {from: owner}))
    .then(assert.fail)
    .catch(error => {
      assert.include(error.toString(), "Error: VM Exception", "Exist employee can not be accepted!");
    });
  });

   it("Test call addEmployee() with empty employee", () => {
    return payroll.addEmployee(0, salary, {from: owner})
    .then(assert.fail)
    .catch(error => {
      assert.include(error.toString(), "Error: VM Exception", "Empty employee can not be accepted!");
    });
  });


});
