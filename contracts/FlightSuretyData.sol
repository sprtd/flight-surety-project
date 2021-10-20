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
  
  mapping(address => uint256[]) paidAirlines;
  


  /********************************************************************************************/
  /*                                       FUNCTION MODIFIERS                                 */
  /********************************************************************************************/
 

  function _onlyOwner() internal view {
    require(msg.sender == contractOwner, 'caller not owner');
  }
  
  function _onlyAuthorizedAirlines(address _account) internal view {
     require(_account == contractOwner || airlines[_account].status == AirlineStatus.Applied, 'caller not authorized');
  }
  
  
  function onlyOwnerAuthorizedAirlines(address _account) external view {
     _onlyAuthorizedAirlines(_account);
  }

  modifier onlyOwner() {
    _onlyOwner();
    _;
  }
  
  modifier onlyAuthorizedAirlines(address _account) {
      _onlyAuthorizedAirlines(_account);
      _;
  }

  modifier isOperational() {
    require(operational, 'contract not operational');
    _;
  }

  modifier hasApplied(address _account) {
    require(airlines[_account].status == AirlineStatus.Applied, 'na application');
    _;
  }
  


  /********************************************************************************************/
  /*                                       EVENTS                                */
  /********************************************************************************************/

  event LogNewAirline(address indexed account, uint256 timestamp, string airlineStatus);
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
    (,,,state) = _getAirlineDetails(_account);
    emit LogNewAirline(msg.sender, block.timestamp, state);
  }
  
  
  function updateAirlineStatus(address _account, uint8 _state) external hasApplied(_account) onlyAuthorizedAirlines(_account) {
     require(_state <= 3, 'not within enum range');
     uint8 statusNum = uint8(airlines[_account].status);
     require(_state > statusNum, 'status cannot be lower than current state');
     airlines[_account].status = AirlineStatus(_state);
     statusNum = uint8(airlines[_account].status);
     string memory state;
     (,,,state) = _getAirlineDetails(_account);
  
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
  
  
  
  function gettotalAppliedAirlines() external view returns(uint256) {
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
    (id, name, airlineAccount, state) = _getAirlineDetails(_account);
    return (id, name, airlineAccount, state);
  }
 
 

  function _getAirlineDetails(address _account) internal view returns(uint256 id, string memory name, address airlineAccount, string memory state) {
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
    (,,,status) = _getAirlineDetails(_account);
  }

}
