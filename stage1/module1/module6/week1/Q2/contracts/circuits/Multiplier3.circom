pragma circom 2.0.0;

// [assignment] Modify the circuit below to perform a multiplication of three signals

template Multiplier3 () {

   // Declaration of signals.
   signal input a;
   signal input b;
   signal input c;
   signal output d;

   // 制約をするときにa*b*cのように三つのシグナルを同時には入れてはいけない。回路的なものだから？
   //   Compiling Multiplier3.circom...
   //error[T3001]: Non quadratic constraints are not allowed!
   //   ┌─ "Multiplier3.circom":14:4
   //   │
   //14 │    d <== a * b * c;
   //   │    ^^^^^^^^^^^^^^^ found here
   //   │
   //   = call trace:
   //     ->Multiplier3
   // previous errors were found
   // Constraints.

   signal f <== a * b;
   d <== f * c;
}

component main = Multiplier3();