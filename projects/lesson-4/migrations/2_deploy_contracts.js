var payroll = artifacts.require("./Payroll.sol");
var safemath = artifacts.require("./SafeMath.sol");

module.exports = function (deployer) {
    deployer.deploy(safemath);
    deployer.link(safemath, payroll);
    deployer.deploy(payroll);
};
