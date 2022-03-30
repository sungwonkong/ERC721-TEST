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
    function approve(address _approved, uint256 _tokenId) public;               //토큰 아이디마다 권한 부여
    function setApprovalForAll(address _operator, bool _approved) public;       //계정에 소유한 모두 토큰들을 모두 권한 부여
    function getApproved(uint256 _tokenId) public view returns (address);
    //function isApprovedForAll(address _owner, address _operator) public view returns (bool);
}

interface ERC721TokenReceiver {
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes _data) public returns(bytes4);
}

interface ERC165 {    
    function supportsInterface(bytes4 interfaceID) public view returns (bool);
}

contract ERC721Implementation is ERC721 {
    mapping (uint256 => address) tokenOwner;
    mapping (address => uint256) ownedTokensCount;
    mapping (uint256 => address) tokenApprovals;
    mapping (address => mapping(address => bool)) operatorApprovals;
    mapping (bytes4 => bool) supportedInterfaces;

    constructor() public {
        supportedInterfaces[0x80ac58cd] = true;
    }

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
        require(msg.sender == owner || getApproved(_tokenId) == msg.sender || isApprovedForAll(owner, msg.sender));
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

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes data) public{
        transferFrom(_from, _to, _tokenId);

        if(isContract(_to)){
            bytes4 returnValue = ERC721TokenReceiver(_to).onERC721Received(msg.sender, _from, _tokenId, data);
            require(returnValue == 0x150b7a02);
        }
    }

    function approve(address _approved, uint256 _tokenId) public{
        address owner = ownerOf(_tokenId);
        require(_approved != owner);
        require(msg.sender == owner);
        tokenApprovals[_tokenId] = _approved;
    }

    function getApproved(uint256 _tokenId) public view returns (address){
        return tokenApprovals[_tokenId];        
    }

    function setApprovalForAll(address _operator, bool _approved) public {
        require(_operator != msg.sender);
        operatorApprovals[msg.sender][_operator] = _approved;
    }

    function isApprovedForAll(address _owner, address _operator) public view returns (bool){
        //토큰소유자가 오퍼레이터에게 권한을 부여했느지 안했는지 체크
        return operatorApprovals[_owner][_operator];
    }

    function supportsInterface(bytes4 interfaceID) public view returns (bool){
        return supportedInterfaces[interfaceID];
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

    function checkSupportsInterface(address _to, bytes4 interfaceID) public view returns (bool){
        return ERC721Implementation(_to).supportsInterface(interfaceID);
    }
}

