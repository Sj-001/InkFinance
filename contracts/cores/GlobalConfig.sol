//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/IConfig.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";


contract GlobalConfig is IConfig, IERC165 {
// 仅能配置该地址域下的key的管理员.


function batchSetConfigAdmin(SetConfigAdminInfo[] configAdmins) external {

}
// 对某些前缀key设置管理员.
// 此处的管理员可以管理所有以该key为前缀的配置.
// 对某些key设置管理员.
// 注: string类型仅用于事件, 合约本地存储用hash后的值.
event SetPrefixConfigAdmin(address indexed domain, string indexed keyPrefix, address indexed admin);

struct SetPrefixConfigAdminInfo{
  string keyPrefix;
  address admin;
}

function batchSetPrefixConfigAdmin(SetPrefixConfigAdminInfo[] prefixConfigAdmins) external {

}

// 仅有对应管理员可以设置该key, domain == msg.sender 时具有所有权限.
// 注: string类型仅用于事件, 合约本地存储用hash后的值.
// 先查domain == msg.sender.
// 再查该domain下的keyPrefix的管理员 == msg.sender.
// 最后查该domain下的 hash(hash("<prefix>"), hash("<key name>")) 的管理员 == msg.sender
event SetKV(address indexed operator, address indexed domain, bytes32 indexed key, string keyPrefix, string keyName, bytes32 typeID, bytes data);

struct KVInfo{
  string keyPrefix;
  string keyName;
  bytes32 typeID;
  bytes data;
}

function batchSetKV(address domain, KVInfo[] kvs) external {

}

function getKV(bytes32 key) external returns(bytes32 typeID, bytes data) {

}


}
