// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import '@openzeppelin/contracts/utils/math/SafeMath.sol';


contract FlightSuretyApp {
  IFlightSuretyData iFlightSuretyData;
  using SafeMath for uint256;
    
  address flightSuretyDataAddress;
    
  address public contractOwner;

  uint256 public constant AIRLINE_FEE =  10 ether;
    
    
  address[] minimumAirlines = new address[](0);
  uint quorum;
    
  
      

    
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
  event LogPayCommitment(address indexed airline, uint256 airlineFee);


  /********************************************************************************************/
  /*                                       CONSTRUCTOR                                        */
  /********************************************************************************************/
  constructor(address _flightSuretyDataAddress) {
    contractOwner = msg.sender;
    flightSuretyDataAddress = _flightSuretyDataAddress;
    iFlightSuretyData = IFlightSuretyData(_flightSuretyDataAddress);
    
    startAirlineApplication('alpha');
    registerAirline(contractOwner, 2);

    // payCommitmentFee();
  }

    /********************************************************************************************/
  /*                                       AIRLINE CORE FUNCTION                               */
  /********************************************************************************************/
    
  function startAirlineApplication(string memory _name) public  {
    iFlightSuretyData.createNewAirline(_name, msg.sender);
      
          
  }

  function registerAirline(address _account, uint8 _state) public {
    iFlightSuretyData.updateAirlineStatus(_account, _state);
    
  }
    
    
    
  // register via consensus
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


  // pay airline fee
  function payCommitmentFee() public payable onlyRegistered {
    require(msg.value == AIRLINE_FEE, 'fee is required');
    (bool send, ) = flightSuretyDataAddress.call{value: msg.value}('');
    require(send, 'failed to deposit ETH');
    iFlightSuretyData.updateToCommitState(3);
    emit LogPayCommitment(msg.sender, msg.value);
  }


  
    
   
/********************************************************************************************/
/*                                      AIRLINE UTILITY FUNCTIONS                                 */
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
    (bool status) = iFlightSuretyData.isAirlineRegistered(msg.sender);
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




  /********************************************************************************************/
  /*                                       ORACLE VARIABLES                         */
  /********************************************************************************************/
  uint256 public constant ORACLE_REGISTRATION_FEE = 1 ether;



    /********************************************************************************************/
  /*                                       ORACLE CORE FUNCTION                               */
  /********************************************************************************************/
  function payOracleRegFees() public payable {
    require(msg.value == ORACLE_REGISTRATION_FEE, 'OR. FEE MUST');
    (bool sent, ) = flightSuretyDataAddress.call{value: msg.value}('');
    require(sent, 'SEND FAILED');
    
    iFlightSuretyData.registerOracle();
  }

}

      






interface IFlightSuretyData {

  // airline functions
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
  function updateToCommitState(uint8 _state) external;
  function isAirlineCommitted(address _account) external view returns(bool checkStatus);


  // oracle functions
  function registerOracle() external payable;

}


