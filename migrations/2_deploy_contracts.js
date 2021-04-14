const KeySpace = artifacts.require("KeySpace");
const Verifier = artifacts.require("Verifier");
module.exports = function(deployer) {
  deployer.deploy(Verifier);
  deployer.link(Verifier, KeySpace);
  deployer.deploy(KeySpace);
};
