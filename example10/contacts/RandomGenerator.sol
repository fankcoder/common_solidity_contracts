// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";
import {VRFCoordinatorV2PlusInterface} from "@chainlink/contracts/src/v0.8/vrf/dev/interfaces/VRFCoordinatorV2PlusInterface.sol";

contract ChainlinkRandom is VRFConsumerBaseV2Plus {

    VRFCoordinatorV2PlusInterface public COORDINATOR;

    uint64 public subscriptionId;
    bytes32 public keyHash;

    uint32 public callbackGasLimit = 200000;
    uint16 public requestConfirmations = 3;
    uint32 public numWords = 1;

    uint256 public lastRequestId;
    uint256 public randomResult;

    event RandomRequested(uint256 requestId);
    event RandomFulfilled(uint256 requestId, uint256 randomWord);

    constructor(
        address _vrfCoordinator,
        uint64 _subscriptionId,
        bytes32 _keyHash
    ) VRFConsumerBaseV2Plus(_vrfCoordinator) {
        COORDINATOR = VRFCoordinatorV2PlusInterface(_vrfCoordinator);
        subscriptionId = _subscriptionId;
        keyHash = _keyHash;
    }

    /// 请求随机数
    function requestRandomNumber() external returns (uint256 requestId) {
        requestId = COORDINATOR.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: keyHash,
                subId: subscriptionId,
                requestConfirmations: requestConfirmations,
                callbackGasLimit: callbackGasLimit,
                numWords: numWords,
                extraArgs: VRFV2PlusClient._argsToBytes(
                    VRFV2PlusClient.ExtraArgsV1({
                        nativePayment: false // false = 用 LINK 支付, true = 用 ETH/BNB 原生币支付
                    })
                )
            })
        );

        lastRequestId = requestId;
        emit RandomRequested(requestId);
    }

    /// Chainlink 回调函数（必须实现）
    function fulfillRandomWords(
        uint256 requestId,
        uint256[] memory randomWords
    ) internal override {
        randomResult = randomWords[0];
        emit RandomFulfilled(requestId, randomWords[0]);
    }

    /// 示例：生成 1~100 的随机数
    function getRandomNumber1to100() external view returns (uint256) {
        require(randomResult > 0, "Random not ready yet");
        return (randomResult % 100) + 1;
    }
}