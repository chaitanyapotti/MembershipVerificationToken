********************************
Poll Implementation
********************************

All the polls implement an abstract contract "BasePoll.sol". It defines the structure of a poll contract.
Please observe the inheritance relationship carefully.

Members vote for a proposal amongst a list. They can also revoke a proposal.

Polls are broadly divided into two types:

:UnBound: 
    No time limit. 
    
    No Action defined at end.

    Can be deployed independently (No action contract needed to support).

    Non-Abstract implementation.

:Bound: 
    Time limited. 
    
    Actionable polls. (calls OnPollFinish() at the end of poll). :ref:`action-nomenclature`.

    Bound polls can't be deployed independently. Need action contract to manage poll.

    Abstract implementation.

UnBound Poll Base
=================

Here is a sample implementation of an unbound poll.


::

  
    pragma solidity ^0.4.24;

    import "../Protocol/IElectusProtocol.sol";


    contract BasePoll {
        struct Proposal {
            bytes32 name;
            uint256 voteCount;
        }

        struct Voter {
            bool voted;
            uint8 vote;   // index of the voted proposal
            address delegate;
            uint256 weight;
        }

        mapping(address => Voter) public voters;

        Proposal[] public proposals;
        IElectusProtocol public protocol;

        modifier isCurrentMember() {
            require(protocol.isCurrentMember(msg.sender), "Not an electus member");
            _;
        }

        constructor(address _electusProtocol, bytes32[] _proposalNames) public {
            protocol = IElectusProtocol(_electusProtocol);
            for (uint8 i = 0; i < _proposalNames.length; i++) {
                proposals.push(Proposal({name: _proposalNames[i], voteCount: 0}));
            }
        }

        function vote(uint8 proposal) public;

        function revokeVote() public;

        function onPollFinish(uint8 winningProposal_) internal;
    }


Bound Poll Base
===============
Here is a sample implementation of a bound poll.

::


    pragma solidity ^0.4.24;

    import "./BasePoll.sol";
    import "../Ownership/Authorizable.sol";

    //Need to unfreeze all accounts at the end of poll

    contract BasePollBound is BasePoll {
        
        uint public startTime;
        uint public endTime;    

        Authorizable public authorizable;

        modifier checkTime() {
            require(now >= startTime && now <= endTime);
            _;
        }

        modifier isAuthorized() {
            require(authorizable.isAuthorized(msg.sender), "Not enough access rights");
            _;
        }

        constructor(address _electusProtocol, address _authorizable, bytes32[] _proposalNames,
        uint _startTime, uint _endTime) public BasePoll(_electusProtocol, _proposalNames) {        
            authorizable = Authorizable(_authorizable);
            require(_startTime >= now && _endTime > _startTime);
            startTime = _startTime;
            endTime = _endTime;
        }
    }



As of today, 6 categories of polls exist

One person - One Vote
=====================

In this category of polls, each member of entity gets to cast a single vote whose weight is constant

UnBound Poll
----------

::


    pragma solidity ^0.4.24;

    import "./BasePoll.sol";


    //these poll contracts are independent. Hence, protocol must be passed as a ctor parameter
    contract OnePersonOneVote is BasePoll {

        constructor(address _electusProtocol, bytes32[] _proposalNames) public BasePoll(_electusProtocol, _proposalNames) {
            
        }

        function vote(uint8 proposal) public isCurrentMember {
            Voter storage sender = voters[msg.sender];
            require(!sender.voted, "Already voted.");
            sender.voted = true;
            sender.vote = proposal;
            sender.weight = 1;

            proposals[proposal].voteCount += sender.weight;
        }

        function revokeVote() public isCurrentMember {
            Voter storage sender = voters[msg.sender];
            require(sender.voted, "Hasn't yet voted.");
            sender.voted = false;
            proposals[sender.vote].voteCount -= sender.weight;
            sender.vote = 0;
            sender.weight = 0;
        }

        function countVotes() public view returns (uint8 winningProposal_) {
            uint winningVoteCount = 0;
            for (uint8 p = 0; p < proposals.length; p++) {
                if (proposals[p].voteCount > winningVoteCount) {
                    winningVoteCount = proposals[p].voteCount;
                    winningProposal_ = p;
                }
            }
        }
    }


Bound Poll
----------

