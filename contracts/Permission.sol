// SPDX-License-Identifier: MIT
pragma solidity >=0.4.24 <0.7.0;

contract Permission {
    address public owner;
    bool public addable = true;
    bool public updateable = true;
    event OwnershipTransferred(address indexed _from, address indexed _to);

    modifier canAdd() {
        require(addable == true);
        _;
    }

    modifier canUpdate() {
        require(updateable == true);
        _;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function setAddable(bool _addable) onlyOwner public returns(bool){
        addable = _addable;
        return true;
    }

    function setUpdateable(bool _updateadd) onlyOwner public returns(bool){
        updateable = _updateadd;
        return true;
    }

    function transferOwnership(address _owner) onlyOwner public {
        require(_owner != address(0));
        owner = _owner;

        emit OwnershipTransferred(owner, _owner);
    }
}
