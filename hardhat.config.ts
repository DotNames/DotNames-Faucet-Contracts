import { exec as _exec } from "child_process";

import "@nomiclabs/hardhat-ethers";
import "@nomiclabs/hardhat-solhint";
import "@nomiclabs/hardhat-truffle5";
import "@nomiclabs/hardhat-waffle";
import dotenv from "dotenv";
import "hardhat-abi-exporter";
import "hardhat-contract-sizer";
import "hardhat-deploy";
import "hardhat-gas-reporter";
import { HardhatUserConfig } from "hardhat/config";
import { promisify } from "util";
import "@nomicfoundation/hardhat-verify";

const exec = promisify(_exec);

// Load environment variables from .env file. Suppress warnings using silent
// if this file is missing. dotenv will never modify any environment variables
// that have already been set.
// https://github.com/motdotla/dotenv
dotenv.config();

let real_accounts = undefined;
if (process.env.DEPLOYER_KEY) {
  real_accounts = [process.env.DEPLOYER_KEY];
}

// circular dependency shared with actions
export const archivedDeploymentPath = "./deployments/archive";

const config: HardhatUserConfig = {
  networks: {
    taiko: {
      url: "https://rpc.jolnir.taiko.xyz",
      accounts: real_accounts,
    },
  },

  //@ts-ignore
  etherscan: {
    apiKey: {
      taiko: "42069",
    },
    customChains: [
      {
        network: "taiko",
        chainId: 167007,
        urls: {
          apiURL: "https://blockscoutapi.jolnir.taiko.xyz/api",
          browserURL: "https://explorer.jolnir.taiko.xyz",
        },
      },
    ],
  },
  mocha: { timeout: 400000000 },
  solidity: {
    compilers: [
      {
        version: "0.8.20",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    ],
  },
  abiExporter: {
    path: "./build/contracts",
    runOnCompile: true,
    clear: true,
    flat: true,
    spacing: 2,
    pretty: true,
  },
  namedAccounts: {
    deployer: {
      default: 0,
    },
    owner: {
      default: 0,
    },
  },
  external: {
    contracts: [
      {
        artifacts: [archivedDeploymentPath],
      },
    ],
  },
};

export default config;
