import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction, ProxyOptions } from "hardhat-deploy/types";

import { readAddressList, storeAddressList } from "../scripts/contractAddress";

// Deploy Proxy Admin
// It is a non-proxy deployment
// Contract:
//    - ProxyAdmin
// Tags:
//    - ProxyAdmin

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts, network } = hre;
  const { deploy } = deployments;

  network.name = network.name == "hardhat" ? "localhost" : network.name;

  const { deployer } = await getNamedAccounts();

  console.log("\n-----------------------------------------------------------");
  console.log("-----  Network:  ", network.name);
  console.log("-----  Deployer: ", deployer);
  console.log("-----------------------------------------------------------\n");

  // Read address list from local file
  const addressList = readAddressList();

  const name = "ProfileNFT";
  const symbol = "ProfileNFT";

  const proxyOptions: ProxyOptions = {
    proxyContract: "OpenZeppelinTransparentProxy",
    viaAdminContract: {
      name: "ProxyAdmin",
      artifact: "ProxyAdmin",
    },
    execute: {
      init: {
        methodName: "initialize",
        args: [name, symbol],
      },
    },
  };

  const profileNFT = await deploy("ProfileToken", {
    contract: "ProfileToken",
    from: deployer,
    proxy: proxyOptions,
    args: [],
    log: true,
  });
  addressList[network.name].ProfileNFT = profileNFT.address;

  console.log("\ndeployed to address: ", profileNFT.address);

  // Store the address list after deployment
  storeAddressList(addressList);
};

func.tags = ["Profile"];
export default func;
