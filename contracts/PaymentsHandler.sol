// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Address.sol";
import "./SafeMath.sol";
import "./AccessControl.sol";

/**
    @title PaymentsHandler

    @dev Handles payments for MonsterCock. Note can be used for other projects as-well.

    This contract is based off of OpenZeppelins PaymentsHandler. 
    See https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/finance/PaymentsHandler.sol
 */
contract PaymentsHandler is AccessControl {
    event PayeeAdded(address account, uint256 shares);
    event PaymentReleased(address to, uint256 amount);
    event PaymentReceived(address from, uint256 amount);

    uint256 private _totalShares;
    uint256 private _totalReleased;

    mapping(address => uint256) private _shares;
    mapping(address => uint256) private _released;
    mapping(address => uint256) private _indexes;

    address[] private _payees;

    constructor() {
        addPayee(owner(), 100);
    }

    /**
     * @dev The Ether received will be logged with {PaymentReceived} events. Note that these events are not fully
     * reliable: it's possible for a contract to receive Ether without triggering this function. This only affects the
     * reliability of the events, and not the actual splitting of Ether.
     *
     * To learn more about this see the Solidity documentation for
     * https://solidity.readthedocs.io/en/latest/contracts.html#fallback-function[fallback
     * functions].
     */
    receive() external payable virtual {
        emit PaymentReceived(_msgSender(), msg.value);
    }

    /**
     * @dev Getter for the total shares held by payees.
     */
    function totalShares() public view returns (uint256) {
        return _totalShares;
    }

    /**
     * @dev Getter for the total amount of Ether already released.
     */
    function totalReleased() public view returns (uint256) {
        return _totalReleased;
    }

    /**
     * @dev Getter for the amount of shares held by an account.
     */
    function shares(address account) public view returns (uint256) {
        return _shares[account];
    }

    /**
     * @dev Getter for the amount of Ether already released to a payee.
     */
    function released(address account) public view returns (uint256) {
        return _released[account];
    }

    /**
     * @dev Getter for the address of the payee number `index`.
     */
    function payee(uint256 index) public view returns (address) {
        return _payees[index];
    }

    /**
        @dev Getter for the index of address '_payee'.
     */
    function indexOfPayee(address _payee) public view returns (uint256) {
        return _indexes[_payee];
    }

    /**
     * @dev Triggers a transfer to `account` of the amount of Ether they are owed, according to their percentage of the
     * total shares and their previous withdrawals.
     */
    function withdraw(address payable account) public {
        require(_shares[account] > 0, "PaymentsHandler: account has no shares");

        uint256 totalReceived = address(this).balance + _totalReleased;
        uint256 payment = (totalReceived * _shares[account]) / _totalShares - _released[account];

        require(payment != 0, "PaymentsHandler: account is not due payment");

        _released[account] = _released[account] + payment;
        _totalReleased = _totalReleased + payment;

        Address.sendValue(account, payment);
        emit PaymentReleased(account, payment);
    }

    /**
     * @dev Add a new payee to the contract.
     * @param account The address of the payee to add.
     * @param shares_ The number of shares owned by the payee.
     */
    function addPayee(address account, uint256 shares_) public adminOrOwner {
        require(account != address(0), "PaymentsHandler: account is the zero address");
        require(shares_ > 0, "PaymentsHandler: shares are 0");
        require(_shares[account] == 0, "PaymentsHandler: account already has shares");

        _payees.push(account);
        _indexes[account] = _payees.length - 1;
        _shares[account] = shares_;
        _totalShares = _totalShares + shares_;
        emit PayeeAdded(account, shares_);
    }

    /**
        @dev Actualiza los shares_ de un payee.
        @param account The address of the payee to add.
        @param shares_ The number of shares owned by the payee.

        Procceso:
            1. Busca el current share
            2. Menos el share sobre ^
            3. Pon el nuevo share
            4. Menos el current share ^^^ a los _totalShares
            5. Mas los _totalShares con el nuevo shares
     */
    function updateSharForPayee(address account, uint256 shares_) public adminOrOwner {
        // Chequea que la cuenta ya exista como un payee
        uint256 index = _indexes[account];
        require(index != 0 && account != owner(), "PaymentsHandler: This accout does not exist.");

        // Cambia los _shares
        // 1.
        uint currentShare = _shares[account];
        // 2.
        _shares[account] -= currentShare; 
        // 3.
        _shares[account] += shares_;
        // 4.
        _totalShares -= currentShare;
        // 5.
        _totalShares += shares_;
    }
}