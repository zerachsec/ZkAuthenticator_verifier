// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title ZKAuthVerifier
 * @author VISHAAL S (AA.SC.P2MCA24077071)
 * @notice Zero-Knowledge Proof based authentication system using Groth16
 * @dev Implements zk-SNARK verification for privacy-preserving authentication
 */

library Pairing {
    struct G1Point {
        uint256 X;
        uint256 Y;
    }

    struct G2Point {
        uint256[2] X;
        uint256[2] Y;
    }

    /// @return the generator of G1
    function P1() internal pure returns (G1Point memory) {
        return G1Point(1, 2);
    }

    /// @return the generator of G2
    function P2() internal pure returns (G2Point memory) {
        return G2Point(
            [
                11559732032986387107991004021392285783925812861821192530917403151452391805634,
                10857046999023057135944570762232829481370756359578518086990519993285655852781
            ],
            [
                4082367875863433681332203403145435568316851327593401208105741076214120093531,
                8495653923123431417604973247489272438418190587263600148770280649306958101930
            ]
        );
    }

    /// @return r the negation of p, i.e. p.addition(p.negate()) should be zero.
    function negate(G1Point memory p) internal pure returns (G1Point memory r) {
        uint256 q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
        if (p.X == 0 && p.Y == 0) {
            return G1Point(0, 0);
        }
        return G1Point(p.X, q - (p.Y % q));
    }

    /// @return r the sum of two points of G1
    function addition(G1Point memory p1, G1Point memory p2) internal view returns (G1Point memory r) {
        uint256[4] memory input;
        input[0] = p1.X;
        input[1] = p1.Y;
        input[2] = p2.X;
        input[3] = p2.Y;
        bool success;

        assembly {
            success := staticcall(sub(gas(), 2000), 6, input, 0xc0, r, 0x60)
            switch success
            case 0 { invalid() }
        }

        require(success, "pairing-add-failed");
    }

    /// @return r the product of a point on G1 and a scalar, i.e. p == p.scalar_mul(1) and p.addition(p) == p.scalar_mul(2) for all points p.
    function scalar_mul(G1Point memory p, uint256 s) internal view returns (G1Point memory r) {
        uint256[3] memory input;
        input[0] = p.X;
        input[1] = p.Y;
        input[2] = s;
        bool success;

        assembly {
            success := staticcall(sub(gas(), 2000), 7, input, 0x80, r, 0x60)
            switch success
            case 0 { invalid() }
        }

        require(success, "pairing-mul-failed");
    }

    /// @return the result of computing the pairing check
    function pairing(G1Point[] memory p1, G2Point[] memory p2) internal view returns (bool) {
        require(p1.length == p2.length, "pairing-lengths-failed");
        uint256 elements = p1.length;
        uint256 inputSize = elements * 6;
        uint256[] memory input = new uint256[](inputSize);

        for (uint256 i = 0; i < elements; i++) {
            input[i * 6 + 0] = p1[i].X;
            input[i * 6 + 1] = p1[i].Y;
            input[i * 6 + 2] = p2[i].X[0];
            input[i * 6 + 3] = p2[i].X[1];
            input[i * 6 + 4] = p2[i].Y[0];
            input[i * 6 + 5] = p2[i].Y[1];
        }

        uint256[1] memory out;
        bool success;

        assembly {
            success := staticcall(sub(gas(), 2000), 8, add(input, 0x20), mul(inputSize, 0x20), out, 0x20)
            switch success
            case 0 { invalid() }
        }

        require(success, "pairing-opcode-failed");
        return out[0] != 0;
    }
}

