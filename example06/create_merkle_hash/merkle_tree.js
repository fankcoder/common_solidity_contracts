// https://medium.com/@ItsCuzzo/using-merkle-trees-for-nft-whitelists-523b58ada3f9
//
// 1. Import libraries. Use `npm` package manager to install
const { MerkleTree } = require('merkletreejs');
const keccak256 = require('keccak256');
const fs = require('fs');

// let data = JSON.stringify(student);
// fs.writeFileSync('student-2.json', data);

let whitelistAddresses = [
  "0x0155dB77fe42c4C3e1cd75fbbA1b528A105FcCDA",
  "0x50E7A1f7647B569795EF844CF0f920D0EE283D4b",
  "0x6A4296cd7472ec0CF3606f0b966Bb5b944EBB889"
]
// 2. Collect list of wallet addresses from competition, raffle, etc.
// Store list of addresses in some data sheeet (Google Sheets or Excel)

// 3. Create a new array of `leafNodes` by hashing all indexes of the `whitelistAddresses`
// using `keccak256`. Then creates a Merkle Tree object using keccak256 as the algorithm.
//
// The leaves, merkleTree, and rootHas are all PRE-DETERMINED prior to whitelist claim
const leafNodes = whitelistAddresses.map(addr => keccak256(addr));

const merkleTree = new MerkleTree(leafNodes, keccak256, { sortPairs: true});

// 4. Get root hash of the `merkleeTree` in hexadecimal format (0x)
// Print out the Entire Merkle Tree.
const rootHash = merkleTree.getRoot();
console.log('Whitelist Merkle Tree\n', merkleTree.toString());

// ***** ***** ***** ***** ***** ***** ***** ***** // 

// CLIENT-SIDE: Use `msg.sender` address to query and API that returns the merkle proof
// required to derive the root hash of the Merkle Tree

// ✅ Positive verification of address
// const claimingAddress = leafNodes[0];
// ❌ Change this address to get a `false` verification

// write whitelist into json file
// var whitelistSave = [];
// for (var i=0;i<whitelistAddresses.length;i++) {
//   var wlDict = {}
//   var claimingAddress = keccak256(whitelistAddresses[i]);
//   var hexProof = merkleTree.getHexProof(claimingAddress);
//   // console.log(hexProof);
//   // console.log(merkleTree.verify(hexProof, claimingAddress, rootHash));
//   wlDict['address'] = whitelistAddresses[i];
//   wlDict['proof'] = hexProof;
//   // whitelistdict[whitelistAddresses[i]] = hexProof;
//   whitelistSave.push(wlDict)
// }
// console.log(whitelistSave)
// let data = JSON.stringify(whitelistSave);
// fs.writeFileSync('whitelistSave.json', data);

const claimingAddress = keccak256("0x0155dB77fe42c4C3e1cd75fbbA1b528A105FcCDA");

// `getHexProof` returns the neighbour leaf and all parent nodes hashes that will
// be required to derive the Merkle Trees root hash.
const hexProof = merkleTree.getHexProof(claimingAddress);
console.log(hexProof);

// ✅ - ❌: Verify is claiming address is in the merkle tree or not.
// This would be implemented in your Solidity Smart Contract
console.log(merkleTree.verify(hexProof, claimingAddress, rootHash));
