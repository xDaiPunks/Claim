// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract ClaimContract is Ownable {
    IERC721 public token;
    IERC20 public punkToken;

    mapping(address => uint256) public claims;
    uint256 public totalClaims;
    uint256[] public tokens;

    uint256 public punkPerMint = 500 ether;
    uint256 public constant maxClaimPerTransaction = 20;

    constructor(IERC721 _token, IERC20 _punkToken) {
        token = _token;
        punkToken = _punkToken;
    }

    function setClaimersAndClaims(
        address[] memory _claimers,
        uint256[] memory _claims
    ) public onlyOwner {
        require(
            _claimers.length == _claims.length,
            "Arrays must be of equal length"
        );

        totalClaims = 0;

        for (uint256 i = 0; i < _claimers.length; i++) {
            claims[_claimers[i]] = _claims[i];
            totalClaims += _claims[i];
        }
    }

    function claim() public {
        _claimFor(msg.sender);
    }

    function claimFor(address _claimer) public onlyOwner {
        _claimFor(_claimer);
    }

    function depositTokens(uint256[] memory _tokens) public onlyOwner {
        for (uint256 i = 0; i < _tokens.length; i++) {
            token.transferFrom(msg.sender, address(this), _tokens[i]);
            tokens.push(_tokens[i]);
        }
    }

    function withdrawTokens(uint256[] memory _tokens) public onlyOwner {
        for (uint256 i = 0; i < _tokens.length; i++) {
            require(
                token.ownerOf(_tokens[i]) == address(this),
                "Contract doesn't own this token"
            );
            token.transferFrom(address(this), msg.sender, _tokens[i]);

            for (uint256 j = 0; j < tokens.length; j++) {
                if (tokens[j] == _tokens[i]) {
                    tokens[j] = tokens[tokens.length - 1];
                    tokens.pop();
                    break;
                }
            }
        }
    }

    function withdrawERC20Tokens(
        address _tokenAddress,
        uint256 _amount
    ) public onlyOwner {
        IERC20 erc20token = IERC20(_tokenAddress);
        require(
            erc20token.balanceOf(address(this)) >= _amount,
            "Not enough tokens in the contract"
        );
        erc20token.transfer(msg.sender, _amount);
    }

    function _claimFor(address _claimer) private {
        require(claims[_claimer] > 0, "No claims left for this address");
        require(tokens.length > 0, "No tokens left to claim");

        for (
            uint256 i = 0;
            i < maxClaimPerTransaction &&
                claims[_claimer] > 0 &&
                tokens.length > 0;
            i++
        ) {
            uint256 randomIndex = uint256(
                keccak256(
                    abi.encodePacked(
                        block.timestamp,
                        block.difficulty,
                        _claimer
                    )
                )
            ) % tokens.length;
            uint256 tokenToTransfer = tokens[randomIndex];

            punkToken.transfer(_claimer, punkPerMint);
            token.transferFrom(address(this), _claimer, tokenToTransfer);

            tokens[randomIndex] = tokens[tokens.length - 1];
            tokens.pop();

            claims[_claimer]--;
            totalClaims--;
        }
    }
}
