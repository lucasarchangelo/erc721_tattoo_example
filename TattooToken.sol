// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract TattooToken is ERC721, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;
    
    struct TattooProperties {
        string name;
        string email;
        string imageURI;
    }

    mapping(uint256 => TattooProperties) public nftHolderAttributes;

    constructor() ERC721("TatooToken", "TTK") {}

    function safeMint(address to, string memory _name, string memory _imageURI) public onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);

        nftHolderAttributes[tokenId].name = _name;
        nftHolderAttributes[tokenId].imageURI = _imageURI;
    }

    function claimNFT(string memory _email, uint256 _tokenId) public {
        require(keccak256(abi.encodePacked(email)) == keccak256(abi.encodePacked("")), "This NFT was already claimed.");
        require(msg.sender == ownerOf(_tokenId), "You're not the owner");
        nftHolderAttributes[_tokenId].email = _email;
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        override
        returns (string memory)
    {
        TattooProperties memory tattooProperties = nftHolderAttributes[
            _tokenId
        ];

        string memory email = tattooProperties.email;

        if(keccak256(abi.encodePacked(email)) == keccak256(abi.encodePacked(""))) {
            email = "Not claimed yet";
        }

        string memory json = Base64.encode(
            abi.encodePacked(
                '{"name": "',
                tattooProperties.name,
                " -- NFT #: ",
                Strings.toString(_tokenId),
                '", "description": "This is an tattoo example", "image": "',
                tattooProperties.imageURI,
                '", "attributes": [ { "trait_type": "Claimable e-mail", "value": ',
                '"', email, '"',
                "}]}"
            )
        );

        string memory output = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        return output;
    }
}
