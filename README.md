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