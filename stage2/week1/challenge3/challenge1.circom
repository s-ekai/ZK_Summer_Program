// secret
// nullifier
// tokenCommitment = poseidon(secret, nullifier)
// nullifierHash = poseidon(nullifier)  public
// tokenCommitmentの元になる二つの値を知っているかどうか。
// その時にprivateでinputしているnullifierからできたnullifierHashがオンチェーンで使われてない確認する
// markle treeで管理するのはtokenCommitment。