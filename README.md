# Token Swap

Swap Ether and ERC20 tokens on the Ethereum network. This is beta software so, please, use with caution. 

If you found this helpful then you can buy me a beer at 0xA459552915C85d079b2EC8e28024314a538f3fd3.

### Usage

1. The buyer calls `create` to begin the Swap.

```
TokenSwap.create(token, tokenAmount, price, seller, buyer, [recipient])
```

* `token` is the `address` of an ERC20-compatible token contract
* `tokenAmount` is the amount of tokens to be sold
* `price` is the total price, in Wei, to be paid for the tokens
* `seller` is the address of the token holder
* `buyer` is the address of the Ether holder (this address must send the payment to conclude the Swap)
* `recipient` is an optional argument specifying an address to receive the tokens; if no `recipient` is specified then `buyer` is used

2. The seller approves the TokenSwap contract to spend `tokenAmount` tokens, using the ERC20 `approve` function.
3. The buyer calls `conclude` with `price` Wei.

If the tokens have not been approved then the call will fail. If the tokens have been, and the value of the call is sufficient, the tokens will be sent to the recipient (or buyer, if none is specified) and the Ether to the seller.

An additional `cancel` function has also been provided. The `buyer`, `seller` and `recipient` are all able to cancel a Swap at any time before it is concluded. Any tokens that have been approved will be refunded.

### Development

1. Install `truffle` and `openzeppelin-solidity` by running `npm i`.
2. Compile the contracts using `truffle compile`.
3. Run the test by installing and launching [ganache](http://truffleframework.com/ganache/), then running `truffle test`.

### License

MIT © Luke Mitchell
