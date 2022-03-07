# --r1cs it generates the file circuit.r1cs that contains the R1CS constraint system of the circuit in binary format.
# --wasm it generates the directory circuit_js that contains the Wasm code (circuit.wasm) and other files needed to generate the witness.
# --sym it generates the file circuit.sym , a symbols file required for debugging or for printing the constraint system in an annotated mode.
circom circuit.circom --r1cs --wasm --sym

# Compute the witness
node generate_witness.js circuit.wasm input.json witness.wtns

# start a new "powers of tau" ceremony:
# 12 originally didn't work for the powers of tau so 14 was tried instaed and worked
snarkjs powersoftau new bn128 14 pot14_0000.ptau -v

# Execute the following command to start the generation of this phase 2
snarkjs powersoftau prepare phase2 pot14_0000.ptau pot14_final.ptau -v

# we generate a .zkey file that will contain the proving and verification keys together with all phase 2 contributions
snarkjs groth16 setup circuit.r1cs pot14_final.ptau circuit_0001.zkey

# Export the verification key:
snarkjs zkey export verificationkey circuit_0001.zkey verification_key.json

# generate a zk-proof associated to the circuit and the witness
snarkjs groth16 prove circuit_0001.zkey witness.wtns proof.json public.json

# To verify the proof, execute the following command:
snarkjs groth16 verify verification_key.json public.json proof.json
