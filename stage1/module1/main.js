function modularCalculator(op, num1, num2, mod) {

  switch (op){
    case '+':
      tmp = num1 + num2
      break;
    case '-':
      tmp = num1 - num2
      break;
    case '*':
      tmp = num1 * num2
      break;
  }
  if (tmp < 0) {
    result = mod - Math.abs(tmp % mod)
  } else {
    result = tmp % mod
  }
  return result
}

module.exports = { modularCalculator };