::


    pragma solidity ^0.4.24;

    import "./BasePollBound.sol";


    //All time bound contracts are abstract in nature. They need to be used within action contracts to 
    //fulfill OnPollFinish() implementation.
    //these poll contracts are independent. Hence, protocol must be passed as a ctor parameter. 
    //These contracts will usually be deployed by Action contracts. Hence, these must refer Authorizable
    contract OnePersonOneVoteBound is BasePollBound {

        constructor(address _electusProtocol, address _authorizable, bytes32[] _proposalNames, 
        uint _startTime, uint _endTime) public BasePollBound(_electusProtocol, _authorizable, _proposalNames,
        _startTime, _endTime) {
        }

        function vote(uint8 proposal) public isCurrentMember checkTime {
            Voter storage sender = voters[msg.sender];
            require(!sender.voted, "Already voted.");
            sender.voted = true;
            sender.vote = proposal;
            sender.weight = 1;

            proposals[proposal].voteCount += sender.weight;
        }

        function revokeVote() public isCurrentMember checkTime {
            Voter storage sender = voters[msg.sender];
            require(sender.voted, "Hasn't yet voted.");
            sender.voted = false;
            proposals[sender.vote].voteCount -= sender.weight;
            sender.vote = 0;
            sender.weight = 0;
        }

        function finalizePoll() public isAuthorized {
            require(now > endTime, "Poll has not ended");
            uint winningVoteCount = 0;
            uint8 winningProposal_ = 0;
            for (uint8 p = 0; p < proposals.length; p++) {
                if (proposals[p].voteCount > winningVoteCount) {
                    winningVoteCount = proposals[p].voteCount;
                    winningProposal_ = p;
                }
            }
            onPollFinish(winningProposal_);
        }
    }



Token weight Uncapped with freeze
=================================

In this category of polls, each member of entity gets to cast a single vote whose weight is proportional to 
the token balance they hold with no cap. When a user casts a vote, his token balance is frozen.


He/she would need to unvote to be able to transfer the tokens


UnBound Poll
----------

::


    pragma solidity ^0.4.24;

    import "./BasePoll.sol";
    import "../Token/IFreezableToken.sol";


    //these poll contracts are independent. Hence, protocol must be passed as a ctor parameter. 
    //These contracts will usually be deployed by Action contracts. Hence, these must refer Authorizable
    contract TokenProportionalUncapped is BasePoll {

        IFreezableToken public token;

        constructor(address _electusProtocol, bytes32[] _proposalNames, address _tokenAddress) 
        public BasePoll(_electusProtocol, _proposalNames) {
            token = IFreezableToken(_tokenAddress);
        }

        function vote(uint proposal) public isCurrentMember {
            Voter storage sender = voters[msg.sender];
            require(!sender.voted, "Already voted.");
            sender.voted = true;
            sender.vote = proposal;
            sender.weight = token.balanceOf(msg.sender);
            proposals[proposal].voteCount += sender.weight;
            //Need to check whether we can freeze or not.!
            token.freezeAccount(msg.sender);
        }

        function revokeVote() public isCurrentMember {
            Voter storage sender = voters[msg.sender];
            require(sender.voted, "Hasn't yet voted.");
            sender.voted = false;
            proposals[sender.vote].voteCount -= sender.weight;
            sender.vote = 0;
            sender.weight = 0;
            token.unFreezeAccount(msg.sender);
        }

        function countVotes() public view returns (uint8 winningProposal_) {
            uint winningVoteCount = 0;
            for (uint8 p = 0; p < proposals.length; p++) {
                if (proposals[p].voteCount > winningVoteCount) {
                    winningVoteCount = proposals[p].voteCount;
                    winningProposal_ = p;
                }
            }        
        }
    }


Bound Poll
----------

