// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Safe is ERC20 {
    struct TokenBalance {
        uint256 exzoBalance;
        uint256 depositTime;
        uint256 tokenIncentive; // Declare tokenIncentive here
    }

    mapping(address => TokenBalance) public balances;
    uint256 public lockDuration = 1 weeks;
    address private constant EXZO_TOKEN_ADDRESS = address(0);
    bool public due = false;

    constructor() ERC20("miniSafeToken", "MST") {
        _mint(address(this), 21000000);
    }

    event Deposited(
        address indexed depositor,
        uint256 amount,
        address indexed token
    );
    event Withdrawn(
        address indexed withdrawer,
        uint256 amount,
        address indexed token
    );
    event TimelockBroken(address indexed breaker, uint256 totalSavings);

    receive() external payable {
        deposit(EXZO_TOKEN_ADDRESS, msg.value);
    }

    function deposit(address tokenAddress, uint256 amount) public {
        if (tokenAddress == EXZO_TOKEN_ADDRESS) {
            require(amount > 0, "EXZO deposit amount must be greater than 0");
            TokenBalance storage exzoBalance = balances[msg.sender];
            exzoBalance.exzoBalance += amount;s
            exzoBalance.depositTime = block.timestamp;
            exzoBalance.tokenIncentive = balanceOf(msg.sender); // Set tokenIncentive on deposit
            emit Deposited(msg.sender, amount, EXZO_TOKEN_ADDRESS);
        }  else {
            revert("Unsupported token");
        }
        _mint(msg.sender, 1);
        TokenBalance storage tokenIncentive = balances[msg.sender]; // Set tokenIncentive on deposit
        tokenIncentive.tokenIncentive += 1;
    }

    function timeSinceDeposit(address depositor) public view returns (uint256) {
        return block.timestamp - balances[depositor].depositTime;
    }
    function breakTimelock() public {
    require(balances[msg.sender].exzoBalance > 0, "No savings to withdraw");

    TokenBalance storage tokenBalance = balances[msg.sender];
    uint256 amount;
    
    if (timeSinceDeposit(msg.sender) < lockDuration) {
        uint256 tokenIncentive = tokenBalance.tokenIncentive;
        require(tokenIncentive > 0, "Insufficient savings to break timelock");

        amount = tokenBalance.exzoBalance;
        tokenBalance.exzoBalance = 0;
        payable(msg.sender).transfer(amount);
        transfer(msg.sender, tokenIncentive);

        emit TimelockBroken(msg.sender, amount);
    } else {
        revert("Cannot break timelock after the lock duration");
    }
}


    function withdraw(address tokenAddress) public {
        TokenBalance storage tokenBalance = balances[msg.sender];
        if (
            (tokenBalance.exzoBalance > 0 &&
                timeSinceDeposit(msg.sender) >= lockDuration)
        ) {
            due = true;
        } else {
            revert(
                "Cannot withdraw before lock duration or no tokens deposited"
            );
        }
        uint256 amount;

        if (tokenAddress == EXZO_TOKEN_ADDRESS) {
            amount = tokenBalance.exzoBalance;
            tokenBalance.exzoBalance = 0;
            payable(msg.sender).transfer(amount);
        } else {
            revert("Unsupported token");
        }

        emit Withdrawn(msg.sender, amount, tokenAddress);
    }

    function getBalance(address account, address tokenAddress)
        public
        view
        returns (uint256)
    {
        TokenBalance storage tokenBalance = balances[account];
        if (tokenAddress == EXZO_TOKEN_ADDRESS) {
            return tokenBalance.exzoBalance;
        } else {
            revert("Unsupported token");
        }
    }
}
