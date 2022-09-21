import { ethers } from "hardhat";
import { expect } from "chai";

import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { ProfileToken, ProfileToken__factory } from "../typechain-types";

describe("SoulBoundToken", function () {
  let dev: SignerWithAddress, alice: SignerWithAddress, bob: SignerWithAddress;

  let sbt: ProfileToken;

  beforeEach(async function () {
    [dev, alice, bob] = await ethers.getSigners();

    const profileTokenFactory = await ethers.getContractFactory("ProfileToken");
    sbt = await profileTokenFactory.deploy("ProfileToken", "PRT");
  });

  describe("Deployment", function () {
    it("should set the right owner", async function () {
      expect(await sbt.owner()).to.equal(dev.address);
    });

    it("should set the right name and symbol", async function () {
      expect(await sbt.name()).to.equal("ProfileToken");
      expect(await sbt.symbol()).to.equal("PRT");
    });
  });

  describe("Mint", function () {
    it("should be able to mint to a user", async function () {
      await sbt.mint(alice.address);
      expect(await sbt.balanceOf(alice.address)).to.equal(1);
      expect(await sbt.ownerOf(0)).to.equal(alice.address);

      await sbt.mint(bob.address);
      expect(await sbt.balanceOf(bob.address)).to.equal(1);
      expect(await sbt.ownerOf(1)).to.equal(bob.address);
    });

    it("should not be able to mint >=2 tokens to a user", async function () {
      await sbt.mint(alice.address);

      await expect(sbt.mint(alice.address)).to.be.revertedWith(
        "SoulBoundToken: already have a soul bound token"
      );
    });

    it("should not be able to transfer the profile token", async function () {
      await sbt.mint(alice.address);

      await expect(
        sbt
          .connect(alice)
          ["safeTransferFrom(address,address,uint256)"](
            alice.address,
            bob.address,
            0
          )
      ).to.be.revertedWith("SBT: No transfers");
    });

    it("should be able to check the tokenURI", async function () {
      await sbt.setBaseURI("https://api.web3edu.xyz/api/v1/profile/");

      expect(await sbt.tokenURI(0)).to.equal(
        "https://api.web3edu.xyz/api/v1/profile/0"
      );
      expect(await sbt.tokenURI(1)).to.equal(
        "https://api.web3edu.xyz/api/v1/profile/1"
      );
    });

    it("should be able to burn the profile token", async function () {
      await sbt.mint(alice.address);

      await sbt.burn();

      expect(await sbt.balanceOf(alice.address)).to.equal(0);
    });
  });

  describe("Link", function () {});
});
