// SPDX-License-Identifier: MIT
// SYS 64738

pragma solidity ^0.8.23;

/*
  ::::::::::: :::    ::: :::::::::: ::::    ::: :::::::::: :::::::::::
     :+:     :+:    :+: :+:        :+:+:   :+: :+:            :+:
    +:+     +:+    +:+ +:+        :+:+:+  +:+ +:+            +:+
   +#+     +#++:++#++ +#++:++#   +#+ +:+ +#+ :#::+::#       +#+
  +#+     +#+    +#+ +#+        +#+  +#+#+# +#+            +#+
 #+#     #+#    #+# #+#        #+#   #+#+# #+#            #+#
###     ###    ### ########## ###    #### ###            ###

TheNFTv3 - TheDAO NFT
thedaonft.eth
https://github.com/0xTycoon/thedao-nft

On the 25th of July, 2017, The Securities and Exchange Commission (SEC)
released an 18 page report about their investigation in to TheDAO.
The report concluded that TheDAO tokens are securities.

The following project converts each page in to an image, then shreds the images
into strips. These strips can be then minted into NFTs

RULES

1. Each NFT requires 1 DAO token to be minted
2. The DAO token will be wrapped inside the NFT
3. The DAO token can be unwrapped
4. When unwrapped, the NFT gets transferred to the "Dead Address"
5. The NFT can be restored from the "Dead Address" with 4 DAO restoration fee
6. the restoration fee goes to the Curator

### Digital Assets

The images are prepared with the help of a script, see script.php for the source.
The input for the script is TheDAO-SEC-34-81207.pdf with the sha256-hash of:
6c9ae041b9b9603da01d0aa4d912586c8d85b9fe1932c57f988d8bd0f9da3bc7

After the script completes creating all the tiles, the following sha256-hash will be printed:
final hash: 3ed52e4afc9030f69004f163017c3ffba0b837d90061437328af87330dee9575

### Minting

Minting is done sequentially from 0 to 1799
Up to 100 NFTs can be minted per transaction at a time (if gas allows)

At the beginning, all tokens are owned by 0x0
balanceOf(address(this)) is used to track how many tokens are yet to be minted

* Tokens cannot be sent to address(this)
* Tokens cannot be sent to 0x0

### Version 2

This upgrade fixes a bug with approvals, which was found & disclosed by @alphasoups

An upgrade method is provided
When minting, we will still use the old contract to mint,
As soon as it's minted, the NFT gets upgraded.

### Version 3

The curse of TheDAO strikes again :-(
This version fixes yet another bug with approvals.
A blackhat hacker discovered that the burn function didn't clear the approval
after transfer to the burn address, and drained all DAO tokens from both
contracts.

The hack has been tested to be fixed in the explot.js test.

This version also fixes indexing, and adds a new upgradeAndBurn function.

*/

import "./TheNFT.sol";
//import "./safemath.sol"; // we don't need it
//import "hardhat/console.sol";