::


    pragma solidity ^0.4.24;

    import "./BasePollBound.sol";
    import "../Token/IFreezableToken.sol";


    contract TokenProportionalUncappedBound is BasePollBound {

        IFreezableToken public token;

        constructor(address _electusProtocol, address _authorizable, address _tokenAddress, bytes32[] _proposalNames,
        uint _startTime, uint _endTime) public BasePollBound(_electusProtocol, _authorizable, _proposalNames,
        _startTime, _endTime) {
            token = IFreezableToken(_tokenAddress);
        }

        function vote(uint proposal) public isCurrentMember checkTime {
            Voter storage sender = voters[msg.sender];
            require(!sender.voted, "Already voted.");
            sender.voted = true;
            sender.vote = proposal;
            sender.weight = token.balanceOf(msg.sender);
            proposals[proposal].voteCount += sender.weight;
            //Need to check whether we can freeze or not.!
            token.freezeAccount(msg.sender);
        }

        function revokeVote() public isCurrentMember checkTime {
            Voter storage sender = voters[msg.sender];
            require(sender.voted, "Hasn't yet voted.");
            if (now <= endTime && now >= startTime) {
                sender.voted = false;
                proposals[sender.vote].voteCount -= sender.weight;
                sender.vote = 0;
                sender.weight = 0;
            }
            token.unFreezeAccount(msg.sender);
        }

        function finalizePoll() public isAuthorized {
            require(now > endTime, "Poll has not ended");
            uint winningVoteCount = 0;
            uint8 winningProposal_ = 0;
            for (uint8 p = 0; p < proposals.length; p++) {
                if (proposals[p].voteCount > winningVoteCount) {
                    winningVoteCount = proposals[p].voteCount;
                    winningProposal_ = p;
                }
            }
            onPollFinish(winningProposal_);
        }
    }



Token Weight Capped with Freeze
===============================

In this category of polls, each member of entity gets to cast a single vote whose weight is proportional to 
the token balance they hold with a specified cap. When a user casts a vote, his token balance is frozen.


He/she would need to unvote to be able to transfer the tokens


UnBound Poll
----------

::


    pragma solidity ^0.4.24;

    import "./BasePoll.sol";
    import "../math/SafeMath.sol";
    import "../Token/IFreezableToken.sol";


    //these poll contracts are independent. Hence, protocol must be passed as a ctor parameter. 
    //These contracts will usually be deployed by Action contracts. Hence, these must refer Authorizable
    contract TokenProportionalCapped is BasePoll {

        IFreezableToken public token;
        uint8 public capPercent;

        constructor(address _electusProtocol, bytes32[] _proposalNames, address _tokenAddress, uint8 _capPercent) 
        public BasePoll(_electusProtocol, _proposalNames) {
            token = IFreezableToken(_tokenAddress);
            capPercent = _capPercent;
        }

        function vote(uint proposal) public isCurrentMember {
            Voter storage sender = voters[msg.sender];
            require(!sender.voted, "Already voted.");
            sender.voted = true;
            sender.vote = proposal;
            //Reduce gas consumption here
            sender.weight = SafeMath.safeMul(SafeMath.safeDiv(token.balanceOf(msg.sender), 
            token.totalSupply()), 100) > capPercent ? capPercent : SafeMath.safeDiv(token.balanceOf(msg.sender), 
            token.totalSupply());
            proposals[proposal].voteCount += sender.weight;
            token.freezeAccount(msg.sender);
        }

        function revokeVote() public isCurrentMember {
            Voter storage sender = voters[msg.sender];
            require(sender.voted, "Hasn't yet voted.");
            sender.voted = false;
            proposals[sender.vote].voteCount -= sender.weight;
            sender.vote = 0;
            sender.weight = 0;
            token.unFreezeAccount(msg.sender);
        }

        function countVotes() public view returns (uint8 winningProposal_) {
            uint winningVoteCount = 0;
            for (uint8 p = 0; p < proposals.length; p++) {
                if (proposals[p].voteCount > winningVoteCount) {
                    winningVoteCount = proposals[p].voteCount;
                    winningProposal_ = p;
                }
            }        
        }
    }


Bound Poll
----------

