// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import '@openzeppelin/contracts/utils/math/SafeMath.sol';


contract FlightSuretyApp {
  IFlightSuretyData iFlightSuretyData;
    
  address flightSuretyDataAddress;
    
  address public contractOwner;
    
    
  address[] minimumAirlines = new address[](0);
  uint quorum;
    
  
  
  constructor(address _flightSuretyDataAddress) {
    contractOwner = msg.sender;
    flightSuretyDataAddress = _flightSuretyDataAddress;
    iFlightSuretyData = IFlightSuretyData(_flightSuretyDataAddress);
    
    startAirlineApplication('alpha');
    registerAirline(contractOwner, 2);
    
  }
    
  /********************************************************************************************/
  /*                                       FUNCTION MODIFIERS                                 */
  /********************************************************************************************/
  
  modifier onlyAuthorizedAirlines(address _account) {
    iFlightSuretyData.onlyAuthorizedAirlines(_account);
    _;
      
  }
  
  modifier onlyRegistered() {
    iFlightSuretyData.onlyRegisteredAirlines(msg.sender);
    _;
  }
  
  
  

  
  
  

/********************************************************************************************/
/*                                       EVENTS                                */
/********************************************************************************************/

event LogRegisteredViaConsensus(address indexed callerAirline, address indexed registeredAirline, uint8 state);

  /********************************************************************************************/
/*                                       AIRLINE FUNCTION                               */
/********************************************************************************************/
  
function startAirlineApplication(string memory _name) public  {
  iFlightSuretyData.createNewAirline(_name, msg.sender);
    
        
}

function registerAirline(address _account, uint8 _state) public {

  iFlightSuretyData.updateAirlineStatus(_account, _state);
  
}
    
    
    
    
    
function registerViaConsensus(address _account, uint8 _state) public  onlyRegistered {

  require(iFlightSuretyData.isAirlineRegistered(_account) == false, 'airline already registered');
  
  uint regAirlines =  iFlightSuretyData.getTotalRegisteredAirlines();
  quorum = regAirlines / 2;
    
    
  bool isDuplicate = false;
  
  for(uint i = 0; i < minimumAirlines.length; i ++) {
    if(minimumAirlines[i] == msg.sender) {
      isDuplicate = true;
      break;
    }
  }

  require(!isDuplicate, 'caller already called the function');

  minimumAirlines.push(msg.sender);
  

  if(minimumAirlines.length == quorum) {
  iFlightSuretyData.enableOperationalStatus(true);
    iFlightSuretyData.updateAirlineStatus(_account, _state);
    minimumAirlines = new address[](0);
    emit LogRegisteredViaConsensus(msg.sender, _account, _state);
  }
}
  
   
/********************************************************************************************/
/*                                       UTILITY FUNCTIONS                                 */
/********************************************************************************************/
    
function getOwner() external view returns(address) {
  return contractOwner;
}


  
function airlineAuthorizationStatus(address _account)  public view returns(bool) {
  return iFlightSuretyData.getAirlineAuthorizationStatus(_account);
}
    
      

function airlineDetails(address _account) public view returns(uint256 id, string memory name, address airlineAccount, string memory state) {
  (id, name, airlineAccount, state) = iFlightSuretyData.getAirlineDetails(_account);
  return (id, name, airlineAccount, state);
}

function isCallerAirlineRegistered() public view returns(bool) {
  bool status;
  (status) = iFlightSuretyData.isAirlineRegistered(msg.sender);
  return status;
}
  
    
function getTotalRegisteredAirlines() public view returns(uint256) {
    return iFlightSuretyData.getTotalRegisteredAirlines();
}
  
function getOperationalStatus() public view returns(bool) {
    return iFlightSuretyData.getOperationalStatus();
}

      
  function getQuorum() public view returns(uint) {
        return quorum;
  }

}


interface IFlightSuretyData {
  function createNewAirline(string memory _name, address _account) external;
  function updateAirlineStatus(address _account, uint8 _state) external;
  function onlyAuthorizedAirlines(address _account) external view;
  function getAirlineAuthorizationStatus(address _account) external view returns(bool status);
  function getAirlineDetails(address _account) external view returns(uint256 id, string memory name, address airlineAccount, string memory state);
  function isAirlineRegistered(address _account) external view returns(bool);
  function onlyRegisteredAirlines(address _account) external view;
  function getTotalRegisteredAirlines() external view returns(uint256);
  function enableOperationalStatus(bool _status) external;
  function getOperationalStatus() external view  returns(bool);
}


