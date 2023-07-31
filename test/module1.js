// test.js
const assert = require('assert');
const { modularCalculator } = require('../module1/main.js');

describe('module1', () => {
  describe('modularCalculator', () => {
    it('modularCalculator(\'+\', 10, 15, 12)', () => {
      assert.strictEqual(modularCalculator('+', 10, 15, 12), 1);
    });

    it('modularCalculator(\'-\', 10, 15, 12)', () => {
      assert.strictEqual(modularCalculator('-', 10, 15, 12), 7);
    });

    it('modularCalculator(\'*\', 10, 15, 12)', () => {
      assert.strictEqual(modularCalculator('*', 10, 15, 12), 6);
    });
  });
});

