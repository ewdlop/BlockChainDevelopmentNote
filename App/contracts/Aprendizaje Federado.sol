// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FederatedLearning {
    address public owner;
    uint256 public modelVersion;
    mapping(uint256 => string) public modelHashes; // Almacena hashes de modelos por versión
    mapping(address => bool) public participants;
    
    event ModelUpdated(uint256 version, string modelHash, address updater);
    event ParticipantAdded(address participant);
    event ParticipantRemoved(address participant);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Solo el propietario puede ejecutar esta acción");
        _;
    }
    
    modifier onlyParticipant() {
        require(participants[msg.sender], "Solo los participantes pueden ejecutar esta acción");
        _;
    }
    
    constructor() {
        owner = msg.sender;
        modelVersion = 0;
    }
    
    // Añadir un nuevo participante
    function addParticipant(address _participant) external onlyOwner {
        participants[_participant] = true;
        emit ParticipantAdded(_participant);
    }
    
    // Remover un participante
    function removeParticipant(address _participant) external onlyOwner {
        participants[_participant] = false;
        emit ParticipantRemoved(_participant);
    }
    
    // Subir una actualización del modelo
    function updateModel(string calldata _modelHash) external onlyParticipant {
        modelVersion += 1;
        modelHashes[modelVersion] = _modelHash;
        emit ModelUpdated(modelVersion, _modelHash, msg.sender);
    }
    
    // Obtener el hash de un modelo específico
    function getModelHash(uint256 _version) external view returns (string memory) {
        return modelHashes[_version];
    }
}
