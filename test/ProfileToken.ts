import { ethers } from "hardhat";
import { expect } from "chai";

import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { ProfileToken, ProfileToken__factory } from "../typechain-types";
import { PROFILE_SERVER_URL } from "../scripts/constants";

describe("SoulBoundToken", function () {
  let dev: SignerWithAddress, alice: SignerWithAddress, bob: SignerWithAddress;

  let sbt: ProfileToken;

  beforeEach(async function () {
    [dev, alice, bob] = await ethers.getSigners();

    const profileTokenFactory: ProfileToken__factory =
      await ethers.getContractFactory("ProfileToken");
    sbt = await profileTokenFactory.deploy();

    await sbt.initialize("BA-ProfileToken", "BA-PRT");
  });

  describe("Deployment", function () {
    it("should set the right owner", async function () {
      expect(await sbt.owner()).to.equal(dev.address);
    });

    it("should set the right name and symbol", async function () {
      expect(await sbt.name()).to.equal("BA-ProfileToken");
      expect(await sbt.symbol()).to.equal("BA-PRT");
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

    it("should not be able to mint more than 1 token to a user", async function () {
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
      await sbt.setBaseURI(PROFILE_SERVER_URL);

      expect(await sbt.tokenURI(0)).to.equal(PROFILE_SERVER_URL + "0");
      expect(await sbt.tokenURI(1)).to.equal(PROFILE_SERVER_URL + "1");
    });

    it("should be able to burn the profile token", async function () {
      await sbt.mint(alice.address);

      await sbt.burn();

      expect(await sbt.balanceOf(alice.address)).to.equal(0);
    });
  });

  describe("Link", function () {});
});
