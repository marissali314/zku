pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/poseidon.circom";
include "./tree.circom";

// calculates the secret from the identity nullifier and identity trapdoor using a hash of the two
template CalculateSecret() {
    signal input identity_nullifier;
    signal input identity_trapdoor;

    signal output out;

    component hasher = Poseidon(2);
    hasher.inputs[0] <== identity_nullifier;
    hasher.inputs[1] <== identity_trapdoor;
    out <== hasher.out;
}

// calculates the identity commitment from the secret calculated from CalculateSecret() using a hash
template CalculateIdentityCommitment() {
    signal input secret_hash;

    signal output out;

    component hasher = Poseidon(1);
    hasher.inputs[0] <== secret_hash;
    out <== hasher.out;
}

// calculates the nullifier hash from a hash of the external nullifier and the identity nullfier
template CalculateNullifierHash() {
    signal input external_nullifier;
    signal input identity_nullifier;

    signal output out;

    component hasher = Poseidon(2);
    hasher.inputs[0] <== external_nullifier;
    hasher.inputs[1] <== identity_nullifier;
    out <== hasher.out;
}
// verifies the merkle root from the identity commitment, tree path indices, tree siblings
// calculates nullifier hash from external nullifier and identity nullifier

// n_levels must be < 32
template Semaphore(n_levels) {

    var LEAVES_PER_NODE = 5;
    var LEAVES_PER_PATH_LEVEL = LEAVES_PER_NODE - 1;

    signal input signal_hash;
    signal input external_nullifier;

    signal input identity_nullifier;
    signal input identity_trapdoor;
    signal input identity_path_index[n_levels];
    signal input path_elements[n_levels][LEAVES_PER_PATH_LEVEL];

    signal output root;
    signal output nullifierHash;

    // calculates the secret
    component secret = CalculateSecret();
    secret.identity_nullifier <== identity_nullifier;
    secret.identity_trapdoor <== identity_trapdoor;

    signal secret_hash;
    secret_hash <== secret.out;

    // calculates the identity commitment
    component identity_commitment = CalculateIdentityCommitment();
    identity_commitment.secret_hash <== secret_hash;

    // calculates the nullifier hash
    component calculateNullifierHash = CalculateNullifierHash();
    calculateNullifierHash.external_nullifier <== external_nullifier;
    calculateNullifierHash.identity_nullifier <== identity_nullifier;

    // verifies identity commitment and tree paths
    var i;
    var j;
    component inclusionProof = QuinTreeInclusionProof(n_levels);
    inclusionProof.leaf <== identity_commitment.out;

    for (i = 0; i < n_levels; i++) {
      for (j = 0; j < LEAVES_PER_PATH_LEVEL; j++) {
        inclusionProof.path_elements[i][j] <== path_elements[i][j];
      }
      inclusionProof.path_index[i] <== identity_path_index[i];
    }

    root <== inclusionProof.root;

    // Dummy square to prevent tampering signalHash
    signal signal_hash_squared;
    signal_hash_squared <== signal_hash * signal_hash;

    nullifierHash <== calculateNullifierHash.out;
}
