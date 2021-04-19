// SPDX-License-Identifier: MIT
pragma solidity=0.8.0;

import "./Permission.sol";
import "./Config.sol";
import "./lib/Strings.sol";

contract KeySpace is Permission, Config{
    struct Key{
        string value;
        uint startTime;
        uint updateTime;
        string contractVersion;
    }
    struct SpaceValue{
        uint startTime;
        uint updateTime;
        string contractVersion;
    }

    mapping(address=>Key) public keys;  //address 是keyspace和label 混合后的地址
    mapping(address=>bool) public labelExist; //address 是keyspace和label混合后的地址
    mapping(address=>string[]) public labels; //address 是keyspace地址， string是label的真实值列表

    mapping (address => SpaceValue) public keySpace;
    mapping(address=>bool) public keySpaceExist;

    event InitKeySpace(address addr, string version);

    constructor() {
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
            {startTime:block.timestamp, updateTime:block.timestamp,
            contractVersion:version}
        );
        keySpaceExist[addr] = true;
        emit InitKeySpace(addr, version);
        return keySpaceExist[addr];
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
    * @param globalHash string
    */
    function addKey(address addr, bytes32 addrHash, bytes32 r, bytes32 s, uint8 v, address label, string memory cryptoKey, string memory labelName, string memory version,bytes32 globalHash) canAdd public returns(bool){
        require(addr!=address(0), "Addr is ZERO");
        require(ecrecover(addrHash, v, r,s)==addr, "Verify signature ERROR");

        string memory rawStr = Strings.concat(Strings.concat(Strings.concat(Strings.fromAddress(label),cryptoKey), labelName),version);
        require(Strings.equals(Strings.fromBytes32(keccak256(Strings.toBytes(rawStr))), Strings.fromBytes32(globalHash)), "Verify globalHash ERROR");
        require(bytes(cryptoKey).length<=MAX_CRYPTO_KEY_LEN);
        require(labelExist[label]==false, "Label Exist");

        //labels[keyspace].push(label);
        keys[label]=Key({value:cryptoKey, startTime:block.timestamp, updateTime:block.timestamp, contractVersion:version});
        labels[addr].push(labelName);
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
    function updateKey(address addr, bytes32 addrHash, bytes32 r, bytes32 s, uint8 v, address label, string memory cryptoKey, bytes32 labelKeyHash) canUpdate public returns(bool){
        require(addr!=address(0), "Addr is ZERO");
        require(ecrecover(addrHash, v, r,s)==addr, "Verify signature ERROR");
        require(keccak256(abi.encodePacked(label, cryptoKey))==labelKeyHash, "Verify label-key ERROR");
        require(labelExist[label]==true, "Label NO Exist");
        require(bytes(cryptoKey).length<=MAX_CRYPTO_KEY_LEN);

        keys[label].value=cryptoKey;
        keys[label].updateTime = block.timestamp;
        return true;
    }
    /**
    * @dev
    * @param addr address The address which keyspace has been stored.
    */
    function allLabels(address addr) public view returns(string[] memory){
        require(addr!=address(0), "Addr is ZERO");
        return labels[addr];
    }

    /**
    * @dev add one key to a special keyspace; before save to storage, must
    *  authentication the params with its hash value；
    * @param addr address
    * @param addrHash bytes32
    * @param r bytes32
    * @param s bytes32
    * @param v uint8
    * @param label address
    * @param labelHash bytes32
    */
    function getKey(address addr, bytes32 addrHash, bytes32 r, bytes32 s, uint8 v, address label, bytes32 labelHash) public view returns(string memory){
        require(addr!=address(0), "Addr is ZERO");
        require(ecrecover(addrHash, v, r,s)==addr, "Verify signature ERROR");
        require(Strings.equals(Strings.fromBytes32(keccak256(Strings.toBytes(Strings.fromAddress(label)))), Strings.fromBytes32(labelHash)), "Verify label hash ERROR");
        //require(labelExist[label]==true, "Label NO Exist");

        return keys[label].value;
    }
}