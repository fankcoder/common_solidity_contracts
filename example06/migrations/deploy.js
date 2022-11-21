const CoolNFTWhiteList = artifacts.require("CoolNFTWhiteList");

module.exports = async function (deployer) {
  await deployer.deploy(CoolNFTWhiteList);
  const cwl = await CoolNFTWhiteList.deployed();
  var dict = {"merkleRoot": "0x4c5db318dde149f5f16a1c35a5764311e687ac83065036f224555d1d78e90fab", "startTime":1663655701, "endTime":1663660801};
  await cwl.setWhitelistSaleConfig(dict);
};
