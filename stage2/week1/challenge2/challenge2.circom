// チャレンジ1だと leafにいるものを自分で定義しないといけない。
// 単純に秘密鍵だけにするケースを考える。
// まずproofが何度も使えるから防止しないといけない。
// nullifierが必要。しかしトルネードキャッシュと同じ考え方はできない。なぜならnullifierは毎回固定だから。
// つまりこれだけでnullifierHashを作ってもだめ。external nullifierを導入する。
// secret = trapdoor + nullifier
// identityCommitment = secret
// nullifierHash = nullifier + externalnullifier *全部poseidon hashをかける
// これアプリごとにidentityCommitmentを買えるのか？？
