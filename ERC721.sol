pragma solidity >=0.4.20 <=0.5.6;

interface ERC721 /* is ERC165 */ {
   
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    function balanceOf(address _owner) public view returns (uint256);
    function ownerOf(uint256 _tokenId) public view returns (address);
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes data) public;
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) public;
    function transferFrom(address _from, address _to, uint256 _tokenId) public;
    function approve(address _approved, uint256 _tokenId) public;
    function setApprovalForAll(address _operator, bool _approved) public;
    function getApproved(uint256 _tokenId) public view returns (address);
    function isApprovedForAll(address _owner, address _operator) public view returns (bool);
}

interface ERC721TokenReceiver {
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes _data) public returns(bytes4);
}


contract ERC721Implementation is ERC721 {
    mapping (uint256 => address) tokenOwner;
    mapping (address => uint256) ownedTokensCount;

    function mint(address _to, uint _tokenId) public {
        tokenOwner[_tokenId] = _to;
        ownedTokensCount[_to] += 1;
    }

    function balanceOf(address _owner) public view returns (uint256){
        return ownedTokensCount[_owner];
    }

    function ownerOf(uint256 _tokenId) public view returns (address){
        return tokenOwner[_tokenId];
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) public {
        address owner = ownerOf(_tokenId);
        require(msg.sender == owner);
        require(_from != address(0));
        require(_to != address(0));

        ownedTokensCount[_from] -= 1;
        tokenOwner[_tokenId] = address(0);

        ownedTokensCount[_to] += 1;
        tokenOwner[_tokenId] = _to;
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) public{
        transferFrom(_from, _to, _tokenId);

        if(isContract(_to)){
            bytes4 returnValue = ERC721TokenReceiver(_to).onERC721Received(msg.sender, _from, _tokenId, '');
            require(returnValue == 0x150b7a02);
        }
    }

    function isContract(address _addr) private view returns(bool){
        uint256 size;
        assembly {size := extcodesize(_addr)}
        return size > 0;
    }
}

contract Auction is ERC721TokenReceiver{
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes _data) public returns(bytes4){
        return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
    }
}
