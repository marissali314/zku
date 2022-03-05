// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;



// creates and stores int
contract StoreInt {
    // creates storedInt as a global variable in this contract
    uint storedInt; 

    // sets storedInt to an int
    function set(uint x) public {
        storedInt = x;
    }
    // gets storedInt
    function get() public view returns (uint) {
        return storedInt;
    }
    
}


// creates and stores public hello world string 
// contract HelloWorld {
//     string public myString = "hello world";
// }
