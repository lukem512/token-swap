pragma solidity ^0.4.17;

// Exchange ERC20 tokens and Ether
// Luke Mitchell <hi@lukemitchell.co>
// Adapted from https://github.com/axic/ethereum-tokenescrow

// Usage:
// 1. call `create` to begin the swap
// 2. the seller approves the TokenSwap to spend the amount of tokens
// 3. the buyer transfers the required amount to ETH to release the tokens

contract IToken {
  function allowance(address _owner, address _spender) constant public returns (uint256 remaining);
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
}

contract TokenSwap {
  address owner;

  modifier owneronly {
    require (msg.sender == owner);
    _;
  }

  function setOwner(address _owner) public owneronly {
    owner = _owner;
  }

  function TokenSwap() public {
    owner = msg.sender;
  }

  struct Swap {
    address token;           // Address of the token contract
    uint tokenAmount;        // Number of tokens requested
    uint price;              // Price to be paid by buyer
    address seller;          // Seller's address (holder of tokens)
    address recipient;       // Address to receive the tokens
  }

  mapping (address => Swap) public Swaps;

  function create(address token, uint tokenAmount, uint price, address seller, address buyer, address recipient) public {
    Swaps[buyer] = Swap(token, tokenAmount, price, seller, recipient);
  }

  function create(address token, uint tokenAmount, uint price, address seller, address buyer) public {
     create(token, tokenAmount, price, seller, buyer, buyer);
  }

  // Incoming transfer from the buyer
  function conclude() public payable {
    Swap storage swap = Swaps[msg.sender];

    // Ensure the contract has been initialised
    // by calling `create`
    require(swap.token != 0);

    // Token interface
    IToken token = IToken(swap.token);

    // Has the seller approved the tokens?
    uint tokenAllowance = token.allowance(swap.seller, this);
    require(tokenAllowance >= swap.tokenAmount);

    // Ensure message value is above agreed price
    require(msg.value >= swap.price);

    // Transfer tokens to buyer
    token.transferFrom(swap.seller, swap.recipient, swap.tokenAmount);

    // Transfer money to seller
    swap.seller.transfer(swap.price);

    // Refund buyer if overpaid
    if (msg.value > swap.price) {
      msg.sender.transfer(msg.value - swap.price);
    }

    // Clean up storage
    delete Swaps[msg.sender];
  }

  function kill() public owneronly {
    selfdestruct(msg.sender);
  }
}
