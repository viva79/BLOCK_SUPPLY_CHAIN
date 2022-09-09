pragma solidity >=0.7.0 <0.9.0;

library CryptoSuite {
    function splitSignature(bytes memory sig) internal pure returns (uint8 v, bytes32 r, bytes32 s) {
    require(sig.length == 65);

    assembly {
        // first 32bytes
        r := mload(add(sig, 32))
        // next 32bytes
        s := mload(add(sig, 64))
        // last 32bytes
        v := byte(0, mload(add(sig, 96)))

    }

    return (v, r, s);
    
  }

    function recoverSigner(bytes32 message, bytes memory signature) internal pure returns (address) {
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(sig);

        return ecrecover(message, v, r, s);
    }
}

    contract ColdChain {

        enum Mode { ISSUER, PROVER, VERIFIER }
        struct Entity {
            address id;
            Mode mode;
            uint[] certificateIds;

        }

        enum Status {MANUFACTURED, DELIVERING_INTERNATIONAl, STORED, DELIVERING_LOCAL, DELIVERED}

        struct Certificate {
            uint id;
            Entity issuer;
            Entity prover;
            bytes signature;
            Status status;

        }

        struct VaccineBatch {
            uint id;
            string brand;
            address manufacturer;
            uint[] certificateIds;
            

        }

        uint public constant MAX_CERTIFICATIONS = 2;
       
        uint[] public certificateIds;
        uint[] public vaccineBatchIds;


        


        mapping(uint => VaccineBatch) public vaccineBatches;
        mapping(uint => Certificate ) public certificates;
        mapping(address => Entity) public entities;

        event addEntity (address entityId, string entityMode);
        event addVaccineBatch (uint vaccineBatchId, address indexed Manufacturer);
        event  IssueCertificate (address indexed issuer, address indexed prover, uint certificateId);
    

    function addEntity (address _id, string memory _mode) public {
        Mode mode =  unmarchalMode(_mode);
         uint[] memory _certificateIds = new uint[]("MAX_CERTIFICATIONS");
        Entity memory entity = Entity(_id, mode, _certificateIds);
        entities[_id] = entity;

        emit addEntity(entity.id, _mode);



    }

    function unmarchalMode (string memory _mode) private pure returns(Mode _mode) {
        bytes32 encodedMode = keccak256(abi.encodePacked(_mode));
        bytes32 encodedMode0 = keccak256(abi.encodePacked("ISSUER"));
        bytes32 encodedMode1 = keccak256(abi.encodePacked("PROVER"));
        bytes32 encodedMode2 = keccak256(abi.encodePacked("VERIFIER"));

        if (encodedMode == encodedMode0 )  {
            return Mode.ISSUER; 
        }
        else if (encodedMode == encodedMode1 )  {
            return Mode.PROVER;
        }
         else if (encodedMode == encodedMode2 )  {
            return Mode.VERIFIER;
        }

        revert("received invalid entity mode")
    }

     function addVaccineBatch (string memory brand, address manufacturer) public returns (uint) {
        
        uint[] memory _certificateIds = new uint[]("MAX_CERTIFICATIONS");
        uint id = vaccineBatchIds.length;
        VaccineBatch memory batch = VaccineBatch(id, brand, manufacturer, _certificateIds);

        vaccineBatches[id] = batch;
        vaccineBatchIds.push(id);
        
        
        
        emit addVaccineBatch(batch.id, batch.manufacturer);
        return id;



    }

    function unmarchalMode (string memory _mode) private pure returns(Mode _mode) {
        bytes32 encodedMode = keccak256(abi.encodePacked(_mode));
        bytes32 encodedMode0 = keccak256(abi.encodePacked("ISSUER"));
        bytes32 encodedMode1 = keccak256(abi.encodePacked("PROVER"));
        bytes32 encodedMode2 = keccak256(abi.encodePacked("VERIFIER"));

        if (encodedMode == encodedStatus0 )  {
            return Mode.ISSUER; 
        }
        else if (encodedMode == encodedStatus1 )  {
            return Mode.PROVER;
        }
         else if (encodedMode == encodedStatus2 )  {
            return Mode.VERIFIER;
        }

        revert("received invalid entity mode")
    }



    function issueCertificate(
        address _issuer, address _prover, string memory _status,
        uint vaccineBatchId, bytes memory signature) public returns(uint) {
            Entity memory issuer = entities[issuer];
            require(issuer.mode = Mode.ISSUER);

            Entity memory prover = entities[prover];
            require(prover.mode = Mode.PROVER);

            Status status = unmarchalStatus(_status);

            uint id = certificates.length;
            Certificate memory certificate = Certificate(id, issuer, prover, signature, status);

//uint certificatePos = 0;
//if (status = Status.MANUFACTURED)

            certificateIds.push(certificateIds.length);
            certificates[certificateIds.length-1] = certificate; // the last one

            emit issueCertificate(_issuer, _prover, certificateIds.length-1);

            return certificateIds.length-1;




        }

    function unmarchalStatus (string memory _status) private pure returns(Status _status) {
        bytes32 encodedStatus = keccak256(abi.encodePacked(_status));
        bytes32 encodedStatus0 = keccak256(abi.encodePacked(" MANUFACTURED"));
        bytes32 encodedStatus1 = keccak256(abi.encodePacked("DELIVERING_INTERNATIONAl"));
        bytes32 encodedStatus2 = keccak256(abi.encodePacked("STORED"));
        bytes32 encodedStatus2 = keccak256(abi.encodePacked("DELIVERING_LOCAL"));
        bytes32 encodedStatus2 = keccak256(abi.encodePacked("DELIVERED"));

        


        if (encodedStatus == encodedStatus0 )  {
            return Status.MANUFACTURED; 
        }
        else if (encodedMode == encodedStatus1 )  {
            return Status.DELIVERING_INTERNATIONAl;
        }
        else if (encodedMode == encodedStatus2 )  {
            return Status.STORED;
        }
        else if (encodedMode == encodedStatus2 )  {
            return Status.DELIVERING_LOCAL;
        }
        else if (encodedMode == encodedStatus2 )  {
            return Status.DELIVERED;
        }

        revert("received invalid certification Status")
    }

    function isMatchingSignature(bytes32 message, uint id, address issuer) public view returns (bool) {
        Certificate memory cert = certificates[id];
        require(cert.issuer.id == issuer);

        address recoveredSigner = CryptoSuite.recoverSigner(message, cert.signature);

        return recoveredSigner == cert.issuer.id;
    }
