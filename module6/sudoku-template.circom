pragma circom 2.1.4;

include "https://github.com/socathie/circomlib-matrix/blob/master/circuits/matAdd.circom";
include "https://github.com/socathie/circomlib-matrix/blob/master/circuits/matElemMul.circom";
include "https://github.com/socathie/circomlib-matrix/blob/master/circuits/matElemSum.circom";
include "https://github.com/socathie/circomlib-matrix/blob/master/circuits/matElemPow.circom";
include "circomlib/poseidon.circom";
include "circomlib/comparators.circom";

//[assignment] include your RangeProof template here
template RangeProof(n) {
    assert(n <= 252);
    signal input in; // this is the number to be proved inside the range
    signal input range[2]; // the two elements should be the range, i.e. [lower bound, upper bound]
    signal output out;

    component lt = LessEqThan(n);
    component gt = GreaterEqThan(n);

    lt.in[0] <== in;
    lt.in[1] <== range[1];

    gt.in[0] <== in;
    gt.in[1] <== range[0];

    // [assignment] insert your code here
    out <== lt.out * gt.out;
}


template sudoku() {
    signal input puzzle[9][9]; // 0  where blank
    signal input solution[9][9]; // 0 where original puzzle is not blank
    signal output out;

    // check whether the solution is zero everywhere the puzzle has values (to avoid trick solution)

    component mul = matElemMul(9,9);

    //[assignment] hint: you will need to initialize your RangeProof components here
    // component rp = RangeProof(32);

    component puzzleCheck[9][9];
    component solutionCheck[9][9];

    for (var i=0; i<9; i++) {
        for (var j=0; j<9; j++) {

            puzzleCheck[i][j] = RangeProof(32);
            puzzleCheck[i][j].in <== puzzle[i][j];
            puzzleCheck[i][j].range[0] <== 0;
            puzzleCheck[i][j].range[1] <== 9;
            puzzleCheck[i][j].out === 1;

            solutionCheck[i][j] = RangeProof(32);
            solutionCheck[i][j].in <== solution[i][j];
            solutionCheck[i][j].range[0] <== 0;
            solutionCheck[i][j].range[1] <== 9;
            solutionCheck[i][j].out === 1;

            mul.a[i][j] <== puzzle[i][j];
            mul.b[i][j] <== solution[i][j];
        }
    }
    for (var i=0; i<9; i++) {
        for (var j=0; j<9; j++) {
            mul.out[i][j] === 0;
        }
    }

    // sum up the two inputs to get full solution and square the full solution

    component add = matAdd(9,9);

    for (var i=0; i<9; i++) {
        for (var j=0; j<9; j++) {
            add.a[i][j] <== puzzle[i][j];
            add.b[i][j] <== solution[i][j];
        }
    }

    component square = matElemPow(9,9,2);

    for (var i=0; i<9; i++) {
        for (var j=0; j<9; j++) {
            square.a[i][j] <== add.out[i][j];
        }
    }

    // check all rows and columns and blocks sum to 45 and sum of sqaures = 285

    component row[9];
    component col[9];
    component block[9];
    component rowSq[9];
    component colSq[9];
    component blockSq[9];


    for (var k=0; k<9; k++) {
        row[k] = matElemSum(1,9);
        col[k] = matElemSum(1,9);
        block[k] = matElemSum(3,3);

        rowSq[k] = matElemSum(1,9);
        colSq[k] = matElemSum(1,9);
        blockSq[k] = matElemSum(3,3);

        for (var i=0; i<9; i++) {
            row[k].a[0][i] <== add.out[k][i];
            col[k].a[0][i] <== add.out[i][k];

            rowSq[k].a[0][i] <== square.out[k][i];
            colSq[k].a[0][i] <== square.out[i][k];
        }
        var x = 3*(k%3);
        var y = 3*(k\3);
        for (var i=0; i<3; i++) {
            for (var j=0; j<3; j++) {
                block[k].a[i][j] <== add.out[x+i][y+j];
                blockSq[k].a[i][j] <== square.out[x+i][y+j];
            }
        }
        row[k].out === 45;
        col[k].out === 45;
        block[k].out === 45;

        rowSq[k].out === 285;
        colSq[k].out === 285;
        blockSq[k].out === 285;
    }

    // hash the original puzzle and emit so that the dapp can listen for puzzle solved events

    component poseidon[9];
    component hash;

    hash = Poseidon(9);

    for (var i=0; i<9; i++) {
        poseidon[i] = Poseidon(9);
        for (var j=0; j<9; j++) {
            poseidon[i].inputs[j] <== puzzle[i][j];
        }
        hash.inputs[i] <== poseidon[i].out;
    }

    out <== hash.out;
}

component main = sudoku();

/* INPUT = {
    "puzzle": [
        ["1", "0", "0", "0", "0", "0", "0", "0", "0"],
        ["0", "8", "0", "0", "0", "0", "0", "0", "0"],
        ["0", "0", "6", "0", "0", "0", "0", "0", "0"],
        ["0", "0", "0", "5", "0", "0", "0", "0", "0"],
        ["0", "0", "0", "0", "3", "0", "0", "0", "0"],
        ["0", "0", "0", "0", "0", "1", "0", "0", "0"],
        ["0", "0", "0", "0", "0", "0", "9", "0", "0"],
        ["0", "0", "0", "0", "0", "0", "0", "7", "0"],
        ["0", "0", "0", "0", "0", "0", "0", "0", "5"]
    ],
    "solution": [
        ["0", "7", "4", "2", "8", "5", "3", "9", "6"],
        ["2", "0", "5", "3", "9", "6", "4", "1", "7"],
        ["3", "9", "0", "4", "1", "7", "5", "2", "8"],
        ["4", "1", "7", "0", "2", "8", "6", "3", "9"],
        ["5", "2", "8", "6", "0", "9", "7", "4", "1"],
        ["6", "3", "9", "7", "4", "0", "8", "5", "2"],
        ["7", "4", "1", "8", "5", "2", "0", "6", "3"],
        ["8", "5", "2", "9", "6", "3", "1", "0", "4"],
        ["9", "6", "3", "1", "7", "4", "2", "8", "0"]
    ]
} */