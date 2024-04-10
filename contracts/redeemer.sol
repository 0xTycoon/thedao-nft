// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

/*
  ::::::::::: :::    ::: :::::::::: ::::    ::: :::::::::: :::::::::::
     :+:     :+:    :+: :+:        :+:+:   :+: :+:            :+:
    +:+     +:+    +:+ +:+        :+:+:+  +:+ +:+            +:+
   +#+     +#++:++#++ +#++:++#   +#+ +:+ +#+ :#::+::#       +#+
  +#+     +#+    +#+ +#+        +#+  +#+#+# +#+            +#+
 #+#     #+#    #+# #+#        #+#   #+#+# #+#            #+#
###     ###    ### ########## ###    #### ###            ###

Burn & redeem TheNft tokens and other utilities

This contract fixes the burning and redeeming of TheDao Tokens from TheNFT
project.
*/

import "hardhat/console.sol";

contract Redeemer {

    ITheNFT public v1;
    ITheNFT public v2;

    // TheDAO stuff
    IERC20 private immutable theDAO;                           // the contract of TheDAO, the greatest DAO of all time
    uint256 private constant oneDao = 1e16;                    // 1 DAO = 16^10 wei or 0.01 ETH

    event Burn(address owner, uint256 tokenId);
    event Restore(address owner, uint256 tokenId);

    address private constant DEAD_ADDRESS = address(0x74eda0); // unwrapped NFTs go here (old)
    address private constant DEAD_ADDRESS2 = address(0x74eda02); // unwrapped NFTs go here (redeemer)
    mapping(uint256 => bool) private isBurned;

    IERC20 private immutable cig;
    uint256 public STIMULUS = 15000 ether;

    address private curator;

    constructor(
        address _v1,     // 0x266830230bf10a58ca64b7347499fd361a011a02
        address _v2,     // 0x79a7D3559D73EA032120A69E59223d4375DEb595
        address _theDao, // 0xbb9bc244d798123fde783fcc1c72d3bb8c189413
        address _cig     // 0xCB56b52316041A62B6b5D0583DcE4A8AE7a3C629
    ) {
        v1 = ITheNFT(_v1);
        v2 = ITheNFT(_v2);
        theDAO = IERC20(_theDao);
        cig = IERC20(_cig);
        theDAO.approve(_v2, type(uint256).max); // approve v2 to spend our thedao tokens
        v1.setApprovalForAll(_v2, true);        // approve v2 to upgrade our v1
        theDAO.approve(_v1, type(uint256).max); // approve v1 to spend our thedao tokens
        curator = msg.sender;
    }

    /**
    * Mint the remainder & burn
    * 1. mint v2, sending 1 TheDAO
    * 2. approve to this
    * 3. burn through the v2 contract
    * 4. yank the burned token, reset approval
    * 5. send to msg.sender
    */
    function mint(uint256 _i, bool _sendCig) external {
        uint256 id = 1800 - v1.balanceOf(address(v1));
        require(
            theDAO.transferFrom(msg.sender, address(this), oneDao* _i) == true,
            "DAO tokens required"
        );
        if (_i + id > 1800) {                              // if it goes over the max supply
            _i = 1800 -  id;                               // cap it
        }
        if (_sendCig) {
            cig.transfer(msg.sender, STIMULUS * _i);       // give cig reward
        }
        v2.mint(_i);                                       // mint on behalf of user
        while (_i > 0) {
            _rescue(id);                                   // get the dao token out and store it here
            v2.transferFrom(address(this), msg.sender, id);// send to minter
            _i--;
            id++;
        }
    }

    /**
    * Upgrade upgrades a v1 NFT to v2, it also uses the hack
    * to rescue a DAO token
    */
    function upgrade(uint256[] calldata _ids) external {
        theDAO.transfer(address(v1), oneDao * _ids.length);      // v1 was drained, so lend our DAO
        for (uint256 i; i < _ids.length; i++) {
            v1.transferFrom(msg.sender, address(this), _ids[i]); // transfer to here
        }
        v2.upgrade(_ids);
        for (uint256 i; i < _ids.length; i++) {
            _rescue(_ids[i]);
            v2.transferFrom(address(this), msg.sender, _ids[i]); // transfer to user
        }
    }

    /*
    * _rescue gets the DAO token out and stores it here
    */
    function _rescue(uint256 _id) internal {
        v2.approve(address(this), _id);                    // approve to self
        v2.burn(_id);                                      // we get 1 DAO back
        v2.transferFrom(DEAD_ADDRESS, address(this), _id); // we can get the nft back due to a bug
        //v2.approve(address(0), _id); // clear approval, dont need as transferFrom does it
    }

    /**
    * Burn burns a NFT and returns a DAO token. The NFT is placed in the redeemer
    * by calling burn() on v2.
    */

    function burn(uint256 _id) external {
        address owner = v2.ownerOf(_id);
        require(owner != address(this), "already burned");
        v2.transferFrom(owner, address(this), _id);// burns & clears approval
        isBurned[_id] = true;                      // record the burn state
        theDAO.transfer(owner, oneDao);            // send 1 DAO back
        emit Burn(owner, _id);
    }


    /**
    * restore takes out a NFT from the redeemer
    */

    function restore(uint256 _id) external {
        theDAO.transferFrom(msg.sender, address(this), oneDao); // take 1 DAO
        address owner = v2.ownerOf(_id);
        require(owner == address(this), "not in redeemer");
        require(isBurned[_id] == true, "not not burned");
        v2.transferFrom(address(this), msg.sender, _id);        // send token to new owner
        isBurned[_id] = false;                                  // un-burn it
        emit Restore(msg.sender, _id);
    }


    /*
     * restoreLegacy restores v2 & v1 nft that have been burned by the legacy contracts
     * In case of a v1, it will automatically upgrade to v2
     * requires 5 DAO approval to work
     * 4 DAO will go to the "curator" set in the v1 contract, and 1 will be
     * kept by the redeemer as a deposit
    */
    function restoreLegacy(address _legacy, uint256 _id) external {
        require(_legacy == address(v1) || _legacy == address(v2), "not legacy");
        ITheNFT l = ITheNFT(_legacy);
        theDAO.transferFrom(
            msg.sender,
            address(this),
            oneDao * 5                                    // 1 for deposit, 4 to curator
        );
        l.restore(_id);
        l.approve(address(this), _id);                    // approve to self, to "steal" 1 DAO back
        l.burn(_id);                                      // exploit, we get 1 DAO back
        l.transferFrom(DEAD_ADDRESS, address(this), _id); // we can get the nft back due to a bug
        if (_legacy == address(v1)) {
            theDAO.transfer(address(v1), oneDao);         // v1 was drained, so lend our DAO
            uint256[] memory i = new uint256[](1);
            i[0] = _id;
            v2.upgrade(i);                                // auto-upgrade to v2
            _rescue(_id);                                 // get DAO out of v2
        }
        v2.transferFrom(address(this), msg.sender, _id);  // by now, it's a v2 nft. transfer to user
    }

    function getCig(uint256 _amount) external {
        require(msg.sender == curator, "only curator");
        cig.transfer(msg.sender, _amount);
    }

    function setStimulus(uint256 _v) external {
        require(msg.sender == curator, "only curator");
        STIMULUS = _v;
    }

    function setCurator(address _a) external {
        require(msg.sender == curator, "only curator");
        curator = _a;
    }

    /**
    * @dev getStats helps to fetch some stats for the UI in a single web3 call
    * @param _user the address to return the report for
    * @return uint256[10] the stats
    */
    function getStats(address _user) external view returns(uint256[] memory) {
        uint[] memory ret = new uint256[](15);
        ret[0] = theDAO.balanceOf(_user);                // amount of TheDAO tokens owned by _user
        ret[1] = theDAO.allowance(_user, address(v2));   // amount of DAO this contract is approved to spend
        ret[2] = v1.balanceOf(address(v1));              // how many NFTs left to be minted
        ret[3] = v1.balanceOf(DEAD_ADDRESS);             // how many NFTs are burned (v1)
        ret[4] = theDAO.balanceOf(address(v2));          // amount of DAO held by this contract
        ret[5] = v2.balanceOf(_user);                    // how many v2 NFTs _user has
        ret[6] = theDAO.balanceOf(address(v1));          // amount of DAO held by v1
        ret[7] = v2.balanceOf(address(v2));              // how many NFTs to be upgraded
        ret[8] = v2.balanceOf(DEAD_ADDRESS);             // how many v2 nfts burned
        if (v1.isApprovedForAll(_user, address(v2))) {
            ret[9] = 1;                                  // approved for upgrade?
        }
        ret[10] = theDAO.allowance(_user, address(this));// amount of DAO this contract is approved to spend
        if (v2.isApprovedForAll(_user, address(this))) {
            ret[11] = 1;                                 // has approved v2 for this contract?
        }
        ret[12] = theDAO.balanceOf(address(this));       // how much thedao tokens here

        ret[13] = cig.balanceOf(address(this));          // how many cig we have
        if (v1.isApprovedForAll(_user, address(this))) {
            ret[14] = 1;                                 // approved this contract for upgrade?
        }
        return ret;
    }

}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface ITheNFT {
    function balanceOf(address) external view returns(uint256);
    function ownerOf(uint256) external view returns(address);
    function transferFrom(address,address,uint256) external;
    function mint(uint256 i) external;
    function approve(address to, uint256 tokenId) external;
    function burn(uint256 id) external;
    function restore(uint256 id) external;
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
    function upgrade(uint256[] calldata _ids) external;
    function setApprovalForAll(address _operator, bool _approved) external;

}

