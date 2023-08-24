pragma circom 2.1.4;

include "circomlib/poseidon.circom";
// include "https://github.com/0xPARC/circom-secp256k1/blob/master/circuits/bigint.circom";

template Example () {
   signal input prKey;
   signal output puKey;
   component poseidon = Poseidon(1);
   poseidon.inputs[0] <== in;
   out <== poseidon.out;
}

component main = Example();

/* INPUT = {
    "in": "5"
} */