::


    pragma solidity ^0.4.24;

    import "./BasePollBound.sol";
    import "../math/SafeMath.sol";
    import "../Token/IFreezableToken.sol";


    contract TokenProportionalCappedBound is BasePollBound {

        IFreezableToken public token;    
        uint8 public capPercent;

        constructor(address _electusProtocol, address _authorizable, address _tokenAddress, bytes32[] _proposalNames, 
        uint8 _capPercent, uint _startTime, uint _endTime) public BasePollBound(_electusProtocol, _authorizable,
        _proposalNames, _startTime, _endTime) {
            token = IFreezableToken(_tokenAddress);
            capPercent = _capPercent;
        }

        function vote(uint8 proposal) public isCurrentMember checkTime {
            Voter storage sender = voters[msg.sender];
            require(!sender.voted, "Already voted.");
            sender.voted = true;
            sender.vote = proposal;
            sender.weight = SafeMath.safeMul(SafeMath.safeDiv(token.balanceOf(msg.sender), 
            token.totalSupply()), 100) > capPercent ? capPercent : SafeMath.safeDiv(token.balanceOf(msg.sender), 
            token.totalSupply());
            proposals[proposal].voteCount += sender.weight;
            //Need to check whether we can freeze or not.!
            token.freezeAccount(msg.sender);
        }

        function revokeVote() public isCurrentMember {
            Voter storage sender = voters[msg.sender];
            require(sender.voted, "Hasn't yet voted.");
            if (now <= endTime && now >= startTime) {
                sender.voted = false;
                proposals[sender.vote].voteCount -= sender.weight;
                sender.vote = 0;
                sender.weight = 0;
            }
            token.unFreezeAccount(msg.sender);
        }

        function finalizePoll() public isAuthorized {
            require(now > endTime, "Poll has not ended");
            uint winningVoteCount = 0;
            uint8 winningProposal_ = 0;
            for (uint8 p = 0; p < proposals.length; p++) {
                if (proposals[p].voteCount > winningVoteCount) {
                    winningVoteCount = proposals[p].voteCount;
                    winningProposal_ = p;
                }
            }
            onPollFinish(winningProposal_);
        }
    }



Delegated voting
================

In this category of polls, each member of entity gets to cast a single vote whose weight is constant but
the member can delegate his vote to another person who he believes is a better judge at the topic.
The member can not cast his vote once he delegates it to another.



UnBound Poll
----------

::


    pragma solidity ^0.4.24;

    import "./BasePoll.sol";


    //these poll contracts are independent. Hence, protocol must be passed as a ctor parameter
    contract DelegatedVote is BasePoll {

        constructor(address _electusProtocol, bytes32[] _proposalNames) public BasePoll(_electusProtocol, _proposalNames) {
            
        }

        function vote(uint8 proposal) public isCurrentMember {
            Voter storage sender = voters[msg.sender];
            require(!sender.voted, "Already voted.");
            sender.voted = true;
            sender.vote = proposal;
            if (sender.weight == 0) {
                sender.weight = 1;
            }

            proposals[proposal].voteCount += sender.weight;
        }

        function revokeVote() public isCurrentMember {
            Voter storage sender = voters[msg.sender];
            require(sender.voted, "Hasn't yet voted.");
            sender.voted = false;
            proposals[sender.vote].voteCount -= sender.weight;
            sender.vote = 0;
        }

        function countVotes() public view returns (uint8 winningProposal_) {
            uint winningVoteCount = 0;
            for (uint8 p = 0; p < proposals.length; p++) {
                if (proposals[p].voteCount > winningVoteCount) {
                    winningVoteCount = proposals[p].voteCount;
                    winningProposal_ = p;
                }
            }
        }

        function delegate(address to) public isCurrentMember {
            Voter storage sender = voters[msg.sender];
            require(!sender.voted, "You already voted.");
            require(to != msg.sender, "Self-delegation is disallowed.");
            require(protocol.isCurrentMember(to), "Not an electus member");
            if (sender.weight == 0) {
                sender.weight = 1;
            }
            // Forward the delegation as long as
            // `to` also delegated.
            // In general, such loops are very dangerous,
            // because if they run too long, they might
            // need more gas than is available in a block.
            // In this case, the delegation will not be executed,
            // but in other situations, such loops might
            // cause a contract to get "stuck" completely.
            while (voters[to].delegate != address(0)) {
                to = voters[to].delegate;

                // We found a loop in the delegation, not allowed.
                require(to != msg.sender, "Found loop in delegation.");
            }

            sender.voted = true;
            sender.delegate = to;
            Voter storage delegate_ = voters[to];
            if (delegate_.voted) {
                // If the delegate already voted,
                // directly add to the number of votes
                proposals[delegate_.vote].voteCount += sender.weight;
            } else {
                // If the delegate did not vote yet,
                // add to her weight.
                delegate_.weight += sender.weight;
            }
        }
    }


Bound Poll
----------

