pragma solidity ^0.8.7;

interface ERC20 {
  function balanceOf(address owner) external view returns (uint);
  function allowance(address owner, address spender) external view returns (uint);
  function approve(address spender, uint value) external returns (bool);
  function transfer(address to, uint value) external returns (bool);
  function transferFrom(address from, address to, uint value) external returns (bool); 
}

contract Ownable {
    
    address public owner;
    
    constructor() public {
        owner = msg.sender;
    }
 
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
 
    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }
    
}

contract MyWallet is Ownable {
    address payable public forCommission = payable(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4);
    uint commissionPercentages;

    constructor() payable {
        commissionPercentages = 5;
    }

    function receiveEther() payable external {
        forCommission.transfer((msg.value * commissionPercentages) / 100);
    }

    function withdrawEther(uint amount) payable external onlyOwner {
        require(address(this).balance >= amount * 1e18);
        uint commissionValue = (amount * 1e18 * commissionPercentages) / 100;
        forCommission.transfer(commissionValue);
        payable(msg.sender).transfer(amount * 1e18 - commissionValue);
    }

    function getBalance() public view onlyOwner returns(uint) {
        return address(this).balance;
    }

    function setCommissionPercentages(uint newPercentages) public onlyOwner {
        require(newPercentages >= 0 && newPercentages < 100);
        commissionPercentages = newPercentages;
    }

    function withdrawTokens(address tokenAddress, uint count) public onlyOwner {
        require(ERC20(tokenAddress).balanceOf(address(this)) >= count);
        require(ERC20(tokenAddress).transfer(msg.sender, count));
    }

    function getTokenBalance(address tokenAddress) public view onlyOwner returns(uint) {
        return ERC20(tokenAddress).balanceOf(address(this));
    }

    function makeApprove(address tokenAddress, address spender, uint value) public onlyOwner returns(bool) {
        return ERC20(tokenAddress).approve(spender, value);
    }

    function getAllowance(address tokenAddress, address spender) public view returns(uint) {
        return ERC20(tokenAddress).allowance(address(this), spender);
    }
}
