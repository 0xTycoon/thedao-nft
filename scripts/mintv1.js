// npx hardhat run scripts/deploy-script.js --network localhost
const hre = require("hardhat");
const {ethers} = require("hardhat");
const tycoon_address = "0xc43473fA66237e9AF3B2d886Ee1205b81B14b2C8";
async function main() {

    let theDAO = await hre.ethers.getContractAt(TheDAOABI, TheDAOAddress); // TheDAO contract

    await theDAO.totalSupply();


    let v1 = await hre.ethers.getContractAt(TheDAONFTABIV1, TheDAONFTAddressV1);

    await hre.network.provider.request({
        method: "hardhat_impersonateAccount",
        params: [tycoon_address],
    });
    let tycoon = await ethers.provider.getSigner(
        tycoon_address
    );
    await theDAO.connect(tycoon).transfer("0x24EcC5E6EaA700368B8FAC259d3fBD045f695A08", ethers.utils.parseUnits("0.01","ether"));
    //console.log(await v1.balanceOf(v1.address));
    //await v1.connect(tycoon).mint(1);
    //console.log((await v1.balanceOf(v1.address)).toNumber());
    console.log((await v1.balanceOf(tycoon_address)).toNumber());
    console.log((await v1.ownerOf(1079)));


}

const TheDAOAddress = "0xbb9bc244d798123fde783fcc1c72d3bb8c189413";
const TheDAOABI = [{
    "constant": true,
    "inputs": [{"name": "", "type": "uint256"}],
    "name": "proposals",
    "outputs": [{"name": "recipient", "type": "address"}, {
        "name": "amount",
        "type": "uint256"
    }, {"name": "description", "type": "string"}, {"name": "votingDeadline", "type": "uint256"}, {
        "name": "open",
        "type": "bool"
    }, {"name": "proposalPassed", "type": "bool"}, {
        "name": "proposalHash",
        "type": "bytes32"
    }, {"name": "proposalDeposit", "type": "uint256"}, {"name": "newCurator", "type": "bool"}, {
        "name": "yea",
        "type": "uint256"
    }, {"name": "nay", "type": "uint256"}, {"name": "creator", "type": "address"}],
    "type": "function"
}, {
    "constant": false,
    "inputs": [{"name": "_spender", "type": "address"}, {"name": "_amount", "type": "uint256"}],
    "name": "approve",
    "outputs": [{"name": "success", "type": "bool"}],
    "type": "function"
}, {
    "constant": true,
    "inputs": [],
    "name": "minTokensToCreate",
    "outputs": [{"name": "", "type": "uint256"}],
    "type": "function"
}, {
    "constant": true,
    "inputs": [],
    "name": "rewardAccount",
    "outputs": [{"name": "", "type": "address"}],
    "type": "function"
}, {
    "constant": true,
    "inputs": [],
    "name": "daoCreator",
    "outputs": [{"name": "", "type": "address"}],
    "type": "function"
}, {
    "constant": true,
    "inputs": [],
    "name": "totalSupply",
    "outputs": [{"name": "", "type": "uint256"}],
    "type": "function"
}, {
    "constant": true,
    "inputs": [],
    "name": "divisor",
    "outputs": [{"name": "divisor", "type": "uint256"}],
    "type": "function"
}, {
    "constant": true,
    "inputs": [],
    "name": "extraBalance",
    "outputs": [{"name": "", "type": "address"}],
    "type": "function"
}, {
    "constant": false,
    "inputs": [{"name": "_proposalID", "type": "uint256"}, {"name": "_transactionData", "type": "bytes"}],
    "name": "executeProposal",
    "outputs": [{"name": "_success", "type": "bool"}],
    "type": "function"
}, {
    "constant": false,
    "inputs": [{"name": "_from", "type": "address"}, {"name": "_to", "type": "address"}, {
        "name": "_value",
        "type": "uint256"
    }],
    "name": "transferFrom",
    "outputs": [{"name": "success", "type": "bool"}],
    "type": "function"
}, {
    "constant": false,
    "inputs": [],
    "name": "unblockMe",
    "outputs": [{"name": "", "type": "bool"}],
    "type": "function"
}, {
    "constant": true,
    "inputs": [],
    "name": "totalRewardToken",
    "outputs": [{"name": "", "type": "uint256"}],
    "type": "function"
}, {
    "constant": true,
    "inputs": [],
    "name": "actualBalance",
    "outputs": [{"name": "_actualBalance", "type": "uint256"}],
    "type": "function"
}, {
    "constant": true,
    "inputs": [],
    "name": "closingTime",
    "outputs": [{"name": "", "type": "uint256"}],
    "type": "function"
}, {
    "constant": true,
    "inputs": [{"name": "", "type": "address"}],
    "name": "allowedRecipients",
    "outputs": [{"name": "", "type": "bool"}],
    "type": "function"
}, {
    "constant": false,
    "inputs": [{"name": "_to", "type": "address"}, {"name": "_value", "type": "uint256"}],
    "name": "transferWithoutReward",
    "outputs": [{"name": "success", "type": "bool"}],
    "type": "function"
}, {"constant": false, "inputs": [], "name": "refund", "outputs": [], "type": "function"}, {
    "constant": false,
    "inputs": [{"name": "_recipient", "type": "address"}, {
        "name": "_amount",
        "type": "uint256"
    }, {"name": "_description", "type": "string"}, {
        "name": "_transactionData",
        "type": "bytes"
    }, {"name": "_debatingPeriod", "type": "uint256"}, {"name": "_newCurator", "type": "bool"}],
    "name": "newProposal",
    "outputs": [{"name": "_proposalID", "type": "uint256"}],
    "type": "function"
}, {
    "constant": true,
    "inputs": [{"name": "", "type": "address"}],
    "name": "DAOpaidOut",
    "outputs": [{"name": "", "type": "uint256"}],
    "type": "function"
}, {
    "constant": true,
    "inputs": [],
    "name": "minQuorumDivisor",
    "outputs": [{"name": "", "type": "uint256"}],
    "type": "function"
}, {
    "constant": false,
    "inputs": [{"name": "_newContract", "type": "address"}],
    "name": "newContract",
    "outputs": [],
    "type": "function"
}, {
    "constant": true,
    "inputs": [{"name": "_owner", "type": "address"}],
    "name": "balanceOf",
    "outputs": [{"name": "balance", "type": "uint256"}],
    "type": "function"
}, {
    "constant": false,
    "inputs": [{"name": "_recipient", "type": "address"}, {"name": "_allowed", "type": "bool"}],
    "name": "changeAllowedRecipients",
    "outputs": [{"name": "_success", "type": "bool"}],
    "type": "function"
}, {
    "constant": false,
    "inputs": [],
    "name": "halveMinQuorum",
    "outputs": [{"name": "_success", "type": "bool"}],
    "type": "function"
}, {
    "constant": true,
    "inputs": [{"name": "", "type": "address"}],
    "name": "paidOut",
    "outputs": [{"name": "", "type": "uint256"}],
    "type": "function"
}, {
    "constant": false,
    "inputs": [{"name": "_proposalID", "type": "uint256"}, {"name": "_newCurator", "type": "address"}],
    "name": "splitDAO",
    "outputs": [{"name": "_success", "type": "bool"}],
    "type": "function"
}, {
    "constant": true,
    "inputs": [],
    "name": "DAOrewardAccount",
    "outputs": [{"name": "", "type": "address"}],
    "type": "function"
}, {
    "constant": true,
    "inputs": [],
    "name": "proposalDeposit",
    "outputs": [{"name": "", "type": "uint256"}],
    "type": "function"
}, {
    "constant": true,
    "inputs": [],
    "name": "numberOfProposals",
    "outputs": [{"name": "_numberOfProposals", "type": "uint256"}],
    "type": "function"
}, {
    "constant": true,
    "inputs": [],
    "name": "lastTimeMinQuorumMet",
    "outputs": [{"name": "", "type": "uint256"}],
    "type": "function"
}, {
    "constant": false,
    "inputs": [{"name": "_toMembers", "type": "bool"}],
    "name": "retrieveDAOReward",
    "outputs": [{"name": "_success", "type": "bool"}],
    "type": "function"
}, {
    "constant": false,
    "inputs": [],
    "name": "receiveEther",
    "outputs": [{"name": "", "type": "bool"}],
    "type": "function"
}, {
    "constant": false,
    "inputs": [{"name": "_to", "type": "address"}, {"name": "_value", "type": "uint256"}],
    "name": "transfer",
    "outputs": [{"name": "success", "type": "bool"}],
    "type": "function"
}, {
    "constant": true,
    "inputs": [],
    "name": "isFueled",
    "outputs": [{"name": "", "type": "bool"}],
    "type": "function"
}, {
    "constant": false,
    "inputs": [{"name": "_tokenHolder", "type": "address"}],
    "name": "createTokenProxy",
    "outputs": [{"name": "success", "type": "bool"}],
    "type": "function"
}, {
    "constant": true,
    "inputs": [{"name": "_proposalID", "type": "uint256"}],
    "name": "getNewDAOAddress",
    "outputs": [{"name": "_newDAO", "type": "address"}],
    "type": "function"
}, {
    "constant": false,
    "inputs": [{"name": "_proposalID", "type": "uint256"}, {"name": "_supportsProposal", "type": "bool"}],
    "name": "vote",
    "outputs": [{"name": "_voteID", "type": "uint256"}],
    "type": "function"
}, {
    "constant": false,
    "inputs": [],
    "name": "getMyReward",
    "outputs": [{"name": "_success", "type": "bool"}],
    "type": "function"
}, {
    "constant": true,
    "inputs": [{"name": "", "type": "address"}],
    "name": "rewardToken",
    "outputs": [{"name": "", "type": "uint256"}],
    "type": "function"
}, {
    "constant": false,
    "inputs": [{"name": "_from", "type": "address"}, {"name": "_to", "type": "address"}, {
        "name": "_value",
        "type": "uint256"
    }],
    "name": "transferFromWithoutReward",
    "outputs": [{"name": "success", "type": "bool"}],
    "type": "function"
}, {
    "constant": true,
    "inputs": [{"name": "_owner", "type": "address"}, {"name": "_spender", "type": "address"}],
    "name": "allowance",
    "outputs": [{"name": "remaining", "type": "uint256"}],
    "type": "function"
}, {
    "constant": false,
    "inputs": [{"name": "_proposalDeposit", "type": "uint256"}],
    "name": "changeProposalDeposit",
    "outputs": [],
    "type": "function"
}, {
    "constant": true,
    "inputs": [{"name": "", "type": "address"}],
    "name": "blocked",
    "outputs": [{"name": "", "type": "uint256"}],
    "type": "function"
}, {
    "constant": true,
    "inputs": [],
    "name": "curator",
    "outputs": [{"name": "", "type": "address"}],
    "type": "function"
}, {
    "constant": true,
    "inputs": [{"name": "_proposalID", "type": "uint256"}, {
        "name": "_recipient",
        "type": "address"
    }, {"name": "_amount", "type": "uint256"}, {"name": "_transactionData", "type": "bytes"}],
    "name": "checkProposalCode",
    "outputs": [{"name": "_codeChecksOut", "type": "bool"}],
    "type": "function"
}, {
    "constant": true,
    "inputs": [],
    "name": "privateCreation",
    "outputs": [{"name": "", "type": "address"}],
    "type": "function"
}, {
    "inputs": [{"name": "_curator", "type": "address"}, {
        "name": "_daoCreator",
        "type": "address"
    }, {"name": "_proposalDeposit", "type": "uint256"}, {
        "name": "_minTokensToCreate",
        "type": "uint256"
    }, {"name": "_closingTime", "type": "uint256"}, {"name": "_privateCreation", "type": "address"}],
    "type": "constructor"
}, {
    "anonymous": false,
    "inputs": [{"indexed": true, "name": "_from", "type": "address"}, {
        "indexed": true,
        "name": "_to",
        "type": "address"
    }, {"indexed": false, "name": "_amount", "type": "uint256"}],
    "name": "Transfer",
    "type": "event"
}, {
    "anonymous": false,
    "inputs": [{"indexed": true, "name": "_owner", "type": "address"}, {
        "indexed": true,
        "name": "_spender",
        "type": "address"
    }, {"indexed": false, "name": "_amount", "type": "uint256"}],
    "name": "Approval",
    "type": "event"
}, {
    "anonymous": false,
    "inputs": [{"indexed": false, "name": "value", "type": "uint256"}],
    "name": "FuelingToDate",
    "type": "event"
}, {
    "anonymous": false,
    "inputs": [{"indexed": true, "name": "to", "type": "address"}, {
        "indexed": false,
        "name": "amount",
        "type": "uint256"
    }],
    "name": "CreatedToken",
    "type": "event"
}, {
    "anonymous": false,
    "inputs": [{"indexed": true, "name": "to", "type": "address"}, {
        "indexed": false,
        "name": "value",
        "type": "uint256"
    }],
    "name": "Refund",
    "type": "event"
}, {
    "anonymous": false,
    "inputs": [{"indexed": true, "name": "proposalID", "type": "uint256"}, {
        "indexed": false,
        "name": "recipient",
        "type": "address"
    }, {"indexed": false, "name": "amount", "type": "uint256"}, {
        "indexed": false,
        "name": "newCurator",
        "type": "bool"
    }, {"indexed": false, "name": "description", "type": "string"}],
    "name": "ProposalAdded",
    "type": "event"
}, {
    "anonymous": false,
    "inputs": [{"indexed": true, "name": "proposalID", "type": "uint256"}, {
        "indexed": false,
        "name": "position",
        "type": "bool"
    }, {"indexed": true, "name": "voter", "type": "address"}],
    "name": "Voted",
    "type": "event"
}, {
    "anonymous": false,
    "inputs": [{"indexed": true, "name": "proposalID", "type": "uint256"}, {
        "indexed": false,
        "name": "result",
        "type": "bool"
    }, {"indexed": false, "name": "quorum", "type": "uint256"}],
    "name": "ProposalTallied",
    "type": "event"
}, {
    "anonymous": false,
    "inputs": [{"indexed": true, "name": "_newCurator", "type": "address"}],
    "name": "NewCurator",
    "type": "event"
}, {
    "anonymous": false,
    "inputs": [{"indexed": true, "name": "_recipient", "type": "address"}, {
        "indexed": false,
        "name": "_allowed",
        "type": "bool"
    }],
    "name": "AllowedRecipientChanged",
    "type": "event"
}];

