var Payroll = artifacts.require("./Payroll.sol");

contract('Payroll', function (accounts) {
  const owner = accounts[0];
  const employee = accounts[1];
  const guest = accounts[5];
  const salary = 1;
  const runway = 20;
  const payDuration = (30 + 1) * 86400;
  const fund = runway * salary;

  let payroll;

  beforeEach("Setup contract for each test cases", () => {
    return Payroll.new.call(owner, {from: owner, value: web3.toWei(fund, 'ether')}).then(instance => {
      payroll = instance;
      payroll.addEmployee(employee, salary, {from: owner});
    });
  });

  it("Test call getPaid() in right way", function () {
    return payroll.calculateRunway()
    .then(runwayRet => {
      if (!runwayRet.toNumber || typeof runwayRet.toNumber !== "function") {
        assert(false, "the function calculateRunway() should be defined as: `function calculateRunway() public view returns (uint)`");
      }
      assert.equal(runwayRet.toNumber(), runway, "Runway is wrong");
      return web3.currentProvider.send({jsonrpc: "2.0", method: "evm_increaseTime", params: [payDuration], id: 0});
    })
    .then(() => {
      return payroll.getPaid({from: employee})
    })
    .then(() => {
      return payroll.calculateRunway();
    })
    .then(runwayRet => {
      assert.equal(runwayRet.toNumber(), runway - 1, "The runway is not correct");
    });
  });

  it("Test call getPaid() before duration", function () {
    return payroll.calculateRunway()
    .then(runwayRet => {
      assert.equal(runwayRet.toNumber(), runway, "Runway is wrong");
      return payroll.getPaid({from: employee})
    })
    .then(assert.fail)
    .catch(error => {
      assert.include(error.toString(), "Error: VM Exception", "Should not getPaid() before a pay duration");
    });
  });


  it("Test call getPaid() by a non-employee", function () {
    return payroll.calculateRunway()
    .then(runwayRet => {
      assert.equal(runwayRet.toNumber(), runway, "Runway is wrong");
      return payroll.getPaid({from: guest})
    })
    .then(assert.fail)
    .catch(error => {
      assert.include(error.toString(), "Error: VM Exception", "Should not call getPaid() by a non-employee");
    });
  });

});
