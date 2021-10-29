# Basic Sample Hardhat Project

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, a sample script that deploys that contract, and an example of a task implementation, which simply lists the available accounts.

Try running some of the following tasks:

```shell
npx hardhat accounts
npx hardhat compile
npx hardhat clean
npx hardhat test
npx hardhat node
node scripts/sample-script.js
npx hardhat help
```

### Creating the NFT

PDF to png using pdftoppm version 0.86.1

```
$ pdftoppm TheDAO-SEC-34-81207.pdf TheDAO-art -png -x 1400 -y 1000 -W 10000 -H 14000 -r 1500 -f 1 -l 2
```

Convert to tiles

```
$ convert TheDAO-art-01.png -crop 1000x1500 +adjoin tiles/tile%04d.png
```


uint256 to string 

```solidity

function toString(uint256 value) public view returns (string memory) {
        // Inspired by openzeppelin's implementation - MIT licence
        // https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Strings.sol#L15
        // this version avoids the decimals counting
        uint8 count;
        if (value == 0) {
            return "0";
        }
        uint256 digits = 0;
        uint256 temp = 0;
        uint256 b;
        while (true) {
            b = 48 + (value % 10);
            b <<= 248; // 8*31 put to the left (ints are little endian, so result is on the right)
            temp = temp | (b & 0xff00000000000000000000000000000000000000000000000000000000000000); // copy
            value /= 10;
            digits++;
            if (value!=0) {
                temp = temp >>= 8; // make room for next value
            } else {
                break;
            }
        }
        // convert int256 to bytes
        bytes memory buffer = new bytes(32);
        assembly {
            mstore (add(32, buffer), temp)
            mstore (add(0, buffer), digits)
        }
        return string(buffer);
    }

```