::


    pragma solidity ^0.4.24;

    import "./BasePollBound.sol";


    //All time bound contracts are abstract in nature. They need to be used within action contracts to 
    //fulfill OnPollFinish() implementation.
    //these poll contracts are independent. Hence, protocol must be passed as a ctor parameter. 
    //These contracts will usually be deployed by Action contracts. Hence, these must refer Authorizable
    contract DelegatedVoteBound is BasePollBound {

        constructor(address _electusProtocol, address _authorizable, bytes32[] _proposalNames, 
        uint _startTime, uint _endTime) public BasePollBound(_electusProtocol, _authorizable, _proposalNames,
        _startTime, _endTime) {
        }

        function vote(uint8 proposal) public isCurrentMember checkTime {
            Voter storage sender = voters[msg.sender];
            require(!sender.voted, "Already voted.");
            sender.voted = true;
            sender.vote = proposal;
            if (sender.weight == 0) {
                sender.weight = 1;
            }

            proposals[proposal].voteCount += sender.weight;
        }

        function revokeVote() public isCurrentMember checkTime {
            Voter storage sender = voters[msg.sender];
            require(sender.voted, "Hasn't yet voted.");
            sender.voted = false;
            proposals[sender.vote].voteCount -= sender.weight;
            sender.vote = 0;
        }

        function finalizePoll() public isAuthorized {
            require(now > endTime, "Poll has not ended");
            uint winningVoteCount = 0;
            uint8 winningProposal_ = 0;
            for (uint8 p = 0; p < proposals.length; p++) {
                if (proposals[p].voteCount > winningVoteCount) {
                    winningVoteCount = proposals[p].voteCount;
                    winningProposal_ = p;
                }
            }
            onPollFinish(winningProposal_);
        }

        function delegate(address to) public isCurrentMember {
            Voter storage sender = voters[msg.sender];
            require(!sender.voted, "You already voted.");
            require(to != msg.sender, "Self-delegation is disallowed.");
            require(protocol.isCurrentMember(to), "Not an electus member");
            if (sender.weight == 0) {
                sender.weight = 1;
            }
            // Forward the delegation as long as
            // `to` also delegated.
            // In general, such loops are very dangerous,
            // because if they run too long, they might
            // need more gas than is available in a block.
            // In this case, the delegation will not be executed,
            // but in other situations, such loops might
            // cause a contract to get "stuck" completely.
            while (voters[to].delegate != address(0)) {
                to = voters[to].delegate;

                // We found a loop in the delegation, not allowed.
                require(to != msg.sender, "Found loop in delegation.");
            }

            sender.voted = true;
            sender.delegate = to;
            Voter storage delegate_ = voters[to];
            if (delegate_.voted) {
                // If the delegate already voted,
                // directly add to the number of votes
                proposals[delegate_.vote].voteCount += sender.weight;
            } else {
                // If the delegate did not vote yet,
                // add to her weight.
                delegate_.weight += sender.weight;
            }
        }
    }


Karma voting
================

In this category of polls, each member of entity gets to cast a single vote whose weight is constant but
the member can delegate his vote to another person who he believes is a better judge at the topic.
The member can cast his vote even after he delegates it to another. The person to who the vote is delegated to gets his weight increased.



UnBound Poll
----------

