// SPDX-License-Identifier: MIT
pragma solidity >=0.4.24 <0.7.0;
pragma experimental ABIEncoderV2;

import "./Permission.sol";

contract KeySpace is Permission{
    struct Key{
        string value;
        uint startTime;
        uint updateTime;
        string contractVersion;
    }
    struct SpaceValue{
        string[] labels;
        uint startTime;
        uint updateTime;
        string contractVersion;
        mapping(string=>Key) keys;
        mapping(string=>bool)labelExist;
    }

    mapping (address => SpaceValue) keySpace;
    mapping(address=>bool) keySpaceExist;
    uint8 constant DefaultLabelsCapacity = 8;

    event InitKeySpace(address addr, string version);

    constructor() public{
        owner = msg.sender;
    }

    /**
    * @dev init keyspace for new user.
    * @param addr address The address is the keyspace value expressed by address type.
    * @param addrHash bytes32
    * @param r bytes32
    * @param s bytes32
    * @param v uint8
    */
    function initKeySpace(address addr, bytes32 addrHash, bytes32 r, bytes32 s,uint8 v, string memory version) canAdd public returns(bool){
        require(ecrecover(addrHash, v, r, s) == addr,"Verify signature ERROR");
        require(addr != address(0),"Addr is ZERO");
        require(keySpaceExist[addr]==false,"Keyspace has Exist");

        keySpace[addr] = SpaceValue(
            {startTime:now, updateTime:now,
            labels:new string[](DefaultLabelsCapacity),
            contractVersion:version}
        );
        keySpaceExist[addr] = true;
        emit InitKeySpace(addr, version);
        return true;
    }

    /**
    * @dev
    * @param addr address The address which you want to know has been stored in contract.
    */
    function spaceExist(address addr) public view returns(bool){
        require(addr != address(0), "Addr is ZERO");
        return keySpaceExist[addr];
    }

    /**
    * @dev add one key to a special keyspace; before save to storage, must
    *  authentication the params with its hash value；
    * @param addr address
    * @param addrHash bytes32
    * @param r bytes32
    * @param s bytes32
    * @param v uint8
    * @param label string
    * @param cryptoKey string
    * @param labelKeyHash string
    */
    function addKey(address addr, bytes32 addrHash, bytes32 r, bytes32 s, uint8 v, string memory label, string memory cryptoKey, bytes32 labelKeyHash, string memory version) canAdd public returns(bool){
        require(addr!=address(0), "Addr is ZERO");
        require(ecrecover(addrHash, v, r,s)==addr, "Verify signature ERROR");
        require(keccak256(abi.encodePacked(label, cryptoKey))==labelKeyHash, "Verify label-key ERROR");

        require(keySpace[addr].labelExist[label]==false, "Label Exist");
        keySpace[addr].labels.push(label);
        keySpace[addr].keys[label]=Key({value:cryptoKey, startTime:now, updateTime:now, contractVersion:version});

        return true;
    }

    /**
    * @dev add one key to a special keyspace; before save to storage, must
    *  authentication the params with its hash value；
    * @param addr address
    * @param addrHash bytes32
    * @param r bytes32
    * @param s bytes32
    * @param v uint8
    * @param label string
    * @param cryptoKey string
    * @param labelKeyHash string
    */
    function updateKey(address addr, bytes32 addrHash, bytes32 r, bytes32 s, uint8 v, string memory label, string memory cryptoKey, bytes32 labelKeyHash) canUpdate public returns(bool){
        require(addr!=address(0), "Addr is ZERO");
        require(ecrecover(addrHash, v, r,s)==addr, "Verify signature ERROR");
        require(keccak256(abi.encodePacked(label, cryptoKey))==labelKeyHash, "Verify label-key ERROR");
        require(keySpace[addr].labelExist[label]==true, "Label NO Exist");

        keySpace[addr].keys[label].value=cryptoKey;
        keySpace[addr].keys[label].updateTime = now;
        return true;
    }
    /**
    * @dev
    * @param addr address The address which keyspace has been stored.
    */
    function allLabels(address addr) public view returns(string[] memory){
        require(addr!=address(0), "Addr is ZERO");
        return keySpace[addr].labels;
    }
}