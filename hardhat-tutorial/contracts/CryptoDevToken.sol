//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ICryptoDevs.sol";

contract CryptoDevToken is ERC20, Ownable{
    
    ICryptoDevs CryptoDevsNFT;
    uint256 public constant tokensPerNFT = 10*10**18;
    //because it is a big number
    uint256 public constant tokenPrice= 0.001 ether;
    uint256 public constant maxTotalSupply = 10000*10**18; //because totalSupply() returns a big number

    mapping(uint256 =>bool) public tokenIdsClaimed;
    constructor(address _cryptoDevsContract) ERC20("Crypto Dev Token", "CD"){
        CryptoDevsNFT = ICryptoDevs(_cryptoDevsContract);

    }

    function claim() public{
        address sender = msg.sender;
        uint256 balance= CryptoDevsNFT.balanceOf(sender);
        require(balance>0, "You don't any CryptoDevs NFTs");
        uint256 amount =0;
        for(uint256 i = 0;i<balance;i++){
            uint256 tokenId= CryptoDevsNFT.tokenOfOwnerByIndex(sender, i);
            if(!tokenIdsClaimed[tokenId]){
                amount+=1;
                tokenIdsClaimed[tokenId] = true;
            }
        }
        require(amount>0, "You have already claimed all your tokens");
        _mint(msg.sender, amount*tokensPerNFT);
    }


    function mint(uint256 amount) public payable{
        uint256 _requiredAmount = tokenPrice * amount;
        require(msg.value>=_requiredAmount, "Ether sent is incorrect. Aur bhej bc");
        uint256 amountWithDecimals = amount * 10 **18;
        require(totalSupply()+amountWithDecimals<=maxTotalSupply, "Exceeds the max total supply available"); 
        _mint(msg.sender, amountWithDecimals);
    }

    receive() external payable{} //when there is no sent data (msg.data is empty)
    fallback() external payable{} // this happens when there is some data sent
    //notice how we didn't have to use a semicolon in these two statements



}