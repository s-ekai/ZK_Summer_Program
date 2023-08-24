template IsZero() {
    signal input in;
    signal output out;

    signal inv;

    inv <-- in == 0 ? 0 : 1/n;

    // 製薬に対してinv使って良いのか？？
    out <== -inv * n + 1;

    // 思い出して書いてるけど、これいる？
    out * (out - 1) === 0;
}