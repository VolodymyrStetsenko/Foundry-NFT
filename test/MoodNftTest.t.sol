// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/Base64.sol";
import {DeployMoodNft} from "../script/DeployMoodNft.s.sol";
import {MoodNft} from "../src/MoodNft.sol";
import {Test, console} from "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";
import {MintBasicNft} from "../script/Interactions.s.sol";
import {ZkSyncChainChecker} from "lib/foundry-devops/src/ZkSyncChainChecker.sol";
import {FoundryZkSyncChecker} from "lib/foundry-devops/src/FoundryZkSyncChecker.sol";

contract MoodNftTest is Test, ZkSyncChainChecker, FoundryZkSyncChecker {
    string constant NFT_NAME = "Mood NFT";
    string constant NFT_SYMBOL = "MN";
    MoodNft public moodNft;
    DeployMoodNft public deployer;
    address public deployerAddress;

    string public constant HAPPY_MOOD_URI =
        "data:application/json;base64,eyJuYW1lIjoiTW9vZCBORlQiLCAiZGVzY3JpcHRpb24iOiJBbiBORlQgdGhhdCByZWZsZWN0cyB0aGUgbW9vZCBvZiB0aGUgb3duZXIsIDEwMCUgb24gQ2hhaW4hIiwgImF0dHJpYnV0ZXMiOiBbeyJ0cmFpdF90eXBlIjogIm1vb2RpbmVzcyIsICJ2YWx1ZSI6IDEwMH1dLCAiaW1hZ2UiOiJkYXRhOmltYWdlL3N2Zyt4bWw7YmFzZTY0LFBITjJaeUI0Yld4dWN6MGlhSFIwY0RvdkwzZDNkeTUzTXk1dmNtY3ZNakF3TUM5emRtY2lJSGRwWkhSb1BTSXlOVFlpSUdobGFXZG9kRDBpTWpVMklqNEtJQ0E4Y21WamRDQjNhV1IwYUQwaU1UQXdKU0lnYUdWcFoyaDBQU0l4TURBbElpQm1hV3hzUFNJalpqQm1PV1ptSWk4K0NpQWdQR05wY21Oc1pTQmplRDBpTVRJNElpQmplVDBpTVRJNElpQnlQU0l4TURBaUlHWnBiR3c5SWlOa01XWmhaVFVpTHo0S0lDQThZMmx5WTJ4bElHTjRQU0k1TmlJZ1kzazlJakV3TmlJZ2NqMGlNVElpSUdacGJHdzlJaU14TVRFNE1qY2lMejRLSUNBOFkybHlZMnhsSUdONFBTSXhOakFpSUdONVBTSXhNRFlpSUhJOUlqRXlJaUJtYVd4c1BTSWpNVEV4T0RJM0lpOCtDaUFnUEhCaGRHZ2daRDBpVFRnNElERTFOaUJSTVRJNElERTRPQ0F4TmpnZ01UVTJJaUJ6ZEhKdmEyVTlJaU14TVRFNE1qY2lJSE4wY205clpTMTNhV1IwYUQwaU9DSWdabWxzYkQwaWJtOXVaU0lnYzNSeWIydGxMV3hwYm1WallYQTlJbkp2ZFc1a0lpOCtDaUFnUEhSbGVIUWdlRDBpTlRBbElpQjVQU0l5TXpBaUlHWnZiblF0YzJsNlpUMGlNVGdpSUhSbGVIUXRZVzVqYUc5eVBTSnRhV1JrYkdVaUlHWnBiR3c5SWlNd05qVm1ORFlpUGtoQlVGQlpQQzkwWlhoMFBnbzhMM04yWno0SyJ9";

    string public constant SAD_MOOD_URI =
        "data:application/json;base64,eyJuYW1lIjoiTW9vZCBORlQiLCAiZGVzY3JpcHRpb24iOiJBbiBORlQgdGhhdCByZWZsZWN0cyB0aGUgbW9vZCBvZiB0aGUgb3duZXIsIDEwMCUgb24gQ2hhaW4hIiwgImF0dHJpYnV0ZXMiOiBbeyJ0cmFpdF90eXBlIjogIm1vb2RpbmVzcyIsICJ2YWx1ZSI6IDEwMH1dLCAiaW1hZ2UiOiJkYXRhOmltYWdlL3N2Zyt4bWw7YmFzZTY0LFBITjJaeUI0Yld4dWN6MGlhSFIwY0RvdkwzZDNkeTUzTXk1dmNtY3ZNakF3TUM5emRtY2lJSGRwWkhSb1BTSXlOVFlpSUdobGFXZG9kRDBpTWpVMklqNEtJQ0E4Y21WamRDQjNhV1IwYUQwaU1UQXdKU0lnYUdWcFoyaDBQU0l4TURBbElpQm1hV3hzUFNJalptWm1OMlZrSWk4K0NpQWdQR05wY21Oc1pTQmplRDBpTVRJNElpQmplVDBpTVRJNElpQnlQU0l4TURBaUlHWnBiR3c5SWlObVpXTmhZMkVpTHo0S0lDQThZMmx5WTJ4bElHTjRQU0k1TmlJZ1kzazlJakV3TmlJZ2NqMGlNVElpSUdacGJHdzlJaU14TVRFNE1qY2lMejRLSUNBOFkybHlZMnhsSUdONFBTSXhOakFpSUdONVBTSXhNRFlpSUhJOUlqRXlJaUJtYVd4c1BTSWpNVEV4T0RJM0lpOCtDaUFnUEhCaGRHZ2daRDBpVFRnNElERTNOaUJSTVRJNElERTBOQ0F4TmpnZ01UYzJJaUJ6ZEhKdmEyVTlJaU14TVRFNE1qY2lJSE4wY205clpTMTNhV1IwYUQwaU9DSWdabWxzYkQwaWJtOXVaU0lnYzNSeWIydGxMV3hwYm1WallYQTlJbkp2ZFc1a0lpOCtDaUFnUEhSbGVIUWdlRDBpTlRBbElpQjVQU0l5TXpBaUlHWnZiblF0YzJsNlpUMGlNVGdpSUhSbGVIUXRZVzVqYUc5eVBTSnRhV1JrYkdVaUlHWnBiR3c5SWlNM1pqRmtNV1FpUGxOQlJEd3ZkR1Y0ZEQ0S1BDOXpkbWMrQ2c9PSJ9";

    address public constant USER = address(1);

    function setUp() public {
        deployer = new DeployMoodNft();
        if (!isZkSyncChain()) {
            moodNft = deployer.run();
        } else {
            string memory sadSvg = vm.readFile("./images/dynamicNft/sad.svg");
            string memory happySvg = vm.readFile(
                "./images/dynamicNft/happy.svg"
            );
            moodNft = new MoodNft(
                deployer.svgToImageURI(sadSvg),
                deployer.svgToImageURI(happySvg)
            );
        }
    }

    function testInitializedCorrectly() public view {
        assert(
            keccak256(abi.encodePacked(moodNft.name())) ==
                keccak256(abi.encodePacked((NFT_NAME)))
        );
        assert(
            keccak256(abi.encodePacked(moodNft.symbol())) ==
                keccak256(abi.encodePacked((NFT_SYMBOL)))
        );
    }

    function testCanMintAndHaveABalance() public {
        vm.prank(USER);
        moodNft.mintNft();

        assert(moodNft.balanceOf(USER) == 1);
    }

    function testTokenURIDefaultIsCorrectlySet() public {
        vm.prank(USER);
        moodNft.mintNft();

        assert(
            keccak256(abi.encodePacked(moodNft.tokenURI(0))) ==
                keccak256(abi.encodePacked(HAPPY_MOOD_URI))
        );
    }

    function testFlipTokenToSad() public {
        vm.prank(USER);
        moodNft.mintNft();

        vm.prank(USER);
        moodNft.flipMood(0);

        assert(
            keccak256(abi.encodePacked(moodNft.tokenURI(0))) ==
                keccak256(abi.encodePacked(SAD_MOOD_URI))
        );
    }

    // logging events doesn't work great in foundry-zksync
    function testEventRecordsCorrectTokenIdOnMinting() public {
        // Removed `onlyVanillaFoundry` to allow compatibility with custom Foundry setups and zkSync chains.
        uint256 currentAvailableTokenId = moodNft.getTokenCounter();

        vm.prank(USER);
        vm.recordLogs();
        moodNft.mintNft();
        Vm.Log[] memory entries = vm.getRecordedLogs();

        bytes32 tokenId_proto = entries[1].topics[1];
        uint256 tokenId = uint256(tokenId_proto);

        assertEq(tokenId, currentAvailableTokenId);
    }

    function testDoubleFlipBackToHappy() public {
        // HAPPY
        vm.prank(USER);
        moodNft.mintNft();

        // 1- flip -> SAD
        vm.prank(USER);
        moodNft.flipMood(0);
        string memory sadUri = moodNft.tokenURI(0);

        // 2- flip ->  HAPPY
        vm.prank(USER);
        moodNft.flipMood(0);
        string memory happyUri = moodNft.tokenURI(0);

        // Check URIs are different
        assertTrue(keccak256(bytes(sadUri)) != keccak256(bytes(happyUri)));
    }
}
