#!/bin/bash

# [assignment] create your own bash script to compile Multiplier3.circom using PLONK below

cd contracts/circuits

mkdir Multiplier3_plonk

if [ -f ./powersOfTau28_hez_final_10.ptau ]; then
    echo "powersOfTau28_hez_final_10.ptau already exists. Skipping."
else
    echo 'Downloading powersOfTau28_hez_final_10.ptau'
    wget https://hermez.s3-eu-west-1.amazonaws.com/powersOfTau28_hez_final_10.ptau
fi

echo "Compiling Multiplier3.circom..."

# compile circuit

circom Multiplier3.circom --r1cs --wasm --sym -o Multiplier3_plonk
snarkjs r1cs info Multiplier3_plonk/Multiplier3.r1cs

# Start a new zkey and make a contribution

# だたplonkに変えただけだと下記のエラー。snarkjs plonk setupした後は、snarkjs zkey contributeは必要ない？
# [ERROR] snarkJS: Error: zkey file is not groth16
#     at phase2contribute (/Users/suzukimasayuki/.nodebrew/node/v18.13.0/lib/node_modules/snarkjs/build/cli.cjs:4988:15)
#     at async Object.zkeyContribute [as action] (/Users/suzukimasayuki/.nodebrew/node/v18.13.0/lib/node_modules/snarkjs/build/cli.cjs:13496:5)
#     at async clProcessor (/Users/suzukimasayuki/.nodebrew/node/v18.13.0/lib/node_modules/snarkjs/build/cli.cjs:481:27)
# [INFO]  snarkJS: EXPORT VERIFICATION KEY STARTED
# [ERROR] snarkJS: [Error: ENOENT: no such file or directory, open 'Multiplier3_plonk/circuit_final.zkey'] {
#   errno: -2,
#   code: 'ENOENT',
#   syscall: 'open',
#   path: 'Multiplier3_plonk/circuit_final.zkey'
# }
# [INFO]  snarkJS: EXPORT VERIFICATION KEY STARTED
# [ERROR] snarkJS: [Error: ENOENT: no such file or directory, open 'Multiplier3_plonk/circuit_final.zkey'] {
#   errno: -2,
#   code: 'ENOENT',
#   syscall: 'open',
#   path: 'Multiplier3_plonk/circuit_final.zkey'
# }

snarkjs plonk setup Multiplier3_plonk/Multiplier3.r1cs powersOfTau28_hez_final_10.ptau Multiplier3_plonk/circuit_final.zkey
# snarkjs zkey contribute Multiplier3_plonk/circuit_0000.zkey Multiplier3_plonk/circuit_final.zkey --name="1st Contributor Name" -v -e="random text"
snarkjs zkey export verificationkey Multiplier3_plonk/circuit_final.zkey Multiplier3_plonk/verification_key.json

# generate solidity contract
snarkjs zkey export solidityverifier Multiplier3_plonk/circuit_final.zkey ../Multiplier3Verifier.sol

cd ../..