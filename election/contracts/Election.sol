pragma solidity ^0.5.0;

contract Election{
	//Model a candidate
	struct Candidate{
		uint id;
		string name;
		uint voteCount;
	}	

	//Store a candidate
	mapping(uint => Candidate) public candidates;
	// store the candidates that have voted
	mapping(address => bool) public voters;
	//Fetch the candidate
	//Store candidate count
	uint public candidatesCount; //in solidity no way of getting candidates' mapping size
								// so as we want to keep track of the number of candidates, we need this variable
	//voted event
	event votedEvent(
		uint indexed _candidateId
		);
	//Constructor
	constructor () public {
			addCandidate("Candidate 1");
			addCandidate("Candidate 2");
	}

	function addCandidate(string memory _name) private {
	//we don't want it to be accessible to the public interface		
	// we don't want any one else to be able to add a candidate to our mapping 
		candidatesCount ++;
		candidates[candidatesCount]= Candidate(candidatesCount, _name, 0);
	}

	function vote(uint _candidateId) public {
		// require that the person has not voted before
		require(!voters[msg.sender]);
		// the voted candidate must be valid
		require(_candidateId > 0 && _candidateId <= candidatesCount);
		// record that a voter has voted
		voters[msg.sender]=true;
		// update candidate vote count
		candidates[_candidateId].voteCount++;
		//trigger voted event
		emit votedEvent(_candidateId);
	}
}
