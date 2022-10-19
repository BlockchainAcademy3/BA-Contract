import { subtask, task, types } from "hardhat/config";
import "@nomiclabs/hardhat-ethers";

import { ProfileToken, ProfileToken__factory } from "../typechain-types";

import { readAddressList } from "../scripts/contractAddress";
import { parseUnits, formatEther } from "ethers/lib/utils";

const addressList = readAddressList();

task("mintProfileNFT", "Mint Profile NFT")
  .addParam("address", "User address", null, types.string)
  .setAction(async (taskArgs, hre) => {
    const { network } = hre;

    // Signers
    const [dev_account] = await hre.ethers.getSigners();
    console.log("The default signer is: ", dev_account.address);

    const profileNFT: ProfileToken = new ProfileToken__factory(
      dev_account
    ).attach(addressList[network.name].ProfileToken);

    const tx = await profileNFT.mint(taskArgs.address);
    console.log("Tx detials:", await tx.wait());
  });
