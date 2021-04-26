// SPDX-License-Identifier: MIT
pragma solidity=0.8.0;

library LibMaxHeapUint256{

    struct Heap{
        uint256[] data;
    }

    function insert(Heap storage heap, uint256 value) internal{
        heap.data.push(value);
        uint256 idx = heap.data.length - 1;
        uint256 parent;

        while(idx > 0){
            parent = (idx - 1) / 2;
            if(heap.data[parent] >= value){
                break;
            }
            //do sift-up
            heap.data[idx] = heap.data[parent];
            heap.data[parent] = value;
            idx = parent;
        }
    }

    function top(Heap storage heap) internal view returns (uint256){
        require(heap.data.length > 0);
        return heap.data[0];
    }

    function extractTop(Heap storage heap) internal returns(uint256 _top){
        require(heap.data.length > 0);
        _top = heap.data[0];
        uint256 last = heap.data[heap.data.length - 1];
        heap.data.pop();
        
        heap.data[0] = last;
        uint256 index = 0;
        uint256 leftIdx;
        uint256 rightIdx;
        //Sift-down
        uint256 swapValue;
        uint256 swapIndex;
        while(index < heap.data.length){
            leftIdx = 2 * index + 1;
            rightIdx = 2 * index + 2;
            swapValue = last;
            swapIndex = index;
            if(leftIdx < heap.data.length && swapValue < heap.data[leftIdx]){
                swapValue = heap.data[leftIdx];
                swapIndex = leftIdx;
            }

            if(rightIdx < heap.data.length && swapValue < heap.data[rightIdx]){
                swapValue = heap.data[rightIdx];
                swapIndex = rightIdx;
            }

            if(swapIndex == index) break;
            heap.data[index] = swapValue;
            heap.data[swapIndex] = last;
            index = swapIndex;
        }
    }
    
    function getSize(Heap storage heap) internal view returns(uint256){
        return heap.data.length; 
    }

}
