import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "hardhat-deploy";

import * as dotenv from "dotenv";
dotenv.config();

const config: HardhatUserConfig = {
  solidity: "0.8.17",
  namedAccounts: {
    deployer: {
      default: 0,
      localhost: 0,
      goerli: 0,
      eth: 0,
    },
  },
  networks: {
    hardhat: {},
    localhost: {
      url: "http://127.0.0.1:8545",
    },
    goerli: {
      url: process.env.GOERLI_URL || "",
      accounts:
        process.env.PK_GOERLI !== undefined ? [process.env.PK_GOERLI] : [],

      timeout: 60000,
    },
    // eth: {
    //   url: process.env.FUJI_URL || "",
    //   accounts: {
    //     mnemonic:
    //       process.env.PHRASE_FUJI !== undefined ? process.env.PHRASE_FUJI : "",
    //     count: 20,
    //   },
    //   timeout: 60000,
    // },
  },
};

export default config;
