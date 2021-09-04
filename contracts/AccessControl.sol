// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Context.sol";

/**
    @title AccessControl

    @dev El accesso para MonterCock y sus contracts.

    Note insperacion viene por {KittyAccess} y el {AccessControl} de OpenZeppelin 
 */
abstract contract AccessControl is Context {
    address private _owner;

    // Here are the roleTypes
    // Note the 0 role should not be used!!!
    // The reason being because el userToRole map defaults to 0.
    // 1: Admin
    // 2: Populaters
    // 3: GeneScience coders
    // 4: Fee handlers
    // 5: BreedingRights

    mapping(address => uint256) private userToRole;

    // Empty constructor
    constructor() {
        _setOwner(_msgSender());
    }

    /* Modifiers */
    modifier adminOrOwner() {
        require(
            _msgSender() == _owner || userToRole[_msgSender()] == 1,
            "AccessControl: Must be owner or admin to call."
        );
        _;
    }

    modifier onlyOwner() {
        require(_msgSender() == _owner, "AccessControl: Address is not owner.");
        _;
    }

    /// @dev Tambien puede ser owner.
    modifier adminOrRole(uint256 role) {
        require(
            userToRole[_msgSender()] == role ||
                userToRole[_msgSender()] == 1 ||
                _msgSender() == _owner,
            string(
                abi.encodePacked(
                    "AccessControl: Must be admin or of role ",
                    role
                )
            )
        );
        _;
    }

    modifier roleOrOwner(uint256 role) {
        require(
            userToRole[_msgSender()] == role || _msgSender() == _owner,
            string(
                abi.encodePacked(
                    "AccessControl: Must be owner or of role ",
                    role
                )
            )
        );
        _;
    }

    modifier onlyRole(uint256 role) {
        require(
            userToRole[_msgSender()] == role,
            string(
                abi.encodePacked(
                    "AccessControl: Must be owner or of role ",
                    role
                )
            )
        );
        _;
    }

    function stopBeingOwner() public onlyOwner {
        _setOwner(address(0));
    }

    function changeOwner(address _newOwner) public onlyOwner {
        _setOwner(_newOwner);
    }

    function addAdmin(address _newAdmin) public onlyOwner {
        _setAdmin(_newAdmin);
    }

    function addRole(address _newRoler, uint256 role) public adminOrOwner {
        _setRole(_newRoler, role);
    }

    function renounceRole() public {
        require(
            userToRole[_msgSender()] != 0,
            "AccessControl: This account has no role to renounce."
        );
        userToRole[_msgSender()] = 0;
    }

    function removeRole(address _toBeRemoved) public adminOrOwner {
        require(
            _toBeRemoved != address(0),
            "AccessControl: You can not remove the 0 address."
        );
        require(
            _toBeRemoved != _owner,
            "AccessControl: You can not remove the owner."
        );
        userToRole[_toBeRemoved] = 0;
    }

    /* Setters */

    function _setOwner(address owner_) private {
        require(
            _owner != owner_,
            "AccessControl: Owner can not be set to themselves."
        );
        _owner = owner_;
    }

    function _setAdmin(address _admin) private {
        require(
            _admin != address(0),
            "AccessControl: Account can not be 0 address."
        );
        require(
            userToRole[_admin] != 1,
            "AccessControl: Account is already admin."
        );
        userToRole[_admin] = 1;
    }

    function _setRole(address account, uint256 role) private {
        require(role != 0, "AccessControl: Can not set account to 0 role.");
        require(
            account != address(0),
            "AccessControl: Account can not be the 0 address."
        );
        require(
            userToRole[account] != role,
            "AccessControl: Account is already role."
        );

        userToRole[account] = role;
    }

    /* Getters */

    function owner() public view returns (address) {
        return _owner;
    }

    function isOwner(address _potentialOwner) public view returns (bool) {
        return _potentialOwner == _owner;
    }

    function isAdmin(address _potentialAdmin) public view returns (bool) {
        return userToRole[_potentialAdmin] == 1;
    }

    function isRole(address _potentialRoler, uint256 _roleToCheck)
        public
        view
        returns (bool)
    {
        return userToRole[_potentialRoler] == _roleToCheck;
    }
}
