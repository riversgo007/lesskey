// SPDX-License-Identifier: MIT
pragma solidity=0.8.0;

/**
 * Doubly ended queue
 * */
 
library LibDeque{
    
    struct Deque{
        mapping(int256 => bytes32) data;
        int256 head;
        int256 tail;
    }
    
    function getSize(Deque storage self) internal view returns(uint256){
        if(self.head == self.tail) return 0;
        return uint(self.tail - self.head - 1);
    }
    
    function isEmpty(Deque storage self) internal view returns(bool){
        return self.head == self.tail;
    }
    
    
    function offerFirst(Deque storage self, bytes32 element) internal {
        bool empty = self.tail == self.head;
        self.data[self.head] = element;
        self.head--;
        if(empty) self.tail++;
    }
    
    function offerLast(Deque storage self, bytes32 element) internal {
        bool empty = self.tail == self.head;
        self.data[self.tail] = element;
        self.tail++;
        if(empty) self.head--;
        
    }
    
    function pollFirst(Deque storage self) internal returns(bytes32 ret) {
        require(!isEmpty(self));
        ret = self.data[++self.head];
        delete self.data[self.head];
    }
    
    function pollLast(Deque storage self) internal returns(bytes32 ret) {
        require(!isEmpty(self));
        ret = self.data[--self.tail];
        delete self.data[self.tail];
    }
    
    function peekFirst(Deque storage self) internal view returns(bytes32 ret) {
        require(!isEmpty(self));
        ret = self.data[self.head + 1];
    }   
    
    function peekLast(Deque storage self) internal view returns(bytes32 ret){
        require(!isEmpty(self));
        ret = self.data[self.tail - 1];
    }
    

    
    function push(Deque storage self, bytes32 element) internal {
        offerFirst(self, element);
    }
    
    function pop(Deque storage self) internal returns(bytes32) {
        return pollFirst(self);
    }

}




