contract TheNFTV3 {
    ITheNFT v1;                                              // points to v1 of TheNFT
    ITheNFT v2;                                              // points to v2 of TheNFT
    /**
    * @dev PNG_SHA_256_HASH is a sha256 hash-sum of all 1800 bitmap tiles saved in the PNG format
    * (the final hash)
    */
    string public constant PNG_SHA_256_HASH = "3ed52e4afc9030f69004f163017c3ffba0b837d90061437328af87330dee9575";
    /**
    * @dev PDF_SHA_256_HASH is a sha256 hash-sum of the pdf file TheDAO-SEC-34-81207.pdf
    */
    string public constant PDF_SHA_256_HASH = "6c9ae041b9b9603da01d0aa4d912586c8d85b9fe1932c57f988d8bd0f9da3bc7";
    address private constant DEAD_ADDRESS = address(0x74eda0); // unwrapped NFTs go here
    address private constant LOCK_ADDRESS = address(0x10ced);  // locked NFTs go here
    address public curator;                                    // the curator receives restoration fees
    string private assetURL;
    string private baseURI;
    uint256 private immutable max;                             // total supply (1800)
    uint256 private constant fee = 4;                          // fee is the amount of DAO needed to restore

    // TheDAO stuff
    IERC20 private immutable theDAO;                           // the contract of TheDAO, the greatest DAO of all time
    uint256 private constant oneDao = 1e16;                    // 1 DAO = 16^10 wei or 0.01 ETH

    mapping(address => uint256) private balances;              // counts of ownership
    mapping(uint256  => address) private ownership;
    mapping(uint256  => address) private approval;
    mapping(address => mapping(address => bool)) private approvalAll; // operator approvals

    /**
     * Mint is fired when a new token is minted
     */
    event Mint(address owner, uint256 tokenId);
    /**
     * @dev Burn is fired when a token is burned
     */
    event Burn(address owner, uint256 tokenId);
    /**
     * @dev Restore is fired when a token is restored from the burn
     */
    event Restore(address owner, uint256 tokenId);
    /**
     * @dev Upgrade is fired when a token is upgraded
     */
    event Upgrade(address owner, uint256 tokenId);
    /**
     * @dev OwnershipTransferred is fired when a curator is changed
     */
    event OwnershipTransferred(address previousOwner, address newOwner);
    /**
     * @dev BaseURI is fired when the baseURI changed (set by the Curator)
     */
    event BaseURI(string);
    /**
    * @dev TheNFT constructor
    * @param _theDAO address of TheDAO contract
    * @param _max max supply of the NFT collection
    * @param _v1 address of old version
    */
    constructor(
        address _theDAO, // 0xBB9bc244D798123fDe783fCc1C72d3Bb8C189413
        uint256 _max,    // 1800
        address _v1,     // 0x266830230bf10A58cA64B7347499FD361a011a02
        address _v2      // 0x79a7D3559D73EA032120A69E59223d4375DEb595
    ) {
        curator = msg.sender;
        theDAO = IERC20(_theDAO);
        v1 = ITheNFT(_v1);
        v2 = ITheNFT(_v2);
        max = _max;
        /* We will use v1 to mint */
        balances[address(this)] = max;          // track how many haven't been upgraded
        theDAO.approve(_v1, type(uint256).max); // allow v1 to spend our DAO
    }

    modifier onlyCurator {
        require(
            msg.sender == curator,
            "only curator can call this"
        );
        _;
    }

    /**
    * @dev regulators are not needed - smart contracts regulate themselves
    */
    modifier regulated(address _to) {
        require(
            _to != DEAD_ADDRESS,
            "cannot send to dead address"
        );
        require(
            _to != address(this),
            "cannot send to self"
        );
        require(
            _to != address(0),
            "cannot send to 0x"
        );
        _;
    }

    /**
    * @dev getStats helps to fetch some stats for the UI in a single web3 call
    * @param _user the address to return the report for
    * @return uint256[10] the stats
    */
    function getStats(address _user) external view returns(uint256[] memory) {
        uint[] memory ret = new uint[](13);
        ret[0] = theDAO.balanceOf(_user);                  // amount of TheDAO tokens owned by _user
        ret[1] = theDAO.allowance(_user, address(this));   // amount of DAO this contract is approved to spend
        ret[2] = v1.balanceOf(address(v1));                // how many NFTs to be minted
        ret[3] = v1.balanceOf(DEAD_ADDRESS);               // how many NFTs are burned (v1)
        ret[4] = theDAO.balanceOf(address(this));          // amount of DAO held by this contract
        ret[5] = balanceOf(_user);                         // how many _user has
        ret[6] = theDAO.balanceOf(address(v1));            // amount of DAO held by v1
        ret[7] = balanceOf(address(this));                 // how many NFTs to be upgraded
        ret[8] = balanceOf(DEAD_ADDRESS);                  // how many v2 nfts burned
        if (v1.isApprovedForAll(_user, address(this))) {
            ret[9] = 1;                                    // approved for upgrade? v1 => v3
        }
        ret[10] = v2.balanceOf(address(v2));
        ret[11] = v2.balanceOf(DEAD_ADDRESS);
        if (v2.isApprovedForAll(_user, address(this))) {
            ret[12] = 1;                                    // approved for upgrade v2 => v3?
        }
        return ret;
    }

    /**
    * We assume that nobody will upgrade a NFT that has been restored, since
    * it costs someone x4 to restore.
    */
    function upgrade(address _old, uint256[] calldata _ids) external {
        ITheNFT old = ITheNFT(_old);
        require (_old == address(v1) || _old == address(v2), "unknown address");
        _upgrade(old, _ids);
    }

    function upgradeAndBurn(address _old, uint256[] calldata _ids) external {
        ITheNFT old = ITheNFT(_old);
        require (_old == address(v1) || _old == address(v2), "unknown address");
        if (_upgrade(old, _ids)) {
            for (uint256 i; i < _ids.length; i++) {
                _burn(_ids[i], msg.sender);
            }
        }
    }

    function _upgrade(ITheNFT _old, uint256[] calldata _ids) internal returns (bool) {
        for (uint256 i; i < _ids.length; i++) {
            uint256 id = _ids[i];
            /*
             * The owner must be caller, and the NFT id must not exist in this contract
             * (the only way for NFTs to exist in this contract is to go through an upgrade, minting from 0x0 address)
             * it's assumed the nft will never be owned by 0x0 unless it wasn't minted yet
             */
            require ((_old.ownerOf(id) == msg.sender && ownership[id] == address(0)), "not upgradable id");
            _old.transferFrom(msg.sender, address(this), id); // transfer to here
            //old.burn(_ids[i]);                                  // won't work after TheDAO tokens been drained
            _mint(id);                                       // issue new nft
        }
        return true;
    }

    function _mint(uint256 _id) internal {
        _transfer(address(this), msg.sender, _id);       // issue new nft
        emit Mint(msg.sender, _id);
    }

    /**
    * @dev mint mints a token. Requires 1 DAO per NFT to mint
    */
    function mint(uint256 _i) external {
        uint256 id = max - v1.balanceOf(address(v1));                   // id is the next assigned id
        require(id < max, "minting finished");
        require (_i > 0 && _i <= 100, "must be between 1 and 100");
        if (_i + id > max) {                                            // if it goes over the max supply
            _i = max -  id;                                             // cap it
        }
        require(
            theDAO.transferFrom(msg.sender, address(this), oneDao* _i) == true,
            "DAO tokens required"
        );
        v1.mint(_i);
        while (_i > 0) {
            v1.burn(id);                                                // take DAO token out
            _mint(id);
            _i--;
            id++;
        }
    }

    /**
    * @dev burn gives 1 DAO back to the owner
    */
    function burn(uint256 _id) external {
        require (msg.sender == ownership[_id], "only owner can burn");
        _burn(_id, msg.sender);
    }

    function _burn(uint256 _id, address _burnee) internal {
        if (theDAO.transfer(_burnee, oneDao)) {   // send theDAO token back to sender
            approval[_id] = address(0);           // clear previous approval
            _transfer(_burnee, DEAD_ADDRESS, _id);// burn the NFT token
            emit Burn(_burnee, _id);
        }
    }

    /**
    * @dev To restore, there will be a 4 DAO fee, so 5 DAO in total to restore
    */
    function restore(uint256 _id) external {
        require(DEAD_ADDRESS == ownership[_id], "must be dead");
        require(theDAO.transferFrom(msg.sender, address(this), oneDao), "DAO deposit insufficient");
        require(theDAO.transferFrom(msg.sender, curator, oneDao*fee), "DAO fee insufficient"); // Fee goes to the curator
        _transfer(DEAD_ADDRESS, msg.sender, _id); // send the NFT token to the new owner
        emit Restore(msg.sender, _id);
    }

    /**
    * @dev NFTs can be locked, and only unlocked if there is enough DAO tokens
    *   in this contract.
    */
    function lock(uint256[] calldata _ids) external {
        for (uint256 i; i < _ids.length; i++) {
            uint256 id = _ids[i];
            require (msg.sender == ownership[id], "only owner can lock");
            approval[id] = address(0);              // clear previous approval
            _transfer(msg.sender, LOCK_ADDRESS, id);// burn the NFT token
        }
    }

    /**
    * @dev NFTs can be unlocked if there is enough DAO tokens
    *   in this contract.
    */
    function unlock(uint256[] calldata _ids) external {
        unchecked {
            require(
                theDAO.balanceOf(address(this)) >= max - balanceOf(DEAD_ADDRESS),
                "cannot unlock"
            );
            uint256 id;
            for (uint256 i; i < _ids.length; i++) {
                id = _ids[i];
                require (LOCK_ADDRESS == ownership[id], "not locked");
                _transfer(LOCK_ADDRESS, msg.sender, id);
            }
        }


    }
    /**
    * @dev setCurator sets the curator address
    */
    function setCurator(address _curator) external onlyCurator {
        _transferOwnership(_curator);
    }

    /**
    * owner is part of the Ownable interface
    */
    function owner() external view returns (address) {
        return curator;
    }
    /**
    * renounceOwnership is part of the Ownable interface
    */
    function renounceOwnership() external  {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address _newOwner) internal virtual {
        address oldOwner = curator;
        curator = _newOwner;
        emit OwnershipTransferred(oldOwner, _newOwner);
    }

    /**
    * @dev setBaseURI sets the baseURI value
    */
    function setBaseURI(string memory _uri) external onlyCurator {
        baseURI = _uri;
        emit BaseURI(_uri);
    }

    /***
    * ERC721 stuff
    */

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Approval is fired when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev ApprovalForAll is fired when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /// @notice Count NFTs tracked by this contract
    /// @return A count of valid NFTs tracked by this contract, where each one of
    ///  them has an assigned and queryable owner not equal to the zero address
    function totalSupply() external view returns (uint256) {
        return max;
    }

    /// @notice Enumerate valid NFTs
    /// @dev Throws if `_index` >= `totalSupply()`.
    /// @param _index A counter less than `totalSupply()`
    /// @return The token identifier for the `_index`th NFT,
    ///  (sort order not specified)
    function tokenByIndex(uint256 _index) external view returns (uint256) {
        require (_index < max, "index out of range");
        return _index;
    }

    /// @notice Enumerate NFTs assigned to an owner
    /// @dev Throws if `_index` >= `balanceOf(_owner)` or if
    ///  `_owner` is the zero address, representing invalid NFTs.
    /// @param _owner An address where we are interested in NFTs owned by them
    /// @param _index A counter less than `balanceOf(_owner)`
    /// @return The token identifier for the `_index`th NFT assigned to `_owner`,
    ///   (sort order not specified)
    function tokenOfOwnerByIndex(address  _owner , uint256 _index) external view returns (uint256) {
        require(_index < balances[_owner], "index out of range");
        require(_owner != address(0), "invalid _owner");
        uint256 id = ownedList[_owner][_index];
        require(ownership[id] != address(0), "token at _index not found");
        return id;
    }

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address _holder) public view returns (uint256) {
        require (_holder != address(0));
        return balances[_holder];
    }

    function name() public pure returns (string memory) {
        return "TheDAO SEC Report NFT";
    }

    function symbol() public pure returns (string memory) {
        return "TheNFTv3";
    }

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 _tokenId) public view returns (string memory) {
        require (_tokenId < max, "index out of range");
        string memory _baseURI = baseURI;
        uint256 num = _tokenId % 100;
        return bytes(_baseURI).length > 0
            ? string(abi.encodePacked(_baseURI, toString(_tokenId/100), "/", toString(num), ".json"))
            : '';
    }

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 _tokenId) public view returns (address) {
        require (_tokenId < max, "index out of range");
        address holder = ownership[_tokenId];
        require (holder != address(0), "not minted.");
        return holder;
    }

    /**
    * @dev Throws unless `msg.sender` is the current owner, an authorized
    *  operator, or the approved address for this NFT. Throws if `_from` is
    *  not the current owner. Throws if `_to` is the zero address. Throws if
    *  `_tokenId` is not a valid NFT.
    * @param _from The current owner of the NFT
    * @param _to The new owner
    * @param _tokenId The NFT to transfer
    */
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory _data) external regulated(_to) {
        _validateTransfer(_tokenId, _from);
        _transfer(_from, _to, _tokenId);
        require(_checkOnERC721Received(_from, _to, _tokenId, _data), "Cannot transfer to an ERC721r");
    }

    /**
    * @dev Throws unless `msg.sender` is the current owner, an authorized
    *  operator, or the approved address for this NFT. Throws if `_from` is
    *  not the current owner. Throws if `_to` is the zero address. Throws if
    *  `_tokenId` is not a valid NFT.
    * @param _from The current owner of the NFT
    * @param _to The new owner
    * @param _tokenId The NFT to transfer
    */
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external regulated(_to) {
        _validateTransfer(_tokenId, _from);
        _transfer(_from, _to, _tokenId);
        require(_checkOnERC721Received(_from, _to, _tokenId, ""), "Cannot transfer to an ERC721");
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) external regulated(_to) {
        _validateTransfer(_tokenId, _from);
        _transfer(_from, _to, _tokenId);
    }

    function _validateTransfer(uint256 _tokenId, address _from) internal {
        require (_tokenId < max, "index out of range");
        address o = ownership[_tokenId];
        require (o == _from, "_from must be owner");
        address a = approval[_tokenId];
        require (o == msg.sender || (a == msg.sender) || (approvalAll[o][msg.sender]), "not permitted");
        if (a != address(0)) {
            approval[_tokenId] = address(0); // clear previous approval
            emit Approval(msg.sender, address(0), _tokenId);
        }
    }

    /**
    * @notice Change or reaffirm the approved address for an NFT
    * @dev The zero address indicates there is no approved address.
    *  Throws unless `msg.sender` is the current NFT owner, or an authorized
    *  operator of the current owner.
    * @param _to The new approved NFT controller
    * @param _tokenId The NFT to approve
    */
    function approve(address _to, uint256 _tokenId) external {
        require (_tokenId < max, "index out of range");
        address o = ownership[_tokenId];
        require (o == msg.sender || isApprovedForAll(o, msg.sender), "action not token permitted");
        approval[_tokenId] = _to;
        emit Approval(msg.sender, _to, _tokenId);
    }
    /**
    * @notice Enable or disable approval for a third party ("operator") to manage
    *  all of `msg.sender`'s assets
    * @dev Emits the ApprovalForAll event. The contract MUST allow
    *  multiple operators per owner.
    * @param _operator Address to add to the set of authorized operators
    * @param _approved True if the operator is approved, false to revoke approval
    */
    function setApprovalForAll(address _operator, bool _approved) external {
        require(msg.sender != _operator, "ERC721: approve to caller");
        approvalAll[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    /**
    * @notice Get the approved address for a single NFT
    * @dev Throws if `_tokenId` is not a valid NFT.
    * @param _tokenId The NFT to find the approved address for
    * @return The approved address for this NFT, or the zero address if there is none
    */
    function getApproved(uint256 _tokenId) public view returns (address) {
        require (_tokenId < max, "index out of range");
        return approval[_tokenId];
    }

    /**
    * @notice Query if an address is an authorized operator for another address
    * @param _owner The address that owns the NFTs
    * @param _operator The address that acts on behalf of the owner
    * @return True if `_operator` is an approved operator for `_owner`, false otherwise
    */
    function isApprovedForAll(address _owner, address _operator) public view returns (bool) {
        return approvalAll[_owner][_operator];
    }

    /**
    * @notice Query if a contract implements an interface
    * @param interfaceId The interface identifier, as specified in ERC-165
    * @dev Interface identification is specified in ERC-165. This function
    *  uses less than 30,000 gas.
    * @return `true` if the contract implements `interfaceID` and
    *  `interfaceID` is not 0xffffffff, `false` otherwise
    */
    function supportsInterface(bytes4 interfaceId) public pure returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            interfaceId == type(IERC165).interfaceId ||
            interfaceId == type(IERC721Enumerable).interfaceId ||
            interfaceId == type(IERC721TokenReceiver).interfaceId;
    }

    /**
    * @dev transfer a token from _from to _to
    * @param _from from
    * @param _to to
    * @param _tokenId the token index
    */
    function _transfer(address _from, address _to, uint256 _tokenId) internal {
        if (_from != address(0)) { // not mint?
            _removeEnumeration(_from, _tokenId);
        }
        unchecked{balances[_to]++;}
        balances[_from]--;
        ownership[_tokenId] = _to;
        _addEnumeration(_to, _tokenId);
        emit Transfer(_from, _to, _tokenId);
    }

    // we do not allow NFTs to be send to this contract
    function onERC721Received(address /*_operator*/, address /*_from*/, uint256 /*_tokenId*/, bytes memory /*_data*/) external pure returns (bytes4) {
        revert("nope");
    }

    mapping(address => mapping(uint256 => uint256)) private ownedList;// track enumeration
    mapping(uint256 => uint64) private index;                         // sequential index in the wallet

    /**
   * @dev called after an erc721 token transfer, after the counts have been updated
    */
    function _addEnumeration(address _to, uint256 _tokenId) internal {
        uint256 last;
        unchecked {
            last = balances[_to] - 1;  // the index of the last position
        }
        ownedList[_to][last] = _tokenId;   // add a new entry
        index[_tokenId] = uint64(last);
    }


    function _removeEnumeration(address _from, uint256 _tokenId) internal {
        uint256 height;
        unchecked {
            height = balances[_from] - 1; // last index
        }
        uint256 i = index[_tokenId];          // index
        if (i != height) {
            // If not last, move the last token to the slot of the token to be deleted
            uint256 lastTokenId = ownedList[_from][height];
            ownedList[_from][i] = lastTokenId;// move the last token to the slot of the to-delete token
            index[lastTokenId] = uint64(i);   // update the moved token's index
        }
        index[_tokenId] = 0;                  // delete from index
        delete ownedList[_from][height];      // delete last slot
    }

    /**
    * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
    * The call is not executed if the target address is not a contract.
    *
    * @param from address representing the previous owner of the given token ID
    * @param to target address that will receive the tokens
    * @param tokenId uint256 ID of the token to be transferred
    * @param _data bytes optional data to send along with the call
    * @return bool whether the call correctly returned the expected magic value
    *
    * credits https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol
    */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (isContract(to)) {
            try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("Cannot transfer to an ERC721");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
            return false; // not needed, but the ide complains that there's "no return statement"
        } else {
            return true;
        }
    }

    /**
     * @dev Returns true if `account` is a contract.
     *
     * credits https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol
     */
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function toString(uint256 value) public pure returns (string memory) {
        // Inspired by openzeppelin's implementation - MIT licence
        // https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Strings.sol#L15
        // this version removes the decimals counting

        uint8 count;
        if (value == 0) {
            return "0";
        }
        uint256 digits = 31;
        // bytes and strings are big endian, so working on the buffer from right to left
        // this means we won't need to reverse the string later
        bytes memory buffer = new bytes(32);
        unchecked {
            while (value != 0) {
                buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
                value /= 10;
                digits -= 1;
                count++;
            }
        }
        uint256 temp;
        assembly {
            temp := mload(add(buffer, 32))
            temp := shl(mul(sub(32,count),8), temp)
            mstore(add(buffer, 32), temp)
            mstore(buffer, count)
        }
        return string(buffer);
    }
}

interface ITheNFT {
    function balanceOf(address) external view returns(uint256);
    function ownerOf(uint256) external view returns(address);
    function transferFrom(address,address,uint256) external;
    function isApprovedForAll(address, address) external view returns(bool) ;
    function burn(uint256) external;
    function mint(uint256) external;
}