contract ZKAuthVerifier {
    using Pairing for *;

    struct VerifyingKey {
        Pairing.G1Point alpha;
        Pairing.G2Point beta;
        Pairing.G2Point gamma;
        Pairing.G2Point delta;
        Pairing.G1Point[] gamma_abc;
    }

    struct Proof {
        Pairing.G1Point a;
        Pairing.G2Point b;
        Pairing.G1Point c;
    }

    // Authentication state
    mapping(address => bool) public authenticatedUsers;
    mapping(bytes32 => bool) public usedNullifiers;
    mapping(address => uint256) public lastAuthTimestamp;

    // Events
    event UserAuthenticated(address indexed user, uint256 timestamp, bytes32 nullifier);
    event AuthenticationRevoked(address indexed user);
    event ProofVerified(bytes32 indexed proofHash, bool success);

    // Configuration
    uint256 public constant AUTH_VALIDITY_PERIOD = 24 hours;
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    /**
     * @notice Returns the verifying key for Groth16 proof verification
     * @dev This key is generated from the Circom circuit using snarkjs
     * @dev Replace these values with your actual verification key
     */
    function verifyingKey() internal pure returns (VerifyingKey memory vk) {
        vk.alpha = Pairing.G1Point(
            uint256(0x2d4d9aa7e302d9df41749d5507949d05dbea33fbb16c643b22f599a2be6df2e2),
            uint256(0x14bedd503c37ceb061d8ec60209fe345ce89830a19230301f076caff004d1926)
        );

        vk.beta = Pairing.G2Point(
            [
                uint256(0x0967032fcbf776d1afc985f88877f182d38480a653f2decaa9794cbc3bf3060c),
                uint256(0x0e187847ad4c798374d0d6732bf501847dd68bc0e071241e0213bc7fc13db7ab)
            ],
            [
                uint256(0x304cfbd1e08a704a99f5e847d93f8c3caafddec46b7a0d379da69a4d112346a7),
                uint256(0x1739c1b1a457a8c7313123d24d2f9192f896b7c63eea05a9d57f06547ad0cec8)
            ]
        );

        vk.gamma = Pairing.G2Point(
            [
                uint256(0x198e9393920d483a7260bfb731fb5d25f1aa493335a9e71297e485b7aef312c2),
                uint256(0x1800deef121f1e76426a00665e5c4479674322d4f75edadd46debd5cd992f6ed)
            ],
            [
                uint256(0x090689d0585ff075ec9e99ad690c3395bc4b313370b38ef355acdadcd122975b),
                uint256(0x12c85ea5db8c6deb4aab71808dcb408fe3d1e7690c43d37b4ce6cc0166fa7daa)
            ]
        );

        vk.delta = Pairing.G2Point(
            [
                uint256(0x26186a2d65ee4d2f9c9a5b91f86f8b8c3b5b5f5e7b3a8c9d1e2f3a4b5c6d7e8f),
                uint256(0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef)
            ],
            [
                uint256(0xabcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890),
                uint256(0x9876543210fedcba9876543210fedcba9876543210fedcba9876543210fedcba)
            ]
        );

        vk.gamma_abc = new Pairing.G1Point[](3);
        vk.gamma_abc[0] = Pairing.G1Point(
            uint256(0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef),
            uint256(0xabcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890)
        );
        vk.gamma_abc[1] = Pairing.G1Point(
            uint256(0x0987654321fedcba0987654321fedcba0987654321fedcba0987654321fedcba),
            uint256(0xfedcba0987654321fedcba0987654321fedcba0987654321fedcba0987654321)
        );
        vk.gamma_abc[2] = Pairing.G1Point(
            uint256(0x1111111111111111111111111111111111111111111111111111111111111111),
            uint256(0x2222222222222222222222222222222222222222222222222222222222222222)
        );
    }

    /**
     * @notice Verify a Groth16 zk-SNARK proof
     * @param input Public inputs to the circuit
     * @param proof The proof structure
     * @return True if proof is valid
     */
    function verify(uint256[] memory input, Proof memory proof) internal view returns (bool) {
        VerifyingKey memory vk = verifyingKey();
        require(input.length + 1 == vk.gamma_abc.length, "Invalid input length");

        // Compute the linear combination vk_x
        Pairing.G1Point memory vk_x = Pairing.G1Point(0, 0);
        for (uint256 i = 0; i < input.length; i++) {
            vk_x = Pairing.addition(vk_x, Pairing.scalar_mul(vk.gamma_abc[i + 1], input[i]));
        }
        vk_x = Pairing.addition(vk_x, vk.gamma_abc[0]);

        // Verify pairing equation
        Pairing.G1Point[] memory p1 = new Pairing.G1Point[](4);
        Pairing.G2Point[] memory p2 = new Pairing.G2Point[](4);

        p1[0] = Pairing.negate(proof.a);
        p2[0] = proof.b;

        p1[1] = vk.alpha;
        p2[1] = vk.beta;

        p1[2] = vk_x;
        p2[2] = vk.gamma;

        p1[3] = proof.c;
        p2[3] = vk.delta;

        return Pairing.pairing(p1, p2);
    }

    /**
     * @notice Authenticate user with ZK proof
     * @param a Proof point A [x, y]
     * @param b Proof point B [[x0, x1], [y0, y1]]
     * @param c Proof point C [x, y]
     * @param input Public inputs [nullifier, commitment]
     * @return True if authentication successful
     */
    function authenticate(uint256[2] memory a, uint256[2][2] memory b, uint256[2] memory c, uint256[2] memory input)
        public
        returns (bool)
    {
        // Create proof structure
        Proof memory proof;
        proof.a = Pairing.G1Point(a[0], a[1]);
        proof.b = Pairing.G2Point([b[0][0], b[0][1]], [b[1][0], b[1][1]]);
        proof.c = Pairing.G1Point(c[0], c[1]);

        // Convert input to array
        uint256[] memory inputArray = new uint256[](2);
        inputArray[0] = input[0];
        inputArray[1] = input[1];

        // Verify the proof
        require(verify(inputArray, proof), "Invalid proof");

        // Check nullifier hasn't been used
        bytes32 nullifier = bytes32(input[0]);
        require(!usedNullifiers[nullifier], "Nullifier already used");

        // Mark nullifier as used
        usedNullifiers[nullifier] = true;

        // Authenticate user
        authenticatedUsers[msg.sender] = true;
        lastAuthTimestamp[msg.sender] = block.timestamp;

        emit UserAuthenticated(msg.sender, block.timestamp, nullifier);
        emit ProofVerified(keccak256(abi.encodePacked(a, b, c)), true);

        return true;
    }

    /**
     * @notice Check if user is currently authenticated
     * @param user Address to check
     * @return True if authenticated and not expired
     */
    function isAuthenticated(address user) public view returns (bool) {
        if (!authenticatedUsers[user]) {
            return false;
        }

        // Check if authentication has expired
        if (block.timestamp - lastAuthTimestamp[user] > AUTH_VALIDITY_PERIOD) {
            return false;
        }

        return true;
    }

    /**
     * @notice Revoke own authentication
     */
    function revokeAuthentication() public {
        require(authenticatedUsers[msg.sender], "User not authenticated");
        authenticatedUsers[msg.sender] = false;
        emit AuthenticationRevoked(msg.sender);
    }

    /**
     * @notice Get authentication details for a user
     * @param user Address to query
     * @return authenticated Current auth status
     * @return timestamp Last authentication time
     * @return timeRemaining Time until expiry (0 if expired)
     */
    function getAuthDetails(address user)
        public
        view
        returns (bool authenticated, uint256 timestamp, uint256 timeRemaining)
    {
        authenticated = authenticatedUsers[user];
        timestamp = lastAuthTimestamp[user];

        if (authenticated && block.timestamp < lastAuthTimestamp[user] + AUTH_VALIDITY_PERIOD) {
            timeRemaining = (lastAuthTimestamp[user] + AUTH_VALIDITY_PERIOD) - block.timestamp;
        } else {
            timeRemaining = 0;
        }
    }

    /**
     * @notice Admin function to revoke any user's authentication
     * @param user Address to revoke
     */
    function adminRevokeAuth(address user) external onlyOwner {
        authenticatedUsers[user] = false;
        emit AuthenticationRevoked(user);
    }
}
