// SPDX-License-Identifier: MIT
pragma solidity=0.8.0;

library LibQueue{
    

    struct Queue{
        uint256 first;
        uint256 next;
        mapping(uint => bytes32) queue;

    }

    function enqueue(Queue storage queue, bytes32 data) internal {
        queue.queue[queue.next++] = data;
    }

    function dequeue(Queue storage queue) internal returns (bytes32) {
        uint256 first = queue.first;
        require(queue.next > first);  // non-empty queue

        bytes32 data = queue.queue[first];
        delete queue.queue[first];
        queue.first += 1;
        return data;
    }

    function element(Queue storage queue) internal view returns (bytes32) {
        uint256 first = queue.first;
        require(queue.next > first);  // non-empty queue
        bytes32 data = queue.queue[first];
        return data;
    }


    function getSize(Queue storage self) internal view returns(uint256){
        return self.next - self.first;
    }
}