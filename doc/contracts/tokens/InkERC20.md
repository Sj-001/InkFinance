# InkERC20



> Implementation of the {IERC20} interface.

## 1.Contents
<!-- START doctoc -->
<!-- END doctoc -->

## 2.Globals

## 3.Modifiers

## 4.Functions

### init



*Declaration:*
```solidity
function init(
) public initializer
```
*Modifiers:*
| Modifier |
| --- |
| initializer |




### mintTo



*Declaration:*
```solidity
function mintTo(
) public
```




### name

> Returns the name of the token.

*Declaration:*
```solidity
function name(
) public returns
(string)
```




### symbol

> Returns the symbol of the token, usually a shorter version of the
name.

*Declaration:*
```solidity
function symbol(
) public returns
(string)
```




### decimals

> Returns the number of decimals used to get its user representation.
For example, if `decimals` equals `2`, a balance of `505` tokens should
be displayed to a user as `5.05` (`505 / 10 ** 2`).

Tokens usually opt for a value of 18, imitating the relationship between
Ether and Wei. This is the value {ERC20} uses, unless this function is
overridden;

NOTE: This information is only used for _display_ purposes: it in
no way affects any of the arithmetic of the contract, including
{IERC20-balanceOf} and {IERC20-transfer}.

*Declaration:*
```solidity
function decimals(
) public returns
(uint8)
```




### totalSupply

> See {IERC20-totalSupply}.

*Declaration:*
```solidity
function totalSupply(
) public returns
(uint256)
```




### balanceOf

> See {IERC20-balanceOf}.

*Declaration:*
```solidity
function balanceOf(
) public returns
(uint256)
```




### transfer

> See {IERC20-transfer}.

*Declaration:*
```solidity
function transfer(
) public returns
(bool)
```




### allowance

> See {IERC20-allowance}.

*Declaration:*
```solidity
function allowance(
) public returns
(uint256)
```




### approve

> See {IERC20-approve}.

*Declaration:*
```solidity
function approve(
) public returns
(bool)
```




### transferFrom

> See {IERC20-transferFrom}.

*Declaration:*
```solidity
function transferFrom(
) public returns
(bool)
```




### increaseAllowance

> Atomically increases the allowance granted to `spender` by the caller.

This is an alternative to {approve} that can be used as a mitigation for
problems described in {IERC20-approve}.

Emits an {Approval} event indicating the updated allowance.

Requirements:

- `spender` cannot be the zero address.

*Declaration:*
```solidity
function increaseAllowance(
) public returns
(bool)
```




### decreaseAllowance

> Atomically decreases the allowance granted to `spender` by the caller.

This is an alternative to {approve} that can be used as a mitigation for
problems described in {IERC20-approve}.

Emits an {Approval} event indicating the updated allowance.

Requirements:

- `spender` cannot be the zero address.
- `spender` must have allowance for the caller of at least
`subtractedValue`.

*Declaration:*
```solidity
function decreaseAllowance(
) public returns
(bool)
```




### _transfer

> Moves `amount` of tokens from `from` to `to`.

This internal function is equivalent to {transfer}, and can be used to
e.g. implement automatic token fees, slashing mechanisms, etc.

Emits a {Transfer} event.

Requirements:

- `from` cannot be the zero address.
- `to` cannot be the zero address.
- `from` must have a balance of at least `amount`.

*Declaration:*
```solidity
function _transfer(
) internal
```




### _mint

> Creates `amount` tokens and assigns them to `account`, increasing
the total supply.

Emits a {Transfer} event with `from` set to the zero address.

Requirements:

- `account` cannot be the zero address.

*Declaration:*
```solidity
function _mint(
) internal
```




### _burn

> Destroys `amount` tokens from `account`, reducing the
total supply.

Emits a {Transfer} event with `to` set to the zero address.

Requirements:

- `account` cannot be the zero address.
- `account` must have at least `amount` tokens.

*Declaration:*
```solidity
function _burn(
) internal
```




### _approve

> Sets `amount` as the allowance of `spender` over the `owner` s tokens.

This internal function is equivalent to `approve`, and can be used to
e.g. set automatic allowances for certain subsystems, etc.

Emits an {Approval} event.

Requirements:

- `owner` cannot be the zero address.
- `spender` cannot be the zero address.

*Declaration:*
```solidity
function _approve(
) internal
```




### _spendAllowance

> Updates `owner` s allowance for `spender` based on spent `amount`.

Does not update the allowance amount in case of infinite allowance.
Revert if not enough allowance is available.

Might emit an {Approval} event.

*Declaration:*
```solidity
function _spendAllowance(
) internal
```




### _beforeTokenTransfer

> Hook that is called before any transfer of tokens. This includes
minting and burning.

Calling conditions:

- when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
will be transferred to `to`.
- when `from` is zero, `amount` tokens will be minted for `to`.
- when `to` is zero, `amount` of ``from``'s tokens will be burned.
- `from` and `to` are never both zero.

To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].

*Declaration:*
```solidity
function _beforeTokenTransfer(
) internal
```




### _afterTokenTransfer

> Hook that is called after any transfer of tokens. This includes
minting and burning.

Calling conditions:

- when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
has been transferred to `to`.
- when `from` is zero, `amount` tokens have been minted for `to`.
- when `to` is zero, `amount` of ``from``'s tokens have been burned.
- `from` and `to` are never both zero.

To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].

*Declaration:*
```solidity
function _afterTokenTransfer(
) internal
```




## 5.Events
