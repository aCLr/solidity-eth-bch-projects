// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract PollingSystem {
  struct Vote {
    bool isValid;
    uint votes;
  }

  mapping(string => Vote) votes;
  string[] choices;
  mapping(address => bool) voters;

  uint finishTime;

  event VotingFinished(string[] winners);
  string[] public winners;

  constructor(string[] memory _choices, uint _votingPeriodSeconds) {
    require(_choices.length >= 2, "need at least 2 options");
    // currently each block generates every 12-14 seconds
    require(_votingPeriodSeconds > 60, "60 seconds for voting is minimum");

    finishTime = block.timestamp + _votingPeriodSeconds;
    choices = _choices;
    for (uint i = 0; i < _choices.length; i++) {
      votes[_choices[i]] = Vote(true, 0);
    }
  }

  modifier winnersNotDefined() {
    require(
      !winnersDefined(),
      "winners defined"
    );
    _;
  }

  function winnersDefined() internal view returns(bool) {
    return winners.length > 0;
  }

  function votingFinished() public view returns(bool) {
    return block.timestamp >= finishTime;
  }

  function vote(string memory _choice) public winnersNotDefined {
    require(!voters[msg.sender], "already voted");
    Vote storage v = votes[_choice];
    require(v.isValid, "not allowed choice");

    voters[msg.sender] = true;
    v.votes ++;

    if (votingFinished()) {
      finishVoting();
    }
  }

  function getVotes(string memory _choice) public view returns(uint) {
    Vote memory v = votes[_choice];
    require(v.isValid, "not allowed choice");
    return v.votes;
  }

  function getWinnersAmount() public view returns (uint) {
    require(
      winnersDefined(),
      "winners not defined"
      );
    return winners.length;
  }

  function getOneOfWinners(uint i) public view returns (string memory) {
    require(
      winnersDefined(),
      "winners not defined"
    );
    require(
      winners.length >= i + 1,
      "invalid winner index"
    );
    return winners[i];
  }

  function finishVoting() public winnersNotDefined {
    require(votingFinished(), "voting not finished");
    uint max = 0;
    for (uint i = 0; i < choices.length; i++) {
      Vote memory vv = votes[choices[i]];
      require(vv.isValid, "internal error: vote is not valid");
      if (vv.votes > max) {
        max = vv.votes;
      }
    }

    for (uint i = 0; i < choices.length; i++) {
      Vote memory vv = votes[choices[i]];
      if (vv.votes == max) {
        winners.push(choices[i]);
      }
    }

    emit VotingFinished(winners);
  }

}
