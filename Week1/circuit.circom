pragma circom 2.0.0; 

// code for mimcsponge hash function
include "mimcsponge.circom";

template merkleRoot(n) {
    // initialized leaves array with length n
    signal input leaves[n];
    signal output merkleRoot;

    // store the number of hashes for all leaves
    component hash[n-1];

    // sets up mimcsponge hash function
    for (var i = 0; i < n-1; i++) {
        hash[i] = MiMCSponge(2, 220, 1); // nRounds = 220 is standard
        hash[i].k <== 0;
    }

    // hash the sum of each pair of leaves ex. hash(h1 + h2) for all leaves
    var j = 0;
    for (var i = 0; i < n; i+=2) {
        hash[j].ins[0] <== leaves[i];
        hash[j].ins[1] <== leaves[i+1];
        j++;
    }

    // compute hashes which become inputs for parent leaves
    j = n/2;
    for (var i = 0; i < n-2; i+=2) {
        hash[j].ins[0] <== hash[i].outs[0];
        hash[j].ins[1] <== hash[i+1].outs[0];
        j++;
    }

    merkleRoot <== hash[n-2].outs[0];
}

component main {public [leaves]} = merkleRoot(8);
