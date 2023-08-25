// secret
// nullifier
// tokenCommitment = poseidon(secret, nullifier)
// nullifierHash = poseidon(nullifier)  public
// tokenCommitmentの元になる二つの値を知っているかどうか。
// その時にprivateでinputしているnullifierからできたnullifierHashがオンチェーンで使われてない確認する
// markle treeで管理するのはtokenCommitment。


include "circomlib/poseidon.circom";
// include "https://github.com/0xPARC/circom-secp256k1/blob/master/circuits/bigint.circom";

template Rearrange() {
    signal input num;
    signal input in[2];
    signal output out[2];

    // 0か1であることを制約に
    num * (num - 1) === 0;

    out[0] <== (in[1] - in[0])*num + in[0];
    out[1] <== (in[0] - in[1])*num + in[1];
}

// INFO: passwordとnullifierからsecretを作成する。
template GenerateSecret() {
    signal input password;
    signal input nullifier;
    signal output secret;

    component poseidon = Poseidon(2);

    poseidon.inputs[0] <== password;
    poseidon.inputs[1] <== nullifier;

    out <== poseidon.out;
}

// INFO: secretからcommientを作成する。
template GenerateCommitment() {
    signal input secret;
    signal output commitment;
    component poseidon = Poseidon(1);
    poseidon.inputs[0] = secret;
    poseidon.out <== commitment;
}

// INFO: nullifierからnulliferHashを作成する。
template GenerateNullifierHash() {
    signal input nullifier;
    signal output nullifierHash;
    component poseidon = Poseidon(1);
    poseidon.inputs[0] <== nullifier;
    nullifierHash <== poseidon.out;
}

template ProveElementMembership (n) {
   signal input element; // rawデータ
   signal input root;
   signal input sibling_elements[n];
   signal input sibling_elements_index[n]; // これは0だと左、1だと右のように仮定する。

   component rearrange_components[n];
   component hashed_components[n];

    for (var i=0; i<n; i++) {
        rearrange_components[i] = Rearrange();
        hashed_components[i] = Poseidon(2);
    }

    // 初期化。numberが0だと仮定するとsiblingが左になる。1だと反対になる。
    rearrange_components[0].in[0] <== sibling_elements[0];
    rearrange_components[0].in[1] <== element;
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

// token mixierで引き出しを行うときに使う回路。
template Withdraw(n) {
    signal input password;
    signal input nullifier;
    signal input markle_tree_elements[n];
    signal input markle_tree_elements_index[n];
    signal input public tokenCommitment;
    signal input public root;
    signal input public nullifierHash; // double spendingを防ぐ。

    signal secret;
    signal commitment;

    component generate_secret = GenerateSecret();
    component generate_commitment = GenerateCommitment();

    // passwordとnullifierの関係性を作る。
    generate_secret.password <== password;
    generate_secret.nullifier <== nullifier;

    secret <== generate_secret.secret;

    // marke treeに追加するハッシュ化した情報
    generate_commitment.secret <== secret;
    generate_commitment.nullifier <== nullifier;
    commitment <== generate_commitment.commitment;

    component prove_element_membership = ProveElementMembership();
    prove_element_membership.element <== commitment;

    for (var i = 0; i < n; i++) {
        prove_element_membership.sibling_elements[i] <== markle_tree_elements[i];
        prove_element_membership.sibling_elements_index[i] <== markle_tree_elements_index[i];
    }
    prove_element_membership.root <== root;

    // double spendingを防ぐために公開する。
    component generate_nullifier_hash = GenerateNullifierHash();
    generate_nullifier_hash.nullifier <== nullifier;
    nullifierHash === generate_nullifier_hash.nullifierHash;

}