pragma circom 2.1.4;

include "circomlib/poseidon.circom";
// include "https://github.com/0xPARC/circom-secp256k1/blob/master/circuits/bigint.circom";

// poseidonハッシュは代入する順番を気にするから、0を受け取ったら左、1を受け取ったら右にする
template Rearrange() {
    signal input num;
    signal input in[2];
    signal output out[2];

    // 0か1であることを制約に
    num * (num - 1) === 0;

    out[0] <== (in[1] - in[0])*num + in[0];
    out[1] <== (in[0] - in[1])*num + in[1];
}

template ProveElementMembership (n) {
   signal input element; // rawデータ
   signal input root;
   signal input sibling_elements[n];
   signal input sibling_elements_index[n]; // これは0だと左、1だと右のように仮定する。

   // elementが生だと仮定する。poseidonでハッシュ化する。
   signal leaf;

   component poseidon = Poseidon(1);
   poseidon.inputs[0] <== element;
   leaf <== poseidon.out;

   component rearrange_components[n];
   component hashed_components[n];

    for (var i=0; i<n; i++) {
        rearrange_components[i] = Rearrange();
        hashed_components[i] = Poseidon(2);
    }

    // 初期化。numberが0だと仮定するとsiblingが左になる。1だと反対になる。
    rearrange_components[0].in[0] <== sibling_elements[0];
    rearrange_components[0].in[1] <== leaf;
    rearrange_components[0].num <== sibling_elements_index[0];

    hashed_components[0].inputs[0] <== rearrange_components[0].out[0];
    hashed_components[0].inputs[1] <== rearrange_components[0].out[1];

    for (var i=1; i<n; i++) {
        rearrange_components[i].in[0] <== sibling_elements[i];
        rearrange_components[i].in[1] <== hashed_components[i-1].out;
        rearrange_components[i].num <== sibling_elements_index[i];

        hashed_components[i].inputs[0] <== rearrange_components[i].out[0];
        hashed_components[i].inputs[1] <== rearrange_components[i].out[1];
    }

    // 一致しているとokだと判定して良い。
    root === hashed_components[n-1].out;
}

component main = ProveElementMembership(3);

/* INPUT = {
    "element": "5",
    "root": "have to poseion hash",
    "sibling_elements": ["poseion hash", "poseion hash", "poseion hash"],
    "sibling_elements_index": ["0", "1", "0"]
} */