// SPDX-License-Identifier: MIT
// SYS 64738

pragma solidity ^0.8.11;

/*
  ::::::::::: :::    ::: :::::::::: ::::    ::: :::::::::: :::::::::::
     :+:     :+:    :+: :+:        :+:+:   :+: :+:            :+:
    +:+     +:+    +:+ +:+        :+:+:+  +:+ +:+            +:+
   +#+     +#++:++#++ +#++:++#   +#+ +:+ +#+ :#::+::#       +#+
  +#+     +#+    +#+ +#+        +#+  +#+#+# +#+            +#+
 #+#     #+#    #+# #+#        #+#   #+#+# #+#            #+#
###     ###    ### ########## ###    #### ###            ###

Burn & redeem TheNft tokens

This contract fixes the burning and redeeming of TheDao Tokens from TheNFT
project
*/

import "hardhat/console.sol";

contract Ciger {
    IERC20 private immutable cig;

    constructor(

        address _cig
    ) {

        cig = IERC20(_cig);
    IERC20(_cig).totalSupply();
       // console.log("cig:", );

    }



}

interface IERC20C {
    function totalSupply() external view returns (uint256);
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

}

interface ITheNFT {
    function balanceOf(address) external view returns(uint256);
    function ownerOf(uint256) external view returns(address);
    function transferFrom(address,address,uint256) external;
    function mint(uint256 i) external;
    function approve(address to, uint256 tokenId) external;
    function burn(uint256 id) external;
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
}