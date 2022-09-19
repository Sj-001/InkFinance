//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../bases/BaseCommittee.sol";

contract TreasuryCommittee is BaseCommittee {
    function init(
        address dao_,
        address config_,
        bytes calldata data_
    ) external override initializer returns (bytes memory callbackEvent) {
        _init(dao_, config_, data_);
        // InitData memory initData = abi.decode(data_, (InitData));
        // makeProposalLockVotes = initData.makeProposalLockVotes;

        // _init(admin, addrRegistry, initData.baseInitData);
        // _memberSetting(admin, 1);

        return callbackEvent;
    }

    /// @inheritdoc ICommittee
    function newProposal(
        NewProposalInfo calldata,
        bool,
        bytes calldata
    ) external pure override returns (bytes32) {
        revert ThisCommitteeCannotMakeProposal();
    }

    /// @inheritdoc ICommittee
    function decideProposal(VoteIdentity calldata, bytes memory)
        external
        override
    {
        revert ThisCommitteeDoesNotSupportThisAction();
    }

    /// @inheritdoc IDeploy
    function getTypeID() external pure override returns (bytes32 typeID) {
        typeID = 0x686ecb53ebc024d158132b40f7a767a50148650820407176d3262a6c55cd458f;
    }

    /// @inheritdoc IDeploy
    function getVersion() external pure override returns (uint256 version) {
        version = 1;
    }
}
