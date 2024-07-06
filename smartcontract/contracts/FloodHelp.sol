// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

struct Request {
    uint id;
    address author;
    string title;
    string descr;
    string contact;
    uint timestamp;
    uint goal; // wei = smallest fraction of coin etherium
    uint balance;
    bool open;
}

contract FloodHelp{
    uint lastId = 0;
    mapping(uint => Request) public requests;
    // for non-native types like "string" you must pass where they were in memory if it is memory or calldata
    function openRequest(
        string memory title, 
        string memory descr,
        string memory contact,
        uint goal
    ) public {
        lastId++;
        requests[lastId] = Request({
            id:lastId,
            title:title,
            descr:descr,
            author:msg.sender,
            contact:contact,
            balance:0,
            goal:goal,
            open:true,
            timestamp: block.timestamp
        });
    }

    function closeRequest( uint id ) public  {
        address author = requests[id].author;
        uint balance = requests[id].balance;
        uint goal = requests[id].goal;
        require(
            requests[id].open
            && (msg.sender == author || balance >= goal),
            unicode"You cannot close this order"
        );

        requests[id].open = false;

        if(balance>0){
            requests[id].balance = 0;
            payable(author).transfer(balance);
        }
    }

    function getOpenRequests(
        uint startId,
        uint qnt
    ) public view returns(Request[] memory){
        Request[] memory result = new Request[](qnt);
        uint id = startId;
        uint count = 0;

        do{
            if(requests[id].open){
                result[count] = requests[id];
                count++;
            }
            id++;
        }while(count < qnt && id <= lastId);

        return result;
    }

    function donate(
        uint id
    )public payable {
        requests[id].balance += msg.value;
        if(requests[id].balance>=requests[id].goal)
            closeRequest(id);
    }
}