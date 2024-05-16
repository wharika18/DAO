// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {MyGovernor} from "../src/MyGovernor.sol";
import {GovToken} from "../src/GovToken.sol";
import {TimeLock} from "../src/TimeLock.sol";
import {Main} from "../src/Main.sol";
import {Crypto} from "../src/Enum.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";

contract MyGovTest is Test {
    GovToken token;
    TimeLock timelock;
    MyGovernor governor;
    Main main;

    uint256 public constant MIN_DELAY = 3600;
    uint256 public constant QUORUM_PERCENTAGE = 4;
    uint256 public constant VOTING_PERIOD = 50400;
    uint256 public constant VOTING_DELAY = 7200;

    address[] proposers;
    address[] executors;

    bytes[] functionCalls;
    address[] addressesToCall;
    uint256[] values;

    address public constant VOTER = address(1);

    function setUp() public {
        token = new GovToken(VOTER);
        token.mint(VOTER, 100e18);

        vm.prank(VOTER);
        token.delegate(VOTER);
        timelock = new TimeLock(MIN_DELAY, proposers, executors);
        governor = new MyGovernor(token, timelock);

        bytes32 proposerRole = timelock.PROPOSER_ROLE();
        bytes32 executorRole = timelock.EXECUTOR_ROLE();
        bytes32 adminRole = timelock.DEFAULT_ADMIN_ROLE();

        timelock.grantRole(proposerRole, address(governor));
        timelock.grantRole(executorRole, address(0));

        main = new Main();

        main.transferOwnership(address(timelock));
        vm.stopPrank();
    }

    function testCantUpdateWithoutGovernance() public {
        Crypto option = Crypto.DAI;
        uint256 value = 100 ether;

        vm.expectRevert();
        main.addInvestment(option, value);
    }

    function testMainFunction() public {
        vm.prank(address(timelock));
        Crypto option = Crypto.DAI;
        uint256 value = 100 ether;
        main.addInvestment(option, value);
        uint256 value1 = 100 ether;
        assert(main.checkPortfolio(option) == value1);
    }
}
