pragma solidity >=0.4.21 <0.6.0;

import "./ERC721Mintable.sol";
import "./Verifier.sol";


// TODO define another contract named SolnSquareVerifier that inherits from your ERC721Mintable class
contract SolnSquareVerifier is Realty {
    // TODO define a contract call to the zokrates generated solidity contract <Verifier> or <renamedVerifier>
    Verifier private verifier;

    // TODO define a solutions struct that can hold an index & an address
    struct Solution {
        uint256 index;
        address prover;
        bool exists;
    }

    // TODO define an array of the above struct
    Solution[] private solutionArr;

    // TODO define a mapping to store unique solutions submitted
    mapping(bytes32 => Solution) submittedSolutions;

    constructor(address verifierAddress) public {
        verifier = Verifier(verifierAddress);
    }

    // TODO Create an event to emit when a solution is added
    event SolutionAdded(uint256 index, address prover);

    // TODO Create a function to add the solutions to the array and emit the event
    function _addSolution(
        uint256 index,
        address prover,
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c,
        uint256[2] memory input
    ) internal {
        require(prover != address(0), "Invalid address");
        bytes32 hashedSolution = keccak256(abi.encodePacked(a, b, c, input));
        require(
            !submittedSolutions[hashedSolution].exists,
            "The solution exists already"
        );

        Solution memory newSolution = Solution(index, prover, true);
        solutionArr.push(newSolution);

        submittedSolutions[hashedSolution] = newSolution;

        emit SolutionAdded(index, prover);
    }

    function solutionCount() public view onlyOwner returns (uint256) {
        return solutionArr.length;
    }

    // testing purpose only
    function deleteSolutions() public onlyOwner {
        delete solutionArr;
    }

    // TODO Create a function to mint new NFT only after the solution has been verified
    //  - make sure the solution is unique (has not been used before)
    //  - make sure you handle metadata as well as tokenSupply
    function mintToken(
        address to,
        uint256 tokenId,
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c,
        uint256[2] memory input
    ) public {
        require(verifier.verifyTx(a, b, c, input), "Not verified");
        _addSolution(tokenId, to, a, b, c, input);
        super.mint(to, tokenId);
    }
}
