//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

error DAO_error1();


interface IDAO is IERC165 {

    struct CallbackData {
        address addr;
        address admin;
        address govTokenAddr;
        string name;
    }
    
    struct FlowInfo {
        bytes32 flowID;
        // ProposalCommitteeInfo[] committees;
    }



    // function addDutyID() external;


    // function addCommitteeDutyID() external;




}
