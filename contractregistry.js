let params = new URLSearchParams(window.location.search.slice(1))
// This is the contract address, i.e., where it's been deployed onto the blockchain
// Here we get it from the URL parameter (addr)
var CONTRACT_ADDRESSS = params.get('EnergyAuction.sol') 

// This is the contract ABI, which tells the JavaScript the interface of the contract
// i.e., what functions it has and what their signatures are
// You can get this from Remix after you compile your contract
var CONTRACT_ABI = [ 
  {
    "inputs": [
      {
        "internalType": "uint256",
        "name": "_biddingTime",
        "type": "uint256"
      },
      {
        "internalType": "address",
        "name": "_seller",
        "type": "address"
      },
      {
        "internalType": "uint256",
        "name": "_power",
        "type": "uint256"
      }
    ],
    "payable": false,
    "stateMutability": "nonpayable",
    "type": "constructor"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": false,
        "internalType": "address",
        "name": "winner",
        "type": "address"
      },
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "amount",
        "type": "uint256"
      }
    ],
    "name": "AuctionEnded",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": false,
        "internalType": "address",
        "name": "bidder",
        "type": "address"
      },
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "amount",
        "type": "uint256"
      }
    ],
    "name": "HighestBidIncreased",
    "type": "event"
  },
  {
    "constant": false,
    "inputs": [],
    "name": "auctionEnd",
    "outputs": [],
    "payable": false,
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "constant": false,
    "inputs": [],
    "name": "bid",
    "outputs": [],
    "payable": true,
    "stateMutability": "payable",
    "type": "function"
  },
  {
    "constant": true,
    "inputs": [],
    "name": "biddingTime",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  },
  {
    "constant": false,
    "inputs": [],
    "name": "contractEnd",
    "outputs": [],
    "payable": false,
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "constant": true,
    "inputs": [],
    "name": "contractEnded",
    "outputs": [
      {
        "internalType": "bool",
        "name": "",
        "type": "bool"
      }
    ],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  },
  {
    "constant": false,
    "inputs": [],
    "name": "launchAuction",
    "outputs": [],
    "payable": false,
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "constant": true,
    "inputs": [
      {
        "internalType": "address",
        "name": "",
        "type": "address"
      }
    ],
    "name": "powerTrack",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  },
  {
    "constant": false,
    "inputs": [],
    "name": "sell",
    "outputs": [
      {
        "internalType": "bool",
        "name": "",
        "type": "bool"
      }
    ],
    "payable": false,
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "constant": true,
    "inputs": [],
    "name": "seller",
    "outputs": [
      {
        "internalType": "address",
        "name": "",
        "type": "address"
      }
    ],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  },
  {
    "constant": false,
    "inputs": [],
    "name": "withdraw",
    "outputs": [
      {
        "internalType": "bool",
        "name": "",
        "type": "bool"
      }
    ],
    "payable": false,
    "stateMutability": "nonpayable",
    "type": "function"
  }
] 




// this will be a reference to our contract once we've loaded it
var CONTRACT = null

/*

  This demonstrates how to work with an already-deployed contract

  You can get the ABI for your contract from the bottom of the "Solidity Compiler" tab in Remix
  You can get the deployed address for your contract from Remix as well, once you've deployed it

*/
function setup_contract() {
  var contract = web3.eth.contract(CONTRACT_ABI)
  return contract.at(CONTRACT_ADDRESSS)
}

/* 

  These demonstrate how to call functions from the contract

*/
function bid() {
  // this calls the "add" function defined in the Solidity contract
  // the last argument is a callback to handle the result
  CONTRACT.bid( function(error, result) {
    if(error) { console.log(error) }
  })
}
function launchAuction() {
  // this calls the "add" function defined in the Solidity contract
  // the last argument is a callback to handle the result
  CONTRACT.launchAuction( function(error, result) {
    if(error) { console.log(error) }
  })
}
function contractEnd() {
  // this calls the "add" function defined in the Solidity contract
  // the last argument is a callback to handle the result
  CONTRACT.contractEnd( function(error, result) {
    if(error) { console.log(error) }
  })
}
function launchSell() {
  // this calls the "add" function defined in the Solidity contract
  // the last argument is a callback to handle the result
  CONTRACT.launchSell( function(error, result) {
    if(error) { console.log(error) }
  })
}


async function get_registration(id) {
  // calling contract functions is asynchronous, so you can't just return values directly
  // instead, we return a Promise, which we can then use to get the result when it's ready

  return new Promise(function(resolve,reject) {
    CONTRACT.get_contract(id, function(error, result) {
      if(error) {
        reject(error)
      } else {
        resolve(result)
      }
    })

  })
}




/* 

  This code is standard JavaScript to do things like update the page

*/
function new_bid(bid,hidden) {
    if(hidden) { return }
    let star_visible = star ? "visible" : "hidden";
    $('#container').append(`<div class="fluid card" style="width:100%">
        <div class="content" style="position:relative;">
          
          <div class="header">
            <i class="file alternate outline icon"></i> 
            <span>Contract ${id}</span>
          </div>

          <div class="ui yellow right corner label" style="visibility: ${star_visible}">
            <i class="star icon"></i>
          </div>
            <div class="ui hidden divider"></div>
          
          <div class="description">
            <div class="ui gray image label">
              <i class="map pin icon"></i>
              Location
              <div class="detail">${location}</div>
            </div>

            <div class="ui hidden divider"></div>

            <div class="ui gray image label">
              <i class="user icon"></i>
              Sender
              <div class="detail">${sender}</div>
            </div>
          </div>
        </div>
      </div>`)
}


function add_contract_to_ui(id) {
  // This is how to get the result from the promise
  get_registration(id).then(
    function(result) {
      append_new_contract(result[0], id, result[1], result[2], result[3])
    }
  )
  .then(
    function(result) {
      add_contract_to_ui(id + 1)
    }
  )
  .catch(err=>console.log(err))
}

function initialise() {
  CONTRACT = setup_contract()

  $("#view_button").click(function() {
    launchAuction()
  })

  $("#add_button").click(function() {
    if ($('#add_location').val() == '') { return }
    add_new_registration(
      $('#add_location').val()
    )
    $('#add_location').val('')
  })
}










/*

 This is from https://github.com/MetaMask/faq/blob/master/DEVELOPERS.md
 It checks that the browser is compatible and sets up the web3 provider

 */
window.addEventListener('load', async () => {
  // Modern dapp browsers...
  if (window.ethereum) {
    window.web3 = new Web3(ethereum);
    try {
      // Request account access if needed
      await ethereum.enable();
      // Acccounts now exposed
      initialise()
    } catch (error) {
      // User denied account access...
    }
  }
  // Legacy dapp browsers...
  else if (window.web3) {
    window.web3 = new Web3(web3.currentProvider);
    // Acccounts always exposed
    initialise()
  }
  // Non-dapp browsers...
  else {
    alert('Non-Ethereum browser detected. You need to get a plugin, such as MetaMask');
  }
});