// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Import necessary contracts from the OpenZeppelin library
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract PayBills {
    // Struct to store merchant information
    struct Merchant {
        uint256 id;
        string name;
        string description;
        address walletAddress;
    }

    // Array to store merchant information
    Merchant[] public merchants;

    // EXZO contract address
    address private constant EXZO_TOKEN_ADDRESS =
        address(0);

    // Event emitted when merchant information is updated
    event MerchantUpdated(
        uint256 indexed merchantId,
        string name,
        string description,
        address walletAddress
    );
    event MerchantAdded(
        uint256 indexed merchantId,
        string name,
        string description,
        address walletAddress
    );
    // Event emitted when EXZO is transferred
    event Sent(address indexed from, address indexed to, uint256 amount);
    mapping(uint256 => address) public owner;
    // Modifier to restrict access to only the merchant owner
    modifier onlyMerchant(uint256 merchantId) {
        require(
            msg.sender == merchants[merchantId].walletAddress,
            "Not authorized"
        );
        _;
    }

    // Function to add merchant information to the array
    function addMerchant(
        string memory _name,
        string memory _description,
        address _walletAddress
    ) external {
        uint256 merchantId = merchants.length + 1;
        merchants.push(Merchant(
             merchantId,
            _name,
            _description,
            _walletAddress));
        emit MerchantUpdated(
            merchantId,
            _name,
            _description,
            _walletAddress)
        ;
        owner[merchantId] = msg.sender;

    }

    // Function to update merchant information
    function updateMerchant(
        uint256 userId,
        string memory _name,
        string memory _description,
        address _walletAddress
    ) external onlyMerchant(userId) {
        Merchant storage merchant = merchants[userId];

        merchant.name = _name;
        merchant.description = _description;
        merchant.walletAddress = _walletAddress;

        emit MerchantUpdated(userId, _name, _description, _walletAddress);
    }

    // Function to get merchant information
    function getMerchantInfo(uint256 userId)
        external
        view
        returns (Merchant memory)
    {
        return merchants[userId];
    }

    function allMerchant() public view returns (Merchant[] memory) {
        return merchants;
    }

    // Function to send EXZO from the contract to a specified address
    function send(address to, uint256 amount) public {
        require(amount > 0, "Amount must be greater than zero");
        require(
            IERC20(EXZO_TOKEN_ADDRESS).balanceOf(address(this)) >= amount,
            "Insufficient EXZO balance"
        );

        IERC20(EXZO_TOKEN_ADDRESS).transfer(to, amount);
        emit Sent(address(this), to, amount);
    }
}
