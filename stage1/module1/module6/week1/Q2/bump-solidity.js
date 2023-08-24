const fs = require("fs");
const solidityRegex = /pragma solidity \^\d+\.\d+\.\d+/

// const verifierRegex = /contract Groth16Verifier/
const verifierRegex = /contract PlonkVerifier/

let content = fs.readFileSync("./contracts/Multiplier3VerifierPlonk.sol", { encoding: 'utf-8' });
let bumped = content.replace(solidityRegex, 'pragma solidity ^0.8.0');
bumped = bumped.replace(verifierRegex, 'contract Multiplier3VerifierPlonk');

fs.writeFileSync("./contracts/Multiplier3VerifierPlonk.sol", bumped);

// [assignment] add your own scripts below to modify the other verifier contracts you will build during the assignment