# Library
I have used the SafeMath library from Open Zeppelin.
This library is useful for preventing overflows and underflows when a integer is too large or too small.
It is great that SafeMath prevents these issues by default.

Libraries allow us to use the `using` keyword..

The SafeMath library has 4 functions - `add`, `sub`, `mul`, and `div`.

Let’s take a look at the code behind SafeMath:

```
pragma solidity ^0.4.24;

/**
* @title SafeMath
* @dev Math operations with safety checks that throw on error
*/
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    require(c / a == b, "SafeMath mul failed");
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a, "SafeMath sub failed");
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    require(c >= a, "SafeMath add failed");
    return c;
  }
}

```
