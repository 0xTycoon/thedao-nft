// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

import "./safemath.sol";
import "./TheNFT.sol";

// PoolTokenMock is a mock contract for testing
contract TheDAOMock {
    using SafeMath for uint256;
    string public name = "TheDAO";
    string public symbol = "D";
    uint8 public decimals = 16;
    uint256 public totalSupply = 0;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor(address _addr) {
        balanceOf[_addr] = balanceOf[_addr].add(200 ether); // give 20000 DAO to _addr
        totalSupply = totalSupply.add(5 ether);
    }

    function mint(address _to, uint256 _amount) public {
        totalSupply = totalSupply.add(_amount);
        balanceOf[_to] = balanceOf[_to].add(_amount);
        emit Transfer(address(0), _to, _amount);
    }

    /**
* @dev transfer token for a specified address
* @param _to The address to transfer to.
* @param _value The amount to be transferred.
*/
    function transfer(address _to, uint256 _value) public returns (bool) {
        // require(_value <= balanceOf[msg.sender], "value exceeds balance"); // SafeMath already checks this
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }


    /**
    * @dev Transfer tokens from one address to another
    * @param _from address The address which you want to send tokens from
    * @param _to address The address which you want to transfer to
    * @param _value uint256 the amount of tokens to be transferred
    */
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
        balanceOf[_from] = balanceOf[_from].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }


    /**
    * @dev Approve tokens of mount _value to be spent by _spender
    * @param _spender address The spender
    * @param _value the stipend to spend
    */
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    IERC721 private nft;

    // fot testing only
    function setNFT(address _nft) public {
        nft = IERC721(_nft);
    }

    function testTransferFrom(address _from, address _to, uint256 _tokenId) public {
        nft.transferFrom(_from, _to, _tokenId);
    }

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