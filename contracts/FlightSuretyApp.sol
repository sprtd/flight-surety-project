// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import '@openzeppelin/contracts/utils/math/SafeMath.sol';



contract FlightSuretyApp {
    IFlightSuretyData iFlightSuretyData;
    
    address flightSuretyDataAddress;
    
    address contractOwner;
    
  
    
    constructor(address _flightSuretyDataAddress) {
        contractOwner = msg.sender;
        flightSuretyDataAddress = _flightSuretyDataAddress;
        iFlightSuretyData = IFlightSuretyData(_flightSuretyDataAddress);
     
    }
    
      /********************************************************************************************/
    /*                                       FUNCTION MODIFIERS                                 */
  /********************************************************************************************/
  
  modifier onlyAuthorizedAirlines(address _account) {
      iFlightSuretyData.onlyAuthorizedAirlines(_account);
      _;
      
  }

    
    
    function registerAirline(address _account, uint8 _state) public {
        iFlightSuretyData.updateAirlineStatus(_account, _state);
    }
    
    function startAirlineApplication(string memory _name) public  {
        iFlightSuretyData.createNewAirline(_name, msg.sender);
        
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

}





interface IFlightSuretyData {
    function createNewAirline(string memory _name, address _account) external;
    function updateAirlineStatus(address _account, uint8 _state) external;
    function onlyAuthorizedAirlines(address _account) external view;
    function getAirlineAuthorizationStatus(address _account) external view returns(bool status);
    function getAirlineDetails(address _account) external view returns(uint256 id, string memory name, address airlineAccount, string memory state);
}