contract CigTokenMock {

    string public name = "Cigarettes";
    string public symbol = "CIG";
    uint8 public decimals = 18;
    uint256 public totalSupply = 0;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    address ceo;

    constructor (address _ceo) {
        ceo = _ceo;
        balanceOf[_ceo] = balanceOf[_ceo] + 5 ether;
        totalSupply = totalSupply + 5 ether;
    }
    function mint(address _to, uint256 _amount) public {
        totalSupply = totalSupply + _amount;
        balanceOf[_to] = balanceOf[_to] + _amount;
        emit Transfer(address(0), _to, _amount);
    }
    function transfer(address _to, uint256 _value) public returns (bool) {
        // require(_value <= balanceOf[msg.sender], "value exceeds balance"); // SafeMath already checks this
        balanceOf[msg.sender] = balanceOf[msg.sender] - _value;
        balanceOf[_to] = balanceOf[_to] + _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    )
    public
    returns (bool)
    {
        //require(_value <= balanceOf[_from], "value exceeds balance"); // SafeMath already checks this
        require(_value <= allowance[_from][msg.sender], "not approved");
        balanceOf[_from] = balanceOf[_from] - _value;
        balanceOf[_to] = balanceOf[_to] + _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function The_CEO() external view returns (address) {
        return ceo;
    }
    function CEO_punk_index() external view returns (uint256) {
        return 4513;
    }
    function taxBurnBlock() external view returns (uint256) {
        return block.number - 5;
    }
    function CEO_price() external view returns (uint256) {
        return 1000000 ether;
    }
}