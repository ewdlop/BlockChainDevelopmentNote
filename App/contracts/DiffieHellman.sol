// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DiffieHellman {
    // Prime number p and generator g for the key exchange
    uint256 public p = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF43;
    uint256 public g = 5;

    // Store public keys of the participants
    mapping(address => uint256) public publicKeys;
    mapping(address => uint256) private privateKeys;
    mapping(address => uint256) public sharedSecrets;

    // Event to notify when a public key is published
    event PublicKeyPublished(address indexed participant, uint256 publicKey);

    // Function to generate a private key and compute the public key
    function generateKeys() public {
        require(publicKeys[msg.sender] == 0, "Keys already generated");

        // Generate a random private key
        privateKeys[msg.sender] = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender))) % p;

        // Compute the public key
        publicKeys[msg.sender] = modExp(g, privateKeys[msg.sender], p);

        // Emit the publicKeyPublished event
        emit PublicKeyPublished(msg.sender, publicKeys[msg.sender]);
    }

    // Function to compute the shared secret using another participant's public key
    function computeSharedSecret(address otherParticipant) public {
        require(publicKeys[otherParticipant] != 0, "Other participant's public key not found");

        // Compute the shared secret
        sharedSecrets[msg.sender] = modExp(publicKeys[otherParticipant], privateKeys[msg.sender], p);
    }

    // Function to perform modular exponentiation
    // Computes (base^exp) % mod efficiently
    function modExp(uint256 base, uint256 exp, uint256 mod) internal pure returns (uint256) {
        uint256 result = 1;
        base = base % mod;
        while (exp > 0) {
            if (exp % 2 == 1) {
                result = (result * base) % mod;
            }
            exp = exp >> 1;
            base = (base * base) % mod;
        }
        return result;
    }

    // Function to retrieve the shared secret for the sender
    function getSharedSecret() public view returns (uint256) {
        return sharedSecrets[msg.sender];
    }
}
