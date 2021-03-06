// SPDX-License-Identifier: MIT

pragma solidity =0.8.4;

interface IBEP20 {
    /**
    * @dev Returns the token name.
    */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender) external view returns (uint256);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

/**
 * @title SafeBEP20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IBEP20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeBEP20 {
    using Address for address;

    function safeTransfer(IBEP20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IBEP20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the initial owner.
     */
    function initializeOwnable(address ownerAddr_) internal {
        _setOwner(ownerAddr_);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) external virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IWrappedToken {
    function initialize(string calldata name, string calldata symbol, uint8 decimals, address owner) external;
    function mintTo(address recipient, uint256 amount) external returns (bool);
    function burnFrom(address account, uint256 amount) external returns (bool);
}

contract BscTeleportAgent is Ownable, Initializable {
    using SafeBEP20 for IBEP20;
    using Address for address;

    struct OriginalToken {
        bool registered;
        uint256 chainId;
        address addr;
    }

    mapping(address/*original token address in present chain*/ => bool/*registered*/) public originalTokens;
    mapping(address/*wrapped token address*/ => OriginalToken) public wrappedToOriginalTokens;
    mapping(bytes32/*other chain start tx hash*/ => bool/*filled*/) public filledTeleports;
    mapping(address/*other chain token address*/ => mapping(uint256/*other chain id*/ => address/*wrapped token address*/)) public otherChainTokensToWrappedTokens;
    mapping(uint256/*original chain id*/ => mapping(address /*original token address*/ => address/*wrapped token address*/)) public originalToWrappedTokens;
    mapping(address/*token address in present chain*/ => mapping(uint256/*to chain id*/ => bool/*registered*/)) public routesFromTokenToChain;
    /**
     * @dev The wrappedTokenImplementation is an address of token implementation
     * must support interface of IWrappedToken and will be cloned (deployed) inside
     * MinimalProxy on creation token pair from other blockchain and represent
     * the original token in the origin blockchain
     */
    address public wrappedTokenImplementation;
    uint256 public registerFee;
    uint256 public teleportFee;

    string private constant ERROR_FEE_MISMATCH = "fee mismatch";
    string private constant ERROR_TELEPORT_PAIR_NOT_CREATED = "teloport pair is not created";
    string private constant ERROR_TELEPORT_TX_FILLED_ALREADY = "teleport tx filled already";
    string private constant ERROR_ZERO_ADDRESS = "zero address";
    string private constant ERROR_SEND_FEE = "failed to send fee";
    string private constant ERROR_REGISTER_IN_ORIGINAL_CHAIN = "no need to register teleport to original chain";

    event TeleportPairRegistered(
        address indexed sponsor,
        uint256 originalTokenChainId,
        address indexed originalTokenAddr,
        address indexed presentChainTokenAddr,
        uint256 toChainId,
        string name,
        string symbol,
        uint8 decimals,
        uint256 feeAmount);

    event TeleportPairCreated(
        uint256 fromChainId,
        address indexed fromChainTokenAddr,
        bytes32 fromChainRegisterTxHash,
        address indexed originalTokenAddr,
        uint256 originalTokenChainId,
        address indexed wrappedTokenAddr,
        string name,
        string symbol,
        uint8 decimals);

    event TeleportStarted(
        address indexed fromAddr,
        uint256 originalTokenChainId,
        address indexed originalTokenAddr,
        address indexed tokenAddr,
        uint256 amount,
        uint256 toChainId,
        uint256 feeAmount);

    event TeleportFinished(
        uint256 fromChainId,
        address indexed fromChainTokenAddr,
        bytes32 fromChainStartTxHash,
        uint256 originalTokenChainId,
        address indexed originalTokenAddr,
        address indexed toAddress,
        uint256 amount);

    function initialize(
        uint256 _registerFee,
        uint256 _teleportFee,
        address payable _ownerAddr,
        address _wrappedTokenImpl) external virtual initializer {

        require(_wrappedTokenImpl != address(0), ERROR_ZERO_ADDRESS);
        require(_ownerAddr != address(0), ERROR_ZERO_ADDRESS);
        initializeOwnable(_ownerAddr);

        registerFee = _registerFee;
        teleportFee = _teleportFee;
        wrappedTokenImplementation = _wrappedTokenImpl;
    }

    modifier ensureNotContract() {
        address msg_sender = _msgSender();
        require(!msg_sender.isContract(), "contract not allowed to teleport");
        require(msg_sender == tx.origin, "proxy not allowed to teleport");
        _;
    }

    function setRegisterFee(uint256 _registerFee) onlyOwner external {
        registerFee = _registerFee;
    }

    function setTeleportFee(uint256 _teleportFee) onlyOwner external {
        teleportFee = _teleportFee;
    }

	/**
     * @dev The registerTeleportPair is called in original blockchain to start the process.
     * Should be called by user willing to register new teleport pair, allowing original token
     * to be teleported(swapped 1:1 to identical token issued in other chain and back).
     */
    function registerTeleportPair(address _presentChainTokenAddr, uint256 _toChainId) payable external returns (bool) {
        require(_presentChainTokenAddr != address(0), ERROR_ZERO_ADDRESS);
        require(_presentChainTokenAddr.isContract(), "given address is not a contract");
        require(!routesFromTokenToChain[_presentChainTokenAddr][_toChainId], "already registered");
        require(msg.value >= registerFee, ERROR_FEE_MISMATCH);

        if (msg.value != 0) {
            (bool sent, ) = owner().call{value: msg.value}("");
            require(sent, ERROR_SEND_FEE);
        }

        OriginalToken memory originalToken = wrappedToOriginalTokens[_presentChainTokenAddr];

        if (!originalToken.registered) {
            if (!originalTokens[_presentChainTokenAddr]) {
                originalTokens[_presentChainTokenAddr] = true;
            }

            originalToken.chainId = block.chainid;
            originalToken.addr = _presentChainTokenAddr;
        }

        require(originalToken.chainId != _toChainId, ERROR_REGISTER_IN_ORIGINAL_CHAIN);

        string memory name = IBEP20(_presentChainTokenAddr).name();
        string memory symbol = IBEP20(_presentChainTokenAddr).symbol();
        uint8 decimals = IBEP20(_presentChainTokenAddr).decimals();

        require(bytes(name).length > 0, "empty token name");
        require(bytes(symbol).length > 0, "empty token symbol");

        routesFromTokenToChain[_presentChainTokenAddr][_toChainId] = true;

        emit TeleportPairRegistered(_msgSender(), originalToken.chainId, originalToken.addr, _presentChainTokenAddr, _toChainId, name, symbol, decimals, msg.value);

        return true;
    }

	/**
     * @dev The createTeleportPair is called by oracle in the target blockchain where
     * original tokens should be teleported. This function creates a corresponding token
     * in target blockchain and shows the reliance between original token in origin chain
	 * and corresponding token in target blockchain.
     */
    function createTeleportPair(
        uint256 _fromChainId,
        address _fromChainTokenAddr,
        bytes32 _fromChainRegisterTxHash,
        address _originalTokenAddr,
        uint256 _originalTokenChainId,
        string calldata _name,
        string calldata _symbol,
        uint8 _decimals) onlyOwner external returns (address) {

        require(_fromChainTokenAddr != address(0), ERROR_ZERO_ADDRESS);
        require(_originalTokenAddr != address(0), ERROR_ZERO_ADDRESS);
        require(otherChainTokensToWrappedTokens[_fromChainTokenAddr][_fromChainId] == address(0x0), "pair already created");
        require(block.chainid != _originalTokenChainId, ERROR_REGISTER_IN_ORIGINAL_CHAIN);

        address wrappedTokenAddr = originalToWrappedTokens[_originalTokenChainId][_originalTokenAddr];

        if (wrappedTokenAddr == address(0x0)) {

            address proxyToken = _deployMinimalProxy(wrappedTokenImplementation);
            IWrappedToken token = IWrappedToken(proxyToken);
            token.initialize(_name, _symbol, _decimals, address(this));

            wrappedTokenAddr = address(token);

            originalToWrappedTokens[_originalTokenChainId][_originalTokenAddr] = wrappedTokenAddr;

            OriginalToken storage originalToken = wrappedToOriginalTokens[wrappedTokenAddr];
            require(!originalToken.registered, "original token already wrapped");

            originalToken.registered = true;
            originalToken.chainId = _originalTokenChainId;
            originalToken.addr = _originalTokenAddr;
        }

        otherChainTokensToWrappedTokens[_fromChainTokenAddr][_fromChainId] = wrappedTokenAddr;

        emit TeleportPairCreated(
            _fromChainId,
            _fromChainTokenAddr,
            _fromChainRegisterTxHash,
            _originalTokenAddr,
            _originalTokenChainId,
            wrappedTokenAddr,
            _name,
            _symbol,
            _decimals);

        return wrappedTokenAddr;
    }

	/**
     * @dev The teleportStart is called by user in original blockchain each time user wants
     * to switch original token in origin blockchain to corresponding token in target chain.
     * It freezes original tokens on the bridge and emit a signal to the oracle.
     */
    function teleportStart(address _tokenAddr, uint256 _amount, uint256 _toChainId) payable external ensureNotContract returns (bool) {
        require(_tokenAddr != address(0), ERROR_ZERO_ADDRESS);

        address msgSender = _msgSender();

        require(msg.value >= teleportFee, ERROR_FEE_MISMATCH);

        if (msg.value != 0) {
            (bool sent, ) = owner().call{value: msg.value}("");
            require(sent, ERROR_SEND_FEE);
        }

        uint256 originalTokenChainId;
        address originalTokenAddr;

        if (originalTokens[_tokenAddr]) {
            require(routesFromTokenToChain[_tokenAddr][_toChainId], ERROR_TELEPORT_PAIR_NOT_CREATED);

            IBEP20(_tokenAddr).safeTransferFrom(msgSender, address(this), _amount);

            originalTokenChainId = block.chainid;
            originalTokenAddr = _tokenAddr;
        } else {
            OriginalToken storage originalToken = wrappedToOriginalTokens[_tokenAddr];

            require(originalToken.registered, "token address not wrapped");

            bool burn_status = IWrappedToken(_tokenAddr).burnFrom(msgSender, _amount);
            require(burn_status, "burn failed");

            originalTokenChainId = originalToken.chainId;
            originalTokenAddr = originalToken.addr;

            if (_toChainId == originalTokenChainId) {
                require(originalToWrappedTokens[_toChainId][originalTokenAddr] == _tokenAddr, ERROR_TELEPORT_PAIR_NOT_CREATED);
            } else {
                require(routesFromTokenToChain[_tokenAddr][_toChainId], ERROR_TELEPORT_PAIR_NOT_CREATED);
            }
        }

        emit TeleportStarted(msgSender, originalTokenChainId, originalTokenAddr, _tokenAddr, _amount, _toChainId, msg.value);

        return true;
    }

	/**
     * @dev The teleportFinish is called by oracle in target blockchain after user's call of the
     * teleportStart function in origin blockchain. It mints necessary amount of corresponding
     * tokens in the target blockchain to the user's wallet.
     */
    function teleportFinish(
        uint256 _fromChainId,
        address _fromChainTokenAddr,
        bytes32 _fromChainStartTxHash,
        uint256 _originalTokenChainId,
        address _originalTokenAddr,
        address _toAddress,
        uint256 _amount) onlyOwner external returns (bool) {

        require(_fromChainTokenAddr != address(0), ERROR_ZERO_ADDRESS);
        require(_originalTokenAddr != address(0), ERROR_ZERO_ADDRESS);
        require(_toAddress != address(0), ERROR_ZERO_ADDRESS);
        require(!filledTeleports[_fromChainStartTxHash], ERROR_TELEPORT_TX_FILLED_ALREADY);
        filledTeleports[_fromChainStartTxHash] = true;

        if (block.chainid == _originalTokenChainId && originalTokens[_originalTokenAddr]) {
            IBEP20(_originalTokenAddr).safeTransfer(_toAddress, _amount);
        } else {
            address wrappedTokenAddr = otherChainTokensToWrappedTokens[_fromChainTokenAddr][_fromChainId];
            require(wrappedTokenAddr != address(0x0), ERROR_TELEPORT_PAIR_NOT_CREATED);

            bool mint_status = IWrappedToken(wrappedTokenAddr).mintTo(_toAddress, _amount);
            require(mint_status, "mint failed");
        }

        emit TeleportFinished(
            _fromChainId,
            _fromChainTokenAddr,
            _fromChainStartTxHash,
            _originalTokenChainId,
            _originalTokenAddr,
            _toAddress,
            _amount);

        return true;
    }

    function _deployMinimalProxy(address _logic) private returns (address proxy) {
        // Adapted from https://github.com/optionality/clone-factory/blob/32782f82dfc5a00d103a7e61a17a5dedbd1e8e9d/contracts/CloneFactory.sol
        bytes20 targetBytes = bytes20(_logic);
        assembly {
            let clone := mload(0x40)
            mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(clone, 0x14), targetBytes)
            mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            proxy := create(0, clone, 0x37)
        }
    }
}