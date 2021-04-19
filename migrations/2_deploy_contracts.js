const KeySpace = artifacts.require("KeySpace");
const Verifier = artifacts.require("Verifier");
const Strings = artifacts.require("Strings");
const Save = artifacts.require("Save");
module.exports = function(deployer) {
  deployer.deploy(Verifier);
  deployer.deploy(Strings);
  deployer.link(Verifier, KeySpace);
  deployer.link(Strings, KeySpace);
  deployer.deploy(KeySpace);
  deployer.deploy(Save);
};
