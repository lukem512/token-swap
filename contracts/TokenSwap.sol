pragma solidity ^0.4.17;

// Exchange ERC20 tokens and Ether
// Luke Mitchell <hi@lukemitchell.co>
// Adapted from https://github.com/axic/ethereum-tokenescrow

// Usage:
// 1. call `create` to begin the swap
// 2. the seller approves the TokenSwap contract to spend the amount of tokens
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
    // Ensure a Swap with the buyer does not exist already
    Swap storage swap = Swaps[buyer];
    require(swap.token == 0);

    // Add a new Swap to storage
    Swaps[buyer] = Swap(token, tokenAmount, price, seller, recipient);
  }

  function create(address token, uint tokenAmount, uint price, address seller, address buyer) public {
     create(token, tokenAmount, price, seller, buyer, buyer);
  }

  function conclude() public payable {
    // Ensure the Swap has been initialised
    // by calling `create`
    Swap storage swap = Swaps[msg.sender];
    require(swap.token != 0);

    // Has the seller approved the tokens?
    IToken token = IToken(swap.token);
    uint tokenAllowance = token.allowance(swap.seller, this);
    require(tokenAllowance >= swap.tokenAmount);

    // Ensure message value is above agreed price
    require(msg.value >= swap.price);

    // Transfer tokens to buyer
    token.transferFrom(swap.seller, swap.recipient, swap.tokenAmount);

    // Transfer money to seller
    swap.seller.transfer(swap.price);

    // Refund seller if overpaid
    // This is done by spending the remaining allowance
    // by sending the seller some of their own tokens
    if (tokenAllowance > swap.tokenAmount) {
      token.transferFrom(swap.seller, swap.seller, tokenAllowance - swap.tokenAmount);
    }

    // Refund buyer if overpaid
    if (msg.value > swap.price) {
      msg.sender.transfer(msg.value - swap.price);
    }

    // Clean up storage
    delete Swaps[msg.sender];
  }

  function cancel(address buyer) public {
    // Ensure the Swap exists
    Swap storage swap = Swaps[buyer];
    require(swap.token != 0);

    // Ensure the sender is authorised to cancel
    require(
      msg.sender == buyer ||
      msg.sender == swap.seller ||
      msg.sender == swap.recipient ||
      msg.sender == owner);

    // Refund any tokens that have been authorised
    IToken token = IToken(swap.token);
    uint tokenAllowance = token.allowance(swap.seller, this);
    if (tokenAllowance > 0) {
      token.transferFrom(swap.seller, swap.seller, tokenAllowance);
    }

    // Delete the swap
    delete Swaps[buyer];
  }

  function kill() public owneronly {
    selfdestruct(msg.sender);
  }
}
