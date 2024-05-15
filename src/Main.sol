// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";

import {Crypto} from "./Enum.sol";

contract Main is Ownable {
    Crypto public option;
    uint256 value;
    mapping(Crypto => uint256) portfolio;
    Crypto[] cryptic;

    constructor(address initialOwner) Ownable(initialOwner) {}

    event AddInvestment(Crypto _option, uint256 _value);

    function addInvestment(Crypto _option, uint256 _value) public onlyOwner {
        value = _value;
        option = _option;
        emit AddInvestment(option, value);
        cryptic.push(option);
        portfolio[option] = value;
    }

    function checkPortfolio(Crypto _option) public view returns (uint256) {
        return portfolio[_option];
    }
}