::


    pragma solidity ^0.4.24;

    import "./BasePoll.sol";


    //these poll contracts are independent. Hence, protocol must be passed as a ctor parameter
    contract KarmaVote is BasePoll {

        constructor(address _electusProtocol, bytes32[] _proposalNames) public BasePoll(_electusProtocol, _proposalNames) {
            
        }

        function vote(uint8 proposal) public isCurrentMember {
            Voter storage sender = voters[msg.sender];
            require(!sender.voted, "Already voted.");
            sender.voted = true;
            sender.vote = proposal;
            if (sender.weight == 0) {
                sender.weight = 1;
            }

            proposals[proposal].voteCount += sender.weight;
        }

        function revokeVote() public isCurrentMember {
            Voter storage sender = voters[msg.sender];
            require(sender.voted, "Hasn't yet voted.");
            sender.voted = false;
            proposals[sender.vote].voteCount -= sender.weight;
            sender.vote = 0;
        }

        function countVotes() public view returns (uint8 winningProposal_) {
            uint winningVoteCount = 0;
            for (uint8 p = 0; p < proposals.length; p++) {
                if (proposals[p].voteCount > winningVoteCount) {
                    winningVoteCount = proposals[p].voteCount;
                    winningProposal_ = p;
                }
            }
        }

        function delegate(address to) public isCurrentMember {
            Voter storage sender = voters[msg.sender];
            require(!sender.voted, "You already voted.");
            require(to != msg.sender, "Self-delegation is disallowed.");
            require(protocol.isCurrentMember(to), "Not an electus member");
            if (sender.weight == 0) {
                sender.weight = 1;
            }
            // Forward the delegation as long as
            // `to` also delegated.
            // In general, such loops are very dangerous,
            // because if they run too long, they might
            // need more gas than is available in a block.
            // In this case, the delegation will not be executed,
            // but in other situations, such loops might
            // cause a contract to get "stuck" completely.
            while (voters[to].delegate != address(0)) {
                to = voters[to].delegate;

                // We found a loop in the delegation, not allowed.
                require(to != msg.sender, "Found loop in delegation.");
            }

            // sender.voted = true;
            sender.delegate = to;
            Voter storage delegate_ = voters[to];
            if (delegate_.voted) {
                // If the delegate already voted,
                // directly add to the number of votes
                proposals[delegate_.vote].voteCount += sender.weight;
            } else {
                // If the delegate did not vote yet,
                // add to her weight.
                delegate_.weight += sender.weight;
            }
        }
    }


Bound Poll
----------

::


    pragma solidity ^0.4.24;

    import "./BasePollBound.sol";


    //All time bound contracts are abstract in nature. They need to be used within action contracts to 
    //fulfill OnPollFinish() implementation.
    //these poll contracts are independent. Hence, protocol must be passed as a ctor parameter. 
    //These contracts will usually be deployed by Action contracts. Hence, these must refer Authorizable
    contract KarmaVoteBound is BasePollBound {

        constructor(address _electusProtocol, address _authorizable, bytes32[] _proposalNames, 
        uint _startTime, uint _endTime) public BasePollBound(_electusProtocol, _authorizable, _proposalNames,
        _startTime, _endTime) {
        }

        function vote(uint8 proposal) public isCurrentMember checkTime {
            Voter storage sender = voters[msg.sender];
            require(!sender.voted, "Already voted.");
            sender.voted = true;
            sender.vote = proposal;
            if (sender.weight == 0) {
                sender.weight = 1;
            }

            proposals[proposal].voteCount += sender.weight;
        }

        function revokeVote() public isCurrentMember checkTime {
            Voter storage sender = voters[msg.sender];
            require(sender.voted, "Hasn't yet voted.");
            sender.voted = false;
            proposals[sender.vote].voteCount -= sender.weight;
            sender.vote = 0;
        }

        function finalizePoll() public isAuthorized {
            require(now > endTime, "Poll has not ended");
            uint winningVoteCount = 0;
            uint8 winningProposal_ = 0;
            for (uint8 p = 0; p < proposals.length; p++) {
                if (proposals[p].voteCount > winningVoteCount) {
                    winningVoteCount = proposals[p].voteCount;
                    winningProposal_ = p;
                }
            }
            onPollFinish(winningProposal_);
        }

        function delegate(address to) public isCurrentMember {
            Voter storage sender = voters[msg.sender];
            require(!sender.voted, "You already voted.");
            require(to != msg.sender, "Self-delegation is disallowed.");
            require(protocol.isCurrentMember(to), "Not an electus member");
            if (sender.weight == 0) {
                sender.weight = 1;
            }
            // Forward the delegation as long as
            // `to` also delegated.
            // In general, such loops are very dangerous,
            // because if they run too long, they might
            // need more gas than is available in a block.
            // In this case, the delegation will not be executed,
            // but in other situations, such loops might
            // cause a contract to get "stuck" completely.
            while (voters[to].delegate != address(0)) {
                to = voters[to].delegate;

                // We found a loop in the delegation, not allowed.
                require(to != msg.sender, "Found loop in delegation.");
            }

            // sender.voted = true;
            sender.delegate = to;
            Voter storage delegate_ = voters[to];
            if (delegate_.voted) {
                // If the delegate already voted,
                // directly add to the number of votes
                proposals[delegate_.vote].voteCount += sender.weight;
            } else {
                // If the delegate did not vote yet,
                // add to her weight.
                delegate_.weight += sender.weight;
            }
        }
    }



Token weight times Stake Duration
=================================

TODO: