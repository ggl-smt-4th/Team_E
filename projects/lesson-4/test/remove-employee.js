let Payroll = artifacts.require("./Payroll.sol");

contract('Payroll:removeEmployee', (accounts) => {
  const owner = accounts[0];
  const employee = accounts[1];
  const guest = accounts[2];
  const salary = 1;

  let payroll;

  beforeEach("Setup contract for each test cases", () => {
    return Payroll.new().then(instance => {
      payroll = instance;
      payroll.addEmployee(employee, salary, {from: owner});
    });
  });

  it("Test call removeEmployee() in right way", () => {
    return payroll.removeEmployee(employee, {from: owner});
  });

  it("Test call removeEmployee() by guest", () => {
    return payroll.removeEmployee(employee, {from: guest})
    .then(assert.fail)
    .catch(error => {
      assert.include(error.toString(), "Error: VM Exception", "Cannot call removeEmployee() by guest");
    });
  });

  it("Test call removeEmployee() by empty employee", () => {
    return payroll.removeEmployee(0, {from: owner})
    .then(assert.fail)
    .catch(error => {
      assert.include(error.toString(), "Error: VM Exception", "Cannot call removeEmployee() by empty employee");
    });
  });

  it("Test call removeEmployee() by a non-employee", () => {
    return payroll.removeEmployee(guest, {from: owner})
    .then(assert.fail)
    .catch(error => {
      assert.include(error.toString(), "Error: VM Exception", "Cannot call removeEmployee() by a non-employee");
    });
  });
});