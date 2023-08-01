const MerkleTree = require('merkletreejs');
const crypto = require('crypto');

function hashFunction(data) {
  const hash = crypto.createHash('sha256');
  hash.update(data);
  return hash.digest();
}

// Create tree
const leaves = ['a', 'b', 'c', 'd'].map(x => hashFunction(x));
// TODO: Build the Merkle tree using the leaves and hashFunction. Compute the root of the tree and print it.

// Generate and verify proof
const leaf = hashFunction('b');
// TODO: Generate a proof for the leaf 'b' and verify it against the root of the tree. It should return true if the leaf is part of the tree.