const TheDAONFTAddressV1 = "0x266830230bf10a58ca64b7347499fd361a011a02"

const TheDAONFTABIV1 = [
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "_theDAO",
                "type": "address"
            },
            {
                "internalType": "uint256",
                "name": "_max",
                "type": "uint256"
            }
        ],
        "stateMutability": "nonpayable",
        "type": "constructor"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": true,
                "internalType": "address",
                "name": "owner",
                "type": "address"
            },
            {
                "indexed": true,
                "internalType": "address",
                "name": "approved",
                "type": "address"
            },
            {
                "indexed": true,
                "internalType": "uint256",
                "name": "tokenId",
                "type": "uint256"
            }
        ],
        "name": "Approval",
        "type": "event"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": true,
                "internalType": "address",
                "name": "owner",
                "type": "address"
            },
            {
                "indexed": true,
                "internalType": "address",
                "name": "operator",
                "type": "address"
            },
            {
                "indexed": false,
                "internalType": "bool",
                "name": "approved",
                "type": "bool"
            }
        ],
        "name": "ApprovalForAll",
        "type": "event"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": false,
                "internalType": "string",
                "name": "",
                "type": "string"
            }
        ],
        "name": "BaseURI",
        "type": "event"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": false,
                "internalType": "address",
                "name": "owner",
                "type": "address"
            },
            {
                "indexed": false,
                "internalType": "uint256",
                "name": "tokenId",
                "type": "uint256"
            }
        ],
        "name": "Burn",
        "type": "event"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": false,
                "internalType": "address",
                "name": "curator",
                "type": "address"
            }
        ],
        "name": "Curator",
        "type": "event"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": false,
                "internalType": "address",
                "name": "owner",
                "type": "address"
            },
            {
                "indexed": false,
                "internalType": "uint256",
                "name": "tokenId",
                "type": "uint256"
            }
        ],
        "name": "Mint",
        "type": "event"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": false,
                "internalType": "address",
                "name": "owner",
                "type": "address"
            },
            {
                "indexed": false,
                "internalType": "uint256",
                "name": "tokenId",
                "type": "uint256"
            }
        ],
        "name": "Restore",
        "type": "event"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": true,
                "internalType": "address",
                "name": "from",
                "type": "address"
            },
            {
                "indexed": true,
                "internalType": "address",
                "name": "to",
                "type": "address"
            },
            {
                "indexed": true,
                "internalType": "uint256",
                "name": "tokenId",
                "type": "uint256"
            }
        ],
        "name": "Transfer",
        "type": "event"
    },
    {
        "inputs": [],
        "name": "PDF_SHA_256_HASH",
        "outputs": [
            {
                "internalType": "string",
                "name": "",
                "type": "string"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "PNG_SHA_256_HASH",
        "outputs": [
            {
                "internalType": "string",
                "name": "",
                "type": "string"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "_to",
                "type": "address"
            },
            {
                "internalType": "uint256",
                "name": "_tokenId",
                "type": "uint256"
            }
        ],
        "name": "approve",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "_holder",
                "type": "address"
            }
        ],
        "name": "balanceOf",
        "outputs": [
            {
                "internalType": "uint256",
                "name": "",
                "type": "uint256"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "uint256",
                "name": "id",
                "type": "uint256"
            }
        ],
        "name": "burn",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "curator",
        "outputs": [
            {
                "internalType": "address",
                "name": "",
                "type": "address"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "uint256",
                "name": "_tokenId",
                "type": "uint256"
            }
        ],
        "name": "getApproved",
        "outputs": [
            {
                "internalType": "address",
                "name": "",
                "type": "address"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "_user",
                "type": "address"
            }
        ],
        "name": "getStats",
        "outputs": [
            {
                "internalType": "uint256[]",
                "name": "",
                "type": "uint256[]"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "_owner",
                "type": "address"
            },
            {
                "internalType": "address",
                "name": "_operator",
                "type": "address"
            }
        ],
        "name": "isApprovedForAll",
        "outputs": [
            {
                "internalType": "bool",
                "name": "",
                "type": "bool"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "uint256",
                "name": "i",
                "type": "uint256"
            }
        ],
        "name": "mint",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "name",
        "outputs": [
            {
                "internalType": "string",
                "name": "",
                "type": "string"
            }
        ],
        "stateMutability": "pure",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "",
                "type": "address"
            },
            {
                "internalType": "address",
                "name": "",
                "type": "address"
            },
            {
                "internalType": "uint256",
                "name": "",
                "type": "uint256"
            },
            {
                "internalType": "bytes",
                "name": "",
                "type": "bytes"
            }
        ],
        "name": "onERC721Received",
        "outputs": [
            {
                "internalType": "bytes4",
                "name": "",
                "type": "bytes4"
            }
        ],
        "stateMutability": "pure",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "uint256",
                "name": "_tokenId",
                "type": "uint256"
            }
        ],
        "name": "ownerOf",
        "outputs": [
            {
                "internalType": "address",
                "name": "",
                "type": "address"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "uint256",
                "name": "id",
                "type": "uint256"
            }
        ],
        "name": "restore",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "_from",
                "type": "address"
            },
            {
                "internalType": "address",
                "name": "_to",
                "type": "address"
            },
            {
                "internalType": "uint256",
                "name": "_tokenId",
                "type": "uint256"
            }
        ],
        "name": "safeTransferFrom",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "_from",
                "type": "address"
            },
            {
                "internalType": "address",
                "name": "_to",
                "type": "address"
            },
            {
                "internalType": "uint256",
                "name": "_tokenId",
                "type": "uint256"
            },
            {
                "internalType": "bytes",
                "name": "_data",
                "type": "bytes"
            }
        ],
        "name": "safeTransferFrom",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "_operator",
                "type": "address"
            },
            {
                "internalType": "bool",
                "name": "_approved",
                "type": "bool"
            }
        ],
        "name": "setApprovalForAll",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "string",
                "name": "_uri",
                "type": "string"
            }
        ],
        "name": "setBaseURI",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "_curator",
                "type": "address"
            }
        ],
        "name": "setCurator",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "bytes4",
                "name": "interfaceId",
                "type": "bytes4"
            }
        ],
        "name": "supportsInterface",
        "outputs": [
            {
                "internalType": "bool",
                "name": "",
                "type": "bool"
            }
        ],
        "stateMutability": "pure",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "symbol",
        "outputs": [
            {
                "internalType": "string",
                "name": "",
                "type": "string"
            }
        ],
        "stateMutability": "pure",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "uint256",
                "name": "value",
                "type": "uint256"
            }
        ],
        "name": "toString",
        "outputs": [
            {
                "internalType": "string",
                "name": "",
                "type": "string"
            }
        ],
        "stateMutability": "pure",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "uint256",
                "name": "_index",
                "type": "uint256"
            }
        ],
        "name": "tokenByIndex",
        "outputs": [
            {
                "internalType": "uint256",
                "name": "",
                "type": "uint256"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "_owner",
                "type": "address"
            },
            {
                "internalType": "uint256",
                "name": "_index",
                "type": "uint256"
            }
        ],
        "name": "tokenOfOwnerByIndex",
        "outputs": [
            {
                "internalType": "uint256",
                "name": "",
                "type": "uint256"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "uint256",
                "name": "_tokenId",
                "type": "uint256"
            }
        ],
        "name": "tokenURI",
        "outputs": [
            {
                "internalType": "string",
                "name": "",
                "type": "string"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "totalSupply",
        "outputs": [
            {
                "internalType": "uint256",
                "name": "",
                "type": "uint256"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "_from",
                "type": "address"
            },
            {
                "internalType": "address",
                "name": "_to",
                "type": "address"
            },
            {
                "internalType": "uint256",
                "name": "_tokenId",
                "type": "uint256"
            }
        ],
        "name": "transferFrom",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    }
];


main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });