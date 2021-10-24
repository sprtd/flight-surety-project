// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/utils/math/SafeMath.sol';

contract FlightSuretyData {
  using SafeMath for uint256;
  
  
  
 


  /********************************************************************************************/
  /*                                       DATA VARIABLES                                     */
  /********************************************************************************************/

  uint256 totalAppliedAirlines;
  
  address private contractOwner;
  bool private operational;
    
  uint256 totalRegisteredAirlines;
  enum AirlineStatus { 
    Unassigned,
    Applied,
    Registered,
    Committed
  }

  struct Airline {
    uint256 id;
    string name;
    AirlineStatus status;
    address airlineAccount;
    
  }



  mapping(address => Airline) airlines;
  
  mapping(AirlineStatus => uint256) public registeredAirlines;
  

  
  mapping(address => uint256[]) paidAirlines;
  


  /********************************************************************************************/
  /*                                       FUNCTION MODIFIERS                                 */
  /********************************************************************************************/
 
  
 

  function _onlyOwner() internal view {
    require(msg.sender == contractOwner, 'caller not owner');
  }
  
  function onlyAuthorizedAirlines(address _account) external view {
     require(_account == contractOwner || airlines[_account].status == AirlineStatus.Applied || airlines[_account].status == AirlineStatus.Registered, 'airline not authorized');
  }
  
  function onlyRegisteredAirlines(address _account) external view {
      require(airlines[_account].status == AirlineStatus.Registered, 'caller not registered');
  }
  
  function onlyAuthorizeRegistrants(address _account) external view {
      require(airlines[_account].status == AirlineStatus.Registered || _account == contractOwner, 'not authorized to register');
  }
  
  modifier checkCaller(address _account) {
      this.onlyAuthorizeRegistrants(_account);
      _;
  }
  
  
  
  
  
  modifier checkRegistration(address _account) {
      this.onlyRegisteredAirlines(_account);
      _;
  }
  

  modifier onlyOwner() {
    _onlyOwner();
    _;
  }
  
  modifier onlyAuthorized(address _account) {
    this.onlyAuthorizedAirlines(_account);
      _;
  }

  modifier isOperational() {
    require(operational, 'contract not operational');
    _;
  }

 

 
  /********************************************************************************************/
  /*                                       EVENTS                                */
  /********************************************************************************************/

  event LogCreatedAirline(address indexed account, uint256 timestamp, string airlineStatus);
  event LogStatusUpdated(address indexed account, string airlineStatus);


  constructor() {
    contractOwner = msg.sender;
    operational = true;

  }
  
  
  
    /********************************************************************************************/
  /*                                       CORE FUNCTIONS                                 */
  /********************************************************************************************/
  function setOperatinalStatus(bool _status) external onlyOwner {
    require(operational != _status, 'must not be current status');
    operational = _status;
  }


  function createNewAirline(string memory _name, address _account) external {
    require(airlines[_account].status == AirlineStatus.Unassigned, 'airline not in unassigned state');
    totalAppliedAirlines = totalAppliedAirlines.add(1);
    airlines[_account] = Airline({
      id: totalAppliedAirlines,
      name: _name,
      status: AirlineStatus.Applied, 
      airlineAccount: _account
    });
    
    
    string memory state;
    (,,,state) = this.getAirlineDetails(_account);

    emit LogCreatedAirline(msg.sender, block.timestamp, state);
   
  }
  
  
  function updateAirlineStatus(address _account, uint8 _state) external onlyAuthorized(_account) isOperational {
    uint8 statusNum = uint8(airlines[_account].status);
    require(_state <= 3, 'not within enum range');
    require(_state > statusNum, 'status cannot be lower than current state');
    disableOperational();
    airlines[_account].status = AirlineStatus(_state);
    totalRegisteredAirlines = totalRegisteredAirlines.add(1);
    
    statusNum = uint8(airlines[_account].status);
  
    
    
    string memory state;
    (,,,state) = this.getAirlineDetails(_account);
    emit LogStatusUpdated(_account, state);
  }

  
  function disableOperational() public {
    if(totalRegisteredAirlines >= 3) {
      operational = false;
        
    }

      
  }
  
  
  function enableOperationalStatus(bool _status) checkRegistration(tx.origin) external {
    require(operational != _status, 'already in operational mode');
    operational = _status;
    
    
      
  }

 




  /********************************************************************************************/
  /*                                       UTILITY FUNCTIONS                                 */
  /********************************************************************************************/

  function getOperationalStatus() external view  returns(bool) {
    return operational;
  }


  function getOwner() external view returns(address) {
    return contractOwner;
  }
  
  
  
  function getTotalAppliedAirlines() external view returns(uint256) {
      return totalAppliedAirlines;
  }
  
  function getAirlineAuthorizationStatus(address _account) external view returns(bool status) {
      if(airlines[_account].status == AirlineStatus.Applied) {
         return status = true;
          
      } else if(airlines[_account].status == AirlineStatus.Registered) {
         return status = true;
      } else {
          return status = false;
      }
  }

  function getAirlineDetails(address _account) external view returns(uint256 id, string memory name, address airlineAccount, string memory state) {
    uint8 airlineState = uint8(airlines[_account].status);
    if(airlineState == 0) {
      state = 'Unassigned';

    } else if(airlineState == 1) {
      state = 'Applied';
    } else if(airlineState == 2) {
      state = 'Registered';
    } else if(airlineState == 3) {
      state = 'Committed';

    }
    
    id = airlines[_account].id;
    name = airlines[_account].name;
    airlineAccount = airlines[_account].airlineAccount;
    
    return (id, name, airlineAccount, state);
    
  }
  
  
  
  function getAirlineApplicationStatus(address _account) public view returns(string memory status) {
    (,,,status) = this.getAirlineDetails(_account);
  }
  
  
  
  function isAirlineRegistered(address _account) external view returns(bool checkStatus) {
    uint8 airlineCheck = uint8(airlines[_account].status);
    if(airlineCheck == 2) {
        
        checkStatus = true;
    } else {
        checkStatus = false;
    }
    
    return checkStatus;
  }
  
  function getTotalRegisteredAirlines() external view returns(uint256) {
    return totalRegisteredAirlines;
  }

}
