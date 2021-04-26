// SPDX-License-Identifier: MIT
pragma solidity=0.8.0;
//todo  maybe useful 代理重加密技术可以用于密钥继承;

contract Inheritor {
    struct Asset{
        uint timeLock;
        address token;
        uint amount;
        string signText;
        address inheritFrom; //每次update的时候，owner 要对inheritFrom签名，solidity里reccover操作验签；
    }
    mapping(address=>Asset) public who; //address: address(user address + token address)

    function updateTimeLock(uint _timeLock, address addr) public returns(bool){
        who[addr].timeLock = _timeLock;
        return true;
    }

    function updateTokenAmount(uint _amount, address addr) public returns(bool){
       who[addr].amount = _amount;
        return true;
    }

    //to: address(user wallet address +token address)
    function addInheritor(uint _timeLock, address _token, uint _amount, string memory _signText, address _inheritFrom, address _to) public returns(bool){
        who[_to]=Asset({
            timeLock:_timeLock,
            token:_token,
            amount:_amount,
            signText:_signText,
            inheritFrom:_inheritFrom});
        return true;
    }

    function deleteInheritor() public pure returns(bool){
       return true;
    }
}
