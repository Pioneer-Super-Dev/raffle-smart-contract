// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Raffle is Pausable, Ownable {
    uint256 private raffleNumber;

    IERC20 private _RTT; // Token address
    address private _vault; // Vault address

    mapping(address => uint256) private balance; // Balance of each address
    uint256 private _vaultBalance = 0; // Balance of vault
    uint256 public rafflePrice = 1 ether; // Price for take part in raffle

    mapping(uint256 => mapping(address => bool)) public raffleEventPrediction; // Prediction of address of each prediction
    mapping(uint256 => mapping(uint256 => address)) public raffleEventAddress; // Address list of each raffle
    mapping(uint256 => uint256) public rafflePriceRaiseCount; // Number of members of up prediction
    mapping(uint256 => uint256) public rafflePriceDownCount; // Number of members of down prediction
    mapping(uint256 => uint256) public raffleParticipantsCount; // Participants of each raffle
    mapping(uint256 => uint256) public rafflePrize; // Prize of each raffle
    mapping(uint256 => uint256) public _btcPrice; // Bitcoin price of each raffle stage
    mapping(uint256 => bool) public raffleResult; // Result of each raffle stage

    modifier onlyVault() {
        require(_vault == msg.sender, "Caller is not the Vault");
        _;
    }

    constructor(address RTT) {
        _vault = msg.sender;
        _RTT = IERC20(RTT);
    }

    // Make prediction of each raffle result
    function createRaffle(bool prediction) public {
        require(balance[msg.sender] > rafflePrice, "Insufficient Balance");

        raffleEventAddress[raffleNumber][
            raffleParticipantsCount[raffleNumber]
        ] = msg.sender;
        raffleEventPrediction[raffleNumber][msg.sender] = prediction;
        if (prediction == true) rafflePriceRaiseCount[raffleNumber]++;
        else rafflePriceDownCount[raffleNumber]++;
        raffleParticipantsCount[raffleNumber]++;
    }

    // Set Raffle result
    function setRaffleResult(uint256 btcPrice) public onlyOwner {
        _btcPrice[raffleNumber] = btcPrice;
        if (raffleNumber > 0) {
            if (_btcPrice[raffleNumber - 1] < _btcPrice[raffleNumber])
                raffleResult[raffleNumber - 1] = true;
            else raffleResult[raffleNumber - 1] = false;
        }
        winnerDisturibution();
        initializeNextRaffle();
    }

    // Disturibute prize to winners
    function winnerDisturibution() private {
        uint256 winner;
        uint256 endedRaffleNumber = raffleNumber - 1;
        if (raffleResult[endedRaffleNumber] == true)
            winner = rafflePriceRaiseCount[endedRaffleNumber];
        else winner = rafflePriceDownCount[endedRaffleNumber];

        uint256 vaultFee = (rafflePrice *
            raffleParticipantsCount[endedRaffleNumber]) / 20;
        _vaultBalance = _vaultBalance + vaultFee;

        rafflePrize[endedRaffleNumber] =
            ((rafflePrice * raffleParticipantsCount[endedRaffleNumber] * 95) /
                100) /
            winner;

        for (
            uint256 i = 0;
            i < raffleParticipantsCount[endedRaffleNumber];
            i++
        ) {
            address participantAddress = raffleEventAddress[endedRaffleNumber][
                i
            ];
            bool prediction = raffleEventPrediction[endedRaffleNumber][
                participantAddress
            ];
            if (raffleResult[endedRaffleNumber] == prediction)
                balance[participantAddress] =
                    balance[participantAddress] +
                    rafflePrize[endedRaffleNumber];
            else
                balance[participantAddress] =
                    balance[participantAddress] -
                    rafflePrice;
        }
    }

    // Initialize variable for next raffle
    function initializeNextRaffle() private {
        raffleNumber++;
    }

    // Pause smart contract transaction
    function pause() public onlyOwner {
        _pause();
    }

    // Unpause smart contract transaction
    function unpause() public onlyOwner {
        _unpause();
    }

    // Set vault address
    function setVault(address vault) public onlyOwner {
        _vault = vault;
    }

    // Get balance of each user
    function getBalance() public view returns (uint256) {
        return balance[msg.sender];
    }

    // Get balance of vault
    function getValutBalance() public view onlyVault returns (uint256) {
        return balance[_vault];
    }

    // Users deposit money to smart contract
    function deposit(uint256 amount) public {
        require(
            _RTT.balanceOf(msg.sender) >= amount,
            "Your Wallet does not have enough RTT"
        );
        _RTT.transferFrom(msg.sender, address(this), amount);
        balance[msg.sender] = balance[msg.sender] + amount;
    }

    // Withdraw user balance
    function withdrawUser(uint256 amount) public returns (bool) {
        require(balance[msg.sender] > amount, "Insufficient Balance");
        return
            _RTT.transferFrom(
                address(this),
                msg.sender,
                _RTT.balanceOf(address(this))
            );
    }

    // Withdraw Vault balance
    function withdrawValut(uint256 amount) public onlyVault returns (bool) {
        require(_vaultBalance > amount, "Insufficient Balance");
        return
            _RTT.transferFrom(
                address(this),
                _vault,
                _RTT.balanceOf(address(this))
            );
    }
}
