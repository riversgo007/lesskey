// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import "./Permission.sol";
contract VersionRouter is Permission{
    string public context;
    uint public startTime;
    uint public startBlock;
    string public chainName;

    address public workingVersion; //当前正在使用的版本合约地址
    mapping(string=>address) public versionStack; //只要使用过的合约版本，全部入栈，允许回退； string: v + versionListLength; as for: v1 v2 v3...
    uint public versionListLength;
    mapping(address=>uint) public versionListWithTimeArrow;
    mapping(address=>string)  keyStorageWithContractVersion; //address: address(keyspace+password+label)
    constructor(string memory _context, string memory _chainName, string memory versionName, address _workingVersion){
        require(bytes(_context).length>0, "gensis context is NULL");
        require(bytes(_chainName).length>0, "chain name is NULL");
        startTime = block.timestamp;
        startBlock = block.number;
        context = _context;
        chainName = _chainName;

        if(false == _enableWorkingVersion(_workingVersion, versionName)){
           revert();
        }
    }
    function _enableWorkingVersion(address _workingVersion, string memory versionName) internal returns(bool){
        require(_workingVersion!=address(0), "working version is ZERO");

        workingVersion = _workingVersion;
        versionListLength = versionListLength+1;
        versionListWithTimeArrow[_workingVersion] = block.number;
        versionStack[versionName] = _workingVersion;

        return true;
    }

    function enableWorkingVersion(address _workingVersion, string memory versionName) onlyOwner public returns(bool){
        return _enableWorkingVersion(_workingVersion, versionName);
    }

    function dispatch() public pure returns(bool){
        return true;
    }
}
