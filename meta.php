#!/usr/bin/php
<?php

/**
 * metadata generation script,
 * Deploy the metadata in a separate IPFS CID
 */

const IPFS_IMG_URL = "ipfs://QmVLhSdxh4rUqYVt1e2cGGbEC2Z5jTFR9uznLkQ78oS7uK/img/";

$dir = __DIR__;

for ($i = 0; $i < 18; $i++) {
    $path = $dir . "/docs/meta/" . $i;
    `rm -rf $path`;
    `mkdir $path`;
}

for ($i = 0; $i < 18; $i++) {

    $path_mata = $dir . "/docs/meta/" . $i;

    for ($t = 0; $t < 100; $t++) {

        $serial = $i.sprintf('%02d', $t);
        if ($i === 0) {
            $serial = $t;
        }
        $pageID = $i+1;
        $tileID = $t+1;

        $obj = new stdClass;
        $obj->name = "TheNFT #$serial/1799";
        $obj->description = "The SEC issued an 18-page investigative report about TheDAO. The report concluded that, DAO Tokens, a Digital Asset, were securities. Each page of the pdf has been converted into bitmaps, then broken up into 100 tiles.

Each tile is minted as an NFT, with 1 original TheDAO token wrapped inside.

The NFT can be burned to unwrap 1 TheDAO token, which is a 16 decimal ERC20 token, created on Ethereum on Apr 30 2016.

This piece is from page $pageID, tile $tileID (serial numbers start from 0)

More details: thedaonft.eth

(This NFT was minted using the V1 contract and upgraded to V2)
  ";
        $obj->image = "ipfs://QmRX4tA5VtPPvetDdTx9SD9Wm1ty4zzeqHzq4y9guvUHAk/$i/$t.png";
        $obj->attributes = [];

        file_put_contents("$path_mata/$t.json", json_encode($obj, JSON_PRETTY_PRINT));

    }
}