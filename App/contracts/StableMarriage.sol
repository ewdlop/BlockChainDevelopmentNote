// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract StableMarriage {
    uint8 public n; // Number of participants on each side
    mapping(uint8 => uint8[]) public menPreferences;
    mapping(uint8 => uint8[]) public womenPreferences;
    uint8[] public menMatch;
    uint8[] public womenMatch;
    bool[] public menFree;
    uint8[] public menNextProposal;

    event MatchingCompleted(uint8[] menMatch, uint8[] womenMatch);

    constructor(uint8 _n, uint8[][] memory _menPreferences, uint8[][] memory _womenPreferences) {
        n = _n;
        menMatch = new uint8[](n);
        womenMatch = new uint8[](n);
        menFree = new bool[](n);
        menNextProposal = new uint8[](n);

        // Initialize preferences
        for (uint8 i = 0; i < n; i++) {
            menPreferences[i] = _menPreferences[i];
            womenPreferences[i] = _womenPreferences[i];
        }

        // Initialize all men and women as free
        for (uint8 i = 0; i < n; i++) {
            menFree[i] = true;
            menMatch[i] = n; // No match
            womenMatch[i] = n; // No match
        }
    }

    function findStableMatching() public {
        uint8 freeMenCount = n;

        while (freeMenCount > 0) {
            uint8 m;
            for (m = 0; m < n; m++) {
                if (menFree[m]) break;
            }

            uint8 w = menPreferences[m][menNextProposal[m]];
            menNextProposal[m]++;

            if (womenMatch[w] == n) {
                womenMatch[w] = m;
                menMatch[m] = w;
                menFree[m] = false;
                freeMenCount--;
            } else {
                uint8 m1 = womenMatch[w];
                if (prefers(w, m, m1)) {
                    womenMatch[w] = m;
                    menMatch[m] = w;
                    menFree[m] = false;
                    menFree[m1] = true;
                }
            }
        }

        emit MatchingCompleted(menMatch, womenMatch);
    }

    function prefers(uint8 w, uint8 m, uint8 m1) internal view returns (bool) {
        for (uint8 i = 0; i < n; i++) {
            if (womenPreferences[w][i] == m) return true;
            if (womenPreferences[w][i] == m1) return false;
        }
        return false;
    }

    function getMenMatch() public view returns (uint8[] memory) {
        return menMatch;
    }

    function getWomenMatch() public view returns (uint8[] memory) {
        return womenMatch;
    }
}
