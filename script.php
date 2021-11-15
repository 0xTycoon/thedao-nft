#!/usr/bin/php
<?php
/***
 * Image generation and hashing script
 *
 *  (Required command: pdftoppm, composite, convert. See below for versions)
 *
 * 1. Rasterize the TheDAO-SEC-34-81207.pdf to 18 pngs, using `pdftoppm` version 0.86.1
 * 2. Split each png into 100 tiles using the `convert` command (ImageMagick 6.9.10-23 Q16 x86_64 20190101)
 * 3. Add the DAO logo to each tile using the `composite` command (ImageMagick 6.9.10-23 Q16 x86_64 20190101)
 *
 *  SHA256 Hashes:
 *  TheDAO-SEC-34-81207.pdf    6c9ae041b9b9603da01d0aa4d912586c8d85b9fe1932c57f988d8bd0f9da3bc7
 *  docs/img/thedao.png fae7a4fda83cc18b60ab88453bf2354a8830696a5ab8518257bc421a09c00b11
 *  Sum of all tiles
 *
 *  tile size: 1000 x 1400
 *
 */
// php forever!
$dir = __DIR__;
// clean up
`rm *.png`;
// delete tiles, re-create dirs
for ($i = 0; $i < 18; $i++) {
    $path = $dir . "/docs/img/" . $i;
    `rm -rf $path`;
    `mkdir $path`;
}
// rasterize pdf
$cmd = "pdftoppm $dir/TheDAO-SEC-34-81207.pdf $dir/TheDAO-art -png -x 1400 -y 1000 -W 10000 -H 14000 -r 1500 -f 1 -l 18";
echo "$cmd\n";
`$cmd`;
$hasher = hash_init("sha256");
for ($i = 0; $i < 18; $i++) {
    $path = $dir . "/docs/img/" . $i;
    $seq = sprintf('%02d', $i+1);
    // split each page into tiles
    $cmd = "convert $dir/TheDAO-art-$seq.png -strip -crop 1000x1400 +adjoin $path/%d.png";
    echo "$cmd\n";
    `$cmd`;
    // add the logo to each tile
    for ($t = 0; $t < 100; $t++) {
        // add the logo, bottom right
        $cmd = "composite -strip -dissolve 70 -gravity southeast -geometry +20+20 -define compose:clip-to-self=true docs/img/thedao.png $path/$t.png $path/output.png";
        echo "$cmd\n";
        `$cmd`;
        // add the "1 DAO" top left
        `convert -strip -background '#fb212d' -fill white -pointsize 60 label:'1 TheDAO token inside' -size 1000x500  miff:- | composite -strip -dissolve 40 -gravity northwest -geometry +0+0  - $path/output.png $path/output2.png `;
        $serial = $i.sprintf('%02d', $t);
        if ($i === 0) {
            $serial = $t;
        }
        // add the serial number top right
        `convert -strip -background '#fb212d' -fill white -pointsize 60 label:'#$serial/1799' -size 1000x500  miff:- | composite -strip -dissolve 40 -gravity northeast -geometry +0+0  - $path/output2.png $path/output3.png `;
        `rm $path/$t.png`; // delete the source
        // delete the intermediate imgs
        `rm $path/output.png`;
        `rm $path/output2.png`;
        // rename the final intermediate
        `mv $path/output3.png $path/$t.png`;
        // shasum each tile with https://www.php.net/manual/en/function.hash-init.php
        $data = file_get_contents("$path/$t.png");
        hash_update($hasher, $data);

        $json =

            `
`;

    }
}
echo "final hash: ".hash_final($hasher)."\n";
