import React, { useState, useCallback, useEffect } from 'react';
import { contractAddress, abi } from '../utils/abi';
import { BrowserProvider, Contract, parseEther, formatUnits } from "ethers";

export default function Home() {
  const exzoAddress = "0x0000000000000000000000000000000000000000";


  const [depositAmount, setDepositAmount] = useState<string>('');
  const [exzoBalance, setexzoBalance] = useState<string>('');
  const [tokenBalance, setTokenBalance] = useState<string>('');

  const getBalance = useCallback(async () => {
    if (window.ethereum) {
      try {
        // Requesting accounts and getting the user address
        let accounts = await window.ethereum.request({
          method: "eth_requestAccounts",
        });
        let userAddress = accounts[0];

        // Setting up the contract
        const provider = new BrowserProvider(window.ethereum);
        const signer = await provider.getSigner(userAddress);
        const contract = new Contract(contractAddress, abi, signer);
        // Getting EXZO balance
        const balanceStruct = await contract.balances(userAddress);
          const exzoBalanceBigInt = formatUnits(balanceStruct.exzoBalance, 18);
          const formattedexzoBalance = exzoBalanceBigInt.toString();
          setexzoBalance(formattedexzoBalance);
      } catch (error) {
        console.error("Error fetching balance:", error);
      }
    }
  }, []);

  const getTokenBalance = useCallback(async () => {
    if (window.ethereum) {
      try {
        // Requesting accounts and getting the user address
        let accounts = await window.ethereum.request({
          method: "eth_requestAccounts",
        });
        let userAddress = accounts[0];

        // Setting up the contract
        const provider = new BrowserProvider(window.ethereum);
        const signer = await provider.getSigner(userAddress);
        const contract = new Contract(contractAddress, abi, signer);
        // Getting token balance
        const tokenBalance = await contract.balanceOf(userAddress);
        if (tokenBalance !== undefined) {
          const tokenBalanceBigInt = formatUnits(tokenBalance, 0);
          const formattedTokenBalance = tokenBalanceBigInt.toString();
          setTokenBalance(formattedTokenBalance);

        }
      } catch (error) {
        console.error("Error fetching token balance:", error);
      }
    }
  }, []);




  const handleDeposit = async (event: React.FormEvent,  depositAmount: string) => {
    event.preventDefault();
    if (!depositAmount) return;
    if (window.ethereum) {
      let accounts = await window.ethereum.request({
        method: "eth_requestAccounts",
      });

      // The current selected account out of the connected accounts.
      let userAddress = accounts[0];
      const provider = new BrowserProvider(window.ethereum);
      const signer = await provider.getSigner(userAddress);
      const contract = new Contract(contractAddress, abi, signer);
      const depositValue = parseEther(depositAmount);
      const gasLimit = parseInt("600000");
        let tx = await contract.deposit(depositValue, { gasLimit });
        let receipt = await tx.wait();
      getBalance();
      getTokenBalance();
      setDepositAmount('');
    }
  };

  const handleWithdraw = async () => {
    if (window.ethereum) {
      let accounts = await window.ethereum.request({
        method: "eth_requestAccounts",
      });

      // The current selected account out of the connected accounts.
      let userAddress = accounts[0];
      const provider = new BrowserProvider(window.ethereum);
      const signer = await provider.getSigner(userAddress);
      const contract = new Contract(contractAddress, abi, signer);
      const gasLimit = parseInt("600000");
        let tx = await contract.withdraw({ gasLimit });
        let receipt = await tx.wait();
      }
      getBalance();
      getTokenBalance();

    }

  const handleBreakLock = async () => {
    if (window.ethereum) {
      let accounts = await window.ethereum.request({
        method: "eth_requestAccounts",
      });

      // The current selected account out of the connected accounts.
      let userAddress = accounts[0];
      const provider = new BrowserProvider(window.ethereum);
      const signer = await provider.getSigner(userAddress);
      const contract = new Contract(contractAddress, abi, signer);
      const gasLimit = parseInt("600000");
        let tx = await contract.breakTimelock({ gasLimit });
        let receipt = await tx.wait();
      getBalance();
      getTokenBalance();
    }
  };

  useEffect(() => {
    getBalance();
    getTokenBalance();
  }, [getBalance, getTokenBalance]);

  return (
    <div className="">
      <div className="bg-gypsum bg-opacity-3 rounded-lg p-8 shadow-lg text-white w-96">
        <div className="flex flex-col items-center justify-center text-4xl font-bold mb-6 items-center text-black uppercase tracking-wider border-b-2 border-black pb-2">START SAVING TODAY</div>
        <div className="flex flex-col items-center justify-center">
          <h3 className="text-black text-sm bg-gradient-to-r from-gray-100 to-prosperity-300 rounded-md p-2 mb-1">Your EXZO Balance: {exzoBalance} CELO</h3>
          <h3 className="text-black text-sm bg-gradient-to-r from-green-50 to-gypsum rounded-md p-2 mt-1">Your ExzoSafe Bonus: {tokenBalance} MST</h3>
        </div>

        <form onSubmit={(e) => handleDeposit(e, depositAmount)} className="mb-4">
          <input
            type="number"
            step="0.01"
            value={depositAmount}
            onChange={(e) => setDepositAmount(e.target.value)}
            className="rounded px-4 py-2 w-full mb-2 text-black"
          />
          <button
            type="submit"
            className="w-full bg-black hover:bg-black rounded py-2"
          >
            Deposit
          </button>
        </form>

        <button
          onClick={handleWithdraw}
          className="w-full bg-black hover:bg-black rounded py-2 mb-2"
        >
          Withdraw
        </button>
        <button
          onClick={handleBreakLock}
          className="w-full  bg-black hover:bg-black rounded py-2 mb-7"
        >
          Break Lock
        </button>
      </div>
      </div>
  );
}
